---
title: Exploitation Basics - Registers
author: Cihat Yildiz
date: 2016-01-23 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Yazmaçlar fiziksel olarak işlemcinin içinde bulunan hafıza alanlarıdır. Bu türden hafıza alanları işlem hızı en yüksek hafıza alanlarıdır. Ancak hızın yüksekliğinin yanında bu alanların boyutları da aynı oranda düşüktür. Burada ağırlıklı olarak 32 bit sistemler üzerinde kısaca  durmaya çalışacağız.

Genel Amaçlı Registerlar |	EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP
Segment Registerları	| CS, DS, SS, ES, FS, GS
Bayrak Registerları	| Zero Flag, Negative Flag
Instruction Pointer	| EIP
Kontrol Registerları | CR0 – CR4, CR3*

# Genel Amaçlı Yazmaclar

Bu registerların temel amacı aritmetik işlemler ile ilgili geçici ilgileri registerlarda bulundurmak yada bir adres göstericisini register alanında bulundurmakdır. Bu registerların hepsi özel bir amaç için tasarlanmış olmasına rağmen uygulamanın o an bulunduğu duruma göre farklı amaçlar için de kullanılabilirler. x86 tabanlı 32 bit işlemcilerde 8 adet genel amaçlı register bulunmaktadır. 32 bit sistemlerde bu registerlar 32 bit uzunluğundadır.

**EAX – Extended Accumulator Register:** İşlemci tarafından matematiksel işlemler için öncelikli olarak kullanılan registerdır. Genellikle bu register fonksiyonların geri dönüş değerlerini bir üst fonksiyonuna taşımak için kullanılır.

**EDX – Extended Data Register:** Genellikle büyük hesaplamalar yapılırken gereken extra alan için kullanılır. EAX registeri çarpma gibi bir matematiksel işlemde gerekli olan extra yeri EDX registerinden temin eder. Ayrıca bu register giriş/çıkış işlemler sırasında gösterici olarak da kullanılır.

**ECX – Extended Count Register:** ECX registeri döngüsel işlemlerinde sıklıkla kullanılmaktadır.

**EBX – Extended Base Pointer:** Bu register data segment içinde bir alanı östermek veya hesaplamalarda extra alan olarak kullanılmaktadır.ESI –

**Extended Source Index:** ESI Registeri, genellikle string yada döngü işlemleri sırasında okuma yapılacak yerin adresini gösterir.

**EDI – Extended Destination Index:** EDI Registeri, genellikle string yada döngü işlemleri sırasında yazma yapılacak yerin adresini gösterir.

**ESP – Extended Stack Printer:** ESP Registerinin kullanma amacı stack alanının en üst noktasının bilgisini tutar.

**EBP – Extended Base Pointer:** EBP Registeri stack yapısı içinde kullanılan yerel değişlenlere erişmek için referans olarak kullanılır.

![upload-image](/assets/img/x86basics/x86_registers.jpg)

Yukarıda görmüş olduğunuz diyagramda, x86 bir sistemde yer alan 16 ve 32 bit registerlar görülmektedir.

## Segment Yazmaclari

Segment registerlarının temel amacı korumalı mod hafıza metodu ile yönetilmesi ile, sanal hafıza içindeki spesifik segment alnanlarının korunmasını sağlamaktadır. Örneğin CS registeri Code segment alanının adresini barındırmaktadır.

## FLAG Registeri

FLAG Registerı, işlemci üzerinde gerçekleştirilen matematiksel işlemlerin durumlarını korumak için kullanılmaktadır. Farklı işlemciler bu registeri kullanırken farklı anlamlarda işlemler gerçekleştirebilirler. Aşağıdaki tabloda 32 bit flag değerleri ilgili bilgiler bulunmaktadır.

## Instruction Pointer

Instruction Pointer (IP) çalıştırılacak olan bir sonraki makina kodunun sanal memory adresini tutan yazmaçtır. Instruction pointer, sanal hafızadaki kod segment alanında bulunan kodları sırasıyla işler. JMP yada CALL gibi hafıza üzerinde sıçrama yapan bir konuta gelene kadar bu sıralı işlemini sürdürür. 32 Bit sistemlerde Instruction Pointer EIP, 64 bit sistemlerde ise RIP olarak adladırılır.Instruction pointer, bir uygulama tarafında doğrudan kontrol edilemez. Uygulamalar içinde bulunan JMP,CALL, RET, IRET gibi kontrol-transfer komutları yardımı ile dolaylı yoldan kontrol edilebilirler. EIP değeri fonksiyonların geri dönüş adreslerinde yapılan manüpilasyonlar ile kontrol edilebilirler.

## Kontrol Registerları

Intel 32 Bit işlemcilerde 5 adet kotrol registeri bulunmaktadır. Bu registerlardan en önemlisi olan CR3 kullanılaın sayfa klasör yapısının başlangıç alanını göstermektedir.

## Little Endian – Big Endian

Farklı işlemciler memory üzerine yazdıkları verileri yazma şekilleri de farklı olabilir. Örneğin Intel işlemciler veriyi hafızaya yazarken adres alanına düşük değerli byte değerinden başlayarak yazarlar(little endian). SPARC gibi işlemciler de düşük adres alanına yüksek değerli byte değerinden başlayarak hafızaya yazarlar(big endian). Siz de eğer memory üzerinde test veya incelmemeler yapıyorsanız bu durumu dikkate almanız gerekecektir.

![upload-image](/assets/img/x86basics/endians.png)

Bir sistemin hangi enndiannnes yapisini kullandigini bulmak ici basit bir C codu isiinze yarayacaktir.

```c
#include <stdio.h> 
int main()  
{ 
   unsigned int i = 1; 
   char *c = (char*)&i; 
   if (*c)     
       printf("Little endian"); 
   else
       printf("Big endian"); 
   getchar(); 
   return 0; 
}
```

```bash
root@kali:~# gcc endian.c -o endian
root@kali:~# chmod +x endian 
root@kali:~# ./endian
Little Endian
```

## 64 Bit Sistemler

Çok kısaca bahsetmek gerekirse, 64 bit sistemler mimari olarak 32 bit sistemlerin genişletilmiş halidir diyebiliriz. Registerler 64 bit sistemlerde 64 bit uzunluktadırlar. Buna ek olarak register adlandırmalarında baş harfe R öneki getirilmiştir. 32 Bit sistemlerde gördüğümüz registerlara ek olarak yeni registerlar da eklenmiştir.

## WOW64

İşlemcilerin 64 bit yapıya geçmesinden bu zamana işletim sistemleri ve yazılım geliştiricilerin 64 bit sistemlere geçişi halen devam etmektedir. Microsoft, Adobe gibi firmalar uygulamlarında 64 bit desteği getirmelerine rağmen birçok firma halen 32 bit uygulamalar geliştirmektedirler. Bu durum, 64 bit işletim sistemlerinde 32 uygulamaları destekleyen bir yapının gerekliliğini ortaya çıkartmıştır.

Microsoft firması bu problemi aşmak için “Windows 32-bit On Windows-64” (WOW) mekanizmasını geliştirmiştir. WOW mekanizması 32 bit windows uygulamalarını 64 bit windows da çalıştırabilen DLL’lerden oluşmaktadır.
