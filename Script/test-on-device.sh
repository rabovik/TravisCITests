#!/bin/sh

# Global settings
project=XCode/TravisCI.xcodeproj
device="iPad Yan" # iOS 5.1.1

# Formatting output
function red() {
    eval "$1=\"$(tput setaf 1)$2$(tput sgr 0)\""
}

function green() {
    eval "$1=\"$(tput setaf 2)$2$(tput sgr 0)\""
}

function yellow() {
    eval "$1=\"$(tput setaf 3)$2$(tput sgr 0)\""
}

function bold() {
    eval "$1=\"$(tput bold)$2$(tput sgr 0)\""
}

function echo_fmt() {
    local str=$1
    local color=$2
    local bold=$3
    if [ "$color" != '' ]; then 
        $color str "$str" 
    fi
    if [ "$bold" != '' ]; then 
        $bold str "$str" 
    fi
    echo $str
}

# Testing
succeeded_count=0
function test() {
    local options="$@"
    echo_fmt "xcodebuild test -project $project $options" yellow

    xcodebuild test -project $project "$@" | xcpretty -c
    local exitcode=${PIPESTATUS[0]}
    if [[ $exitcode != 0 ]] ; then
        echo_fmt "xcodebuild exited with code $exitcode" red
        echo_fmt "=== TESTS FAILED ===" red bold
        exit 1
    else
        ((succeeded_count++))
    fi
}

function test_on_device()
{
    local scheme=$1
    local configuration=$2
    shift 2
    echo_fmt "=== TEST SCHEME $scheme DEVICE $device CONFIGURATION $configuration ===" yellow bold

    test -scheme "$scheme" \
         -sdk iphoneos \
         -destination name="$device" \
         -configuration "$configuration" \
         "$@"
}

#Logic tests
for configuration in Release Debug
do
    test_on_device iOSDeviceLogicTests "$configuration"
done

# UI tests
test_on_device iOSUITests Debug

# Result
echo_fmt "=== SUCCEEDED $succeeded_count CONFIGURATIONS. ===" green bold
