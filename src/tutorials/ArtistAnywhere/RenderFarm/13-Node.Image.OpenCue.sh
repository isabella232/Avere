#!/bin/bash

set -ex

if [ "$(cat /etc/os-release | grep 'CentOS-7')" ]; then
    yum -y install gcc
    yum -y install python-devel
    yum -y install epel-release
    yum -y install python-pip
elif [ "$(cat /etc/os-release | grep 'CentOS-8')" ]; then
    dnf -y install gcc
    dnf -y install python3-devel
fi

cd /usr/local/bin

downloadUrl='https://mediasolutions.blob.core.windows.net/bin/OpenCue/v0.4.95'

fileName='opencue-requirements.txt'
curl -L -o $fileName $downloadUrl/$fileName

fileName='opencue-pycue.tar.gz'
curl -L -o $fileName $downloadUrl/$fileName
tar -xzf $fileName

fileName='opencue-pyoutline.tar.gz'
curl -L -o $fileName $downloadUrl/$fileName
tar -xzf $fileName

fileName='opencue-rqd.tar.gz'
curl -L -o $fileName $downloadUrl/$fileName
tar -xzf $fileName

fileName='opencue-rqd.service'
curl -L -o $fileName $downloadUrl/$fileName

find . -type f -name *.pyc -delete
if [ "$(cat /etc/os-release | grep 'CentOS-7')" ]; then
    pip install --upgrade pip
    pip install --upgrade setuptools
    pip install --requirement 'opencue-requirements.txt' --ignore-installed
    cd pycue-*
    python setup.py install
    cd ../pyoutline-*
    python setup.py install
    cd ../rqd-*
    python setup.py install
elif [ "$(cat /etc/os-release | grep 'CentOS-8')" ]; then
    pip3 install --upgrade pip
    pip3 install --upgrade setuptools
    pip3 install --requirement 'opencue-requirements.txt' --ignore-installed
    cd pycue-*
    python3 setup.py install
    cd ../pyoutline-*
    python3 setup.py install
    cd ../rqd-*
    python3 setup.py install
fi
