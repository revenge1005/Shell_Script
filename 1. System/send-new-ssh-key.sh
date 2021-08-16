#!/bin/bash


# << SSH Key를 여러 서버에 복사할 때 >>
# 시스템을 구축하고, 애플리케이션을 설치할 경우 해당 애플리케이션을 사용하는 서버들끼리는
# SSH 접속을 할 때 패스워드 대신 SSH 키를 주로 사용하며, 그리고 SSH 공개키를 복사하여
# 패스워드 입력 없이 서버에 접속한다.

# 이와 같은 경우에도 서버가 한 두 대라면 상관이 없지만, 3 대 이상이면 매우 번거로운 일이
# 발생하므로, 간단하게 스크립트를 만들어 사용하면 쉽고 빠르게 SSH 공개키를 여러 서버에
# 복사할 수 있다.

# ssh-copy-id를 사용할 경우 remote 서버로 패스워드 인증 없이 접속이 가능하며,
# 이후 ssh server "script" 형태로 쉘 스크립트를 원격으로 실행할 수 있다.
# 하지만 최초의 SSH 키를 복사하는 과정에서는 스크립트로 처리하기가 어려운데,
# 이를 위해서 expect를 이용하는 방법이 있다.


# SSH 키 경로, 공개키 경로를 변수에 저장
servers="node1 node2"
sshKey="$HOME/.ssh/id_rsa"
sshPub="$HOME/.ssh/id_rsa.pub"
id="choi"
pw="1234"

# SSH Key 생성
ssh-keygen -N "" -t rsa -f $sshKey -q

# 생성된 SSH key를 해당 서버에 복사
for server in $servers
do
  echo -e "\033[32m" \>\> $server public key copy . . ."\033[0m"
  /usr/bin/expect <<EOE
  spawn bash -c "ssh-copy-id -i ${sshPub} ${id}@${server}"
  expect {
        "yes/no" { send "yes\r"; exp_continue }
        -nocase "password" { send "${pw}\r"; exp_continue }
  }
EOE
done

echo -e "\033[32m"Command Success . . ."\033[0m"
