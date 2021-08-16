#!/bin/bash

# AWK : 특정 인덱스 문자열을 출력할 수 있는 명령
# 즉, 앞에서 사전에 실행된 명령어의 결과나 파일로부터 레코드(Record)를 선택하고, 선택된 레코드의 특정 인덱스에 해당하는 값을 출력할 수 있다.
# 또한 선택된 레코드를 가지고 패턴과 일치하는지를 확인하고, 데이터 조작 및 연산 등의 액션을 수행하여 그 결과를 출력할 수 있다.

## 기본 사용법 - 1
# awk [옵션] '패턴 { 액션 }' 대상파일
# ex1)
# ls -al Script/ > file-list.txt
# awk '$2 == 2 { print $NF }' file-list.txt

## 기본 사용법 - 2
# awk [옵션] -f awk_프로그램_파일 대상파일
# ex2)
# echo '$2 == 2 { print $NF }' > awk-prog.txt
# awk -f awk-prog.txt file-list.txt

## 기본 사용법 - 3
# 명령어 | awk [옵션] '패턴 { 액션 }'
# ex3)
# ls -l Script/ | awk '$2 == 2 { print $NF }'

########################################################################################################################################################

## 1-1) 액션 - 1 

### cat awk-sample1.txt
-rw-rw----. 1   nelee nele  65942   05-15   16:49   aa.txt
-rw-------. 1   nelee nele     40   05-22   16:34   amin.txt
-rw-rw----. 1   nelee nele  65942   05-15   16:49   bb.txt

### ex1) print - 대상 파일의 내용을 그대로 출력함
[choi@localhost awk]$ awk '{ print }' awk-sample1.txt
-rw-rw----. 1   nelee nele  65942   05-15   16:49   aa.txt
-rw-------. 1   nelee nele     40   05-22   16:34   amin.txt
-rw-rw----. 1   nelee nele  65942   05-15   16:49   bb.txt

### ex2) print 필드리스트 - 출력하고자 하는 필드 인덱스를 나열하면, 해당 플드값을 출력함
# 1번째 필드와 8번째 필드값 출력
[choi@localhost awk]$ awk '{ print $1, $8 }' awk-sample1.txt
-rw-rw----. aa.txt
-rw-------. amin.txt
-rw-rw----. bb.txt
# 파일의 레코드 번호를 파일 내용과 함께 출력
[choi@localhost awk]$ awk '{ print FNR, $0 }' awk-sample1.txt
1 -rw-rw----. 1   nelee nele  65942   05-15   16:49   aa.txt
2 -rw-------. 1   nelee nele     40   05-22   16:34   amin.txt
3 -rw-rw----. 1   nelee nele  65942   05-15   16:49   bb.txt

### ex3) print 필드리스트 > 파일 - 필드리스트에서 선택된 필드값을 터미널에 보여주는 것이 아니라, 명시한 파일에 저장하라는 의미
# 1번째 필드와 8번째 필드값을 awk-result.txt 파일에 저장
[choi@localhost ~]$ awk '{ print $1, $8 }' > awk-result.txt awk-sample1.txt
[choi@localhost ~]$ cat awk-result.txt
-rw-rw----. aa.txt
-rw-------. amin.txt
-rw-rw----. bb.txt

### ex4) printf 포맷, 파일리스트 - 지정한 포맷에 맞게 필드리스트를 출력
# 8번째 필드와 6번째 필드를 저장한 포맷에 맞게 출력
[choi@localhost ~]$ awk '{ printf "%-10s %s\n", $8, $6 }' awk-sample1.txt
aa.txt     05-15
amin.txt   05-22
bb.txt     05-15

### ex5) printf 포맷, 파일리스트 > 파일 - 지정한 포맷에 맞게 필드리스트를 명시한 파일에 저장
# 8번째 필드와 6번째 필드를 저장한 포맷에 맞게 awk-res.txt 파일에 저장
[choi@localhost ~]$ awk '{ printf "%-10s %s\n", $8, $6 }' > awk-res.txt  awk-sample1.txt
[choi@localhost ~]$ cat awk-res.txt
aa.txt     05-15
amin.txt   05-22
bb.txt     05-15
# 그외 예제.
[choi@localhost ~]$ echo "a b c" | awk '{ printf "%2$s\n", $1, $2, $3 }'
b
[choi@localhost ~]$ awk '{ printf "%10s, %-10s,\n", $NF, $NF }' awk-sample1.txt
    aa.txt, aa.txt    ,
  amin.txt, amin.txt  ,
    bb.txt, bb.txt    ,
[choi@localhost ~]$ echo "30 -20 10" | awk '{ printf "%d%-d=%d\n", $1, $2 ,$3 }'
30-20=10
[choi@localhost ~]$ echo "10.568" | awk '{ printf "%f %8.2f%%\n", $1, $1 }'
10.568000    10.57%

########################################################################################################################################################

## 1-2) 액션 - 2

### ex6) getline - 대상 파일로부터 라인을 읽는다, getline은 print문 앞에서 사용되어야 하며 대상 파일의 짝수 번째 라인을 읽어들인다.
# 파일의 짝수 번째 라인을 읽어 마지막 필드값 출력
[choi@localhost ~]$ awk '{ getline; print $NF }' awk-sample1.txt
amin.txt
bb.txt

### ex7) getline var - getline과 반대로 홀수 번째 라인을 읽어들인다.
# 파일의 짝수 번째 라인을 읽어 마지막 필드값 출력
[choi@localhost ~]$ awk '{ getline var; print $NF }' awk-sample1.txt
aa.txt
bb.txt

# awk 내장 변수
# ARGC      : 명령어의 인수 개수 
# ARGIND    : 현재 파일의 ARGV 인덱스
# ARGV      : 명령줄 인수 배열     
# FILENAME  : 대상 파일명               
# FNR       : 대상 파일 라인 번호    
# FS        : 필드 구분 기호
# NF        : 대상 파일 필드 개수
# NR        : 대상 파일 총 레코드 개수
# OFMT      : 숫자의 기본 출력 포맷
# OFS       : 출력 필드 구분 기호
# ORS       : 출력 레코드 구분 기호
# RS        : 대상 파일의 레코드 구분 기호

### ex8) getline < 파일 - 명시한 파일로부터 데이터를 읽어, 출력 시 대상 파일의 데이터를 교체
# 파일에 Ascii_text를 다음과 같이 저장
[choi@localhost ~]$ cat awk-filetype.txt
 Ascii_text
 Ascii_text
 Ascii_text
 # awk-filetype.txt의 값을 첫 번째 필드값으로 변경하여 출력
[choi@localhost ~]$ awk '{ getline $1 < "awk-filetype.txt"; print }' awk-sample1.txt
 Ascii_text 1 nelee nele 65942 05-15 16:49 aa.txt
 Ascii_text 1 nelee nele 40 05-22 16:34 amin.txt
 Ascii_text 1 nelee nele 65942 05-15 16:49 bb.txt

### ex9) getline var < 파일 
# 파일에 8이라는 숫자를 다음과 같이 저장
[choi@localhost ~]$ cat awk-test.txt
8
8
8
# awk-test.txt 값을 읽어 var에 저장하고, var에 해당하는 필드값 출력
[choi@localhost ~]$ awk '{ getline var < "awk-test.txt"; print $var }' awk-sample1.txt
aa.txt
amin.txt
bb.txt

########################################################################################################################################################

## 2) 패턴

[choi@localhost ~]$ cat awk-sample.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt
-rw-rw-r--.  1   nalee nalee    750 05-13 14:40 expression.tar.gz
-rw-------.  1   nalee nalee    717 05-21 12:26 expression.txt
drwxrwxr-x.  2   nalee nalee     87 05-20 17:09 File
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rwxr-xr-x.  1   nalee nalee 159024 05-13 20:31 grep-test
drwxrwxr-x.  2   nalee nalee     86 05-21 13:07 pattern
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile
-rw-rw-rw-.  1   nalee nalee     60 05-21 12:27 Separator.txt
-r--r--r--.  1   nalee nalee    721 05-19 11:14 test.txt
[choi@localhost ~]$ cat awk-sample1.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt

### ex1) BEGIN { 액션 } END { 액션 } - 다른 패턴 표현과는 다르게 awk 수행을 위해 다상 파일에서 데이터를 읽어들이기 전 또는 후에 실행되는 특수 패턴
# 8번째 필드를 출력하기 전에 "# filename #" 문구를 출력
[choi@localhost ~]$ awk 'BEGIN {print "# Fileame #"} {print $8}' awk-sample1.txt
# Fileame #
aa.txt
amin.txt
bb.txt
# 8번째 필드를 출력하기 후에 "# The file is NR #" 문구를 출력
[choi@localhost ~]$ awk '{print $8} END {print "*The file is "NR }' awk-sample1.txt
aa.txt
amin.txt
bb.txt
*The file is 3

### ex2) BEGINFILE { 액션 } ENDFILE { 액션 } - awk 내장변수 중 FILENAME이라는 변수를 사용할 겨우 사용하는 특수 패턴
# 8번째 필드를 출력하기 전 "Start--> 파일명"을 출력하고, 8번째 출력 후 "END--> 파일명"을 출력
[choi@localhost ~]$ awk 'BEGINFILE {print "Start--> " FILENAME} {print $8} ENDFILE {print "End--> " FILENAME}' awk-sample1.txt
Start--> awk-sample1.txt
aa.txt
amin.txt
bb.txt
End--> awk-sample1.txt

### ex3) /정규 표현식/ - 대상 파일에 정규 표현식으로 명시한 패턴과 일치하는 데이터가 있는지 확인하여, 해당 데이터가 포함된 라인을 출력
# 소유자만 읽기 쓰기가 가능한 파일 목록 출력
[choi@localhost ~]$ awk '/^-rw-{7}/ {print}' awk-sample1.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
# 파일명이 a로 시작해 txt로 끝나는 파일 목록 출력
[choi@localhost ~]$ awk '/a[[:lower:]]*.txt/ {print}' awk-sample1.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt

### ex4) 관계식 - 패턴 관계식은 산술 연산자를 이용하여 2개의 값을 비교할 수 있다.
# 2번째 필드값이 2로, 디렉토리일 경우에만 디렉토리명 출력
[choi@localhost ~]$ awk '$2 == 2 {print $NF}' awk-sample.txt
File
pattern

### ex5) 패턴1 && 패턴2 - 산술식 또는 정규 표현식으로 이루어진 두 패턴 사이의 AND 연산을 수행
# 레코드 번호가 1이 아니고, 디렉토리인 경우만 디렉토리 목록 출력
[choi@localhost ~]$ awk 'NR !=1 && $2 == 2 {print}' awk-sample.txt
drwxrwxr-x.  2   nalee nalee     87 05-20 17:09 File
drwxrwxr-x.  2   nalee nalee     86 05-21 13:07 pattern
# 소유자가 읽고 쓸 수 있으며, a와 txt 사이가 영문소문자로 이루어진 파일 목록 출력
[choi@localhost ~]$ awk '/^-rw-*/ && /a[[:lower:]]*.txt/ {print}' awk-sample.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw-rw-.  1   nalee nalee     60 05-21 12:27 Separator.txt

### ex6) 패턴1 || 패턴2 - 산술식 또는 정규 표현식으로 이루어진 두 패턴 사이의 OR 연산을 수행
# 파일 소유자가 nelee가 아니고, 파일 사이즈가 0인 파일 목록 출력
[choi@localhost ~]$ awk '$3 != "nalee" || $4 == 0 {print}' awk-sample.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile

### ex7) 패턴1 ? 패턴2 
# 2번째 필드값이 2면 directory를 res에 저장하고, 아니면 file을 res에 저장한 후, 파일명은 10칸 내에 맞추고,
# res 변수값과 뉴라인을 추가하여 출력함
[choi@localhost ~]$ awk '$2 == 2 ? res="Directory" : res="File" {printf "%-10s %s\n", $NF, res}' awk-sample1.txt
aa.txt     File
amin.txt   File
bb.txt     File

### ex8) (패턴) - 산술식이든 정규 표현식이든 소괄호()를 이용해 그룹핑을 하거나, 산술식 같은 경우 연산 우선순위를 결정
# 6번째 필드(수정일자)가 05-22보다 크거나 같은 경우의 파일 목록 출력
# 관계식을 소괄호()로 묶어 가독성을 높이는데 사용
[choi@localhost ~]$ awk '($6 >= "05-22") {print}' awk-sample.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile

### ex9) ! 패턴 - NO 연산 수행
# 파일 소유작 nalee가 아닌 파일 목록 출력
[choi@localhost ~]$ awk '!(/nalee/) {print}' awk-sample.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile

### ex10) 패턴1, 패턴2 - awk에서만 사용되는 형식으로 범위 패턴이라고하며, 패턴1부터 패턴2 사이에 해당하는 레코드를 출력
# 파일 레코드 번호가 2부터 5까지에 해당하는 파일 목록 출력
[choi@localhost ~]$ awk 'FNR==2, FNR==5 {print}' awk-sample.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt
-rw-rw-r--.  1   nalee nalee    750 05-13 14:40 expression.tar.gz
-rw-------.  1   nalee nalee    717 05-21 12:26 expression.txt
# 파일 수정일자가 05-20보다 늦고 05-25보다 빠른 일자에 수정한 파일 목록 출력
[choi@localhost ~]$ awk '($6 > "05-20"), ($6 < "05-25") {print}' awk-sample.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-------.  1   nalee nalee    717 05-21 12:26 expression.txt
-rw-rw-r--.  1   test   test      0 05-22 14:28 findtestfile
drwxrwxr-x.  2   nalee nalee     86 05-21 13:07 pattern
-rw-r--r--.  1   root   root      0 05-24 11:52 rootfile
-rw-rw-rw-.  1   nalee nalee     60 05-21 12:27 Separator.txt

########################################################################################################################################################

## 3) 표준 옵션

[choi@localhost ~]$ cat awk-test.csv
Nalee Jang,2,Red Hat Korea,1230
Gildong Hong,1,ABC Corporation,2345
Yejee Kim,2,BBB Company,5678
Heechul Park,1,CCC Company,6789

### ex1) -f 파일 / --file 파일 - 명시한 파일은 awk 프로그래밍이 되어 잇는 파일이여야 한다.
# 패턴과 액션을 awk-prog.txt 파일에 저장
[choi@localhost ~]$ echo '$2 == 2 {print $NF}' > awk-prog.txt
[choi@localhost ~]$ awk -f awk-prog.txt awk-sample.txt
File
pattern

### ex2) -F 구분 기호 / --field-separator - 대상 파일의 구분 기호를 변경할 때 사용하는 옵션
[choi@localhost ~]$ awk '{print $1}' awk-test.csv
Nalee
Gildong
Yejee
Heechul
[choi@localhost ~]$ awk -F ',' '{print $1}' awk-test.csv
Nalee Jang
Gildong Hong
Yejee Kim
Heechul Park

### ex3) -v 변수=값 / --assign 변수=값 - 명신된 변수에 명신된 값을 저장 그리고 해당 변수를 액션에서 출력할 경우 함께 사용할 수 있다.
[choi@localhost ~]$ awk -v label="Filename: " '{print label $NF}' awk-sample1.txt
Filename: aa.txt
Filename: amin.txt
Filename: bb.txt

########################################################################################################################################################

## 4) 확장 옵션 

### ex1) -b / --characters-as-bytes - 문자를 바이트로 계산하며, 영문자를 제외한 한글이나, 일본어, 중국어 같은 경우 1문자를 표현하기 위해 2바이트 내지 3바이트를 사용함
# 문자열 "테스트"의 길이 출력
[choi@localhost ~]$ echo "테스트" | awk '{ print length($1) }'
3
# -b 옵션에 의해 "테스트"에 소요된 총 바이트 수를 출력
[choi@localhost ~]$ echo "테스트" | awk -b '{ print length($1) }'
9

### ex2) -C / --copyright - awk의 라이센스 정보를 출력
[choi@localhost ~]$ awk -C
Copyright (C) 1989, 1991-2018 Free Software Foundation.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

### ex3) -d 파일명 / --dump-variables=파일명 - 대상 파일로부터 필요한 파일을 출력할 때 사용된 awk 내장변수 정보를 명시한 파일에 저장한다.
[choi@localhost ~]$ awk -ddump-var.txt '{print}' awk-sample1.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 aa.txt
-rw-------.  1   nalee nalee     40 05-22 16:34 amin.txt
-rw-rw----.  1   nalee nalee  65942 05-15 16:49 bb.txt
[choi@localhost ~]$ cat dump-var.txt
ARGC: 2
ARGIND: 1
ARGV: array, 2 elements
BINMODE: 0
CONVFMT: "%.6g"
ENVIRON: array, 28 elements
ERRNO: ""
FIELDWIDTHS: ""
FILENAME: "awk-sample1.txt"
FNR: 3
FPAT: "[^[:space:]]+"
FS: " "
FUNCTAB: array, 41 elements
IGNORECASE: 0
LINT: 0
NF: 8
NR: 3
OFMT: "%.6g"
OFS: " "
ORS: "\n"
PREC: 53
PROCINFO: array, 20 elements
RLENGTH: 0
ROUNDMODE: "N"
RS: "\n"
RSTART: 0
RT: "\n"
SUBSEP: "\034"
SYMTAB: array, 28 elements
TEXTDOMAIN: "messages"

### ex4) -L 'fatal' / --lint='fatal' - awk 프로그램에 구문 오류가 있을 경우 왜 에러가 발생했는지를 자세히 보여주며, 예제와 같이 에러 메시지를 출력하지 않는 경우에도
### 에러 메시지를 보여준다다. 따라서, 작성한 awk 구문에 문제가 있는지 여부를 확인할 때 유용
# 테스트를 위한 빈 파일 생성 후 해당 파일을 이용해 awk 실행
[choi@localhost ~]$ echo "" > awk-prog.txt
[choi@localhost ~]$ awk -f awk-prog.txt awk-sample1.txt
# -L 옵션에 의해 에러 메시지를 보여줌
[choi@localhost ~]$ awk -L 'fatal' -f awk-prog.txt awk-sample1.txt
awk: fatal: no program text at all!

### ex5) -p파일명 / --profile=파일명 - 명시한 파일에 awk의 액션과 패턴에 해당하는 구문을 파싱하여 저장한다.
# 8번째 필드 출력 전 "Start--> 파일명"을 출력하고, 8번째 출력 후 "End--> 파일명"을 출력
[choi@localhost ~]$ awk -p 'BEGINFILE {print "Start--> " FILENAME} {print $8} ENDFILE {print "End--> " FILENAME}' awk-sample1.txt
Start--> awk-sample1.txt
aa.txt
amin.txt
bb.txt
End--> awk-sample1.txt
# awkprof.out에 앞서 실행한 awk 프로그램 코드가 파싱되어 저장되었음
[choi@localhost ~]$ cat awkprof.out
        # gawk profile, created Sun Aug 15 04:49:53 2021

        # BEGINFILE rule(s)

        BEGINFILE {
     1          print "Start--> " FILENAME
        }

        # Rule(s)

     3  {
     3          print $8
        }

        # ENDFILE rule(s)

        ENDFILE {
     1          print "End--> " FILENAME
        }

### ex6) -S / --sandbox - 대상 파일을 제외한 이외 파일의 접근을 차단
# awk-filetyp.txt의 파일 내용을 읽어 첫 번째 필드의 값을 변경
[choi@localhost ~]$ awk '{ getline $1 < "awk-filetype.txt"; print }' awk-sample1.txt
 Ascii_text 1 nalee nalee 65942 05-15 16:49 aa.txt
 Ascii_text 1 nalee nalee 40 05-22 16:34 amin.txt
 Ascii_text 1 nalee nalee 65942 05-15 16:49 bb.txt
# -S 옵션을 사용하면 awk-filetype.txt에서 파일 내용을 못 읽어옴
[choi@localhost ~]$ awk -S '{ getline $1 < "awk-filetype.txt"; print }' awk-sample1.txt
awk: cmd. line:1: (FILENAME=awk-sample1.txt FNR=1) fatal: redirection not allowed in sandbox mode