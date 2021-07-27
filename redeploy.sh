#!/bin/bash
# ./redeploy.sh
#   - redeploys all services of the assembly line
# ./redeploy.sh <SERVICE>
#   - redeploys <SERVICE>, e.g. ./redeploy dm-ofn-record-manager
# ENV_FILE=.env.development ./redeploy.sh <SERVICE>
#   - redeploys <SERVICE>, e.g. ./redeploy dm-ofn-record-manager, using the properties from the .env.development file
DIR=$(dirname $(readlink -m $0))
cd $DIR
echo "INFO: `date +%F-%H:%M:%S` -- redeploy script called with variable ENV_FILE=$ENV_FILE." >> redeploy.log
echo "INFO: `date +%F-%H:%M:%S` -- redeploy script called with parameters '$*'." >> redeploy.log
git pull

ENV_FILE="${ENV_FILE:-.env.production}"
SERVICE="${1:-}"
cat /etc/nginx/conf.d/gh-token | docker login -u jakubklimek --password-stdin docker.pkg.github.com
#cat github.auth | docker login -u blcham --password-stdin docker.pkg.github.com
echo "Deploying $SERVICE"
docker-compose --env-file=$ENV_FILE pull $SERVICE
echo "Pulled $SERVICE"
docker-compose --env-file=$ENV_FILE up --force-recreate --build -d $SERVICE
echo "Restarted $SERVICE"

if [ "$SERVICE" = "dm-s-pipes-engine" ]; then
	echo "INFO: `date +%F-%H:%M:%S` -- updating s-pipes-engine module." >> redeploy.log
	./bin/update-scripts.sh
	. ./bin/set-env.sh $ENV_FILE
	./bin/deploy-all-forms.sh
fi
