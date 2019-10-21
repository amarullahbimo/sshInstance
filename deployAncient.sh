#!/bin/bash

remoteHost="skynat.stargate.id"
action=$1
username=$2
environment=$3
sudo=$4
pubkey=$5
ssh ${remoteHost} "bash /opt/infra/ancient/ancient.sh ${action} ${username} ${environment} ${sudo} '${pubkey}'"
