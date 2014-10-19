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
#	echo $Executable 1>&2
	strings "$Executable" | grep "$@"
done

