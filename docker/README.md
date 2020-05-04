# Docker scripts

## build_docker_container.sh
```
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
```

## delete_dockerr_container.sh
```
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
```

## Misc
* TODO: Script to remove dangling docker images: https://nickjanetakis.com/blog/docker-tip-31-how-to-remove-dangling-docker-images
```
docker images -f "dangling=true" -q
```