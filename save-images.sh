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
        sleep 1
      done
    done
}

# Start the Spinner
spin_start()
{
    spin &
    # Make a note of its Process ID (PID):
    SPIN_PID=$!
    # Kill the spinner on any signal, including our own exit.
    trap "kill -9 $SPIN_PID" `seq 0 15`
}

# Stop the Spinner
spin_stop()
{
    kill -9 $SPIN_PID
}

usage() 
{ 
    echo -e "\nUsage: $0 [-n <namespace>] [-p <directory_path>]" 1>&2;
    echo "
    Description: 
        This script will use your local install of kubectl,
        will search and find all images used by containers in specific namespace,
        and will save them all to .tar files."
    echo "
    Options:
        -h help
        -n <namespace>         namespace for seaching images from (Default: default)
        -p <Directory_path>    DIR path for saveing all images to (Default: ./)"
    exit 0; 
} 

# Get all images
get_images()
{
    echo -e "\e[93mSearching for all images in $NAMESPACE namespace...\e[0m"
    spin_start
    IMAGES=$(kubectl get pods -n $NAMESPACE -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |uniq -u|sort)
    if (( $(echo $IMAGES|wc -w) == 0 )); then
        echo "NO images found in $NAMESPACE namespace"
        spin_stop
        return 1;
    else spin_stop
    fi
   
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
        image_name=$FILES_PATH/$(echo $image| tr /. _).tar
        echo "Saving: $image_name"
        spin_start
        docker save -o $image_name $image
        spin_stop
    done
}

main()
{ 
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
while getopts n:p:h option
do
case "${option}"
in
n) NAMESPACE=${OPTARG};;
p) FILES_PATH=${OPTARG};;
h|*) usage;;
esac
done
main