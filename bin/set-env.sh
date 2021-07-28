#!/bin/bash

ENV_FILE=$1

export $(cat $ENV_FILE | xargs)
