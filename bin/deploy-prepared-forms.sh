#!/bin/bash

RDF4J_SERVER=http://localhost:8888/rdf4j-server


./bin/rdf4j-deploy-context.sh -R -s $RDF4J_SERVER -r record-manager-formgen -c https://slovník.gov.cz/datový/turistické-cíle/form-template--sample-form scripts/sgov-forms/generated-forms/turistické-cíle.ttl
