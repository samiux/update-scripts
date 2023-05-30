#!/usr/bin/bash

curl -X POST https://threatfox-api.abuse.ch/api/v1/ -d '{ "query": "get_iocs", "days": 7 }' > iocs_list.json

cat iocs_list.json | jq -c -r '.data[] | select( .ioc_type == "domain") | .ioc' > domains.txt

sort domains.txt | uniq > a
cp a domains.txt

while IFS= read -r line; do echo -n $line | base64 -w 1000; done < domains.txt > domains_iocs.list

cat iocs_list.json | jq -c -r '.data[] | select( .ioc_type == "ip:port") | .ioc' | cut -d':' -f 1 > ips.txt

sort ips.txt | uniq > a
cp a ips.txt

sed -e 's/$/,1,10/' -i ips.txt

cp ips.txt reputation.blacklist

cat iocs_list.json  | jq -c -r '.data[] | select( .ioc_type == "sha256_hash") | .ioc' > sha256_iocs.list

echo " Finished!  Upload domains.txt, domains_iocs.list, sha256_iocs.list and reputation.blacklist."
