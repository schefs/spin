#!/bin/bash

# Cleanup on trap
cleanup()
{
    spin_stop
    exit 100
}

# Spinning loading dot
spin()
{
    local spinstr='|/-\'
    while : 
    do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.05
        printf "\b\b\b\b\b\b"
    done
}

# Start the Spinner
spin_start()
{
    spin &
    # Make a note of its Process ID (PID):
    SPIN_PID=$!
}

# Stop the Spinner
spin_stop()
{
    if [ -z $SPIN_PID ]; then
    echo "Spinner is already down...";    
    else
        #echo killing Spinner $SPIN_PID
        kill -n 9 $SPIN_PID &> /dev/null
        unset SPIN_PID;
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
        spin_start
        docker pull $image 1> /dev/null
        spin_stop
        echo "Saving: $image_name"
        spin_start
        docker save -o $image_name $image
        spin_stop
    done
}

main()
{ 
    
    # Kill the spinner on any signal, including our own exit.
    trap 'echo "Cought trap!" ; cleanup' 1 2 3 6 9 14 15

    # Get images from kubernetes
    get_images
    
    # Check if any images found
    if [ $? == 0 ]; then
        list_images
        save_images;
    else
        exit 101;
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