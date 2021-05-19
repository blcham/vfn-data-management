#!/bin/bash

if [ ! "$#" -eq 1 ]; then
      echo Construct form for specified ENTITY_NAME. 
      echo Usage :  $0 "ENITY_NAME" 
      echo Example:
      echo "  $0 aktuality"
      echo "  $0 sportoviště"
      echo "  $0 turistické-cíle"
      echo "  $0 události"
      exit
fi

#. ./bin/set-env.sh

RDF4J_SERVER=http://dm-rdf4j:8080/rdf4j-server
SPIPES_SERVICE=http://localhost:8889/s-pipes
OUTPUT_DIR=./target/generated-forms
#SGOV_SERVICE_URL=https://graphdb.onto.fel.cvut.cz/repositories/kodi-slovnik-gov-cz

ENTITY_NAME=$1

echo "==================================="
echo "INFO: s-pipes url $SPIPES_SERVICE"
echo "INFO: rdf4j-server url $RDF4J_SERVER"
echo "INFO: sgov service url form $SGOV_SERVICE_URL"
echo "INFO: entity name $ENTITY_NAME"
echo "==================================="

mkdir -p $OUTPUT_DIR

FILE=$OUTPUT_DIR/form-$ENTITY_NAME.json
FORM_TEMPLATE="https://slovník.gov.cz/datový/$ENTITY_NAME/form-template"

curl -v -G -H 'Accept: text/json, text/plain, */*' \
	--data-urlencode "_pId=deploy-sample" \
	--data-urlencode "sgovRepositoryUrl=$SGOV_SERVICE_URL" \
	--data-urlencode "formGenRepositoryUrl=$RDF4J_SERVER/repositories/ofn-record-manager-formgen" \
	--data-urlencode "recordGraphId=http://vfn.cz/ontologies/study-manager/formGen-sample" \
	--data-urlencode "repositoryUrl=$RDF4J_SERVER/repositories/ofn-record-manager-app" \
	--data-urlencode "_DformTemplate=$FORM_TEMPLATE" \
	--data-urlencode "_DexecutionId=0" \
	"$SPIPES_SERVICE/service" > $FILE
