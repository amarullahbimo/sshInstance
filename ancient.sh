#!/bin/sh

username=$2
environment=$3
sudo=$4
pubkey=$5
pubkeypath="/opt/infra/ancient/pub_key/${username}.pub"
userpath="/opt/infra/ancient/user/${environment}/${username}.yaml"
timestamp=`date +"%F_%T"`
tmppub_key="/opt/infra/ancient/tmp/pub_key/${username}-${timestamp}.pub"
tmpyaml="/opt/infra/ancient/tmp/user/${environment}/${username}-${timestamp}.yaml"

function createFile() {
  if [ ! -z "${pubkey}" ]; then
    if [ -f "${pubkeypath}" ]; then
      echo "[?] Put old ${username} pubkey to tmp/pub_key"
      oldpub_key=`cat ${pubkeypath}`
      echo ${oldpub_key} > ${tmppub_key}
    fi
    echo "[+] Add new ${username} pubkey"
    cat <<EOF >${pubkeypath}
${pubkey}
EOF
  fi
  if [ -f "${userpath}" ]; then
    echo "[?] Put old ${username} yaml with ${environment} environment to tmp/user/${environment}"
    oldyaml=`cat ${userpath}`
    echo ${oldyaml} > ${tmpyaml}
  fi
  echo "[+] Add new ${username} yaml with ${environment} environment"
  cat <<EOF >${userpath}
---
users:
- username: ${username}
  use_sudo: ${sudo}
  groups: olimpus
EOF
}

function deleteFile() {
  mv ${pubkeypath} ${tmppub_key}
  mv ${userpath} ${tmpyaml}
}

function createUser() {
  local my_username=$1
  if [ -z "${my_username}" ]; then
    ansible-playbook -i hosts createUsers.yaml --extra-vars "host=${environment}"
  else
    ansible-playbook -i hosts createUsers.yaml --extra-vars "host=${environment} username=${my_username}"
  fi
}

function deleteUser() {
  ansible-playbook -i hosts deleteUsers.yaml --extra-vars "host=${environment} username=${username}"
}

#============================
#       END OF FUNCTION
#============================
action=$1

case ${action} in
  create)
    createFile
    createUser ${username}
    ;;
  run)
    createUser
    ;;
  delete)
    deleteUser
    deleteFile
    ;;
  *)
    echo "${action} parameter is NOT FOUND read wisely"
    ;;
esac
