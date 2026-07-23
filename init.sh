#!/bin/sh

git config --local core.hooksPath tools/git_hooks
make config
make config SIM=xsim
