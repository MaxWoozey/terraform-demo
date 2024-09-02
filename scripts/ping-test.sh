#!/bin/bash

sudo apt-get update
sudo apt-get install -y curl

# Next ping ip
CURRENT_VM_NAME=$1
NEXT_VM_NAME=$2
NEXT_VM_IP=$3
CURRENT_VM_IP=$(hostname -I | awk '{print $1}')

# Ping it
echo "${CURRENT_VM_IP} Pinging ${NEXT_VM_IP}"
# Ping it and get the result
PING_RESULT=$(ping -c 4 ${NEXT_VM_IP} > /dev/null; echo $?)

# Determine the result
if [ ${PING_RESULT} -eq 0 ]; then
  RESULT="pass"
else
  RESULT="fail"
fi


SAS_TOKEN=$4

STORAGE_ACCOUNT_NAME="bonusmaxbos"
CONTAINER_NAME="results"
BLOB_NAME="ping_result_${CURRENT_VM_IP}.txt"
FILE_PATH="/tmp/ping_result"

# Write result to file
echo "Ping to ${NEXT_VM_NAME}(${NEXT_VM_IP}) from ${CURRENT_VM_NAME}(${CURRENT_VM_IP}) ${RESULT}" > ${FILE_PATH}

UPLOAD_URL="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}/${BLOB_NAME}?${SAS_TOKEN}"

# Upload the file
curl -X PUT -T ${FILE_PATH} -H "x-ms-blob-type: BlockBlob" "${UPLOAD_URL}"
