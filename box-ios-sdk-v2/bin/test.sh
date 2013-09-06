#!/usr/bin/env bash

USAGE="
$0 [iOS/OSX SDK Version] [Configuration]

Valid versions are
  6.1
  6.0
  5.1
  5.0
 10.8
  all

Valid configurations are
  Release
  Debug [default]
"

function print_build_status
{
  status="$1"
  build_name="$2"

  [ "$status" == "0" ] && echo "$build_name SUCCEEDED" || echo "$build_name FAILED"
}

configuration="Debug"
[ "$2" == "release" ] && configuration="Release"
[ "$2" == "Release" ] && configuration="Release"

case "$1" in
  "10.8")
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxCocoaSDKTests -sdk macosx10.8 -configuration $configuration clean build
    ;;
  "5.0")
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator5.0 -configuration $configuration clean build
    ;;
  "5.1")
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator5.1 -configuration $configuration clean build
    ;;
  "6.0")
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator6.0 -configuration $configuration clean build
    ;;
  "6.1")
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator6.1 -configuration $configuration clean build
    ;;
  "all")
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator5.0 -configuration $configuration clean build
    build_status_50=$?
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator5.1 -configuration $configuration clean build
    build_status_51=$?
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator6.0 -configuration $configuration clean build
    build_status_60=$?
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxSDKTests -sdk iphonesimulator6.1 -configuration $configuration clean build
    build_status_61=$?
    xcodebuild -project BoxSDK.xcodeproj/ -target BoxCocoaSDKTests -sdk macosx10.8 -configuration $configuration clean build
    build_status_108=$?

    print_build_status "$build_status_50" "iOS 5.0"
    print_build_status "$build_status_51" "iOS 5.1"
    print_build_status "$build_status_60" "iOS 6.0"
    print_build_status "$build_status_61" "iOS 6.1"
    print_build_status "$build_status_108" "OSX 10.8"

    [ "$build_status_50" == "0" ] || exit 1
    [ "$build_status_51" == "0" ] || exit 1
    [ "$build_status_60" == "0" ] || exit 1
    [ "$build_status_61" == "0" ] || exit 1
    [ "$build_status_61" == "0" ] || exit 1
    [ "$build_status_108" == "0" ] || exit 1

    echo "ALL SYSTEMS GO! LAUNCH!! LAUNCH!! LAUNCH!!"

    ;;
  *)
    echo "${USAGE}"
    exit 255
esac

