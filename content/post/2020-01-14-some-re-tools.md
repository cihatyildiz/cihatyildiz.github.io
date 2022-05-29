---
title: Some Reverse Engineering Tools
author: Cihat Yildiz
date: 2020-01-14 20:55:00 +0800
categories: [Reverse Engieering, Notes]
tags: [writing]
pin: false
---

Reverse engineering is analyzing an object, system or application to see how it works in order to understand the design and the behavior. If you are in the cybersecurity domain, you may use several different tools that help on the reverse engineering process. You may use your reverse engineering skills on many different projects such as exploit development and malware analysis. In this post, I want to write about some reverse engineering tools that you may use during your research. To be honest, I can’t cover all the tools in this post. But, I would like to point out some useful ones. 

![upload-image](/assets/img/sample/re_pic.png)

## Debuggers

Debuggers help you control the environment and see the memory and CPU values in the virtual memory of an application and hardware values. 

* OllyDbg
* Immunity Debugger
* WinDbg
* GDB

In Windows OS, OllyDbg and immunity debugger are fully featured debuggers that support additional plugin and python scripts. These tools are user-mode debuggers for x86 executable files. They can not access to OS kernel space. There is one more debugger that I want to talk about for the windows systems is called WinDbg. This is a tool developed by Microsoft. This tool has a comprehensive tool for Windows systems. You can do kernel-level debugging and debug x64 executable files.

The most powerful tool for Unix like systems is GDB which is “GNU Debugger”. This is the debugger for Linux based systems including Mac systems. And, This can debug x86 and x64 binaries. This tool can work in ring0 and ring3 zones in operating systems.

## Disassemblers

Dissassammblers regularly convert binary code into the assembly code. There a number of disassemblers for different platforms I will talk about only for some of them. 

* IDA Pro
* Ghidra
* Radare2 
* Binary Ninja
* Hopper

The most famous one of the disassemblers is IDA Pro. This is the most powerful and comprehensive and expensive disassembler tool. it supports many different binary formats like x86, x64, .NET, etc. 

Ghidra has been published earlier in 2019 by the NSA. This is a reverse engineering tool for security researchers to analyze malicious code and malware like viruses, and can give cybersecurity professionals a better understanding of potential vulnerabilities in their networks and systems.it also supports a number of executables of different systems. 

Radare2 is a reverse engineering tool that is free and open-source. This tool utilizes a sweet command-line interface as opposed to a graphical one. 

Binary Ninja is a disassembler that has a more programmatic approach to reverse engineering. This brings modern features and plugins to reverse engineering. And also, Binary Ninja supports Linux, windows and mac systems. Actually, it is a good alternative to IDA Pro.

The last tool in the list is Hopper which is another disassembler runs on Mac and Linux systems. This tool supports Windows, Linux and Mac executables. 

## Decompilers 

Decompilers are more advanced tools for reverse engineering. Basically, these tools convert binary or assembly code into higher-level programming languages such as Java or C. I would like to note that decompiler tools are generally not perfect. Because compiler loses alt of information when you compile code and generate a binary. But it is still useful for reverse engineers to understand the flow. 

* Hex-Ray decompiler
* .Net Reflector
* VB Decompiler
* Java Decompiler

There are several decompilers for different platforms. Here I would like to talk about “Hex-Rays Decompiler”. This is a plugin for IDA disassembler. This is an expensive plugin to convert binary to C/C++ code. It makes the code easier to understand. 

[.Net reflector][11] is a powerful and fully-featured decompiler for .Net binary files. it converts C#, VisualBasic binary files to source code. [VB Decompiler][12] is a decompiler for visual basic applications. This tool supports native and portable compiled files.

## HEX and PE Editors

Hex editors are used to editing or modify binary files. I can say that all of them can edit binary files and executable files. Some of them can parse specific files and their headers. You can see the header content of the files.

* Hex workshop
* WinHex
* HIEW
* 101 Editor

The Hex Workshop is a complete set of hexadecimal editing and development tool that runs in Windows. You can edit different files in hexadecimal level and change the content. It integrates advanced binary editing and data interpretation and visualization with the ease and flexibility of a modern word processor. 

One my favorite is 010 Editor that is software that you can edit text file, binary file and many different file formats. The tool has ability to parse different file formats and see the file structure. Also you can create a parser for specific file formats. You can see more information in the SweetScape website 

## Monitoring tools

There is a number of monitoring tools that we can use. Basically, those tools basically used to understand the behavior of a binary application. 

* Process explorer
* Process monitor
* API Monitor

Sysinternals tool suite contains number of great tools for monitoring the running process. I just mentioned two of them. They can get lots of information about the process such as threats, registry activities, environments, network connections, etc. Also, You can visit [Sysinternals website][13] to check all the tools. 

lastly, rihitab.com has a tool called API Monitor for monitoring API calls of a binary application. It supports the applications of in x86 and x64 platforms. So, You can monitor your API calls in your application. It is a very useful tool for reverse engineers.

[1]: https://blog.cihatyildiz.com/ "Cihat's Security Notes"
[2]: https://blog.cihatyildiz.com#content "Skip to content"
[3]: http://blog.cihatyildiz.com
[4]: https://blog.cihatyildiz.com/research/
[5]: https://blog.cihatyildiz.com/notes/
[6]: https://cihatyildiz.github.io/2016-06-12-win32-sys-prog-notes/
[7]: https://cihatyildiz.github.io/2016-01-11-linux-sys-programming-notes/
[8]: https://blog.cihatyildiz.com/about-me/
[9]: https://blog.cihatyildiz.com/some-reverse-engineering-tools/#respond
[10]: https://blog.cihatyildiz.com/wp-content/uploads/2019/12/re_pic.png
[11]: https://www.red-gate.com/products/dotnet-development/reflector/
[12]: https://www.vb-decompiler.org/
[13]: https://docs.microsoft.com/en-us/sysinternals/
