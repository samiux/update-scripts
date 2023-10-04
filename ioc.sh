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

wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/fake-googlebots.list -O fake-googlebots.txt

sort fake-googlebots.txt | uniq > a
cp a fake-googlebots.txt

sed -e 's/$/,1,10/' -i fake-googlebots.txt

cp fake-googlebots.txt fake-googlebots.blacklist

wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-ip-addresses.list -O bad-ip-addresses.txt

sort bad-ip-addresses.txt | uniq > a
cp a bad-ip-addresses.txt

sed -e 's/$/,1,10/' -i bad-ip-addresses.txt

cp bad-ip-addresses.txt bad-ip-addresses.blacklist

wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-referrers.list -O bad-referrers.txt

sort bad-referrers.txt | uniq > a
cp a bad-referrers.txt

while IFS= read -r line; do echo -n $line | base64 -w 1000; done < bad-referrers.txt > bad-referrers.list

cat iocs_list.json  | jq -c -r '.data[] | select( .ioc_type == "sha256_hash") | .ioc' > sha256_iocs.list

echo "Check if samiux.github.io is on list or not ..."
cat iocs_list.json | grep 185.199.110.153
cat bad-ip-addresses.blacklist | grep 185.199.110.153

echo " Finished!  Upload domains.txt, domains_iocs.list, sha256_iocs.list, reputation.blacklist, fake-googlebots.blocklist, bad-ip-addresses.blacklist, bad-referrers.txt and bad-referrers.list."
