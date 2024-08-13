# SWAGView

## Overview

SWAGView is a simple GUI viewer application for the [SWAG Pascal Code Collection](https://github.com/delphidabbler/swag).

It is available in 64 bit format for Windows 64 bit systems and in 32 bit format for 32 bit Windows.

⚠️ This code is in early development. Expect bugs!

## Installing & Unistalling

Download the latest version from the SWAGView GitHub repository's releases page. Download `swagview-exe64-x.y.z.zip` if you a running 64 bit Windows or `swagview-exe32-x.y.z.zip` for 32 bit Windows. Here `x.y.z` is the release version number.

There is no installer, so you need to install the program manually. Proceed as follows:

1. Create a new sub-directory to store the program and its associated files. This can be created in any writeable directory on your system drive(s), or on a removable drive.

    ⚠️ Avoid using the `%ProgramFiles%` directory since will likely not be writeable.

2. Extract all the files from the zip file and copy them into the newly created directory.

3. Optionally create a shortcut to the executable file in some convenient location.

4. Run the program. The first time it runs it will prompt you to install the SWAG database. See the [Getting Started](https://delphidabbler.com/help/swagview/0.0/getting-started) online help topic for details of how to do this. Once the database installation is complete the database files will have been created in a `swag` sub-directory of the directory you created at step 1.

To unistall simply delete the directory in which you installed the program, along with all its sub-directories.

## Documentation

Help is available [online](https://delphidabbler.com/help/swagview/0.0/).

SWAGView also has a [web page](https://delphidabbler.com/software/swagview) on delphidabbler.com.

## Source Code

SWAGView's source code is maintained in the [`ddabapps/swagview`](https://github.com/ddabapps/swagview) repository on GitHub.

The head of the `main` branch always reflects the state of source code as of the latest release, while current development takes place on the `develop` branch.

The [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) development methodology has been adopted.

## Contributing

To contribute to this project please fork the repository on GitHub. Create a feature branch off the `develop` branch. Make your changes to your feature branch then submit a pull request via GitHub.

⚠️ Do not create branches off `main`, always branch from `develop`.

## Compiling

The project is currently being compiled with Delphi 12.1. Subject to the following [dependencies](#dependencies), the entire project can be built from within the Delphi IDE.

Releases are created outside the IDE by running the `Deploy.bat` script. See the comments within the script for usage information.

### Dependencies

The build process requires that [DelphiDabbler Version Information Editor](https://delphidabbler.com/software/vied) is installed and that its installation directory is stored in the `VIEdRoot` environment variable.

The release script additionally requires that [InfoZIP `zip.exe`](https://delphidabbler.com/extras/info-zip) is installed and that its installation directory is stored in the `ZipRoot` environment variable. 

## License

SWAGView is licensed under the terms of the [Mozilla Public Licence v2.0](https://www.mozilla.org/MPL/2.0/).

## Changes

See [`CHANGELOG.md`](https://github.com/ddabapps/swagview/blob/main/CHANGELOG.md) for details of notable changes to the project.

## Bug Reports and Features

You can report bugs or request new features using the [Issues](https://github.com/ddabapps/swagview/issues) section of the SWAGView GitHub project. You will need a GitHub account to do this.

Please do not report bugs unless you have checked whether the bug exists in the latest version of the program.
