#!/bin/bash
# ./redeploy.sh
#   - redeploys all services of the assembly line
# ./redeploy.sh <SERVICE>
#   - redeploys <SERVICE>, e.g. ./redeploy dm-ofn-record-manager
# ENV_FILE=.env.development ./redeploy.sh <SERVICE>
#   - redeploys <SERVICE>, e.g. ./redeploy dm-ofn-record-manager, using the properties from the .env.development file
DIR=$(dirname $(readlink -m $0))
LOG_FILE=./logs/redeploy.log
cd $DIR
echo "INFO: `date +%F-%H:%M:%S` -- redeploy script called with variable ENV_FILE=$ENV_FILE." >> $LOG_FILE
echo "INFO: `date +%F-%H:%M:%S` -- redeploy script called with parameters '$*'." >> $LOG_FILE
git pull

ENV_FILE="${ENV_FILE:-.env.production}"
SERVICE="${1:-}"
cat /etc/nginx/conf.d/gh-token | docker login -u jakubklimek --password-stdin docker.pkg.github.com
#cat github.auth | docker login -u blcham --password-stdin docker.pkg.github.com
if [ "$SERVICE" = "dm-prepared-forms" ]; then
	# TODO not systematic approach
	echo "INFO: `date +%F-%H:%M:%S` -- updating from prepared forms ..." >> $LOG_FILE

	# execute update on background so webhook won't time-out
	. ./bin/set-env.sh $ENV_FILE
	./bin/update-scripts.sh
	./bin/deploy-prepared-forms.sh
	exit
fi

. ./bin/set-env.sh $ENV_FILE # temporaly added
./bin/update-scripts.sh # temporaly added
./bin/deploy-prepared-forms.sh # temporaly added


echo "Deploying $SERVICE" | tee >> $LOG_FILE
docker-compose --env-file=$ENV_FILE pull $SERVICE
echo "Pulled $SERVICE" | tee >> $LOG_FILE
docker-compose --env-file=$ENV_FILE up --force-recreate --build -d $SERVICE
echo "Restarted $SERVICE" | tee >> $LOG_FILE


if [ "$SERVICE" = "dm-s-pipes-engine" -o -z "$SERVICE" ]; then
	echo "INFO: `date +%F-%H:%M:%S` -- updating s-pipes-engine module ..." >> $LOG_FILE
	
	# execute update on background so webhook won't time-out
#	( . ./bin/set-env.sh $ENV_FILE;  ./bin/update-scripts.sh; ./bin/deploy-all-forms.sh ) & 	# temporaly removed
fi

