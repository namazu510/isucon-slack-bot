#!/bin/bash

mkdir tmp
wget https://github.com/matsuu/kataribe/releases/download/v0.3.0/linux_amd64.zip -O tmp/kataribe.zip
cd tmp
unzip kataribe.zip
mv kataribe ../

bundle install --path vendor/bundler
