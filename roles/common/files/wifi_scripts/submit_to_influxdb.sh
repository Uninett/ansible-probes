#!/bin/bash

. ${SCRIPT_DIR}influxdb.credentials

curl -o /dev/null -w "%{http_code}" -s -i -XPOST "http://${DB_USERNAME}:${DB_PASSWORD}@${DB_SERVER}/write?db=${DB_NAME}" --data-binary "$1"
