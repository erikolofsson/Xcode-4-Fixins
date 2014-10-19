#!/bin/bash

xcodebuild -workspace "XCFixins.xcworkspace" -scheme "Release All maintained" clean
xcodebuild -workspace "XCFixins.xcworkspace" -scheme "Release All maintained"
