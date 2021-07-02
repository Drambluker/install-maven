#!/bin/bash

maven_dist=""
default_maven_dir="/usr/local/apache-maven"
maven_installation_dir="$default_maven_dir"

function usage() {
    echo ""
    echo "This script will not download the Maven distribution. You must download Maven tar.gz distribution. Then use this script to install it."
    echo "Usage: "
    echo "install-maven.sh -f <maven_dist> [-p <maven_installation_dir>]"
    echo ""
    echo "-f: The maven tar.gz file."
    echo "-p: Maven installation directory. Default: $default_maven_dir."
    echo "-h: Display this help and exit."
    echo ""
}

function confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [y/N] " response
    case $response in
    [yY][eE][sS] | [yY])
        true
        ;;
    *)
        false
        ;;
    esac
}

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

while getopts "f:p:h" opts; do
    case $opts in
    f)
        maven_dist=${OPTARG}
        ;;
    p)
        maven_installation_dir=${OPTARG}
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done

if [[ ! -f $maven_dist ]]; then
    echo "Please specify the Maven distribution file."
    echo "Use -h for help."
    exit 1
fi

# Validate Maven Distribution
maven_dist_filename=$(basename $maven_dist)

if [[ ${maven_dist_filename: -7} != ".tar.gz" ]]; then
    echo "Maven distribution must be a valid tar.gz file."
    exit 1
fi

# Create the default directory if user has not specified any other path
if [[ $maven_installation_dir == $default_maven_dir ]]; then
    mkdir -p $maven_installation_dir
fi

#Validate maven directory
if [[ ! -d $maven_installation_dir ]]; then
    echo "Please specify a valid Maven installation directory."
    exit 1
fi

echo "Installing: $maven_dist_filename"

# Check Maven executable
maven_exec="$(tar -tzf $maven_dist | grep ^[^/]*/bin/mvn$ || echo "")"

if [[ -z $maven_exec ]]; then
    echo "Could not find \"mvn\" executable in the distribution. Please specify a valid Maven distribution."
    exit 1
fi

# Maven Directory with version
maven_dir="$(echo $maven_exec | cut -f1 -d"/")"
extracted_dirname=$maven_installation_dir"/"$maven_dir

# Extract Maven Distribution
if [[ ! -d $extracted_dirname ]]; then
    echo "Extracting $maven_dist to $maven_installation_dir"
    tar -xof $maven_dist -C $maven_installation_dir
    echo "Maven is extracted to $extracted_dirname"
else
    echo "WARN: Maven was not extracted to $maven_installation_dir. There is an existing directory with the name \"$maven_dir\"."
    if ! (confirm "Do you want to continue?"); then
        exit 1
    fi
fi

if [[ ! -f "${extracted_dirname}/bin/mvn" ]]; then
    echo "ERROR: The path $extracted_dirname is not a valid Maven installation."
    exit 1
fi

USER_HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"

if [[ -d "$USER_HOME" ]] && (confirm "Do you want to add Maven to the environment PATH variable in $USER_HOME/.bashrc?"); then
    if grep -q "export M2_HOME=.*" $USER_HOME/.bashrc; then
        sed -i "s|export M2_HOME=.*|export M2_HOME=$extracted_dirname|" $USER_HOME/.bashrc
    else
        echo "export M2_HOME=$extracted_dirname" >> $USER_HOME/.bashrc
    fi
    
    if grep -q "export M2=.*" $USER_HOME/.bashrc; then
        sed -i "s|export M2=.*|export M2=$M2_HOME/bin|" $USER_HOME/.bashrc
    else
        echo "export M2=\$M2_HOME/bin" >> $USER_HOME/.bashrc
    fi
    
    echo "export PATH=\$M2:\$PATH" >> $USER_HOME/.bashrc
fi

