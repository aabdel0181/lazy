#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Please provide the input file name as an argument"
    exit 1
fi

input_file=$1

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file $input_file does not exist"
    exit 1
fi

# Create a directory to store the tarballs
mkdir -p docker_images

# Read the input file line by line
while IFS= read -r image; do
    # Skip empty lines
    [ -z "$image" ] && continue

    # Create a filename-safe version of the image name
    safe_name=$(echo $image | sed 's/[\/:]/_/g')

    # Check if the image exists locally
    if docker image inspect "$image" >/dev/null 2>&1; then
        echo "Saving image: $image"
        # Save the image as a tarball
        docker save "$image" -o "docker_images/${safe_name}.tar"
    else
        echo "Image not found locally: $image"
    fi
done < "$input_file"

echo "Image tarballs saved in the docker_images directory"
