# python-makefile
A Makefile to deploy python projects with a root-less virtualenv.

## Usage

Fill in your project-relative parameters in the first lines according to the
description below (also described shortly in the Makefile as comments).

### Preliminaray configuration

#### `main_file`
*Default: None*

**Name of the main file of this project** - Name of the main file of the
project. It will be copied with a prepended (virtual-env relative) shebang in
order to allow direct invokation of the file.

#### `executable`
*Default: None*

**Name of the executable to generate** - Name of the executable generated (with
the virtual-env relative shebang) generated from the `main_file`. **It shall be
a non-existing file**.

#### `additional_files_and_dirs`
*Default: Makefile requirements.txt*

**List the required files and directories here.** - A full list of the files
that shall be deployed.

#### `deployment_host`
*Default: None*

**Name of the host to deploy to. Can be an IP address.** - Address of the host
that the application will be deployed to (using ssh).

#### `python_version`
*Default: 2*

**Version of python to use.** - 2 for python 2, 3 for python 3.

### Invokation

- `make` shall check the dependencies and create the executable as configured
	in the makefile.
- `make distribute` shall copy the `main_file` (but **not** the executable) and
	the files listed under `additional_files_and_dirs` to the `deployment_host`
	via scp.
- `make deploy` does the same as `make distribute` but also creates the
	executable (as with bare `make`) *remotely*.
- `make run` does the same as `make deploy` but also runs the executable once
	in the foreground.
- `make start` does the same as `make deploy` but also kills any already
	running executable with the name configured with `executable` in the
	makefile, and starts the executable with `nohup`.
- `make clean` will delete (clean) all the files created by running `make`
	(without arguments).

#### Notes

There are a few more targets that exist in the file, but since they are not
meant to be called directly, they won't be described here (feel free to check
the code if you are curious about what they do). They are also not to be relied
on as no effort will be made to keep their presence and/or function.
