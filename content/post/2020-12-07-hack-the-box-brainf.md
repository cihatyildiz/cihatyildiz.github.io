---
title: Writeup - Hack The Box - Brainfuck
author: Cihat Yildiz
date: 2020-10-24 20:55:00 +0800
categories: [hackthebox]
tags: [ctf]
pin: false
---

In this post, I will show how I resolve the machine called Brainfuck. The difficulty of this macihne is hard. 
<!--more-->
![upload-image](/assets/img/htb/htb-brainfuck.png)
 

# Port and Service Discovery

Lets start with a basic nmap scan

```
root@kali:/home/kali# nmap 10.10.10.17
Starting Nmap 7.91 ( https://nmap.org ) at 2020-11-02 23:03 EST
Nmap scan report for 10.10.10.17
Host is up (0.094s latency).
Not shown: 995 filtered ports
PORT    STATE SERVICE
22/tcp  open  ssh
25/tcp  open  smtp
110/tcp open  pop3
143/tcp open  imap
443/tcp open  https

Nmap done: 1 IP address (1 host up) scanned in 7.41 seconds
root@kali:/home/kali# 
```

version scanning

```
root@kali:/home/kali# nmap -sS -sV -p- 10.10.10.17
Starting Nmap 7.91 ( https://nmap.org ) at 2020-11-02 23:08 EST
Nmap scan report for 10.10.10.17
Host is up (0.084s latency).                                                                                                                      
Not shown: 65530 filtered ports                                                                                                                   
PORT    STATE SERVICE  VERSION                                                                                                                    
22/tcp  open  ssh      OpenSSH 7.2p2 Ubuntu 4ubuntu2.1 (Ubuntu Linux; protocol 2.0)                                                               
25/tcp  open  smtp     Postfix smtpd                                                                                                              
110/tcp open  pop3     Dovecot pop3d                                                                                                              
143/tcp open  imap     Dovecot imapd                                                                                                              
443/tcp open  ssl/http nginx 1.10.0 (Ubuntu)                                                                                                      
Service Info: Host:  brainfuck; OS: Linux; CPE: cpe:/o:linux:linux_kernel                                                                         
                                                                                                                                                  
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .                                                    
Nmap done: 1 IP address (1 host up) scanned in 166.69 seconds                                                                                     
root@kali:/home/kali# 
```

script scan 

```
root@kali:/home/kali# nmap -sS -sV -sC -O -p22,25,110,143,443 10.10.10.17
Starting Nmap 7.91 ( https://nmap.org ) at 2020-11-02 23:12 EST                                                                                   
Nmap scan report for 10.10.10.17                                                                                                                  
Host is up (0.086s latency).                                                                                                                      
                                                                                                                                                  
PORT    STATE SERVICE  VERSION                                                                                                                    
22/tcp  open  ssh      OpenSSH 7.2p2 Ubuntu 4ubuntu2.1 (Ubuntu Linux; protocol 2.0)                                                               
| ssh-hostkey:                                                                                                                                    
|   2048 94:d0:b3:34:e9:a5:37:c5:ac:b9:80:df:2a:54:a5:f0 (RSA)                                                                                    
|   256 6b:d5:dc:15:3a:66:7a:f4:19:91:5d:73:85:b2:4c:b2 (ECDSA)                                                                                   
|_  256 23:f5:a3:33:33:9d:76:d5:f2:ea:69:71:e3:4e:8e:02 (ED25519)                                                                                 
25/tcp  open  smtp     Postfix smtpd                                                                                                              
|_smtp-commands: brainfuck, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN,                                  
110/tcp open  pop3     Dovecot pop3d
|_pop3-capabilities: SASL(PLAIN) USER PIPELINING TOP UIDL CAPA RESP-CODES AUTH-RESP-CODE
143/tcp open  imap     Dovecot imapd
|_imap-capabilities: SASL-IR IDLE LITERAL+ LOGIN-REFERRALS ID have ENABLE Pre-login listed more capabilities OK AUTH=PLAINA0001 post-login IMAP4rev1
443/tcp open  ssl/http nginx 1.10.0 (Ubuntu)
|_http-server-header: nginx/1.10.0 (Ubuntu)
|_http-title: Welcome to nginx!
| ssl-cert: Subject: commonName=brainfuck.htb/organizationName=Brainfuck Ltd./stateOrProvinceName=Attica/countryName=GR
| Subject Alternative Name: DNS:www.brainfuck.htb, DNS:sup3rs3cr3t.brainfuck.htb
| Not valid before: 2017-04-13T11:19:29
|_Not valid after:  2027-04-11T11:19:29
|_ssl-date: TLS randomness does not represent time
| tls-alpn: 
|_  http/1.1
| tls-nextprotoneg: 
|_  http/1.1
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.10 - 4.11 (92%), Linux 3.13 (92%), Linux 3.16 (92%), Linux 3.16 - 4.6 (92%), Linux 3.18 (92%), Linux 3.2 - 4.9 (92%), Linux 4.2 (92%), Linux 3.12 (90%), Linux 3.13 or 4.2 (90%), Linux 3.8 - 3.11 (90%)
No exact OS matches for host (test conditions non-ideal).
Service Info: Host:  brainfuck; OS: Linux; CPE: cpe:/o:linux:linux_kernel

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 56.71 seconds
root@kali:/home/kali#
```
There is an interesting information here about the domain names in certificate. See the below line. 

```
Subject Alternative Name: DNS:www.brainfuck.htb, DNS:sup3rs3cr3t.brainfuck.htb
```

Based on this information, if I add "www.brainfuck.htb" and "sup3rs3cr3t.brainfuck.htb" in my hosts file.

udp port scan

```
root@kali:/home/kali# nmap -sU -p- -oA udp 10.10.10.17
Starting Nmap 7.91 ( https://nmap.org ) at 2020-11-03 11:20 EST
Nmap scan report for www.brainfuck.htb (10.10.10.17)
Host is up (0.11s latency).
Not shown: 65532 open|filtered ports
PORT    STATE  SERVICE
110/udp closed pop3
143/udp closed imap
443/udp closed https

Nmap done: 1 IP address (1 host up) scanned in 1411.09 seconds
root@kali:/home/kali#
```
