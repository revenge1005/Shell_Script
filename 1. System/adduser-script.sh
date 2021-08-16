#!/bin/bash

# 사용자 계정 및 패스워드가 입력되었는지 확인
if [[ -n $1 ]] && [[ -n $2 ]]
then
        UserList=($1)
        Password=($2)

        # 사용자 계정 생성
        for (( i=0; i < ${#UserList[@]}; i++ ))
        do
                if [[ $(cat /etc/passwd | grep ${UserList[$i]} | wc -l) == 0 ]]
                then
                        useradd ${UserList[$i]}
                        echo ${Password[$i]} | passwd ${UserList[$i]} --stdin
                        # 우분투 환경
                        # echo ${UserList[$i]}:${Password[$i]} | chpasswd
                else
                        echo "This User ${UserList[$i]} is Existing."
                fi
        done
else
        # 사용자 계정과 패스워드를 입력하라는 메시지
        echo -e 'Please input User id Password. \nUsage: adduser-script.sh "user01 user02" "pw01 pw02"'
fi
