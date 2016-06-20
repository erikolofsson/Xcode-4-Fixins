#!/bin/bash


IFS=$'\n'
set -f
set -x

XcodeExecutables="$XcodeExecutables
$(find /System/Library/PrivateFrameworks -type f -perm +111)"
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
mkdir -p "$CurrentPath/XcodeDump"
if [ -e "$CurrentPath/XcodeDump/CDStructures.h" ]; then
	rm "$CurrentPath/XcodeDump/CDStructures.h"
fi

for Executable in $XcodeExecutables; do
	if [[ "$Executable" == "/Applications/Xcode.app/Contents/OtherFrameworks/DevToolsCore.framework/Versions/A/DevToolsCore" ]]; then
		continue
	fi

	echo $Executable 1>&2
	#class-dump --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk "$Executable"
	/Source/class-dump/build/Release/class-dump -H -F --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk -o $CurrentPath/XcodeDump "$Executable"
	#class-dump -H -I --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
	#class-dump -H -I -r --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
done


