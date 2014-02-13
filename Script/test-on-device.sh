#!/bin/sh

project=XCode/TravisCI.xcodeproj
device="iPad Yan"

function print_header()
{
    text=$1
    echo "$(tput setaf 3)$(tput bold)$text$(tput sgr 0)"
}

succeeded_count=0
function process_xcodebuild_exit_code
{
    exitcode=$1
    if [[ $exitcode != 0 ]] ; then
        echo "$(tput setaf 1)xcodebuild exited with code $exitcode$(tput sgr 0)"
        echo "$(tput setaf 1)$(tput bold)=== TESTS FAILED ===$(tput sgr 0)"
        exit 1
    else
        ((succeeded_count++))
    fi
}

function print_result()
{
    echo "$(tput setaf 2)$(tput bold)=== SUCCEEDED $succeeded_count CONFIGURATIONS. ===$(tput sgr 0)"
}

function test_on_device()
{
    scheme=$1
    configuration=$2
    print_header "=== TEST SCHEME $scheme DEVICE $device CONFIGURATION $configuration ==="
    xcodebuild  -project $project \
                -scheme $scheme \
                -sdk iphoneos \
                -destination name="$device" \
                -configuration $configuration \
                test
    process_xcodebuild_exit_code $?
}

#Logic tests
for configuration in Release Debug
do
    test_on_device iOSDeviceLogicTests "$configuration"
done

# UI tests
test_on_device iOSUITests Debug

print_result
