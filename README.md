<h1 align="center">🐧📦 dnf-manager 📋 



[![LOGO](https://img.shields.io/github/issues/0n1cOn3/dnf-manager?style=plastic)]() [![LOGO](https://img.shields.io/github/issues-pr/0n1cOn3/dnf-manager?style=plastic)]() [![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/) </h1>


This is a Bash script for managing packages in a Fedora-based Linux distribution. It can 📤 export a list of currently installed packages to a file, and 📥 import a list of packages from a file to install them on the system.

## Usage 💻

    sudo ./pkg_manage.sh [-o <export|import>] [-p <file_path>]


## Options 🛠️

    -o: Specifies the operation to perform. Can either be export or import.
    -p: Specifies the file path. For export, the file should not exist, and for import, the file should exist and be readable.

## Examples 🚀

Export a list of installed packages to a file:

    sudo ./pkg_manage.sh -o export -p pkg_list.txt

Import a list of packages from a file:

    sudo ./pkg_manage.sh -o import -p pkg_list.txt
## Functions 📦

    export_pkgs: Exports names of installed packages (without version and architecture) to a plain text file.
    import_pkgs: Imports package names from plain text file and installs the same set of packages removing the ones not in the list.
    check_pkgs: Compares the package list from import_pkgs against the list of installed packages and shows the differences. Asks the user if they want to install the missing packages.

## Contributing 🤝

Feel free to submit pull requests or issues if you find any bugs or have any suggestions for improvement.
Copyright Disclaimer 📜

Original source code has been brought by Molnix888.
