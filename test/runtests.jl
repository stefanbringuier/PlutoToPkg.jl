using PlutoToPkg
using Test
using Pkg
using Markdown

function installed()
    deps = Pkg.dependencies()
    installs = Dict{String, VersionNumber}()
    for (uuid, dep) in deps
        dep.is_direct_dep || continue
        dep.version === nothing && continue
        installs[dep.name] = dep.version
    end
    return installs
end

@testset "Test Notebook 1" begin
    mktempdir()  do temp_folder
        test_notebook_path = joinpath(@__DIR__,"notebooks/test_notebook_1.jl")
        project_toml, manifest_toml, notebook_code = parse_pluto_notebook(test_notebook_path)
        write_to_file(joinpath(temp_folder, "Project.toml"), project_toml)
        write_to_file(joinpath(temp_folder, "Manifest.toml"), manifest_toml)
        write_to_file(joinpath(temp_folder, "Notebook.jl"), generate_header(test_notebook_path) * notebook_code)
        Pkg.activate(temp_folder)
        Pkg.instantiate()
        include(joinpath(temp_folder,"Notebook.jl"))

        @test test_text  == md"""Test text."""
        @test isdefined(Main,:f)
        @test test_value == 4
        @test haskey(installed(), "PlutoUI")
        @test isdefined(Main,:test_pkg)
    end
end

