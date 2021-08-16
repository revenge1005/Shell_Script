#!/bin/bash

for server in "node-ubuntu node-centos"
do
        echo $server
        ssh root@$server "useradd $1"
        ssh root@$server "echo $2 | passwd $1 --stdin"
        # ssh root@$server "echo $1:$2 | chpasswd"
done
