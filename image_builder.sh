#!/bin/bash
# Script to automate Dockerfile creation and image building from a .txt file

# Function to extract container names from the file
extract_containers() {
    grep -oP '(?<=\[)[^\]]+(?=\])' "$1" | sed -n 'n;p'
}

# Check if file is provided
if [ $# -eq 0 ]; then
    echo "Please provide the path to the .txt file"
    exit 1
fi

# Extract container names from the file
containers=($(extract_containers "$1"))

# Output the number of containers found
container_count=${#containers[@]}
echo "Found $container_count containers in the file."

for container in "${containers[@]}"; do
    # Create a safe name for the Dockerfile
    safe_name=$(echo "$container" | tr '/:' '__')

    # Create Dockerfile
    cat << EOF > "Dockerfile_${safe_name}"
FROM $container
COPY wallaby.so /home/wallaby/wallaby.so
ENV LD_PRELOAD=/home/wallaby/wallaby.so
EOF

    # Build Docker image
    sudo docker build -t "$container" -f "Dockerfile_${safe_name}" .

    echo "Built image for $container"
done

echo "All $container_count images have been built."
