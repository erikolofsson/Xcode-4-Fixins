#!/bin/bash


IFS=$'\n'
set -f

XcodeExecutables="$XcodeExecutables
$(find /Applications/Xcode.app/Contents/Plugins -type f -perm +111)"
XcodeExecutables="$XcodeExecutables
$(find /Applications/Xcode.app/Contents/OtherFrameworks -type f -perm +111)"
XcodeExecutables="$XcodeExecutables
$(find /Applications/Xcode.app/Contents/SharedFrameworks -type f -perm +111)"
XcodeExecutables="$XcodeExecutables
$(find /Applications/Xcode.app/Contents/Frameworks -type f -perm +111)"
XcodeExecutables="$XcodeExecutables
$(find /Applications/Xcode.app/Contents/MacOS -type f -perm +111)"

CurrentPath=$PWD
mkdir $CurrentPath/XcodeDump

for Executable in $XcodeExecutables; do
	echo $Executable
	class-dump -H --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
	#class-dump -H -I --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
	#class-dump -H -I -r --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
done


