#!/bin/bash
test -z "${DEBUG}" || set -o xtrace
set -o errexit

nginx -V
nginx -t
nginx -g 'daemon off;' &
nginx_pid=$!

# capture packets containing `P` for `POST /...`
tcpdump -i any -nlA port 80 and ip[52]=80 &
tcpdump_pid=$!

sleep 2 # let background processes initialize

prefix=AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz # 52 bytes

# this will succeed showing unaltered POST body beginning:
# AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz^^
data="${prefix}$(dd if=/dev/zero ibs=8140 count=1 2>/dev/null | tr '\000' '^')"
echo "Size of request body: ${#data}" # expect 8192 (ie 8kiB)
echo -n "${data}" | nghttp https://127.0.0.1/with_auth_request -d - >/dev/null

# this will show a POST body with 32 corrupted bytes beginning:
# ????????????????????????????????QqRrSsTtUuVvWwXxYyZz^^
data="${prefix}$(dd if=/dev/zero ibs=8141 count=1 2>/dev/null | tr '\000' '^')"
echo "Size of request body: ${#data}" # expect 8193 (ie 8kiB + 1)
echo -n "${data}" | nghttp https://127.0.0.1/with_auth_request -d - >/dev/null

sleep 2 # let tcpdump display the captured packets

test -z "${DEBUG}" || cat /var/log/nginx/*.log

kill "${nginx_pid}" "${tcpdump_pid}"
wait
