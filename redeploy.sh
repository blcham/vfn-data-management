#!/bin/bash
# ./redeploy.sh
#   - redeploys all services of the assembly line
# ./redeploy.sh <SERVICE>
#   - redeploys <SERVICE>, e.g. ./redeploy dm-ofn-record-manager
# ENV_FILE=.env.development ./redeploy.sh <SERVICE>
#   - redeploys <SERVICE>, e.g. ./redeploy dm-ofn-record-manager, using the properties from the .env.development file
DIR=$(dirname $(readlink -m $0))
LOG_FILE=./logs/redeploy.log

function log_info() {
	TIMESTAMP="`date +%F--%H:%M:%S`"
	echo INFO: $TIMESTAMP -- $* >> $LOG_FILE
}

cd $DIR
log_info "Redeploy script called with variable ENV_FILE=$ENV_FILE."
log_info "Redeploy script called with parameters '$*'."
git pull

ENV_FILE="${ENV_FILE:-.env.production}"
SERVICE="${1:-}"
cat /etc/nginx/conf.d/gh-token | docker login -u jakubklimek --password-stdin docker.pkg.github.com
#cat github.auth | docker login -u blcham --password-stdin docker.pkg.github.com
if [ "$SERVICE" = "dm-prepared-forms" ]; then
	# TODO not systematic approach
	log_info "Updating from prepared forms ..."

	# execute update on background so webhook won't time-out
	. ./bin/set-env.sh $ENV_FILE
	./bin/update-scripts.sh
	./bin/deploy-prepared-forms.sh
	exit
fi

. ./bin/set-env.sh $ENV_FILE # temporaly added
log_info "Updating scripts ..."
./bin/update-scripts.sh # temporaly added
log_info "Deploying prepared forms ..."
./bin/deploy-prepared-forms.sh # temporaly added


export PATH="/usr/local/bin/:/bin"	# workaround to not be able to run docker compose
log_info "Running docker-compose pull $SERVICE ..."
/usr/local/bin/docker-compose --env-file=$ENV_FILE pull $SERVICE
log_info "Running docker-compose up $SERVICE ..."
/usr/local/bin/docker-compose --env-file=$ENV_FILE up --force-recreate --build -d $SERVICE


if [ "$SERVICE" = "dm-s-pipes-engine" -o -z "$SERVICE" ]; then
	log_info "Updating s-pipes-engine module ..."

	# execute update on background so webhook won't time-out
#	( . ./bin/set-env.sh $ENV_FILE;  ./bin/update-scripts.sh; ./bin/deploy-all-forms.sh ) & 	# temporaly removed
fi


log_info "Redeploy script returns sucessfully."

