#!/bin/bash
# 
# Script deletes docker container, and images as directed by name
# 
# Args: 
#     container_name/image_name: Name of the container/image. Required.
#     dry_run: Dry run - ensures that only messages printed and no containers are
#              deleted. Shows which containers/images would be deleted. By 
#              default, set to 1. Set to 0 to force delete containers, images.
#     delete_containers: Flag sets whether to rebuild this container OR not. By
#                        default, set to 1. Set to 0 to not remove containers.
#     delete_images: Flag forces the image rebuild. By default, 0.
#
# Outputs:
#     Debug log, as it deletes the images and containers
# 
# Examples:
#     To show all the images and containers to delete that match named 
#     'athena-test' (dry-run):
#         ./delete_docker_container.sh 'athena-test' 1 1 1
#
#     To delete the containers called 'athena-test', but not images from workstation:
#         ./delete_docker_container.sh 'athena-test' 0
# 
#     To delete ALL images, containers from this workstation:
#         ./delete_docker_container.sh 'athena-test' 0 1 1
#
if [ $# -lt 1 ]; then
    echo "[-] $0 <container_name/image_name> 
                 [dry_run=1]
                 [delete_containers=1] 
                 [delete_images=0]"
    exit 1
fi
container_name="$1"
dry_run=${2:-"1"}
delete_containers=${3:-"1"}
delete_images=${4:-"0"}

image_name="$container_name"

echo "[*] Checking if containers should be deleted"
if [ "$delete_containers" == "1" ]; then

    echo "[*] Get list of all docker containers"
    all_docker_containers=$(docker container ls -a)
    
    echo "[*] Getting the status of the docker container: $container_name"
    container_ids=$(echo "$all_docker_containers" | grep -i "$container_name" \
               | tr -s "  " " " \
               | cut -d" " -f1)

    echo "[+] container_ids: $container_ids"

    echo "[*] Stopping, then Deleting all containers listed above"
    if [ "$dry_run" == "0" ]; then
        echo "$container_ids" | xargs docker stop
        echo "$container_ids" | xargs docker rm 
    fi
fi

echo "[*] Checking if images  should be deleted"
if [ "$delete_images" == "1" ]; then

    echo "[*] Get list of all docker images"
    all_docker_images=$(docker images -a)

    echo "[*] Delete the containers with name: $container_name"
    image_ids=$(echo "$all_docker_images" | grep -i "$image_name" \
                | tr -s "  " " " \
                | cut -d" " -f3)

    echo "image_ids: $image_ids"

    echo "[*] Deleting all images listed above"
    if [ "$dry_run" == "0" ]; then
        echo "$image_ids" | xargs docker rmi -f
    fi
fi