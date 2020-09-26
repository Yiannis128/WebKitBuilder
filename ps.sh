#!/usr/bin/env bash

echo 'This script is meant to initialize a docker powershell container for linux'
echo 'users so they can use powershell.'
echo 'Make sure to run this script with sudo.'
echo 'The only thing that this script leaves left over is the powershell docker'
echo 'image so that it doesnt have to redownload the image at every run.'
echo 'The image can be removed using:'
echo 'sudo docker rmi mcr.microsoft.com/powershell'
echo
echo

docker run -itv "$(pwd):/home/" --rm mcr.microsoft.com/powershell
