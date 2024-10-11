#!/usr/bin/bash
whoami
. ~/.bashrc
pyenv versions

echo " #### At first the python version is: #### "
python3 -V
pyenv global 3.8.9
python3 -m pip install --user virtualenv
source myenv/bin/activate

echo "#### Second python version is: ####"
python3 -V

echo "#### Install requirements ####"

echo "#### The current working dir is ####:"
pwd
