#!/bin/bash
set -e
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

MONGO_RS_1=`ping -c 1 mongo-rs0-1 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
MONGO_RS_2=`ping -c 1 mongo-rs0-2 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
MONGO_RS_3=`ping -c 1 mongo-rs0-3 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
ES=`ping -c 1 elasticsearch | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`


/scripts/wait-until-mongodb-started.sh


################################
# Write to MongoDB

echo "================================="
echo "Writing to MongoDB"
mongo ${MONGO_RS_1} <<EOF
  use harvester-test
  rs.config()
  var p = {title: "Breaking news", content: "It's not summer yet."}
  db.entries.save(p)
EOF


echo "================================="
echo "Fetching data from Mongo"
echo curl http://${MONGO_RS_1}:28017/harvester-test/entries/?limit=10
curl http://${MONGO_RS_1}:28017/harvester-test/entries/?limit=10
echo "================================="


printf "\nReading from Elasticsearch (waiting for the transporter to start)\n\n"
sleep 4
################################
# Read from Elasticsearch

printf "\nWaiting for the transporter to start\n\n"

until test -f /scripts/.TRANSPORTER_STARTED; do
  printf '.'
  sleep 1
done
printf "\nTransporter started \n\n"

printf "\nReading from Elasticsearch\n\n"
curl -XGET "http://${ES}:9200/harvester-test/_search?pretty&q=*:*"


echo "================================="
echo "DONE"
