#!/bin/bash

# Ping each VM in a round-robin fashion
for i in $(seq 0 2); do
  for j in $(seq 0 2); do
    if [ $i -ne $j ]; then
      echo "VM$i pinging VM$j"
      ping -c 4 $(az vm show --resource-group example-resources --name example-vm-$j --query "privateIps" -o tsv)
    fi
  done
done
