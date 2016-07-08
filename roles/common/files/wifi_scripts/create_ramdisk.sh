#!/bin/bash

# 1. argument: dir the tmpfs should be mounted to
# 2. argument: script dir

mount -o size=64M -t tmpfs none $1

rsync -a $2/ $1/ --exclude $1
