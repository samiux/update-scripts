#!/bin/bash

input="phishings.txt"
n=100000000
x=184

while IFS= read -r domain; do
	printf 'drop dns any any -> any any (msg: "DNS Phishing %s"; dns.query; content:"%s"; nocase; pcre:"/%s$/"; priority:1; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
	printf 'drop http any any -> any any (msg: "HTTP Phishing %s"; http.uri; content:"%s"; nocase; pcre:"/%s$/"; priority:1; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
	printf 'drop tls any any -> any any (msg: "SNI Phishing %s"; tls.sni; content:"%s"; nocase; pcre:"/%s$/"; priority:1; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
	printf 'drop tls any any -> any any (msg: "SSL Phishing %s"; tls.cert_subject; content:"%s"; nocase; pcre:"/%s$/"; priority:1; classtype:policy-violation; sid: %d; rev:%s;)\n' "$domain" "$domain" "$domain" "$n" "$x" >> malicious.rules
	n=$((n+1))
done < "$input"
