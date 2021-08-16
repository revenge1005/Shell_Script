#!/bin/bash

# 운영체제 타입 확인
ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

# 네트워크 정보를 사용자로부터 입력 받음
echo -e "\033[36m"=== Network Devices==="\033[0m"
ip a | grep '^[0-9]' | awk '{print $1" "$2}' | grep -v -e 'lo' -e 'v' -e 't'
read -p "Please input network interface: " net_name
read -p "Please input network ip(ex: 192.168.219.12/24): " net_ip
read -p "Please input network gateway: " net_gw
read -p "Please input network dns: " net_dns

# 하나라도 입력하지 않았을 경우 입력하라는 메시지 출력 후 스크립트 종료
if [[ -z $net_name ]] || [[ -z $net_ip ]] || [[ -z $net_gw ]] || [[ -z $net_dns ]]; then
    echo -e "\033[31m"You need to input network information. Please retry this script"\033[0m"
    exit
fi

# 운영체제가 페도라 계열일 경우 nmcli 명령을 이용하여 네트워크 설정
if [[ $ostype == "rhel fedora" ]]; then
    nmcli con mod $net_name ifname $net_name ipv4.address $net_ip ipv4.gateway $net_gw ipv4.dns $net_dns ipv4.method manual
    nmcli con up $net_name
    nmcli con reload $net_name
# 운영체제가 데비안 계열일 경우 netplan에 yaml 파일을 생성하여 네트워크 설정, 우부투는 18 버전 부터 netplan을 사용한다 그래서 netplan 기준으로 작성한 것이다.
elif [[ $ostype == "debian" ]]; then
    ip_chk=$(cat /etc/netplan/*.yaml | grep ens32 | wc -l)
    # 설정하고자 하는 IP로 설정 파일이 없을 경우 관련 네트워크 yaml 파일 생성
    if [ $ip_chk -eq 0 ]; then
        echo -e "\033[31m"Warning : No network configuration file exists, creating a new file."\033[0m"
        net_path="/etc/netplan/${net_name}.yaml"
    # 우분투는 버전마다 네트워크 설정 파일 이름이 다르다, 설정 파일이 존재하면 버전에 맞게 타겟 지정
    else
        os_version=$(cat /etc/*release | grep VERSION_ID | sed "s/VERSION_ID=//;s/\"//g")
        if [[ $os_version == "18.04" ]]; then
            echo -e "\033[36m"Ubuntu Version: 18.04 OK"\033[0m"
            net_path="/etc/netplan/50-cloud-init.yaml"
        elif [[ $os_version == "20.04" ]]; then
            echo -e "\033[36m"Ubuntu Version: 20.04 OK"\033[0m"
            net_path="/etc/netplan/00-installer-config.yaml"
        else
            echo -e "\033[31m"This ${net_name} is configured already."\033[0m"
            exit;
        fi
        cp ${net_path} ${net_path}.bak
    fi
    cat > ${net_path} << EOF
network:
    version: 2
    renderer: networkd
    ethernets:
        $net_name:
            dhcp4: no
            dhcp6: no
            addresses: [$net_ip]
            gateway4: $net_gw
            nameservers:
                addresses: [$net_dns]
EOF
    echo -e "\033[32m"cat ${net_path}"\033[0m"
    cat ${net_path}
    echo -e "\033[32m"apply netplan"\033[0m"
    netplan apply
fi