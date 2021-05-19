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

urlencode() {
    # urlencode <string>

    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

echo "==================================="
echo "INFO: s-pipes url $SPIPES_SERVICE"
echo "INFO: rdf4j-server url $RDF4J_SERVER"
echo "INFO: sgov service url form $SGOV_SERVICE_URL"
echo "INFO: entity name $ENTITY_NAME"
echo "==================================="

mkdir -p $OUTPUT_DIR

FILE=$OUTPUT_DIR/form-$ENTITY_NAME.json


FORM_TEMPLATE="https://slovník.gov.cz/datový/$ENTITY_NAME/form-template"


FT="`urlencode $FORM_TEMPLATE`"
S="`urlencode $RDF4J_SERVER`"
SGOV_SERVICE_URL_ENCODED="`urlencode $SGOV_SERVICE_URL`"

URL="$SPIPES_SERVICE/service?_pId=deploy-sample&sgovRepositoryUrl=$SGOV_SERVICE_URL_ENCODED&formGenRepositoryUrl=$S%2Frepositories%2Fofn-record-manager-formgen&recordGraphId=http%3A%2F%2Fvfn.cz%2Fontologies%2Fstudy-manager%2FformGen-sample&repositoryUrl=$S%2Frepositories%2Fofn-record-manager-app&_DformTemplate=$FT&_DexecutionId=0"

set -x

curl  -H 'Accept: text/json, text/plain, */*'  "$URL" > $FILE

set -x
