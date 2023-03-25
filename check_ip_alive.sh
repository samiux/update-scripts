#!/bin/bash

input="reputation.blacklist"

while IFS= read -r domain; do
	sleep 2
	ip=$(echo $domain | cut -d',' -f 1)
	RESULT=$(fping -r 1 $ip)

	if [[ $RESULT == *"alive"* ]]
	then
		echo "$ip is still alive!"
		printf $domain'\n' >> new_reputation.blacklist
	fi
done < "$input"
