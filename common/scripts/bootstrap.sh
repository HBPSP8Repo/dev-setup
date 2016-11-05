#!/bin/bash

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

ROOT=$(get_script_dir)
cd $ROOT
SUDO="sudo"
if [ ! -z "$WERCKER_STEP_ID" ]; then
  SUDO=""
fi
[ -x /usr/local/bin/ansible ] || [ -x /usr/bin/ansible ] || (

  # Install Ansible
  [ -x /usr/bin/add-apt-repository ] && (
    $SUDO add-apt-repository ppa:ansible/ansible
    $SUDO apt-get update
    $SUDO apt-get install -y ansible
  ) || (
    $SUDO apt-get install -y git python-setuptools python-yaml python-jinja2 python-paramiko python-keyczar
    $SUDO apt-get install -y python-pip || $SUDO -H easy_install pip
    $SUDO -H pip install -r requirements.txt
  )
)

if [ "$1" != "--skip-git-crypt" ]; then
  [ -x /usr/bin/git ] || $SUDO apt-get install -y git

  [ -x /usr/bin/git-crypt ] || (
    echo "Please enter the sudo password for this local computer to install git-crypt"
    ansible-playbook --ask-become-pass -i ../../envs/install/etc/ansible ../playbooks/ansible-install.yml
  )
fi
