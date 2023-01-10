#!/bin/bash

API_TOKEN=$1
VOL_SIZE='990M'
IMAGES_LIST='./images.txt'


IMAGES_DIR=/tmp/images/
VOLUMES_DIR=/tmp/volumes/

# Простая функция для парсинга свойств из JSON
function parseJson()
{
    local output
    regex="(\"$1\":[\"]?)([^\",\}]+)([\"]?)"
    [[ $2 =~ $regex ]] && output=${BASH_REMATCH[2]}
    echo $output
}

# Функция для отправки файла
function sendFile
{

    FILENAME=$2
    FILEPATH=$1
    TOKEN=$3

    echo "Start sending a file: $FILEPATH to $FILENAME"

    # Получаем URL для загрузки файла
    sendUrlResponse=`curl -s -H "Authorization: OAuth $TOKEN" https://cloud-api.yandex.net:443/v1/disk/resources/upload/?path=app:/$FILENAME&overwrite=true`
    sendUrl=$(parseJson 'href' $sendUrlResponse)
    # Отправляем файл
    sendFileResponse=`curl -s -T $FILEPATH -H "Authorization: OAuth $TOKEN" $sendUrl`
    echo "Completing a file upload: $FILEPATH"

}

#sendFile $1 $2

function iterateOnImages
{
    IMAGES_FILE=$1
    rm -rf $IMAGES_DIR
    mkdir -p $IMAGES_DIR
    while read image; do
        echo "$image"
        sudo docker pull $image
        image_file_name=$(echo ${image//'/'/'___'})
        echo "$image_file_name"
        sudo docker save $image | gzip > $IMAGES_DIR/$image_file_name.tar.gz
    done < $IMAGES_FILE
}

#iterateOnImages $1

function images2Volumes
{
    IMAGES_FILE=$1
    VOLUME_SIZE=$2
    TIME=$(date '+%Y%m%d%H%M')
    rm -rf $VOLUMES_DIR
    mkdir -p $VOLUMES_DIR
    tar cfv - $IMAGES_DIR | split -b $VOLUME_SIZE - $VOLUMES_DIR/$IMAGES_FILE-$TIME.tar.
}

#images2Volumes  100M 


function transferFiles
{
    API_TOKEN_YA=$1
    cd $VOLUMES_DIR
    for filename in *; do sendFile $VOLUMES_DIR$filename $filename $API_TOKEN_YA; done
}


function call
{
    iterateOnImages $1 
    images2Volumes $1 $2
    transferFiles $3
} 

call $IMAGES_LIST $VOL_SIZE  $API_TOKEN