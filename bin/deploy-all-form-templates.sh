#!/bin/bash

RDF4J_SERVER=http://localhost:8888/rdf4j-server
FORMGEN_REPOSITORY=ofn-record-manager-formgen

echo "==================================="
echo "INFO: rdf4j-server url $RDF4J_SERVER"
echo "INFO: formgen repository $FORMGEN_REPOSITORY"
echo "==================================="

CLEAR_REPOSITORY=false
TEMPLATES_DIR=./scripts/sgov-forms/config

if $CLEAR_REPOSITORY; then
	rdf4j-deploy-context.sh -R -C 'text/turtle' -s $RDF4J_SERVER -r $FORMGEN_REPOSITORY empty.ttl
fi

ls $TEMPLATES_DIR/d*-form-template.ttl  | while read FILE; do
	GRAPH="`cat $FILE | rdfpipe -  -i turtle -o nt | sed -n 's/ .*Ontology.*//p' | tr -d '<' | tr -d '>'`"
	if [ "$GRAPH" = "" ]; then
		echo "WARN: Unable to find ontology IRI in file \"$FILE\"."
		continue;
	fi
	rdf4j-deploy-context.sh -R -C 'text/turtle' -s $RDF4J_SERVER -r $FORMGEN_REPOSITORY -c $GRAPH $FILE $TEMPLATES_DIR/shared-form-template.ttl
done
