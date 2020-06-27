#!/bin/bash
# 
# Taken from: 
#    https://stackoverflow.com/questions/49021954/how-to-remove-dangling-images-in-docker
sudo docker rmi $(sudo docker images -f "dangling=true" -q)
