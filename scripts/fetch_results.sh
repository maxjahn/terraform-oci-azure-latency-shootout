#!/bin/sh

# remove remote crontab
ssh ${1}@${2} "crontab -r"
ssh ${1}@${2} "crontab -l"

ssh ${1}@${2} "tar cvfz ${2}_logs.tgz *.log"

scp ${1}@${2}:"${2}_logs.tgz" .
