#!/bin/bash


IFS=$'\n'
set -f
set -e
#set -x

#XcodeExecutables="$XcodeExecutables
#$(find /System/Library/Frameworks -type f -perm +111)"
#XcodeExecutables="$XcodeExecutables
#$(find /System/Library/PrivateFrameworks -type f -perm +111)"
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
	[[ "$Executable" == "/Applications/Xcode.app/Contents/OtherFrameworks/DevToolsCore.framework/Versions/A/DevToolsCore" ]] && continue
	[[ "$Executable" == "/Applications/Xcode.app/Contents/Plugins/IDEInterfaceBuilderKit.framework/Versions/A/Resources/nibextractor" ]] && continue
	[[ $Executable =~ ^/Applications/Xcode\.app/Contents/OtherFrameworks/DevToolsInterface\.framework/Versions/A/Resources/UtilityScripts/.*$ ]] && continue
	[[ $Executable =~ ^.*\.pl$ ]] && continue
	[[ $Executable =~ ^.*\.py$ ]] && continue
	[[ "$Executable" == "/Applications/Xcode.app/Contents/SharedFrameworks/DTDeviceKitBase.framework/Versions/A/Resources/sync_ddi" ]] && continue
	[[ "$Executable" == "/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash" ]] && continue
	[[ "$Executable" == "" ]] && continue
	[[ "$Executable" == "" ]] && continue
	[[ "$Executable" == "" ]] && continue
	[[ "$Executable" == "" ]] && continue

#	echo $Executable 1>&2
	#class-dump --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk "$Executable"
	echo -e "\033[32m/Source/class-dump/build/Release/class-dump -H -F --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk -o $CurrentPath/XcodeDump $Executable \033[0m" 1>&2
	/Source/class-dump/build/Release/class-dump -H -F --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk -o $CurrentPath/XcodeDump "$Executable" || true
	#class-dump -H -I --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
	#class-dump -H -I -r --sdk-mac /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk -o $CurrentPath/XcodeDump "$Executable"
done



