#!/bin/bash
[[ $1 =~ .*yaml$ ]] && register_frontend.py update $1
