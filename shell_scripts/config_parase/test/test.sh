#!/bin/sh

source ../ini_prase.sh

result=$(GetIniKey "test.ini" "server:ip")
echo $result
