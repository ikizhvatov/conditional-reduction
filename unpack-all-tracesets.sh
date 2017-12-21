#!/bin/bash

# Unpacks bzipped tarballs in all subdirectories

find . -type f -name *.tar.bz2 -execdir tar xjvf {} \;
