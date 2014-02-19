#!/bin/sh

# Global settings
project=XCode/TravisCI.xcodeproj

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

function test_ios() {
    local scheme=$1
    local iosversion=$2
    local device="$3"
    local configuration=$4
    shift 4
    echo_fmt "=== TEST SCHEME $scheme IOS $iosversion DEVICE $device CONFIGURATION $configuration ===" yellow bold

    test -scheme "$scheme" \
         -sdk iphonesimulator \
         -destination OS="$iosversion",name="$device" \
         -configuration "$configuration" \
         "$@"
}

function test_osx() {
    local scheme=$1
    local configuration=$2
    shift 2
    echo_fmt "=== TEST SCHEME $scheme OSX CONFIGURATION $configuration ===" yellow bold
    test -scheme "$scheme" -configuration "$configuration" "$@"
}

# Logic tests
for configuration in Release Debug
do
    for iosversion in 6.0 6.1 7.0 #5.0 5.1 # Mavericks does not support iOS 5 Simulator
    do
        test_ios "iOSLogicTests" "$iosversion" "iPad Retina" "$configuration"
    done

    test_ios "iOSLogicTests-64bit" 7.0 "iPad Retina (64-bit)" "$configuration" ONLY_ACTIVE_ARCH=YES
    
    test_osx "OSXTests" "$configuration"    
done

# UI tests
test_ios "iOSUITests" 6.0 "iPhone" Debug
for device in "iPad" "iPhone Retina (3.5-inch)" "iPhone Retina (4-inch)" "iPad Retina"
do
    for iosversion in 6.0 7.0
    do
        test_ios "iOSUITests" "$iosversion" "$device" Debug
    done
done

# Result
echo_fmt "=== SUCCEEDED $succeeded_count CONFIGURATIONS. ===" green bold
