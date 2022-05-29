---
title: Reversing Challenge - Hack The Box - Impossible Password
author: Cihat Yildiz
date: 2021-07-25 20:55:00 +0000
categories: [hackthebox]
tags: [ctf]
pin: false
---

In this blog post, we will see the solution of a Hack-The-Box reversing challenge called "Impossible Password". Its been a long time solving some reversing puzzles :) 
<!--more-->
Let's check the binary first. 

```bash
$ file impossible_password.bin 
impossible_password.bin: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=ba116ba1912a8c3779ddeb579404e2fdf34b1568, stripped
```

This is a 64-bit ELF binary. So, we can use *objdump* command to see imported functions in this application

```bash
$ objdump -T impossible_password.bin 

impossible_password.bin:     file format elf64-x86-64

DYNAMIC SYMBOL TABLE:
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 putchar
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 printf
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 __libc_start_main
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 srand
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 strcmp
0000000000000000  w   D  *UND*  0000000000000000              __gmon_start__
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 time
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 malloc
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.7   __isoc99_scanf
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 exit
0000000000000000      DF *UND*  0000000000000000  GLIBC_2.2.5 rand
```

We can the that the application uses a couple functions from *glibc* library. We can use this information during our analysis. 

```bash
$ strings impossible_password.bin 
--- SNIP ---
printf
malloc
strcmp
__libc_start_main
GLIBC_2.7
GLIBC_2.2.5
SuperSeKretKey
%20s
GCC: (GNU) 4.8.5 20150623 (Red Hat 4.8.5-11)
--- SNIP ---
```

When I search strings in the application I can see many information, but looks like "SuperSeKretKey" is different than others. Now let's run the application and see how it works.

```bash
$ ./impossible_password.bin 
* asdada
[asdada]
```

The application shows what I enter as an input. Now I will use ltrace application to see if there is any library functions are used. 

```bash
$ ltrace ./impossible_password.bin                                                                                                                                                                                                                     1 ⨯
__libc_start_main(0x40085d, 1, 0x7ffdb1afea48, 0x4009e0 <unfinished ...>
printf("* ")                                                                                                                                                 = 2
__isoc99_scanf(0x400a82, 0x7ffdb1afe930, 0, 0* testString
)                                                                                                               = 1
printf("[%s]\n", "testString"[testString]
)                                                                                                                               = 13
strcmp("testString", "SuperSeKretKey")                                                                                                                       = 33
exit(1 <no return ...>
+++ exited (status 1) +++
```

Basically what happens is, the application compare my input with "*SuperSeKretKey*". if my input doesn't match with the string data, exit the program. 

```bash
$ ltrace ./impossible_password.bin                                                                                                                                                                                                                   130 ⨯
__libc_start_main(0x40085d, 1, 0x7ffed7da77a8, 0x4009e0 <unfinished ...>
printf("* ")                                                                                                                                                 = 2
__isoc99_scanf(0x400a82, 0x7ffed7da7690, 0, 0* SuperSeKretKey
)                                                                                                               = 1
printf("[%s]\n", "SuperSeKretKey"[SuperSeKretKey]
)                                                                                                                           = 17
strcmp("SuperSeKretKey", "SuperSeKretKey")                                                                                                                   = 0
printf("** ")                                                                                                                                                = 3
__isoc99_scanf(0x400a82, 0x7ffed7da7690, 0, 0** testString
)                                                                                                               = 1
time(0)                                                                                                                                                      = 1626591042
srand(0x9489d839, 10, 0x930c3128, 0)                                                                                                                         = 0
malloc(21)                                                                                                                                                   = 0x22e9ac0
rand(0x22e9ac0, 21, 33, 0x22e9ad0)                                                                                                                           = 0x6c8094
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac0, 94)                                                                                                          = 0x5436d442
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac1, 94)                                                                                                          = 0xa242547
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac2, 94)                                                                                                          = 0x2a045efa
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac3, 94)                                                                                                          = 0x379c34a0
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac4, 94)                                                                                                          = 0x75ec02c3
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac5, 94)                                                                                                          = 0x74091ee1
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac6, 94)                                                                                                          = 0x22097b52
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac7, 94)                                                                                                          = 0x156e190a
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac8, 94)                                                                                                          = 0x624047de
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ac9, 94)                                                                                                          = 0x6893f2f1
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9aca, 94)                                                                                                          = 0x17211d98
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9acb, 94)                                                                                                          = 0x264b215c
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9acc, 94)                                                                                                          = 0x106a3853
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9acd, 94)                                                                                                          = 0xce7992a
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ace, 94)                                                                                                          = 0x3d0562f5
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9acf, 94)                                                                                                          = 0x14484045
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ad0, 94)                                                                                                          = 0x4e8f4c28
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ad1, 94)                                                                                                          = 0x2b6ff460
rand(0x7f3b53b9c740, 0x7ffed7da75f4, 0x22e9ad2, 94)                                                                                                          = 0x33cf64a2
strcmp("testString", "q3\\?C4<=c'~G#$[h8Kck")                                                                                                                = 3
+++ exited (status 3) +++                                                                                                                                                                                                                                  
```

Once we use the key in the first step we see another step. After I enter the second input the applications runs number of rand function before comparison 

We need to analyze the binary. I will use radare2 for binary analysis.  

```bash
$ r2 -w impossible_password.bin
[0x004006a0]> s main
[0x0040085d]> aaa
[x] Analyze all flags starting with sym. and entry0 (aa)
[x] Analyze function calls (aac)
[x] Analyze len bytes of instructions for references (aar)
[x] Check for vtables
[x] Type matching analysis for all functions (aaft)
[x] Propagate noreturn information
[x] Use -AA or aaaa to perform additional experimental analysis.
[0x0040085d]> s main
[0x0040085d]>
```

Let's disassembly the application

![upload-image](/assets/img/htb/htb_reverse_impossible_password_1.png)

In the assembly code we can see the *SuperSeKretKey* in the code. When we review the rest of the code, we see that there are two *strcmp* function in the code. Those functions used for to compare user input. 

![upload-image](/assets/img/htb/htb_reverse_impossible_password_2.png)

As we see above, in the line 0x0040094f, application runs a function. When you see the details this function is to generate random string number. After this line, the generated string is used in the second *strcmp* operation. That means we will see different strings in every run and we won't be able to match strings. The code never will come to the address *0x00400971*. I assume the flag for this challenge is stored in the function *fcn.00400978*.

To access the function *fcn.00400978,* we can add JMP just before 0x00400968 or change the instruction at 0x00400968. Adding NOPs would be a good option i think. I added one NOP but I got "segmentation fault". So you need to add minimum 2 NOPs in the app

![upload-image](/assets/img/htb/htb_reverse_impossible_password_3.png)

Next step I removed the JNE instruction and added 9090 instead. After the change we can run the code again and get the flag. 

![upload-image](/assets/img/htb/htb_reverse_impossible_password_4.png)

```
Radare2 Tips:
V - for visual view
c - for cursor navigation
i - insert instruction
s <functions> - to select the function
pdf - print function details
aaa - analyze all referenced code 

```
