#!/bin/bash

set -x

LOG=petclinic.log
java -ea -Dappmap.debug -javaagent:appmap.jar -jar target/spring-petclinic*.jar &> $LOG &
JVM_PID=$!

export WS_URL="http://localhost:8080"
export OUTPUT_DIR="$1"
export APPMAP_FILE_SUFFIX=".appmap.json"
export IGNORE_RESPONSE_BODY="-o /dev/null"

mkdir -p $OUTPUT_DIR

printf 'getting set up'
while [ -z "$(curl -sI "${WS_URL}" | grep 'HTTP/1.1 200')" ]; do
    if ! kill -0 "${JVM_PID}" 2> /dev/null; then
        printf '. failed!\n\nprocess exited unexpectedly:\n'
        cat $LOG
        exit 1
    fi
    printf '.'
    sleep 2
done
printf ' done!\n'

_curl() {
    curl -H 'Accept: application/json' "$@"
}

start_recording() {
    unset output
    _curl -sXPOST "${WS_URL}/_appmap/record"
}

stop_recording() {
    output=$(_curl -sXDELETE ${WS_URL}/_appmap/record)
    if [[ ! "$#" -eq "1" ]]; then
        echo "Wrong number of arguments, $# ($@)"
        exit 1
    fi
    scenario=${1//_/ }
    output=$(jq -c --arg scenario "$scenario"  '.metadata["name"] = $scenario' <<< $output)
    echo $output > $OUTPUT_DIR/${@}$APPMAP_FILE_SUFFIX
}

# using different resource ids for all http requests to avoid hibernate's first-level caching and capture as many events as possible.
record_maps(){

    start_recording
    _curl -sXPOST ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners/new" --data "firstName=John&lastName=Doe&address=Ample+Street&city=London&telephone=1234567891"
    stop_recording Create_Owner
    
    OWNER_ID=10
    start_recording
    _curl -sXPOST ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners/${OWNER_ID}/edit" --data "firstName=Smith&lastName=Doe&address=Green+Street&city=London&telephone=1234567890"
    stop_recording Update_Owner
    
    OWNER_ID=9
    start_recording
    _curl -sXPOST ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners/${OWNER_ID}/pets/new" --data "id=&name=Test&birthDate=2015-09-09&type=lizard"
    stop_recording Create_Pet_For_Owner
    
    OWNER_ID=8
    PET_ID=10
    start_recording
    _curl -sXPOST ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners/${OWNER_ID}/pets/${PET_ID}/edit" --data "id=&name=Shelja&birthDate=2019-09-09&type=lizard"
    stop_recording Update_Pet_For_Owner
    
    OWNER_ID=7
    PET_ID=9
    start_recording
    _curl -sXPOST ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners/${OWNER_ID}/pets/${PET_ID}/visits/new" --data "date=2020-09-12&description=routine+check+up&petId=${PET_ID}"
    stop_recording Create_Visit_For_Pet

    start_recording
    _curl -sXGET ${IGNORE_RESPONSE_BODY} "${WS_URL}/vets.html"
    stop_recording Get_All_Vets

    start_recording
    _curl -sXGET ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners?lastName=Doe"
    stop_recording Get_All_Owners

    OWNER_ID=4
    start_recording
    _curl -sXGET ${IGNORE_RESPONSE_BODY} "${WS_URL}/owners/${OWNER_ID}"
    stop_recording Get_Owner

    start_recording
    _curl -sXPOST ${IGNORE_RESPONSE_BODY} "${WS_URL}/oups"
    stop_recording Invalid_Path
}

record_maps

kill ${JVM_PID}
wait ${JVM_PID}
cat $LOG
