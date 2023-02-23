#!/bin/bash

input="malicious.url"
n=100000000
x=122

while IFS= read -r domain; do
	printf 'drop dns any any -> any any (msg: "DNS %s"; dns.query; content:"%s"; nocase; pcre:"/%s$/"; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
	printf 'drop http any any -> any any (msg: "HTTP %s"; http.uri; content:"%s"; nocase; pcre:"/%s$/"; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
	printf 'drop tls any any -> any any (msg: "SNI %s"; tls.sni; content:"%s"; nocase; pcre:"/%s$/"; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
	printf 'drop tls any any -> any any (msg: "SSL %s"; tls.cert_subject; content:"%s"; nocase; pcre:"/%s$/"; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
done < "$input"
