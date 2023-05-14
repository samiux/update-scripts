#!/bin/bash

input="malicious.txt"
n=100000000
x=193

while IFS="," read -r domain urlcontent; do
	printf 'drop http any any -> any any (msg: "Malicious URL %s"; http.header; content:"%s"; http.uri; content:"%s"; nocase; priority:1; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain$urlcontent" "$domain" "$urlcontent" "$n" "$x" >> malicious.rules
	n=$((n+1))
done < "$input"
