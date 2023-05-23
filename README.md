# PlutoToPkg.jl
[![Build Status](https://github.com/stefanbringuier/PlutoToPkg.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/stefanbringuier/PlutoToPkg.jl/actions/workflows/CI.yml?query=branch%3Amain)

> A simple utility to convert [Pluto.jl](https://plutojl.org/) notebooks to Julia project/package folder.

## Why
There is nothing magical about this package other than I regulary start doing data analysis or prototyping in a Pluto.jl notebook and as the notebook builds-up in funcitonality I sometimes find two scenarios emerge:

1. I want to use the functions implemented in a notebook as the base for a more standard Julia package.
2. I want the interact with the functionality implemeted in the notebook without reactivity of the cells.

This requires extracting the Julia package information since the code I implement makes heavy use of other Julia packages. This is easy because which is stored in the Pluto.jl notebook stores this information as Julia strings. 

**Note** You can of course do all this manually by adding the packages and copying the code, but that is very cumbersome!


## Usage

The primary intent for using this utility is to clone the repo and then via the command line execute:

`julia --project=@. src/PlutoToPkg.jl Pluto_Notebook.jl` 

Eventually I'll try to get a binary executable working so that:

`plutotopkg.exe Pluto_Notebook.jl`

will work. This will require `PackageCompiler.jl` which I'm having some trouble with.

```shell

usage: PlutoToPkg.jl [--rename RENAME] [-h] filepath

Command-line utility to convert Pluto.jl notebook to Julia project.

positional arguments:
  filepath         File path for the Pluto.jl notebook

optional arguments:
  --rename RENAME  Use specific project folder/file name rather than
                   the Pluto.jl notebook
  -h, --help       show this help message and exit
```

## Output
The command outputs a structure such that:

`Notebook-Name-Folder`
    - Project.toml
    - Manifest.toml
    - `Notebook-Name`.jl

## Commentary 
The functionality here is straightfoward so a more useful approach would be to add an "export" option to the Pluto.jl frontend banner that would this for you. Since I have no experience with `javascript` its pretty challenging for me to do so there would need to be buy-in from the Pluto devs to implement. I assume there should be a  way with `javascript` to create a tarball or zip folder of the Notebook, Project.toml, and Manifest.toml files.