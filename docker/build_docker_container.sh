#!/bin/bash
# 
# Script to build/restart a Docker container from scratch with all dependencies
# for hosting docker container. Script will build or rebuild (if requested) an
# image and then build container for this image. It will then launch a shell
# 
# 
# Args: 
#     dockerfile: Path to the dockerfile. Required.
#     container_name/image_name: Name of the container/image. Required.
#     rebuild_image: Flag forces the image rebuild. By default, 0.
#     rebuild_container: Flag sets whether to rebuild this container OR not.  By
#                        default, set to 0. Set to 1 to remove all containers
#     start_shell: After starting the container, get a shell. By default, set to 
#                  1.
#     shell_type: Type of shell to launch. By default, the shell i 
#     shared_folders: Folders comma-sep to share in container. By default, are 
#                     '/opt/athena-tools','/opt/athena-tools-private'.
# 
# Outputs:
#     Details of the built container and steps performed to-date
# 
# Examples:
#     To rebuild container called 'athena-test' with Dockerfile 'in-Dockerfile'
#     from scratch:
#         ./build_docker_container.sh in-Dockerfile 'athena-test' 1 1
# 
#     To start shell on existing container without rebuilding image, container:
#         ./build_docker_container.sh in-Dockerfile 'athena-test'
#

if [ $# -lt 2 ]; then
    echo "[-] $0 <dockerfile> <container_name> 
                [rebuild_image=0] 
                [rebuild_container=0] 
                [start_shell=1] [shell_type=/bin/bash] 
                [shared_folders=/opt/athena-tools,/opt/athena-tools-private]"
    exit 1
fi
dockerfile="$1"
container_name="$2" 
rebuild_image=${3:-"0"}
rebuild_container=${4:-"0"}
start_shell=${5:-"1"}
shell_type=${6:-"/bin/bash"}
shared_folders=${7:-"/opt/athena-tools,/opt/athena-tools-private"}

# image name is the same as container name
image_name="$container_name"

echo "[*] Getting the list of all the docker containers on the device"
all_docker_containers=$(docker container ls -a)
all_docker_images=$(docker images -a)

echo "[*] Getting the image id with name: $image_name"
image_id=$(echo "$all_docker_images" | grep -i "$image_name" \
               | tr -s "  " " " \
               | cut -d" " -f3)
echo "image_id: $image_id"

echo "[*] Getting the status of the docker container: $container_name"
container_id=$(echo "$all_docker_containers" | grep -i "$container_name" \
               | tr -s "  " " " \
               | cut -d" " -f1)
echo "[+] container_id: $container_id"

# If No docker image found, or requested to build one, then build one
if [ "$rebuild_image" == "1" ] || [ -z "$image_id" ]; then

    if [ ! -z "$image_id" ]; then
        echo "[*] Deleting previous image with image_id: $image_id"
        echo "$image_id" | xargs docker rmi -f
    fi

    echo "[*] Building image: $image_name:latest, dockerfile: $dockerfile"
    docker build -t "$image_name:latest" -f "$dockerfile" .
fi

# No docker container found - need to build one
if [ -z "$container_id" ] || [ "$rebuild_container" == "1" ]; then
    # Build the list of shared folders to mount as provided
    if [ ! -z "$shared_folders" ]; then
        
        if [ ! -z "$container_id" ]; then
            echo "[*] Stopping, then Deleting previous container with id: $container_id"
            echo "$container_id" | xargs docker stop
            echo "$container_id" | xargs docker rm 
        fi

        echo "[*] Building shared folders list"
        shared_folders_mount_str=""
        IFS=","
        for shared_folder_path in $shared_folders; do
            shared_folders_mount_str="$shared_folders_mount_str -v $shared_folder_path:$shared_folder_path"
        done
    fi

    echo "[*] Shared folders string: $shared_folders_mount_str"

    echo "[*] Starting docker container with name: $container_name"
    /bin/bash -c "docker run -it $shared_folders_mount_str \"$container_name\" \"$shell_type\""

else

    echo "[*] Getting the list of all the docker containers on the device again"
    all_docker_containers=$(docker container ls -a)
    all_docker_images=$(docker images -a)

    echo "[*] Getting the image id with name: $image_name again"
    image_id=$(echo "$all_docker_images" | grep -i "$image_name" \
                | tr -s "  " " " \
                | cut -d" " -f3 \
                | head -n1)
    echo "image_id: $image_id"

    echo "[*] Getting the status of the docker container: $container_name again"
    container_id=$(echo "$all_docker_containers" | grep -i "$container_name" \
                | tr -s "  " " " \
                | cut -d" " -f1 \
                | head -n1)
    echo "[+] container_id: $container_id"

    echo "[*] Starting container with name: $container_name, id: $container_id"
    docker start "$container_id"

    # Launch shell if requested by user
    if [ "$start_shell" == "1" ]; then
        echo "[*] Start shell on container name: $container_name, id: $container_id"
        docker exec -it "$container_id" "$shell_type"
    fi
fi