#!/bin/bash

#
# Uses git bundle to create a compressed backup of a git repository and provides possibility to restore it.
# (c) 2011-2014 by Tim Bolender
#

#
# How To Use:
#   gitbackup backup <repository> <repname> [[<outputfolder>]]
#        
#       Create repository backup with git-bundle. The outputfile will be <repname>.<yyyymmdd>.git-bundle
#
#       repository  : git repository to clone
#       repname     : name of repository
#       outputfolder: output folder for compressed file
#
#   gitbackup restore <bundle> [[<outputfolder>]]
#        
#       Restore repository from backup created with git-bundle.
#
#       bundle      : git bundle to restore
#       outputfolder: output folder for restored repository
#

printHowToUse() {
    echo "gitbackup backup <repository> <repname> [[<outputfolder>]]"
    echo ""
    echo "    Create repository backup with git-bundle. The outputfile will be <repname>.<yyyymmdd>.git-bundle"
    echo ""
    echo "    repository  : git repository to clone"
    echo "    repname     : name of repository"
    echo "    outputfolder: output folder for compressed file"
    echo ""
    echo "gitbackup restore <bundle> [[<outputfolder>]]"
    echo ""     
    echo "    Restore repository from backup created with git-bundle."
    echo ""
    echo "    bundle      : git bundle to restore"
    echo "    outputfolder: output folder for restored repository"
}

#
# $1 = directory name
# $2 = file name
# output: valid concatenated path
#
filename() {
    local fullpath=$( readlink -m "$1" )
    echo "${fullpath}/$2" | sed 's/\/\//\//g'
}

#
# $1 = repository
# $2 = bundle file name
#
backup() {
    local backupPwd=$( pwd )
    local ret=0

    echo "-- Creating bundle of repository"
    cd "$1"
    git bundle create "$2" --all
    if [[ $? -ne 0 ]]
    then
        echo -e "\nERROR: Failed to create bundle of repository!"
        ret=1
    fi
    cd "$backupPwd"

    exit $ret
}

#
# $1 = bundle file name
# $2 = output folder
#
restore() {
    local backupPwd=$( pwd )

    echo "-- Creating empty repository with bundle as remote"
    mkdir -p "$2"
    cd "$2"
    git init
    git remote add bundle "$1"
    git fetch bundle

    if [[ $? -eq 0 ]]
    then
        echo "-- Recreate all branches of backup"
        local branches=$( git branch -r | sed 's/.*bundle\///g' )
        local removemaster=1

        for b in $branches
        do
            if [[ $b == "master" ]]
            then
                removemaster=0
                git checkout master
                git pull bundle master
            else
                other=$b
                git checkout -b $b bundle/$b
            fi
        done

        # Remove default master if it was removed
        if [[ $removemaster -ne 0 ]]
        then
            git checkout $other
            git branch -d master
        fi

        echo "-- Remove bundle from remote list"
        git remote remove bundle
    else
        echo -e "\nERROR: Failed to prepare an empty repository!"
        exit 1
    fi

    exit 0
}

# Just about stuff
echo -e "gitbackup v0.3"
echo -e "(c) 2011-2014 by Tim Bolender\n"

# Check whether arguments were given
if [[ $# -lt 1 ]]
then
    printHowToUse
    exit 1
fi

case $1 in
'backup')
    # Check whether enough arguments were given
    if [[ $# -lt 3 ]]
    then
        printHowToUse
        exit 1
    fi

    # Get arguments
    gitRep=$( readlink -m "$2" )
    repName="$3"
    if [[ $# -ge 4 ]]
    then
        outputfolder=$( readlink -m "$4" )
    else
        outputfolder=$( pwd )
    fi

    # Generate output file name
    date=$(git -C "${gitRep}" log -1 --date=iso --pretty=format:%cd)
    date=${date/ /-}
    output=$( filename "$outputfolder" "${repName}.${date/ /}.git-bundle" )

    # Create bundle
    backup "$gitRep" "$output"
    
    ;;

'restore')
    # Check whether enough arguments were given
    if [[ $# -lt 2 ]]
    then
        printHowToUse
        exit 1
    fi

    # Get arguments
    fileRep=$( readlink -m "$2" )
    if [[ $# -ge 3 ]]
    then
        outputfolder=$( readlink -m "$3" )
    else
        outputfolder=$( pwd )
    fi

    # Restore bundle
    restore "$fileRep" "$outputfolder"

    ;;
*)
    printHowToUse
    exit 1

    ;;
esac
