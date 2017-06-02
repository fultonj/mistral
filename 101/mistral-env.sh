#!/usr/bin/env bash
# Filename:                mistral-env.sh
# Description:             explores-mistral-envs
# -------------------------------------------------------
HELP=1
ENVS=0
if [[ $HELP -eq 1 ]]; then 
    for cmd in $(mistral --help | grep environment | awk {'print $1'}); do 
	echo -e "$cmd\n<---"
	mistral $cmd; 
	echo -e "---> \n"
    done
fi

if [[ $ENVS -eq 1 ]]; then 
    for env in $(mistral environment-list | awk {'print $2'} | grep -v Name); do 
	echo -e "$env\n<---"
	mistral environment-get $env
	echo -e "---> \n"
    done
fi
