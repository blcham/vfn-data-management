#!/bin/bash


### DEFAULTS ###
APPEND=true
CONTENT_TYPE='text/turtle'
#CONTENT_TYPE='application/rdf+xml'
#CONTENT_TYPE='text/x-nquads'
#CONTENT_TYPE='application/ld+json'

function print_usage() {
	  echo "Rdf4j server deploy script."
          echo "Parameters: "
          echo -e "\t-R -- replace content of GRAPH_IRI (appends by default)"
          echo -e "\t-C CONTENT_TYPE -- content type of input FILES, i.e. text/turtle (default), application/rdf+xml ..."
          echo "Usage: "
          echo -e "\t$0 -R -C <CONTENT_TYPE> -s <RDF4J_SERVER> -r <REPO_ID> -c <GRAPH_IRI> <FILES>"
          echo "Examples: "
          echo -e "\tEXAMPLE-1 (append context): $0 -s http://onto.mondis.cz/openrdf-RDF4J -r ontomind_owlim -c http://onto.mondis.cz/resource/mdr-1.0-SNAPSHOT-temporary mdr.owl" 
          echo -e "\tEXAMPLE-2 (replace context): $0 -R -C 'text/turtle' -s http://onto.fel.cvut.cz/rdf4j-server -r test -c http://vfn.cz/ontologies/fertility-saving-study study-model.ttl"
	  echo -e "\tEXAMPLE-3 (replace repository): $0 -R -C 'text/x-nquads' -s http://onto.fel.cvut.cz/rdf4j-server -r test fss-study-formgen.ng"
}

if [ "$#" -eq 0 ]; then
	print_usage
        exit
fi


while getopts "h:s:r:c:RC:" arg; do
      case $arg in
        h)
	  print_usage
          exit 0
          ;;
        s)
          RDF4J_SERVER=$OPTARG
          ;;
        r)
          REPOSITORY=$OPTARG
          ;;
        c)
          GRAPH=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "<$OPTARG>")
          ;;
	R)
	  APPEND=false 
	  ;;
	C)
	  CONTENT_TYPE=$OPTARG
	  ;;
      esac
done

shift $(($OPTIND-1))
FILES=$@

REPOSITORY_URL=$RDF4J_SERVER/repositories/$REPOSITORY

echo "INFO: *** DEPLOYING ***"
echo "INFO:  destination server:  $RDF4J_SERVER"
echo "INFO:    - repository $REPOSITORY"
echo "INFO:    - graph $GRAPH"
echo "INFO:    - files $FILES"

if [ "$APPEND" = false ] ; then
   echo "INFO: *** CLEARING THE GRAPH ***"
   TEMP_FILE=`tempfile`
   QUERY_PARAMS="context=$GRAPH"
   if [ ! "$GRAPH" ]; then QUERY_PARAMS= ;  fi
   curl $REPOSITORY_URL/statements?$QUERY_PARAMS -v -X DELETE &> $TEMP_FILE
   cat $TEMP_FILE | grep "HTTP/1.1 204" &>/dev/null && echo 'INFO:  clearing graph was sucessfull'  
   cat $TEMP_FILE | grep "HTTP/1.1 204" &>/dev/null || ( echo 'ERROR:  clearing graph failed. Output of the process : '; cat $TEMP_FILE )
fi 

echo "INFO: *** SENDING DATA ***"
for FILE in $FILES
do
   echo INFO: " -- sending $FILE";
   TEMP_FILE=`tempfile`
   QUERY_PARAMS="context=$GRAPH"
   if [ ! "$GRAPH" ]; then QUERY_PARAMS= ;  fi
  
   wget --method POST --header "Content-Type: $CONTENT_TYPE"  --body-file="$FILE"  --output-document - --server-response $REPOSITORY_URL/statements?$QUERY_PARAMS  &> $TEMP_FILE
   cat $TEMP_FILE | grep "HTTP/1.1 204" &>/dev/null && echo 'INFO:  sending data was sucessfull'  
   cat $TEMP_FILE | grep "HTTP/1.1 204" &>/dev/null || ( echo 'ERROR:  sending data failed. Output of the process : '; cat $TEMP_FILE )
done;

echo "INFO: *** CHECKING ***"
TEMP_FILE=`tempfile`
GRAPH_SIZE=`curl $REPOSITORY_URL/size 2> $TEMP_FILE`
echo "INFO:  size of the new graph is $GRAPH_SIZE"

