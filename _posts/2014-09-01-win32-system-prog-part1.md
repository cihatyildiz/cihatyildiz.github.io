---
title: Win32 System Programming - Part 1
author: Cihat Yildiz
date: 2014-09-01 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

This note has been created in the “Windows System Programming” course that taken from “C and System programmers Accosiaion” in 2014. Kaan Arslan was the lecturer in this course.

Bu yazida, daha once yayinlamis oldugum C ve sistem prgramcilari derneginden almis oldugum windows sistem programlama kursu kurs notlarini tekrar bir araya getirdim. Bu kurs C ve System programcilari dernegi tarafindan 2014 yili eylul ayinda alinisti.

Temel Kavramlar
---------------

İşletim sistemi bilgisayar temel donanımını yöneten kullanıcı ile sistem arasında arayüz oluşturan bir sistem yazılımıdır. Sistemler temelde iki bolume ayrilirlar.

*   kernel (cekirdek)
*   Shell (kabul)

Windows daki desktop uygulamasi bir kabuktur. Aynı şekilde Linuxda da bash bir bir kabuktur. İşletim Sistemi Alt Sistemleri

*   Proses yöneticisi
*   Dosya sistemi
*   Network alt sistemi
*   Programın RAM’de nerelere yerleştirileceğine karar veren bellek yöneticisi
*   Çizelgeleyici

İşletim Sistemlerinin Sınıflandırılması

*   Multiprocessing sistemleri – ayni anda birden fazla programi calistirabilen sistemleri
*   preemptive
*   non-preemptive

Single processing sistemler – ayni anda tek bir programi calistirabilen sistemleri – Cizelgeleyici sisteme gore

*   Realtime isletim sistemleri
*   Hard realtime
*   Soft realtime

Desktop isletim sistemi kernele gore

*   monolitik kernel (linux)
*   microkernel (windwos) Darvin > zunu >

mac sistemlerin cekirdegi acik bir sistemdir. hibrit bir sistemdir.macosx internals kitaplari okunmasi gereken onemli kitaplar www.tiobe.com index icerisinde yapilan arastirmalarda Functional paradigma – f# haskel etc.

Isletim sistemi sistem fonksiyonlari

*   windows da api fonksiyonlari
*   linux da system calls olarak adlandirilir.

isletim sistemleri pure c ile yazilmistir. Object Oriented teknik performansi azaltici ozelliklere sahip oldugu icin isletim sistemlerinde kullanilmaz OS icerisindeki her fonksiyon cagirilamaz. sana izi erilen fonksiyonlari kullanabilirsin api fonksiyonlari ni bimek tam olarak yeterli degil. Bu fonksiyonlarin isleyis mantiklarini da bilmek gerekmektedir.

İşlemcilerin Koruma Mekanizması
-------------------------------

isletim sistemi ram da calisan bir kod. Ramz icerisinde farkli programlarin calistigi alanlara mudahale etmemelk gerekmektedir. Bir process ile kendine ait bir ram bolgesine erismek istedigin zaman isletim sistemi tarafinda engellenir. Buna koruma mekanizmasi denir. belirli komutlari da kullanamzsin Bu nedenle uygulamalar ikiye ayrilir.

*   user mode (butun servis ve processlere erisemez ve butun komutlari calistiramazsin, ozel makina koutlarini calistimazsin.)
*   kernel mode (her seyi yapar. butun sistem cagrilarina erisebilir.) Process Kavramı calismakta olan programlara process denir. bir process in gorevi bitikten sonra process sonrlanir. process ile task sozcukleri bazi sistemlerde kucuk fakliliklari olsa da temel de aynidir. 
*   Bir process iki farkli modda calisir
*   kernel mod
*   user mod
*   Bir process belli bir anda user modda ve kernel modda ola bilir. Process user modda iken bellekte istedigi yere erisemez ve istedigi makina kodlarini kullanamaz kernel modda iken herseyi yapabilir.
*   Hic bir guvenlik onlemine takilmadan calisan bir uygulama yazabilmek icin device driver yapmak lazim.

### fopen – createfile

*   kernel moda gecisin zaman maliyeti var
*   isletim sisteminin pekcok sistem fonksiyonu bellekte cesitli veri yapilarina erismekte ve cesitli makina komutlarini kullanmaktadir. Bunun saglanabilmesi icin user moddan kernel moda gecis mekanizmasi olusturlmustur. Ornegin intel terminolojisinde bu mekanizmayi saglayan yapiya kapi(gate) denir.
*   isletim sistemlerini yazanlar sistem fonksiyonlarini kapilara yerlestirmistir. Bu fonksiyonlar cagirildiginda User moddan kernel moda otomatik gecis gerceklesir. cagirma bitince yeniden user moda donus yapilir.
*   Opensource windows > reactos
*   windows da native api > “windows 2000 native api’s” kitabi incelenebilir.
*   User moddan kernel moda gecis genel olarak zaman kaybina neden olmaktadir.

### Zaman Paylaşımlı çalışma

*   quanta suresi 20 ms
*   cizelgeleme algortmalari var
*   task swirch – context switck
*   Hardware interrapt olusturulur.
*   Windows ve linux makinalari da 1 ms timer kesmeleri var. Bu kesme ile task switch
*   Isletim sistemleri birden fazla processi zaman paylasimli olarak calistirirlar. Bir process bir surecalistirilir. sonra calismasina ara verilip kalinan yer not alinir. Sonra digeri kalinan yerden devam ettirilir. Bu parcali calisma suresine quanta veya quanta suresi denilir. Quanta suresi doldugunda gecis ansizin donanim kesmesi yolu ile yapilir. Bu tur sistemlere preemptive sistemler denir.
*   Bu tur olmayan sistemler cooperative sistemlerdir.
*   Bu konudaki detaylar isletin sisteminin uyguladigi cizelgeleme algoritmasina baglidir.
*   quanta degirinin degisimi ??

### throughput – birim zamanda yapilan is

*   Cizelgeleme isleminin detaylari genellikle karasiktir. Bir takim kalibrasyonlar yapilmaktatdir.
*   Masa ustu isletim sistemleri round robin scheduking ve turevlerini kullanir bu sistemde oncelik grupleri ve quanta suresi farkliliklari olusturulabilir.
*   cok islemcili sistemlerde cizelgeleme algoritmalari dafarkliliklar gostermektedir. Ornegin bazi sistemlerde her islemci yada cekirdek icin ayri bir kyruk olusturulur. Bazilarinda ise tek bir kuyruk vardir.

Bir process islemini bir cpu da kullanmak icin paralel processing (processor efinity)  openmp  .nette paralel task library

### Processlerin Bloke Olması – Process Blocking

 Dissal bir olayi baslatan process veya thread ler o olay gerceklesene kadar isletim sistemi tarafindan gecici olarak cizelge disina cikartilirlar. Boylece o olayin gerceklesmesi beklenirken bosa cpu zamani harcanmamis olur. Bu surece processin bloke olmasi denilmektedir.  Bir processin yasam dongusu.tipik olarak soyledir. (Sekil-1)

Kitap : Windows via c/c++ Kitap : Understanding the linux kernel

### Proses Kontrol Blogu – Process Control Block

*   Linux da task-struct Windows da eproct,
*   Bir processin tum bilgileri ismine process kontrol blogu denilen bir veri yapisinda tutulur. Bu bilgilerden bazilari process id’s, processin erisim haklari (process credentals), procesin calisma dizini (cwd), tahsis ettigi bellek alanlari, tahsis ettigi dosyalar, cevre degiskenleri, task swirch sirasinda kalinan degerleri berlirten yazmac degerleri
*   process control block (wikipedia dan incele)
*   linux kaynak kodunu incelemek icin o understand c++ kullanilabilir. o lxr.linux.no
*   – buun linux kodlarinin o source nav source code navigator. o lind source code analiz