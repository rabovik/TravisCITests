#!/bin/sh

project=XCode/TravisCI.xcodeproj

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

function test_ios()
{
    scheme=$1
    iosversion=$2
    device=$3
    configuration=$4
    print_header "=== TEST SCHEME $scheme IOS $iosversion DEVICE $device CONFIGURATION $configuration ==="
    xcodebuild  -project $project \
                -scheme $scheme \
                -sdk iphonesimulator \
                -destination platform="iOS Simulator",OS=$iosversion,name="$device" \
                -configuration $configuration \
                test
    process_xcodebuild_exit_code $?
}

function test_osx()
{
    scheme=$1
    configuration=$2
    print_header "=== TEST SCHEME $scheme OSX CONFIGURATION $configuration ==="
    xcodebuild  -project $project -scheme $scheme -configuration $configuration test
    process_xcodebuild_exit_code $?
}

# Logic tests
for configuration in Release Debug
do
    for iosversion in 6.0 6.1 7.0 #5.0 5.1 # Mavericks does not support iOS 5 Simulator
    do
        test_ios iOSLogicTests "$iosversion" "iPad" "$configuration"
    done
    
    test_osx OSXTests "$configuration"
    
    # Still can not test because of the XCode bug "Simulator is already in use"
    #test_ios iOSLogicTests-64bit 7.0 "iPad Retina (64-bit)" "$configuration"
done

# UI tests
test_ios iOSUITests 6.0 iPhone Debug
for device in "iPad" "iPhone Retina (3.5-inch)" "iPhone Retina (4-inch)" "iPad Retina"
do
    for iosversion in 6.0 7.0
    do
        test_ios iOSUITests "$iosversion" "$device" Debug
    done
done

print_result
