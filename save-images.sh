#!/bin/bash

# Spinning loading dot
spin()
{
    spinner="/|\\-/|\\-"
    while :
    do
      for i in `seq 0 7`
      do
        echo -n "${spinner:$i:1}"
        echo -en "\010"
        sleep 0.5
      done
    done
}

# Start the Spinner
spin_start()
{
    spin &
    # Make a note of its Process ID (PID):
    SPIN_PID=$!
    echo spin pid is $SPIN_PID
}

# Stop the Spinner
spin_stop()
{
    if [ -n $SPIN_PID ]; then
        echo killing $SPIN_PID
        kill -n 9 $SPIN_PID
        unset SPIN_PID;
    else
    echo "nothing to kill...";
    fi
}

usage() 
{ 
    echo -e "\nUsage: $0 [-n <namespace>] [-o <output_path>]" 1>&2;
    echo "
    Description: 
        This script will use your local install of kubectl,
        will search and find all images used by containers in specific namespace,
        and will save them all to .tar files."
    echo "
    Options:
        -h help
        -n <namespace>         namespace for seaching images from (Default: default)
        -o <output_path>    DIR path for saveing all images to (Default: ./)
        "
    exit 0; 
} 

# Get all images
get_images()
{
    echo -e "\e[93mSearching for all images in $NAMESPACE namespace...\e[0m"
    spin_start
    IMAGES=$(kubectl get pods -n $NAMESPACE -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |uniq |sort)
    if (( $(echo $IMAGES|wc -w) == 0 )); then
        echo "NO images found in $NAMESPACE namespace"
        spin_stop
        return 1;
    fi
    spin_stop
}

# Echo all images
list_images()
{
    echo -e "\e[93mImage List:\n\e[0m$IMAGES"
}

# Save all images to files
save_images()
{
    echo -e "\e[0m........\e[92m Saving Images \e[0m........"
    for image in $IMAGES
    do
        image_name=$FILES_PATH$(echo $image| tr /. _|tr : -).tar
        echo "Pulling $image:"
        docker pull $image
        echo "Saving: $image_name"
        spin_start
        docker save -o $image_name $image
        spin_stop
    done
}

main()
{ 
    # Kill the spinner on any signal, including our own exit.
    trap spin_stop 0 1 2 3 6 9 14 15
    get_images
    if [ $? == 0 ]; then
        list_images
        save_images
    fi
}

# Set default vars
NAMESPACE=default
FILES_PATH=.

# Set vars from user input
while getopts n:o:h option
do
case "${option}"
in
n) NAMESPACE=${OPTARG};;
o) FILES_PATH=${OPTARG};;
h|*) usage;;
esac
done

# Run main
main