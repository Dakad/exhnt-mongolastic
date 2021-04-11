#!/bin/bash
set -ev

MONGO_RS_1=`ping -c 1 mongo-rs0-1 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
MONGO_RS_2=`ping -c 1 mongo-rs0-2 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`
MONGO_RS_3=`ping -c 1 mongo-rs0-3 | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`

echo "Waiting for startup.."
until curl http://${MONGO_RS_1}:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

echo curl http://${MONGO_RS_1}:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Started..."


echo SETUP.sh time now: `date +"%T" `
mongo --host ${MONGO_RS_1}:27017 <<EOF
   var rs_conf = {
        "_id": "rs0",
        "version": 1,
        "members": [
            {
                "_id": 0,
                "host": "${MONGO_RS_1}:27017",
                "priority": 2
            },
            {
                "_id": 1,
                "host": "${MONGO_RS_2}:27017",
                "priority": 0
            },
            {
                "_id": 2,
                "host": "${MONGO_RS_3}:27017",
                "priority": 0
            }
        ]
    };
    rs.initiate(rs_conf, { force: true });
    rs.reconfig(rs_conf, { force: true });
EOF
