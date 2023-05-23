using PackageCompiler


pkg_dir = "PlutoToPkg"
compile_dir = "PlutoToPkg/app"
executables = ["plutotopkg.exe" => "main_exe"]

create_app(pkg_dir,compile_dir,executables=executables)

