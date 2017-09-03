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
	if [[ "$File" == "./.DS_Store" ]] ; then
		continue
	else
		if [ -e "XcodeDump/$File" ]; then
			echo $File 1>&2
			cp XcodeDump/$File Xcode/$File
		else
			if [[ "$File" == "./Shared.h" ]]; then
				continue
			fi
			rm "Xcode/$File"
			echo -e "\033[31mMISSING:\033[0m XcodeDump/$File"
		fi
	fi
done



