#!/bin/bash

# sed : 찾는 문자열을 바꿀 수 있는 명령어
# sed는 스트림 편집기이며, 스트림 편집기는 입력 스트림에서 텍스트 변환을 수행하는데 사용한다.
# 즉, 특정 문자열을 찾아 원하는 문자열로 변경하는 것뿐만 아니라, 범위를 지정하고 해당 범위의 문자열을 변경할 수도 있다.

## 기본 사용법 - 1
# sed [옵션] '어드레스 {명령어}' 대상파일
# [root@localhost ~]# cat /etc/ssh/sshd_config | grep '^PermitRoot'
# PermitRootLogin yes
# [root@localhost ~]# sed 's/PermitRoot/#PermitRoot/' /etc/ssh/sshd_config | grep '^#PermitRoot'
# #PermitRootLogin yes

## 기본 사용법 - 2
# sed [옵션] -f 스크립트파일 대상파일
# [root@localhost ~]# echo "s/PermitRootLogin/#PermitRootLogin/" > sed-script.txt
# [root@localhost ~]# sed -f sed-script.txt /etc/ssh/sshd_config | grep '^#PermitRoot'
# #PermitRootLogin yes

## 기본 사용법 - 3
# 명령어 | sed [옵션] '{스크립트}'
# [root@localhost ~]# cat /etc/ssh/sshd_config | sed -e 's/#PermitRoot/PermitRoot/' | grep '^PermitRoot'
# PermitRootLogin yes


########################################################################################################################################################


## 1) 어드레스 - 어드레스는 대상 파일에서 어떤 번위에 해당하며, 어드레스가 정의되지 않았을 경우에는 대상 파일 전체에서 특정 문자열을 찾거나 명령어를 수행
#                - 어드레스는 특정 라인일수도 있고, 정규 표현식과 같은 패턴일 수도 있으며 특정 라인부터 특정 패턴이 포함된 라인까지이거나 특정 패턴이 포함된
#                  라인부터 명시한 라인 수까지일 수도 있다.


[choi@localhost 06.Sed]$ cat hosts
# This is Sed Sample File
# We will test to replace from a-text to b-text.
# It was created by NaleeJang.

127.0.0.1   localhost

# Development
192.168.100.250 git.example.com
192.168.100.10  servera.example.com
192.168.100.11  dev.example.com

# Test

172.10.2.12 test1.example.com
172.10.2.13 test2.example.com

# Production
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com


### ex1) number 어드레스 - 명시된 숫자에 해당하는 라인을 의미, 5 다음에 있는 p는 print의 약자료 현재 어드레스에 의해 정의된 범위의 내용을 출력하라는 의미
[choi@localhost 06.Sed]$ sed -n '5 p' hosts
127.0.0.1   localhost


### ex2) first~step 어드레스 : 모두 숫자로 명시해야 하며, 첫 번째로 명시한 숫자는 숫자에 해당하는 라인을 의미하며, 두 번째 명시한 숫자는 첫 번째 명시한 
### 숫자에 해당하는 라인부터 두번째 명시한 숫자만큼 라인을 건너뛰라는 의미, = 기호는 현재 읽어들인 라인의 라인 번호를 출력하라는 의미
# 1 번째 라인부터 시작하여, 3라인마다 해당 라인 번호 출력
[choi@localhost 06.Sed]$ sed -n '1~3 =' hosts
1
4
7
10
13
16
19


### ex3) $ 어드레스 : 파일의 마지막 라인을 의미
# '$ ='는 마지막 라인의 라인 번호 출력을 의미
[choi@localhost 06.Sed]$ sed -n '$ =' hosts
20
# '$ p'는 마지막 라인의 내용을 출력하라는 의미
[choi@localhost 06.Sed]$ sed -n '$ p' hosts
122.10.10.33 service2.example.com


### ex4) /regexp/ 어드레스 - 라인 번호 외에도 정규표현식을 사용하여 어드레스틀 표현한다. 
### 다음과 같이 정규표현식을 사용하면 해당 패턴이 포함된 라인이 대상 범위가 된다.
# test와 숫자로 시작하는 문자열이 포함된 라인 출력
[choi@localhost 06.Sed]$ sed -n '/test[0-9].*/ p' hosts
172.10.2.12 test1.example.com
172.10.2.13 test2.example.com


### ex5) \cregexpc 어드레스 - 정규표현식을 표현할 때 슬래시(//) 사이에 표현할 수도 잇지만, 역슬레시(\)와 검색하고자 하는 문자열에 포함되지 않은
### 영문소문자 사이에 정규표현식을 표현할 수도 있다. 
# test와 숫조로 시작하는 문자열이 포한된 라인 출력
[choi@localhost 06.Sed]$ sed -n '\ctest[0-9].*c p' hosts
172.10.2.12 test1.example.com
172.10.2.13 test2.example.com


### ex6) 0,addr2 어드레스 - 첫 번째 라인부터 addr2가 포함된 라인까지가 대상범위가 되며, addr2는 정규표현식으로 표현된다.
# 1번째 라인부터 # Devel로 시작하는 문자열이 있는 라인까지 출력
[choi@localhost 06.Sed]$ sed -n '0,/^# Devel*/ p' hosts
# This is Sed Sample File
# We will test to replace from a-text to b-text.
# It was created by NaleeJang.

127.0.0.1   localhost

# Development


### ex7) addr2,+N - addr1은 정규표현식으로 표현하며, N은 숫자로 명시해야 한다.
### 정규표현식에 의해 일치하는 라인부터 명시한 숫자에 해당하는 라인을 더한 만큼이 명령어 수행 대상범위가 된다.
# # Devel로 시작하는 라인부터 아래 3줄까지 출력
[choi@localhost 06.Sed]$ sed -n '/^# Devel*/,+3 p' hosts
# Development
192.168.100.250 git.example.com
192.168.100.10  servera.example.com
192.168.100.11  dev.example.com


### ex8) addr1,~N - 명시한 숫자에 해당하는라인까지가 명령어 수행 대상범위가 된다.
# # Devel이 포함된 라인을 기준으로 3번째 라인까지 출력
[choi@localhost 06.Sed]$ sed -n '/^# Devel*/,~3 p' hosts
# Development
192.168.100.250 git.example.com
192.168.100.10  servera.example.com


########################################################################################################################################################


## 2) 명령어 


## 2-1) 0 or 1 어드레스 명령어
## 0 어드레스 명령어에는 라벨, 주석, 블록과 같이 파일 내용에 아무런 영향을 주지 않는 명령어와 문자열 추가,삽입,스크립트 종료, 파일 내용 추가와 같은 명령어들로
## 어드레스가 필요한 명령어가 있다.


:label      -> 라벨                                 #   i \test     -> 문자열 삽입
#comment    -> 주석                                 #   q           -> sed 스크립트 실행 종료
{...}       -> 블록                                 #   Q           -> sed 스크립트 실행 종료
=           -> 현재 라인번호출력                    #   r 파일명    -> 파일 내용 추가
a \text     -> 문자열 추가                          #   R 파일명    -> 파일의 첫 라인 추가


### ex1) :label, #comment, {...}, = 명령어
# /# Test/,+3 은 어드레스 범위로 # Test가 포함된 라인부터 3번째 라인까지가 대상범위이며, 해당 범위의 명령어들을 중괄호{}로 블록화하였다.
# 중괄호 안에 오는 명령어들은 현재 라인 번호를 출력하는 = 명령어와 #으로 시작하는 주석, 클론:으로 시작하는 라벨이 있다.
# 해당 스크립트를 실행하면 대상범위에 해당하는 라인 번호가 출력됨을 알 수 있다.
[choi@localhost 06.Sed]$ cat sed-script.txt
/# Test/,+3 {
=
# first label
:label1
}
[choi@localhost 06.Sed]$ sed -n -f sed-script.txt hosts
12
13
14
15


### ex2) a \text - 해당 어드레스 다음 라인에 명시한 문자열을 추가한다.
### sed에서 사용되는 명령어들은 한 라인에 한 명령어만 사용할 수 있으며, 여러 줄의 명령어를 사용하려면 중괄화{}로 블록을 만들어 주어야 한다.
# 172.10.2.3이 있는 다음 라인에 새 주소 172.10.2.14 추가해서 출력
[choi@localhost 06.Sed]$ sed -n '/172.10.2.13/ { a \
> 172.10.2.14 test3.example.com
> p }' hosts
172.10.2.13 test2.example.com
172.10.2.14 test3.example.com


### ex3) i \text - 해당 어드레스 이전 라인에 명시한 문자열을 삽입
# 172.10.2.3에 있는 라인 위에 새 주소 172.10.2.14 추가해서 출력
[choi@localhost 06.Sed]$ sed -n '/172.10.2.13/ { i \
172.10.2.14 test3.example.com
p }' hosts
172.10.2.14 test3.example.com
172.10.2.13 test2.example.com


### ex4) q 명령어 - 수행 중이던 스크립트를 종료할 때 사용하는 명령어
# a 명령에 의해 추가할 172.10.2.14 test3.example.com을 추가하지 않은채 추가할 텍스트만 출력하고 sed 실행 종료
[choi@localhost 06.Sed]$ sed -n '/172.10.2.13/ { a \
> 172.10.2.14 test3.example.com
> q
> p }' hosts
172.10.2.14 test3.example.com


### ex5) Q 명령어 
# 출력 조차하지 않고 바로 sed 수행을 종료
[choi@localhost 06.Sed]$ sed -n '/172.10.2.13/ { a \
172.10.2.14 test3.example.com
Q
p }' hosts


### ex6) r 파일명 - 앞에서 명시한 해당 어드레스 뒤에 명시한 파일로부터 해당 내용을 읽어 해당 내용을 추가한다.
# 추가할 IP 주소와 호스트명을 sed-read.txt에 저장하고, sed를 이용해 단일 어드레스인 172.10.2.13 뒤에 sed-read.txt를 선언하고 해당 내용을 출력하다록 하였다.
# 172.1.2.13이 포함된 라인 뒤에 파일 내용인 172.10.2.14 test3.example.com과 172.10.2.15 test4.example.com이 추가된 것을 확인
[choi@localhost 06.Sed]$ sed -n '/172.10.2.13/ { r sed-read.txt
> p }' hosts
172.10.2.13 test2.example.com
172.10.2.14 test3.example.com
172.10.2.15 test4.example.com


### ex7) R 파일명 - 해당 파일의 첫 번째 라인만 읽어 추가한다.
[choi@localhost 06.Sed]$ sed -n '/172.10.2.13/ { R sed-read.txt
> p }' hosts
172.10.2.13 test2.example.com
172.10.2.14 test3.example.com


## 2-2) 어드레스 범위 명령
## 특정 라인부터 특정 라인까지를 의미하며, 이런 어드레스를 허용하는 명령어들에는 문자열 변경, 삭제, 출력, 라벨 분기와 같은 명령어들이 있다.


b label                     -> 라벨을 호출함                                                
c \ text                    -> 앞에서 명시된 패턴이 포함된 라인을 text 문자열로 변경        
d D                         -> 앞에서 명시된 패턴 삭제                                      
h H                         -> 패턴 공간을 홀드 공간에 복사/추가
g G                         -> 홀드 공간을 패턴 공간에 복사/추가
l                           -> 입력된 데이터의 현재 라인 출력
l width                     -> 명시한 너비에 맞게 입력된 데이터의 현재 라인 출력

n N                         -> 입력된 데이터의 다음 라인을 복사/추가
p P                         -> 현재 패턴 공간 출력
s/regexp/replacement/       -> 정규표현식(regexp)에 해당하는 데이터를 그 다음 오는 데이터로 변경
t label / T label           -> 앞에서 선언된 명령어를 실행 후 라벨로 분기
w 파일명 / W 파일명         -> 명시한 파일에 현재 패턴 공간을 저장함
x                           -> 홀드와 패턴 공간의 콘텐츠를 교환
y/source/dest/              -> 패턴이 포함된 라인의 문자열(Source)을 dest 문자열로 변경


### ex1) b label - sed 명령어를 수행하다가 b label를 만나면 해당 라벨로 분기를 수행한다.
# sed-script1.txt를 보면 # Text가 포함된 라인부터 3줄까지가 어드레스 범위이며, 중괄호{} 사이의 블록에는 읽어들인 라인에 값이 없을 경우
# 다음 명령어인 문자열 변경을 수행하지 말고, label1이라는 라벨로 분기하라는 내용
[choi@localhost 06.Sed]$ cat sed-script1.txt
/# Test/,+3 {
# if input line is empty, doesn’t execute replacing
/^$/ b label1
s/[tT]est/dev/
: label1
p
}
# 이렇게 생성된 파일을 이용하여 sed를 수행하면 다음과 같이 Test나 test가 dev로 변경된 것을 확인할 수 있다.
[choi@localhost 06.Sed]$ sed -n -f sed-script1.txt hosts
# dev

172.10.2.12 dev1.example.com
172.10.2.13 dev2.example.com


### ex2) c \text - 앞에서 명시한 어드레스가 포함된 라인을 명시한 text로 변경하라는 의미
# service.e로 시작되는 문자열이 포함된 라인을 122.10.10.30 vip.service.example.com으로 변경하였음을 확인할 수 있다.
# sed 명령어 다음에 사용된 tail 명령어는 파일 내용이 길어 해당 내용을 마지막 4라인만 확인하기 위해 사용되었다.
[choi@localhost 06.Sed]$ sed '/service.e/ c \122.10.10.30 vip.service.example.com' hosts | tail -n4
# Production
122.10.10.30 vip.service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com


### ex3) d D - 앞에서 명시한 어드레스에 해당하는 문자열이 포함된 라인을 삭제한다.
### d - 뉴라인과 상관없이 해당 문자열이 포함된 라인을 삭제, D - 패턴공간의 뉴라인을 인식하여 해당 뉴라인까지만 삭제
# hosts의 문자열중 We will test to replace를 We will test to와 replace 사이에 뉴라인 \n을 추가하여 문자열 변경을 하였다.
# 그리고, text 포함된 라인을 삭제한 후 편집 내용을 출력해 보면 Web will로 시작ㅎ하는 라인이 모두 사라진 것을 확인할 수 있다.
[choi@localhost 06.Sed]$ sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
/test/ d
p }' hosts
# This is Sed Sample File
# It was created by NaleeJang.

# D 명령을 사용한 두번째 예제를 보면 Web will test to 까지만 삭제하고, 나머지 문자열을 삭제되지 않았음을 알 수 있다.
[choi@localhost 06.Sed]$ sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
/test/ D
p }' hosts
# This is Sed Sample File
replace from a-text to b-text.
# It was created by NaleeJang.


### ex4) h H - 홀드 버퍼의 내용을 패턴 버퍼로 복사
# Production을 Service로 변경한 후 홀드 버퍼의 내용을 패턴 버퍼로 복사하고 패턴 버퍼의 내용을 출력함
# 문자열 변경은 패턴 버퍼에서 수행헀고, 그 이후 홀드 버퍼를 패턴 버퍼로 복사했기 때문에 패턴 버퍼에서 변경됐던 문자열을 원래 문자열로 원복되었음을 알 수 있다.
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 {
s/Production/Service/
h
p }' hosts
# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com


### ex5) g G - 패턴 버퍼에 있는 내용을 홀드 버퍼로 복사
# 패턴 버퍼에서 Production을 Service로 변경하는 명령을 수행한 후 홀드 버퍼의 내용을 패턴 버퍼로 복사한다.
# 그리고 다시 패턴 버퍼에 122.10.10을 199.9.9로 변경한 후 패턴 버퍼 내용을 홀드 버퍼에 복사한다.
# 마지막으로 패턴 버퍼 내용을 출력한다.
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 {
> s/Production/Service/
> h
> s/122.10.10/199.9.9/
> g
> p }' hosts
# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com

# 대문자 H와 G를 사용할 경우 sed의 문자열 변경과정을 볼 수 있음
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 {
s/Production/Service/
H
s/122.10.10/199.9.9/
G
p }' hosts
# Service

# Service
199.9.9.31 service.example.com

# Service
122.10.10.31 service.example.com
199.9.9.32 service1.example.com

# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
199.9.9.33 service2.example.com

# Service
122.10.10.31 service.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com


### ex6) l - 현재 읽어들인 라인을 출력
# l 명령어는 패턴 버퍼의 내용을 출력하는 p 명령어와는 다르게 문자의 끝을 알리는 $ 기호와 같은 특수기호를 함께 출력
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 l' hosts
# Production$
122.10.10.31 service.example.com$
122.10.10.32 service1.example.com$
122.10.10.33 service2.example.com$


### ex7) l Width - width는 너비를 의미하는 숫자로, 명시한 숫자 만큼 라인의 너비를 보여준다.
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 l 20' hosts
# Production$
122.10.10.31 servic\
e.example.com$
122.10.10.32 servic\
e1.example.com$
122.10.10.33 servic\
e2.example.com$


### ex8) n N - 입력된 다음 라인을 복사
# 첫 번째 예제에서는 n 명령을 p 명령보다 먼저 선언하여 입력된 라인의 다음 라인을 복사한 후 출력을 수행했으므로, 복사된 값이 출려되었다.
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 {
> n
> p }' hosts
122.10.10.31 service.example.com
122.10.10.33 service2.example.com
# 두 번째 예제에서는 p 명령을 수행한 후 N 명령을 수행하여 입려된 라인을 출력했음을 알 수 있다.
[choi@localhost 06.Sed]$ sed -n '/Product/ ,+3 {
> p
> N }' hosts
# Production
122.10.10.32 service1.example.com


### ex9) p P - 패턴 공간의 내용을 그대로 출력
[choi@localhost 06.Sed]$ sed -n '0,/NaleeJang/ {
> s/We will test to replace/We will test to\nreplace/
> p }' hosts
# This is Sed Sample File
# We will test to
replace from a-text to b-text.
# It was created by NaleeJang.


### ex10) s/regexp/replacement/ - regexp라는 정규표현식과 일치하는 문자열을 replacement에서 명시된 문자열로 변경 
[choi@localhost 06.Sed]$ sed -n '0,/Nalee/ {
> s/^# //
> p }' hosts
This is Sed Sample File
We will test to replace from a-text to b-text.
It was created by NaleeJang.


### ex11) t lable / T lable - 명시한 라벨로 분기하는 명령어
# 해당 범위에 192.20.3이 있든 없든 label2로 분기하여 명령어 수행
[choi@localhost 06.Sed]$ sed -n '/# Test/ ,+3 {
> :label2
> s/172.10.2/192.20.3/
> /192.20.3/ t label2
> p }' hosts
# Test

192.20.3.12 test1.example.com
192.20.3.13 test2.example.com
# 해당 범위에 172.10.2가 없기 때문에 label2로 분기됨
sed -n '/# Test/ ,+3 {
:label
s/172.10.2/192.20.3/
/172.10.2/ T label
p }' hosts
# Test

192.20.3.12 test1.example.com
192.20.3.13 test2.example.com


### ex12) w W - 현재 패턴 내용을 파일로 저장
# w 명령을 사용하여 변경된 패턴 내용을 sed-w.txt에 저장해 해당 파일을 확인해보면 패턴 내용과 동일한 내용이 저장된 것을 확인할 수 있다.
[choi@localhost 06.Sed]$ sedn -n '0,/NaleeJang/ {
> s/We will test to replace/We will test to\nreplace/
> w sed-w.txt
> p }' hosts
bash: sedn: command not found
[choi@localhost 06.Sed]$ sed -n '0,/NaleeJang/ {
s/We will test to replace/We will test to\nreplace/
w sed-w.txt
p }' hosts
# This is Sed Sample File
# We will test to
replace from a-text to b-text.
# It was created by NaleeJang.
[choi@localhost 06.Sed]$ cat sed-w.txt
# This is Sed Sample File
# We will test to
replace from a-text to b-text.
# It was created by NaleeJang.

# W 명령은 패턴 내용과 일치하지 않음을 알 수 있는데, 이렇듯 소문자로 된 명령어는 패턴에 편집된 뉴라인을 모두 정상적으로 처리하지만,
# 대문자로 된 명령어는 패턴에 편집된 뉴라인의 다음 라인은 모두 제외하고 처리한다.
[choi@localhost 06.Sed]$ sed -n '0,/NaleeJang/ {
> s/We will test to replace/We will test to\nreplace/
> W sed-w.txt
> p }' hosts
# This is Sed Sample File
# We will test to
replace from a-text to b-text.
# It was created by NaleeJang.
[choi@localhost 06.Sed]$ cat sed-w.txt
# This is Sed Sample File
# We will test to
# It was created by NaleeJang.


### ex13) x - 패턴 버퍼와 홀드 버퍼의 내용을 서로 바꿔줌
# 172.10.2를 192.20.3으로 변경하는 명령어 앞뒤로 패턴 버퍼와 홀드 버퍼의 내용을 서로 부꾸고 출력하였더니, 
# 해당 내용에 문자열이 변경되지 않은 채 출력되었음을 알 수 있다.
[choi@localhost 06.Sed]$ sed -n '/# Test/ ,+3 {
> x
> s/172.10.2/192.20.3/
> x
> p }' hosts
# Test

172.10.2.12 test1.example.com
172.10.2.13 test2.example.com


### ex14) y/source/dest/ - source 위치에서 명시한 문자열을 dest에서 명시한 문자열로 변경할 때 사용
# y 명령어를 이용해 test라는 소문자로 구성된 각각의 문자 TEST라는 대문자로 구성된 각각의 문자로 변경되었음을 알 수 있다.
[choi@localhost 06.Sed]$ sed -n '/# Test/ ,+3 {
> y/test/TEST/
> p }' hosts
# TEST

172.10.2.12 TEST1.ExamplE.com
172.10.2.13 TEST2.ExamplE.com


########################################################################################################################################################


## 3) 옵션


### ex1) -n, --quiet, --silent : 모두 현재 패턴 버퍼의 내용을 출력하지 않을 때 사용되는 옵션
# sed는 대상 파일 내용을 포함하여 편집 중인 패턴 버퍼의 내용을 출력하지만, -n 옵션을 사용하면 명령어에 의해 해당 내용만 출력한다.
# 예제는 전체 파일 내용을 출력하지 않고, 명령어에 의해 첫 번째 라인부터 5번째 라인까지만 출력한다.
[choi@localhost 06.Sed]$ sed -n '1,5 p' hosts
# This is Sed Sample File
# We will test to replace from a-text to b-text.
# It was created by NaleeJang.

127.0.0.1   localhost


### ex2) -e 스크립트, --expression=스크립트 : 여러 개의 스크립트를 실행할 경우 사용하는 옵션.
# 예제에서는 hosts 파일에서 172.1.2가 포함된 라인의 test를 imsi로 변경하는 스크립트와 Test라는 문자열을 Imsi로 변경하는 스크립트를 동시에 실행하는 예제
[choi@localhost 06.Sed]$ sed -n -e '/172.10.2.*/ s/test/imsi/p' -e 's/Test/Imsi/p' hosts
# Imsi
172.10.2.12 imsi1.example.com
172.10.2.13 imsi2.example.com


### ex3) -f 스크립트파일, --file=스크립트파일 : sed 수행 스크립트를 파일에 저장하고 해당 파일을 이용하여 sed를 수행할 때 사용
[choi@localhost 06.Sed]$ echo "/test[0-9].[a-z]*/ s/172.10.2/192.10.8/p" > script.txt
[choi@localhost 06.Sed]$ sed -n -f script.txt hosts
192.10.8.12 test1.example.com
192.10.8.13 test2.example.com


### ex4) -i 파일 확장자, --in-place=파일 확장자 : 
# 파일 확장자를 생략하고 옵션을 사용할 수도 있으며, 파일 확장자와 함께 사용할 수도 있다.
# -i 옵션만 사용할 경우에는 편집된 내용을 바로 파일에 반영하지만, 파일 확장자와 함께 사용했을 경우에는
# 편집된 내용을 파일에 적용하기 전에 명시한 파일 확장자로 끝나는 원본 파일을 백업한다.
[choi@localhost 06.Sed]$ sed -i '/test[0-9].[a-z]*/ s/172.10.2/192.10.8/' hosts
[choi@localhost 06.Sed]$ cat hosts | grep 'test[0-9].[a-z]*'
192.10.8.12 test1.example.com
192.10.8.13 test2.example.com
[choi@localhost 06.Sed]$
[choi@localhost 06.Sed]$ sed -i.bak '/test[0-9].[a-z]*/ s/192.10.8/192.1.2/' hosts
[choi@localhost 06.Sed]$ ll hosts*
-rw-rw-r--. 1 choi choi 426  8월 17 03:39 hosts
-rw-rw-r--. 1 choi choi 428  8월 17 03:38 hosts.bak


### ex5) --follow-symlinks : 심볼릭 링크가 대상 파일일 경우 사용하는 옵션
# 심볼릭 링크의 파일 내용을 수정할 때 --follow-symlinks 옵션을 함께 사용한 경우에는 심볼릭 링크와 연결된 원본 파일의 내용이 수정되었지만,
# 그렇지 않은 경우에는 심볼릭 링크에 해당 패턴 내용이 바로 저장되어 심볼릭 링크가 파일로 변경된 것을 확인할 수 있다.

# 테스트를 위해 hosts를 바로 보는 심볼릭 링크 sym-hosts를 생성
[choi@localhost 06.Sed]$ ln -s hosts sym-hosts
[choi@localhost 06.Sed]$ ll *hosts
-rw-rw-r--. 1 choi choi 426  8월 17 03:39 hosts
lrwxrwxrwx. 1 choi choi   5  8월 17 03:42 sym-hosts -> hosts

# --follow-symlinks 옵션을 이용하여 심볼릭 링크 내용 수정
[choi@localhost 06.Sed]$ sed --follow-symlinks -i '/test[0-9].[a-z]*/ s/192.1.2/172.10.2/' sym-hosts
[choi@localhost 06.Sed]$ ll *hosts
-rw-rw-r--. 1 choi choi 428  8월 17 03:43 hosts
lrwxrwxrwx. 1 choi choi   5  8월 17 03:42 sym-hosts -> hosts

# --follow-symlinks 옵션 없이 심볼릭 링크 내용 수정
[choi@localhost 06.Sed]$ sed -i '/test[0-9].[a-z]*/ s/172.10.2/192.10.8/' sym-hosts
[choi@localhost 06.Sed]$ ll *hosts
-rw-rw-r--. 1 choi choi 428  8월 17 03:43 hosts
-rw-rw-r--. 1 choi choi 428  8월 17 03:44 sym-hosts


### ex6) -c --copy : 
[choi@localhost 06.Sed]$ sed -ic '/test[0-9].[a-z]*/ s/172.10.2/192.1.2/' hosts
[choi@localhost 06.Sed]$ ll hosts*
-rw-rw-r--. 1 choi choi 426  8월 17 03:51 hosts
-rw-rw-r--. 1 choi choi 428  8월 17 03:38 hosts.bak
-rw-rw-r--. 1 choi choi 428  8월 17 03:43 hostsc


### ex7) -l N, --line-length=N : 
[choi@localhost 06.Sed]$ echo "This is a test sentence for testing line length. 
sed command has line break function. If you want to apply this function, you can use -l N option. N is number of line length" > sed-line-length.txt
[choi@localhost 06.Sed]$ sed -n -l 50 'l' sed-line-length.txt
This is a test sentence for testing line length. \
sed command has line break function. If you want \
to apply this function, you can use -l N option. \
N is number of line length length.txt$


### ex8) -r, --regexp-extended : 어드레스를 명시할 때 확장 정규표현식을 이용할 경우 사용할 수 있는 옵션
[choi@localhost 06.Sed]$ sed -n -r '/[[:lower:]]+[0-9].*/ p' hosts
192.1.2.12 test1.example.com
192.1.2.13 test2.example.com
122.10.10.32 service1.example.com
122.10.10.33 service2.example.com


### ex9) --posix : -r 옵션과 다르게 확장 정규표현식을 사용하지 못하도록 하는 옵션
[choi@localhost 06.Sed]$ sed -n --posix '/[[:lower:]]+[0-9].*/ p' hosts
[choi@localhost 06.Sed]$


### ex10) -s, --separate : 두 개의 대상 파일을 사용할 경우 대상 파일을 하나의 파일로 인식하는 것이 아닌, 각각의 파일로 인식하도록 할 경우 사용함
# sed 패턴 공간이라는 곳에 읽어들인 파일 내용을 저장하는데 -s 옵션이 없는 경우에는 두 개의 파일 내용을 하나의 패턴에 모두 저장하며,
# -s 옵션을 사용할 경우에는 각각의 파일을 위해 분리된 별도의 패턴을 사용한다.

# -s 옵션이 없으면 hosts와 hostsc 파일의 마지막 라인 번호를 출력하면 40이 출력
[choi@localhost 06.Sed]$ sed -n '$=' hosts hostsc
40

# -s 옵션 사용하면 hosts와 hostsc 각각 파일의 마지막 라인 번호 출력
[choi@localhost 06.Sed]$ sed -n -s '$=' hosts hostsc
20
20
