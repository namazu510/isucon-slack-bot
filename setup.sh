#!/bin/bash

wget https://github.com/matsuu/kataribe/releases/download/v0.3.0/linux_amd64.zip kataribe.zip
unzip kataribe.zip

bundle install --path vendor/bundler
