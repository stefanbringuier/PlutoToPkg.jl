module PlutoToPkg

using ArgParse

export parse_pluto_notebook
export write_to_file
export generate_header

const __name__ = "PlutoToPkg.jl"
const __version__ = "0.0.1"


function generate_header(file)
    name = "### Generated by $(__name__) $(__version__) ###"
    file = "### Package converted from: $(file) ###"
    return join([name, file,"\n"], "\n")
end

macro display_warning(message::String)
    quote 
        yellow = "\u001b[33m"
        reset = "\u001b[0m"
        println(yellow, "Warning: ",$(message), reset)
    end
end

"""
Provides overwriting folder creation if requested.
"""
function createdir(foldername)
    if isdir(foldername)
        @display_warning "The directory already exists. Do you want to overwrite it? [y/n]"
        response = readline(stdin)
        response = strip(lowercase(response))
        if response in ["n", "no"]
            println("Aborting.")
            exit()
        else
            rm(foldername,recursive=true)
            return mkdir(foldername)
        end
    else
        return mkdir(foldername)
    end
end


function write_to_file(filename, content)
    open(filename, "w") do f
        write(f, content)
    end
end


"""
checks for Pluto.jl cell details indicated by:
    - "\u0023 \u2554\u2550\u2561" -> "# ╔═╡"
    - "\u0023 \u2560\u2550" -> "# ╠═"
    - "\u0023 \u255F\u2500" -> "# ╟─"
"""
function pluto_comment(line::String) :: Bool
    comments = ("\u0023 \u2554\u2550\u2561",
                "\u0023 \u2560\u2550",
                "\u0023 \u255F\u2500",
                )
    return any(startswith(line, comment) for comment in comments)
end

"""
	parse_pluto_notebook(file)

The Pluto.jl notebook details in the strings "PLUTO_PROJECT_TOML_CONTENTS","PLUTO_MANIFEST_TOML_CONTENTS" are extracted by this function along with the Julia code. Any valid Julia comments that don't contain specific Pluto.jl unicode characters (see [`pluto_comment`](@ref) function) are retained in the `notebook_code`  variable.

# Arguments
- file::String - path to Pluto.jl notebook

# Returns
- pluto_project_toml:: String - the Project.toml representation
- pluto_manifest_tol:: String - the Manifest.toml representation
- notebook_code:: String - Julia code and comments  in notebook
"""
function parse_pluto_notebook(file)
    pluto_project_toml = ""
    pluto_manifest_toml = ""
    notebook_code = ""
    inside_project_toml = false
    inside_manifest_toml = false

    for line in eachline(file)
        if occursin("PLUTO_PROJECT_TOML_CONTENTS", line)
            inside_project_toml = true
            continue
        elseif occursin("PLUTO_MANIFEST_TOML_CONTENTS", line)
            inside_manifest_toml = true
            continue
        end

        if inside_project_toml
            if line == "\"\"\""
                inside_project_toml = false
            else
                pluto_project_toml *= line * "\n"
            end
        elseif inside_manifest_toml
            if line == "\"\"\""
                inside_manifest_toml = false
            else
                pluto_manifest_toml *= line * "\n"
            end
        else
            if !pluto_comment(line)
                notebook_code *= line * "\n"
            end
        end
    end

    return pluto_project_toml, pluto_manifest_toml, notebook_code
end


"""
	pluto_to_julia(filepath;rename=nothing)

# Arguments
- filepath::String - path to the Pluto.jl notebook
- rename::Union{Nothing,String}=nothing - rename project created. Default is to use notebook name.
"""
function pluto_to_julia(filepath, rename::Union{Nothing,String}=nothing)
    if !isnothing(rename)
        filename = rename
        new_folder = createdir(rename)
    else
        filename = splitext(basename(filepath))[1]
        new_folder = createdir(filename)
    end

    open(filepath, "r") do f
        project_toml, manifest_toml, notebook_code = parse_pluto_notebook(f)

        write_to_file(joinpath(new_folder, "Project.toml"), project_toml)

        write_to_file(joinpath(new_folder, "Manifest.toml"), manifest_toml)

        write_to_file(joinpath(new_folder, "$filename.jl"), generate_header(filepath) * notebook_code)
    end
end

"""
```shell
usage: PlutoToPkg.jl [--rename RENAME] [-h] filepath

Command-line utility to convert Pluto.jl notebook to Julia project.

positional arguments:
  filepath         File path for the Pluto.jl notebook

optional arguments:
  --rename RENAME  Rename the project created from the Pluto.jl
                   notebook
  -h, --help       show this help message and exit

````
"""
function parse_commandline()
    s = ArgParseSettings(prog=__name__,
                         version=__version__,
                         description="Command-line utility to convert Pluto.jl notebook to Julia project.",
                         )

    @add_arg_table! s begin
        "--rename"
            help="Use specific project folder/file name rather than the Pluto.jl notebook"
            default = nothing
        "filepath"
            help="File path for the Pluto.jl notebook"
            required = true
    end

    return parse_args(s)
end

function main()
    args = parse_commandline()
    pluto_to_julia(args["filepath"], args["rename"])
end


"""
PackageCompiler.jl signature
"""
function main_exe() :: Cint
    main()
    return 0
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end


end
