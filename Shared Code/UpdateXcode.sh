#!/bin/bash


IFS=$'\n'
set -f
set -e

pushd Xcode
FilesToUpdate="$XcodeExecutables
$(find . -type f)"
popd

CurrentPath=$PWD

for File in $FilesToUpdate; do
	echo $File 1>&2
	if [[ "$File" == "./.DS_Store" ]] ; then
		continue
	else
		if [ -f "$File" ]; then
			cp XcodeDump/$File Xcode/$File
		fi
	fi
done


