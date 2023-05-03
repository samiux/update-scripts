#!/bin/bash

sort phishing.txt | uniq > phishings.txt

while IFS= read -r line; do echo -n $line | base64 -w 1000; done < phishings.txt > domains_phishing.list

echo "Finished!  Upload domains_phishing.list and phishings.txt."
