# dnf-manager

A script created to ease a process of moving to a new system by restoring
a set of predefined DNF packages.

Uses package names and ignores versions during operations.
Can use any text file with package names list for import operation.

**Requires root privileges to run.**

## Use

    $ sudo ./dnf-manager.sh
    Usage: sudo ./dnf-manager.sh [-o <export|import>] [-p <arg...>]

    -o  Operation to perform, can either be export or import:
            export - Exports names of installed packages (without version and architecture) to a plain text file.
            import - Imports package names from plain text file and installs the same set of packages removing the ones not in the list.

    -p  Relative filepath, file shouldn't exist for export operation and should exist, be readable and not empty for import operation.

## Copyright Disclaimer 
Original source code has been brought by [Molnix888](https://github.com/Molnix888/dnf-export-import-pkgs)
