#!/bin/bash

input="malicious.url"

while IFS= read -r domain; do
	sleep 2
	RESULT=$(fping -r 1 $domain)

	if [[ $RESULT == *"alive"* ]]
	then
		echo "$domain is still alive!"
		printf $domain'\n' >> new_malicious.rules
	fi
done < "$input"
