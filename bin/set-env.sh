#!/bin/bash

ENV_FILE=$1

export $(cat $ENV_FILE | sed 's/\s*#.*//g' | xargs)
