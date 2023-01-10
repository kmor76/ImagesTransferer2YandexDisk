#!/bin/bash

DIR=/u00/tmp/transferer/katibTrial

function untar
{
    VOLUMES_DIR=$1
    echo "$VOLUMES_DIR"
    cd $VOLUMES_DIR
    cat ./*.tar.* | tar xvf -
}

function iterateOnImages
{
    IMAGES_DIR=$1
    cd $IMAGES_DIR
    for filename in *; do
        sudo docker load < $filename;
        #echo $filename
        imageNamePre=$(echo ${filename//'.tar.gz'/''})
        imageName=$(echo ${imageNamePre//___/'/'})
        retagName=$(echo ${imageName/'docker.io'/'your-registry:443'})
        sudo docker tag $imageName $retagName
    done
}

function call
{
    VOLUMES_DIR=$1
    untar $VOLUMES_DIR
    iterateOnImages $VOLUMES_DIR/tmp/images/
}

call $DIR