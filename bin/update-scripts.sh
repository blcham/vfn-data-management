#!/bin/bash

SCRIPTS_DIR=./scripts

SPIPES_MODULES=s-pipes-modules
SPIPES_MODULES_GIT_REPO=https://kbss.felk.cvut.cz/gitblit/r/$SPIPES_MODULES

SGOV_SFORMS=sgov-forms
SGOV_FORMS_GIT_REPO=https://github.com/opendata-mvcr/$SGOV_SFORMS

mkdir -p $SCRIPTS_DIR
cd $SCRIPTS_DIR

if [ ! -d ${SPIPES_MODULES} ]; then
	git clone ${SPIPES_MODULES_GIT_REPO}
else 
	cd ${SPIPES_MODULES}	
	git pull
	cd
fi

if [ ! -d ${SGOV_SFORMS} ]; then
	git clone ${SGOV_FORMS_GIT_REPO}
else 
	cd ${SGOV_SFORMS}	
	git pull
	cd
fi
