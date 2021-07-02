Apache Maven installation script for Linux
========================================================

"install-maven.sh" is an installation script for setting up Apache Maven on Debian based Linux Operating Systems.

Currently, the `install-maven.sh` script supports `tar.gz` distribution.

I'm mainly using Ubuntu and therefore this script is tested only on different versions of Ubuntu.

## Prerequisites

The "install-maven.sh" script will not download the Apache Maven distribution. You must download Maven `tar.gz` distribution.

## Installation

The script needs to be run as root.

You need to provide the Maven distribution file (`tar.gz`) and the Apache Maven Installation Directory.
The default value for Apache Maven installation directory is "/usr/local/apache-maven"

```console
$ sudo ./install-maven.sh -h

Usage: 
install-maven.sh -f <maven_dist> [-p <maven_installation_dir>]

-f: The maven tar.gz file.
-p: Apache Maven installation directory. Default: /usr/local/apache-maven.
-h: Display this help and exit.

```

## License

Copyright (C) 2021 Eric Vlaskin
