---
title: Writeup - OverTheWire Bandit
author: Cihat Yildiz
date: 2017-07-10 20:55:00 +0800
categories: [writeup]
tags: [writing]
pin: false
---

In this post, you will see the solutions of OverTheWire-bandit challenges. Challenges in Bandit are easy if you have some experience in Linux and Security. If not, don't worry about it. Google will help you to get basic knowledge of the challenges.

When you complete the challenges you are gonna feel yourself more powerful on technical problem-solving. 

## Bandit0
    
```bash  
$ ssh -l bandit0 -p2220 bandit.labs.overthewire.org
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames
bandit0@bandit.labs.overthewire.org's password:
bandit0@bandit:~$ pwd
/home/bandit0
bandit0@bandit:~$ cat readme
boJ9jbbUNNfktd78OOpsqOltutMc3MY1
bandit0@bandit:~$
```
    

password for bandit1 is boJ9jbbUNNfktd78OOpsqOltutMc3MY1

## Bandit1
    
```bash
bandit1@bandit:~$ ls
-
bandit1@bandit:~$ ls -la
total 24
-rw-r-----  1 bandit2 bandit1   33 Oct 16 14:00 -
drwxr-xr-x  2 root    root    4096 Oct 16 14:00 .
drwxr-xr-x 41 root    root    4096 Oct 16 14:00 ..
-rw-r--r--  1 root    root     220 May 15  2017 .bash_logout
-rw-r--r--  1 root    root    3526 May 15  2017 .bashrc
-rw-r--r--  1 root    root     675 May 15  2017 .profile
bandit1@bandit:~$ cat ./
-             .bash_logout  .bashrc       .profile
bandit1@bandit:~$ cat ./-
CV1DtqXWVFXTvM2F0k09SHz0YwRINYA9
bandit1@bandit:~$
```    

password for bandit2 is CV1DtqXWVFXTvM2F0k09SHz0YwRINYA9

## Bandit2
    
```bash 
bandit2@bandit:~$ ls
spaces in this filename
bandit2@bandit:~$ pwd
/home/bandit2
bandit2@bandit:~$ ls
spaces in this filename
bandit2@bandit:~$ ls -la
total 24
drwxr-xr-x  2 root    root    4096 Oct 16 14:00 .
drwxr-xr-x 41 root    root    4096 Oct 16 14:00 ..
-rw-r--r--  1 root    root     220 May 15  2017 .bash_logout
-rw-r--r--  1 root    root    3526 May 15  2017 .bashrc
-rw-r--r--  1 root    root     675 May 15  2017 .profile
-rw-r-----  1 bandit3 bandit2   33 Oct 16 14:00 spaces in this filename
bandit2@bandit:~$ cat spaces in this filename
UmHadQclWmgdLOKQ3YNgjWxGoRMb5luK
bandit2@bandit:~$
```    

Password for bandit3 is UmHadQclWmgdLOKQ3YNgjWxGoRMb5luK

## Bandit3
    
```bash
bandit3@bandit:~$ ls
inhere
bandit3@bandit:~$ ls -la
total 24
drwxr-xr-x  3 root root 4096 Oct 16 14:00 .
drwxr-xr-x 41 root root 4096 Oct 16 14:00 ..
-rw-r--r--  1 root root  220 May 15  2017 .bash_logout
-rw-r--r--  1 root root 3526 May 15  2017 .bashrc
drwxr-xr-x  2 root root 4096 Oct 16 14:00 inhere
-rw-r--r--  1 root root  675 May 15  2017 .profile
bandit3@bandit:~$ ls inhere/
bandit3@bandit:~$ ls -la inhere/
total 12
drwxr-xr-x 2 root    root    4096 Oct 16 14:00 .
drwxr-xr-x 3 root    root    4096 Oct 16 14:00 ..
-rw-r----- 1 bandit4 bandit3   33 Oct 16 14:00 .hidden
bandit3@bandit:~$ cat inhere/.hidden
pIwrPrtPN36QITSp3EQaw936yaFoFgAB
bandit3@bandit:~$
``` 

Password for bandit4 is pIwrPrtPN36QITSp3EQaw936yaFoFgAB

## Bandit4
    
```bash  
bandit4@bandit:~$ ls
inhere
bandit4@bandit:~$ ls -la
total 24
drwxr-xr-x  3 root root 4096 Oct 16 14:00 .
drwxr-xr-x 41 root root 4096 Oct 16 14:00 ..
-rw-r--r--  1 root root  220 May 15  2017 .bash_logout
-rw-r--r--  1 root root 3526 May 15  2017 .bashrc
drwxr-xr-x  2 root root 4096 Oct 16 14:00 inhere
-rw-r--r--  1 root root  675 May 15  2017 .profile
bandit4@bandit:~$ cd inhere/
bandit4@bandit:~/inhere$ ls
-file00  -file01  -file02  -file03  -file04  -file05  -file06  -file07  -file08  -file09
bandit4@bandit:~/inhere$ ls -la
total 48
drwxr-xr-x 2 root    root    4096 Oct 16 14:00 .
drwxr-xr-x 3 root    root    4096 Oct 16 14:00 ..
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file00
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file01
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file02
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file03
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file04
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file05
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file06
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file07
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file08
-rw-r----- 1 bandit5 bandit4   33 Oct 16 14:00 -file09
bandit4@bandit:~/inhere$ file ./*
./-file00: data
./-file01: data
./-file02: data
./-file03: data
./-file04: data
./-file05: data
./-file06: data
./-file07: ASCII text
./-file08: data
./-file09: data
bandit4@bandit:~/inhere$ cat ./-file07
koReBOKuIDDepwhWk7jZC0RTdopnAYKh
bandit4@bandit:~/inhere$
```   

Password for bandit5 is koReBOKuIDDepwhWk7jZC0RTdopnAYKh

## Bandit5
    
```bash    
bandit5@bandit:~$ ls
inhere
bandit5@bandit:~$ cd inhere/
bandit5@bandit:~/inhere$ ls
maybehere00  maybehere03  maybehere06  maybehere09  maybehere12  maybehere15  maybehere18
maybehere01  maybehere04  maybehere07  maybehere10  maybehere13  maybehere16  maybehere19
maybehere02  maybehere05  maybehere08  maybehere11  maybehere14  maybehere17
bandit5@bandit:~/inhere$ ls -la *
bandit5@bandit:~/inhere$ find . -type f -size 1033
bandit5@bandit:~/inhere$ find . -type f -size 1033c
./maybehere07/.file2
bandit5@bandit:~/inhere$ cat ./maybehere07/.file2
DXjZPULLxYr17uwoI01bNLQbtFemEgo7
bandit5@bandit:~/inhere$
```
    

Password for bandit5 is DXjZPULLxYr17uwoI01bNLQbtFemEgo7

## Bandit6
    
```bash 
bandit6@bandit:~$ ls
bandit6@bandit:~$ pwd
/home/bandit6
bandit6@bandit:~$ ls -la
total 20
drwxr-xr-x  2 root root 4096 Oct 16 14:00 .
drwxr-xr-x 41 root root 4096 Oct 16 14:00 ..
-rw-r--r--  1 root root  220 May 15  2017 .bash_logout
-rw-r--r--  1 root root 3526 May 15  2017 .bashrc
-rw-r--r--  1 root root  675 May 15  2017 .profile
bandit6@bandit:~$ find / -size 33c -group bandit6 -user bandit7 2> /dev/null
/var/lib/dpkg/info/bandit7.password
bandit6@bandit:~$ cat /var/lib/dpkg/info/bandit7.password
HKBPTKQnIay4Fw76bEy8PVxKEDQRKTzs
bandit6@bandit:~$
```
    

Password for bandit7 is HKBPTKQnIay4Fw76bEy8PVxKEDQRKTzs

## Bandit7
    
```bash
bandit7@bandit:~$
bandit7@bandit:~$ ls
data.txt
bandit7@bandit:~$ cat data.txt | grep millionth
millionth   cvX2JJa4CFALtqS87jk27qwqGhBM9plV
```   

Password for bandit8 is cvX2JJa4CFALtqS87jk27qwqGhBM9plV

## Bandit8
    
```bash
bandit8@bandit:~$ ls data.txt bandit8@bandit:~$ cat data.txt | sort | uniq -u UsvVyFSfZZWbi6wgC7dAFyFuR6jQQUhR bandit8@bandit:~$
```

Password for bandit9 is UsvVyFSfZZWbi6wgC7dAFyFuR6jQQUhR

##  Bandit9 
    
```bash    
bandit9@bandit:~$ ls data.txt bandit9@bandit:~$ cat data.txt | egrep "^=" Binary file (standard input) matches bandit9@bandit:~$ file data.txt data.txt: data bandit9@bandit:~$ strings data.txt | grep "=" 2========== the ========== password

t= yP rV~dHm= ========== isa =FQ?PU = F[ pb=x J;m= =)$= ========== truKLdjsbJ5g7yyJ2X2R0o3a5HQJFuLk iv8!= ```
```

Password for bandit10 is truKLdjsbJ5g7yyJ2X2R0o3a5HQJFuLk

## Bandit10
    
```bash
bandit10@bandit:~$ cat
.bash_logout  .bashrc       data.txt      .profile
bandit10@bandit:~$ cat
.bash_logout  .bashrc       data.txt      .profile
bandit10@bandit:~$ cat data.txt
VGhlIHBhc3N3b3JkIGlzIElGdWt3S0dzRlc4TU9xM0lSRnFyeEUxaHhUTkViVVBSCg==
bandit10@bandit:~$ cat data.txt | base64 -d
The password is IFukwKGsFW8MOq3IRFqrxE1hxTNEbUPR
bandit10@bandit:~$
```

The password for bandit11 is IFukwKGsFW8MOq3IRFqrxE1hxTNEbUPR

## Bandit11
    
```bash
bandit11@bandit:~$ ls
data.txt
bandit11@bandit:~$ cat data.txt
Gur cnffjbeq vf 5Gr8L4qetPEsPk8htqjhRK8XSP6x2RHh
bandit11@bandit:~$ cat data.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m'
The password is 5Te8Y4drgCRfCx8ugdwuEX8KFC6k2EUu
bandit11@bandit:~$
```

The password for bandit12 is 5Te8Y4drgCRfCx8ugdwuEX8KFC6k2EUu

## Bandit12
    
```bash    
bandit12@bandit:~$ mkdir /tmp/cx
bandit12@bandit:~$ xxd -r data.txt > /tmp/cx/data.bin  # this is the important point for the challenge
bandit12@bandit:~$ file /tmp/cx/data.bin
/tmp/cx/data.bin: gzip compressed data, was "data2.bin", last modified: Tue Oct 16 12:00:23 2018, max compression, from Unix
bandit12@bandit:~$ cd /tmp/cx
bandit12@bandit:/tmp/cx$ ls
data.bin.gz
bandit12@bandit:/tmp/cx$ mv data.bin data2.bin
bandit12@bandit:/tmp/cx$ file data2.bin
data2.bin: gzip compressed data, was "data2.bin", last modified: Tue Oct 16 12:00:23 2018, max compression, from Unix
bandit12@bandit:/tmp/cx$ mv data2.bin data2.bin.gz
bandit12@bandit:/tmp/cx$ gunzip data2.bin.gz
bandit12@bandit:/tmp/cx$ ls
data2.bin
bandit12@bandit:/tmp/cx$ file data2.bin
data2.bin: bzip2 compressed data, block size = 900k
bandit12@bandit:/tmp/cx$ mv data2.bin data2.bin.bzip
bandit12@bandit:/tmp/cx$ bzip2 data2.bin.bzip
bandit12@bandit:/tmp/cx$ ls
data2.bin.bzip.bz2
bandit12@bandit:/tmp/cx$ bzip2 -d data2.bin.bzip.bz2
bandit12@bandit:/tmp/cx$ ls
data2.bin.bzip
bandit12@bandit:/tmp/cx$ bzip2 -d data2.bin.bzip
bzip2: Can't guess original name for data2.bin.bzip -- using data2.bin.bzip.out
bandit12@bandit:/tmp/cx$ ls
data2.bin.bzip.out
bandit12@bandit:/tmp/cx$ file data2.bin.bzip.out
data2.bin.bzip.out: gzip compressed data, was "data4.bin", last modified: Tue Oct 16 12:00:23 2018, max compression, from Unix
bandit12@bandit:/tmp/cx$ mv data2.bin.bzip.out data4.bin.gz
bandit12@bandit:/tmp/cx$ gzip data4.bin.gz
gzip: data4.bin.gz already has .gz suffix -- unchanged
bandit12@bandit:/tmp/cx$ mv data4.bin.gz data4.bin
bandit12@bandit:/tmp/cx$ gzip -S data4.bin
gzip: compressed data not written to a terminal. Use -f to force compression.
For help, type: gzip -h
bandit12@bandit:/tmp/cx$ gzip data4.bin
bandit12@bandit:/tmp/cx$ ls
data4.bin.gz
bandit12@bandit:/tmp/cx$ gunzip data4.bin.gz
bandit12@bandit:/tmp/cx$ ls -la
total 1712
drwxr-sr-x 2 bandit12 root 4096 Feb 5 23:20 .
drwxrws-wt 10368 root root 1740800 Feb 5 23:20 ..
-rw-r--r-- 1 bandit12 root 435 Feb 5 23:14 data4.bin
bandit12@bandit:/tmp/cx$ file data4.bin
data4.bin: gzip compressed data, was "data4.bin", last modified: Tue Oct 16 12:00:23 2018, max compression, from Unix
bandit12@bandit:/tmp/cx$ mv data4.bin data4.gz
bandit12@bandit:/tmp/cx$ gzip -d data4.gz
bandit12@bandit:/tmp/cx$ ls
data4
bandit12@bandit:/tmp/cx$ file data4
data4: POSIX tar archive (GNU)
bandit12@bandit:/tmp/cx$ mv data4 data4.tar
bandit12@bandit:/tmp/cx$ man tar
bandit12@bandit:/tmp/cx$ tar -xf data4.tar
bandit12@bandit:/tmp/cx$ ls
data4.tar data5.bin
bandit12@bandit:/tmp/cx$ file data5.bin
data5.bin: POSIX tar archive (GNU)
bandit12@bandit:/tmp/cx$ mv data5.bin data5.tar
bandit12@bandit:/tmp/cx$ tar -xf data5.tar
bandit12@bandit:/tmp/cx$ ls
data4.tar data5.tar data6.bin
bandit12@bandit:/tmp/cx$ file data6.bin
data6.bin: bzip2 compressed data, block size = 900k
bandit12@bandit:/tmp/cx$ mv data6.bin data6.bzip2
bandit12@bandit:/tmp/cx$ bzip2 -d data6.bzip2
bzip2: Can't guess original name for data6.bzip2 -- using data6.bzip2.out
bandit12@bandit:/tmp/cx$ file data6.bzip2.out
data6.bzip2.out: POSIX tar archive (GNU)
bandit12@bandit:/tmp/cx$ tar xf data6.bzip2.out
bandit12@bandit:/tmp/cx$ ls
data4.tar data5.tar data6.bzip2.out data8.bin
bandit12@bandit:/tmp/cx$ file data8.bin
data8.bin: gzip compressed data, was "data9.bin", last modified: Tue Oct 16 12:00:23 2018, max compression, from Unix
bandit12@bandit:/tmp/cx$ mv data8.bin data8.gz
bandit12@bandit:/tmp/cx$ gunzip data8.gz
bandit12@bandit:/tmp/cx$ ls
data4.tar data5.tar data6.bzip2.out data8
bandit12@bandit:/tmp/cx$ file data8
data8: ASCII text
bandit12@bandit:/tmp/cx$ cat data8
The password is 8ZjyCRiBWFYkneahHwxCv3wb2a1ORpYL
bandit12@bandit:/tmp/cx$ bandit12@bandit:~$
```   

## Bandit13
    
```bash   
bandit13@bandit:~$ ls
sshkey.private
bandit13@bandit:~$ file sshkey.private
sshkey.private: PEM RSA private key
bandit13@bandit:~$ ssh --help
unknown option -- -
usage: ssh [-1246AaCfGgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
            [-D [bind_address:]port] [-E log_file] [-e escape_char]
            [-F configfile] [-I pkcs11] [-i identity_file]
            [-J [user@]host[:port]] [-L address] [-l login_name] [-m mac_spec]
            [-O ctl_cmd] [-o option] [-p port] [-Q query_option] [-R address]
            [-S ctl_path] [-W host:port] [-w local_tun[:remote_tun]]
bandit13@bandit:~$ cat sshkey.private --


---BEGIN RSA PRIVATE KEY----- MIIEpAIBAAKCAQEAxkkOE83W2cOT7IWhFc9aPaaQmQDdgzuXCv+ppZHa++buSkN+ gg0tcr7Fw8NLGa5+Uzec2rEg0WmeevB13AIoYp0MZyETq46t+jk9puNwZwIt9XgB ZufGtZEwWbFWw/vVLNwOXBe4UWStGRWzgPpEeSv5Tb1VjLZIBdGphTIK22Amz6Zb ThMsiMnyJafEwJ/T8PQO3myS91vUHEuoOMAzoUID4kN0MEZ3+XahyK0HJVq68KsV ObefXG1vvA3GAJ29kxJaqvRfgYnqZryWN7w3CHjNU4c/2Jkp+n8L0SnxaNA+WYA7 jiPyTF0is8uzMlYQ4l1Lzh/8/MpvhCQF8r22dwIDAQABAoIBAQC6dWBjhyEOzjeA J3j/RWmap9M5zfJ/wb2bfidNpwbB8rsJ4sZIDZQ7XuIh4LfygoAQSS+bBw3RXvzE pvJt3SmU8hIDuLsCjL1VnBY5pY7Bju8g8aR/3FyjyNAqx/TLfzlLYfOu7i9Jet67 xAh0tONG/u8FB5I3LAI2Vp6OviwvdWeC4nOxCthldpuPKNLA8rmMMVRTKQ+7T2VS nXmwYckKUcUgzoVSpiNZaS0zUDypdpy2+tRH3MQa5kqN1YKjvF8RC47woOYCktsD o3FFpGNFec9Taa3Msy+DfQQhHKZFKIL3bJDONtmrVvtYK40/yeU4aZ/HA2DQzwhe ol1AfiEhAoGBAOnVjosBkm7sblK+n4IEwPxs8sOmhPnTDUy5WGrpSCrXOmsVIBUf laL3ZGLx3xCIwtCnEucB9DvN2HZkupc/h6hTKUYLqXuyLD8njTrbRhLgbC9QrKrS M1F2fSTxVqPtZDlDMwjNR04xHA/fKh8bXXyTMqOHNJTHHNhbh3McdURjAoGBANkU 1hqfnw7+aXncJ9bjysr1ZWbqOE5Nd8AFgfwaKuGTTVX2NsUQnCMWdOp+wFak40JH PKWkJNdBG+ex0H9JNQsTK3X5PBMAS8AfX0GrKeuwKWA6erytVTqjOfLYcdp5+z9s 8DtVCxDuVsM+i4X8UqIGOlvGbtKEVokHPFXP1q/dAoGAcHg5YX7WEehCgCYTzpO+ xysX8ScM2qS6xuZ3MqUWAxUWkh7NGZvhe0sGy9iOdANzwKw7mUUFViaCMR/t54W1 GC83sOs3D7n5Mj8x3NdO8xFit7dT9a245TvaoYQ7KgmqpSg/ScKCw4c3eiLava+J 3btnJeSIU+8ZXq9XjPRpKwUCgYA7z6LiOQKxNeXH3qHXcnHok855maUj5fJNpPbY iDkyZ8ySF8GlcFsky8Yw6fWCqfG3zDrohJ5l9JmEsBh7SadkwsZhvecQcS9t4vby 9/8X4jS0P8ibfcKS4nBP+dT81kkkg5Z5MohXBORA7VWx+ACohcDEkprsQ+w32xeD qT1EvQKBgQDKm8ws2ByvSUVs9GjTilCajFqLJ0eVYzRPaY6f++Gv/UVfAPV4c+S0 kAWpXbv5tbkkzbS0eaLPTKgLzavXtQoTtKwrjpolHKIHUz6Wu+n4abfAIRFubOdN /+aLoRQ0yBDRbdXMsZN/jvY44eM+xRLdRVyMmdPtP8belRi2E2aEzA== -----END RSA PRIVATE KEY----- 


bandit13@bandit:~$ ssh -i ./sshkey.private
bandit14@localhost Could not create directory '/home/bandit13/.ssh'. The authenticity of host 'localhost (127.0.0.1)' can't be established. ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)?
yes --- ... ... ---
bandit14@bandit:~$ cat /etc/bandit_pass/bandit14 4wcYUJFw0k0XLShlDzztnTBHiqxU3b3e
bandit14@bandit:~$ 
```

## Bandit14
    
```bash   
bandit14@bandit:~$ ls
bandit14@bandit:~$ pwd
/home/bandit14
bandit14@bandit:~$ telnet localhost 30000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

Wrong! Please enter the correct current password
Connection closed by foreign host.
bandit14@bandit:~$ nc localhost 30000
4wcYUJFw0k0XLShlDzztnTBHiqxU3b3e
Correct!
BfMYroe26WYalil77FoDi9qh59eK5xNr

bandit14@bandit:~$
```

## Bandit15
    
```bash    
bandit15@bandit:~$ nc localhost 30001

help
bandit15@bandit:~$ nc localhost 30001
BfMYroe26WYalil77FoDi9qh59eK5xNr
bandit15@bandit:~$ ncat localhost 30001
help
pwd
BfMYroe26WYalil77FoDi9qh59eK5xNr
Ncat: Broken pipe.
bandit15@bandit:~$ ncat localhost 30001
BfMYroe26WYalil77FoDi9qh59eK5xNr
Ncat: Connection reset by peer.
bandit15@bandit:~$ openssl s_client -quiet -connect localhost:30001
depth=0 CN = localhost
verify error:num=18:self signed certificate
verify return:1
depth=0 CN = localhost
verify return:1
BfMYroe26WYalil77FoDi9qh59eK5xNr
Correct!
cluFn7wTiGryunymYOu4RcffSxQluehd

bandit15@bandit:~$
``` 

## Bandit16
    
```bash    
bandit16@bandit:~$ nmap -p31000-32000 localhost

Starting Nmap 7.40 ( https://nmap.org ) at 2019-02-06 00:55 CET
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00032s latency).
Not shown: 999 closed ports
PORT      STATE SERVICE
31518/tcp open  unknown
31790/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 0.08 seconds
bandit16@bandit:~$
bandit16@bandit:~$ openssl s_client -quiet -connect localhost:31518
depth=0 CN = localhost
verify error:num=18:self signed certificate
verify return:1
depth=0 CN = localhost
verify return:1
cluFn7wTiGryunymYOu4RcffSxQluehd
cluFn7wTiGryunymYOu4RcffSxQluehd

^C
bandit16@bandit:~$ openssl s_client -quiet -connect localhost:31790
depth=0 CN = localhost
verify error:num=18:self signed certificate
verify return:1
depth=0 CN = localhost
verify return:1
cluFn7wTiGryunymYOu4RcffSxQluehd
Correct!
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvmOkuifmMg6HL2YPIOjon6iWfbp7c3jx34YkYWqUH57SUdyJ
imZzeyGC0gtZPGujUSxiJSWI/oTqexh+cAMTSMlOJf7+BrJObArnxd9Y7YT2bRPQ
Ja6Lzb558YW3FZl87ORiO+rW4LCDCNd2lUvLE/GL2GWyuKN0K5iCd5TbtJzEkQTu
DSt2mcNn4rhAL+JFr56o4T6z8WWAW18BR6yGrMq7Q/kALHYW3OekePQAzL0VUYbW
JGTi65CxbCnzc/w4+mqQyvmzpWtMAzJTzAzQxNbkR2MBGySxDLrjg0LWN6sK7wNX
x0YVztz/zbIkPjfkU1jHS+9EbVNj+D1XFOJuaQIDAQABAoIBABagpxpM1aoLWfvD
KHcj10nqcoBc4oE11aFYQwik7xfW+24pRNuDE6SFthOar69jp5RlLwD1NhPx3iBl
J9nOM8OJ0VToum43UOS8YxF8WwhXriYGnc1sskbwpXOUDc9uX4+UESzH22P29ovd
d8WErY0gPxun8pbJLmxkAtWNhpMvfe0050vk9TL5wqbu9AlbssgTcCXkMQnPw9nC
YNN6DDP2lbcBrvgT9YCNL6C+ZKufD52yOQ9qOkwFTEQpjtF4uNtJom+asvlpmS8A
vLY9r60wYSvmZhNqBUrj7lyCtXMIu1kkd4w7F77k+DjHoAXyxcUp1DGL51sOmama
+TOWWgECgYEA8JtPxP0GRJ+IQkX262jM3dEIkza8ky5moIwUqYdsx0NxHgRRhORT
8c8hAuRBb2G82so8vUHk/fur85OEfc9TncnCY2crpoqsghifKLxrLgtT+qDpfZnx
SatLdt8GfQ85yA7hnWWJ2MxF3NaeSDm75Lsm+tBbAiyc9P2jGRNtMSkCgYEAypHd
HCctNi/FwjulhttFx/rHYKhLidZDFYeiE/v45bN4yFm8x7R/b0iE7KaszX+Exdvt
SghaTdcG0Knyw1bpJVyusavPzpaJMjdJ6tcFhVAbAjm7enCIvGCSx+X3l5SiWg0A
R57hJglezIiVjv3aGwHwvlZvtszK6zV6oXFAu0ECgYAbjo46T4hyP5tJi93V5HDi
Ttiek7xRVxUl+iU7rWkGAXFpMLFteQEsRr7PJ/lemmEY5eTDAFMLy9FL2m9oQWCg
R8VdwSk8r9FGLS+9aKcV5PI/WEKlwgXinB3OhYimtiG2Cg5JCqIZFHxD6MjEGOiu
L8ktHMPvodBwNsSBULpG0QKBgBAplTfC1HOnWiMGOU3KPwYWt0O6CdTkmJOmL8Ni
blh9elyZ9FsGxsgtRBXRsqXuz7wtsQAgLHxbdLq/ZJQ7YfzOKU4ZxEnabvXnvWkU
YOdjHdSOoKvDQNWu6ucyLRAWFuISeXw9a/9p7ftpxm0TSgyvmfLF2MIAEwyzRqaM
77pBAoGAMmjmIJdjp+Ez8duyn3ieo36yrttF5NSsJLAbxFpdlc1gvtGCWW+9Cq0b
dxviW8+TFVEBl1O4f7HVm6EpTscdDxU+bCXWkfjuRb7Dy9GOtt9JPsX8MBTakzh3
vBgsyi/sN3RqRBcGU40fOoZyfAMT8s1m/uYv52O6IgeuZ/ujbjY=
-----END RSA PRIVATE KEY-----

bandit16@bandit:~$
bandit16@bandit:/tmp/cxx$ vi bandit17ssh.key
bandit16@bandit:/tmp/cxx$ ssh -i bandit17ssh.key -l bandit17 localhost
Could not create directory '/home/bandit16/.ssh'.
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit16/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0644 for 'bandit17ssh.key' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "bandit17ssh.key": bad permissions
bandit17@localhost's password:
Permission denied, please try again.
bandit17@localhost's password:

bandit16@bandit:/tmp/cxx$ ls -la bandit17ssh.key
-rw-r--r-- 1 bandit16 root 1675 Feb  6 01:11 bandit17ssh.key
bandit16@bandit:/tmp/cxx$ chmod 400 bandit17ssh.key
bandit16@bandit:/tmp/cxx$ ssh -i bandit17ssh.key -l bandit17 localhost

.....

bandit17@bandit:~$
/home/bandit17
bandit17@bandit:~$
```

## Bandit17
    
```bash
SSH Key for bandit17 user
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvmOkuifmMg6HL2YPIOjon6iWfbp7c3jx34YkYWqUH57SUdyJ
imZzeyGC0gtZPGujUSxiJSWI/oTqexh+cAMTSMlOJf7+BrJObArnxd9Y7YT2bRPQ
Ja6Lzb558YW3FZl87ORiO+rW4LCDCNd2lUvLE/GL2GWyuKN0K5iCd5TbtJzEkQTu
DSt2mcNn4rhAL+JFr56o4T6z8WWAW18BR6yGrMq7Q/kALHYW3OekePQAzL0VUYbW
JGTi65CxbCnzc/w4+mqQyvmzpWtMAzJTzAzQxNbkR2MBGySxDLrjg0LWN6sK7wNX
x0YVztz/zbIkPjfkU1jHS+9EbVNj+D1XFOJuaQIDAQABAoIBABagpxpM1aoLWfvD
KHcj10nqcoBc4oE11aFYQwik7xfW+24pRNuDE6SFthOar69jp5RlLwD1NhPx3iBl
J9nOM8OJ0VToum43UOS8YxF8WwhXriYGnc1sskbwpXOUDc9uX4+UESzH22P29ovd
d8WErY0gPxun8pbJLmxkAtWNhpMvfe0050vk9TL5wqbu9AlbssgTcCXkMQnPw9nC
YNN6DDP2lbcBrvgT9YCNL6C+ZKufD52yOQ9qOkwFTEQpjtF4uNtJom+asvlpmS8A
vLY9r60wYSvmZhNqBUrj7lyCtXMIu1kkd4w7F77k+DjHoAXyxcUp1DGL51sOmama
+TOWWgECgYEA8JtPxP0GRJ+IQkX262jM3dEIkza8ky5moIwUqYdsx0NxHgRRhORT
8c8hAuRBb2G82so8vUHk/fur85OEfc9TncnCY2crpoqsghifKLxrLgtT+qDpfZnx
SatLdt8GfQ85yA7hnWWJ2MxF3NaeSDm75Lsm+tBbAiyc9P2jGRNtMSkCgYEAypHd
HCctNi/FwjulhttFx/rHYKhLidZDFYeiE/v45bN4yFm8x7R/b0iE7KaszX+Exdvt
SghaTdcG0Knyw1bpJVyusavPzpaJMjdJ6tcFhVAbAjm7enCIvGCSx+X3l5SiWg0A
R57hJglezIiVjv3aGwHwvlZvtszK6zV6oXFAu0ECgYAbjo46T4hyP5tJi93V5HDi
Ttiek7xRVxUl+iU7rWkGAXFpMLFteQEsRr7PJ/lemmEY5eTDAFMLy9FL2m9oQWCg
R8VdwSk8r9FGLS+9aKcV5PI/WEKlwgXinB3OhYimtiG2Cg5JCqIZFHxD6MjEGOiu
L8ktHMPvodBwNsSBULpG0QKBgBAplTfC1HOnWiMGOU3KPwYWt0O6CdTkmJOmL8Ni
blh9elyZ9FsGxsgtRBXRsqXuz7wtsQAgLHxbdLq/ZJQ7YfzOKU4ZxEnabvXnvWkU
YOdjHdSOoKvDQNWu6ucyLRAWFuISeXw9a/9p7ftpxm0TSgyvmfLF2MIAEwyzRqaM
77pBAoGAMmjmIJdjp+Ez8duyn3ieo36yrttF5NSsJLAbxFpdlc1gvtGCWW+9Cq0b
dxviW8+TFVEBl1O4f7HVm6EpTscdDxU+bCXWkfjuRb7Dy9GOtt9JPsX8MBTakzh3
vBgsyi/sN3RqRBcGU40fOoZyfAMT8s1m/uYv52O6IgeuZ/ujbjY=
-----END RSA PRIVATE KEY-----
we need to use the above key to log in as bandit17.

bandit17@bandit:~$ ls
passwords.new passwords.old
bandit17@bandit:~$ diff passwords.new passwords.old
42c42
< kfBf3eYk5BPBRzwjqutbbfE887SVc5Yd
---
> hlbSBPAWJmL6WFDb06gpTx1pPButblOA
bandit17@bandit:~$...
Cihats-MacBook-Pro:Downloads cihatyildiz$ ssh -p2220 -l bandit18 bandit.labs.overthewire.org
.....
.....
.....
.....

    Enjoy your stay!

Byebye !
Connection to bandit.labs.overthewire.org closed.
Cihats-MacBook-Pro:Downloads cihatyildiz$
```
    

## Bandit18
    
```bash   
Cihats-MacBook-Pro:Downloads cihatyildiz$ ssh -p2220 -l bandit18 bandit.labs.overthewire.org -t "cat readme"
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

bandit18@bandit.labs.overthewire.org's password:
IueksS7Ubh8G3DCwVzrTd8rAVOwq3M5x
Connection to bandit.labs.overthewire.org closed.
```
    

## Bandit19
    
```bash 
bandit19@bandit:~$ ls
bandit20-do
bandit19@bandit:~$ ls -la
total 28
drwxr-xr-x  2 root     root     4096 Oct 16 14:00 .
drwxr-xr-x 41 root     root     4096 Oct 16 14:00 ..
-rwsr-x---  1 bandit20 bandit19 7296 Oct 16 14:00 bandit20-do
-rw-r--r--  1 root     root      220 May 15  2017 .bash_logout
-rw-r--r--  1 root     root     3526 May 15  2017 .bashrc
-rw-r--r--  1 root     root      675 May 15  2017 .profile
bandit19@bandit:~$ file bandit20-do
bandit20-do: setuid ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=8e941f24b8c5cd0af67b22b724c57e1ab92a92a1, not stripped
bandit19@bandit:~$ cat /etc/bandit_pass
cat: /etc/bandit_pass: Is a directory
bandit19@bandit:~$ ls /etc/bandit_pass
bandit0   bandit11  bandit14  bandit17  bandit2   bandit22  bandit25  bandit28  bandit30  bandit33  bandit6  bandit9
bandit1   bandit12  bandit15  bandit18  bandit20  bandit23  bandit26  bandit29  bandit31  bandit4   bandit7
bandit10  bandit13  bandit16  bandit19  bandit21  bandit24  bandit27  bandit3   bandit32  bandit5   bandit8
bandit19@bandit:~$ ./bandit20-do
Run a command as another user.
    Example: ./bandit20-do id
bandit19@bandit:~$ ./bandit20-do cat /etc/bandit_pass/bandit20
GbKksEFF4yrVs6il55v6gwY5aVje5f0j
bandit19@bandit:~$ cat /etc/bandit_pass/bandit20
cat: /etc/bandit_pass/bandit20: Permission denied
bandit19@bandit:~$
```
    

## Bandit20