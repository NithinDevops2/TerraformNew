#!/bin/bash

sudo update-alternatives --config 'java'
sudo yum install java-17-openjdk
java -version