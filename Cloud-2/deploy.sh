#!/bin/bash
cd $HOME
git clone git@github.com:express42/reddit.git
cd $HOME/reddit
touch test_file
bundle install
puma -d