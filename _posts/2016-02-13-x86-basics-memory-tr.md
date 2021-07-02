---
title: Exploitation Basics - Memory
author: Cihat Yildiz
date: 2016-01-23 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

En basit anlatımıyla memory, üzerinde yazma ve okuma işlemleri gibi işlemlerin gerçekleştirildiği bir elektronik donanımdır. PC donanımları üzerinde birçok hafıza mekanizması kullanılmaktadır. Bu yazıda RAM (Random Access Memory ) ve bir sonraki yazımızda da yazmaçlar üzerinde duracağız.  

# RAM – Random Access Memory

RAM olarak bilinen rastgele erişimli hafıza alanları geçici hafıza alanlarıdır ve işlemci ile birlıkte çalışan, donanımsal olarak işlemciye yakın duran bir alandır. Yazmaçlardan sonra en hızlı çalışan hafıza alanıdır. Bu alanlarda bulunan bilgiler geçici bilgilerdir. Fiziksel donanımın gücü kesildiğinde içinde barındırdığı bilgileri de kaybolmuş olur.

# Sanal Bellek

Sanal bellek mekanizması, fiziksel bellek alanının boyutundan bağımsız olarak çalışan her proses için bellek alanı sağlayan bir mekanizmadır.  Bu yapıya göre bir uygulama çalıştırıldığı zaman fiziksel hafıza alanına bağlı kalınmaksızın o proses için geniş ve kullanılabilir bir hafıza alanı ayırılır. Sanal olarak ayrımı yapılmış olan bu hafıza alanı işletim sistemi tarafından kontrol edilmektedir. Sanal bellek kullanımının iki temel gerekçesi vardır(Wikipedia):

* Programların konumlandırılması, belleğin programlar arasında etkin ve güvenli bir şekilde paylaşılması.
* Sınırlı boyuta sahip ana belleğin programlama ve kullanım açısından yaratacağı güçlükleri aşmak.

Bu nedenle bu yazı ve sonrasındaki yazılarda kullandığımız adresler sanal bellek mekanizmasına ait olan adres değerleridir.

# Bellek Bolumleri

İşletim sistemi üzerinde çalıştırılacak olan her proses, çalışma sırasında hafıza üzerinde kendine ait  bir alana ihtiyaç duymaktadır. Proses için ayrılan bu hafıza alanı ise işletim sistemi tarafında farklı amaçlar için kullanılmak üzere bölümlere ayrılmıştır. Bu bölümler den kısaca bahsedelim

## .text

Bu hafıza alanı çalıştırılan binary dosyanın kodlarının saklandığı hafıza lanıdır. Bu alanda uygulamaya ait makina kodları şeklinde bulunmaktadır. Uygulama çalıştırıldığında işlemci program counter vasıtası ile bu alandaki kodaları işleyerek uygulamanın çalışmasını gerçekleştirir.

## .data

Bu alanda yazdığınız program içerisinde global olarak tanımlanmış ve ilk değer atanmış değişkenler bulunmaktadır.

## .bss

Bu alanda da aynen .data segment alanında olduğu gibi global olarak tanımlanmış değişkenler tutulur. Ancak bu değişkenler kodlama sırasında ilk değer almamışlardır.

## Heap

Heap alanı programın çalışması sırasında dinamik olarak kullanılan bir alandır. Bu alanın kullanımı programcı tarafından kontrol edilmektedir. Programı bu kontrol ederken malloc(), new() gibi allocator fonksiyonlarını kullanmalıdır.

## Stack

Bu alan uygulama çalıştırılırken kullanılan özel bir alandır. Çalıştırılan fonksiyonların geçici değerleri bu alanda barındırılmaktadır. Bir fonksiyon sistemde oluşturulduğu zaman stack üzerinde de o fonksiyon ile ilgili bir alan oluşturulur. Fonksiyonun çalışması tamamlandıktan sonra ise o fonksiyona ait hafıza alanı kullanılmaz ve stack ona göre tekrar düzenlenir. Bu alan programcı tarafından yönetilmesine gerek duyulmayan bir alandır. Diğer hafıza alanlarından farklı olarak stack yüksek adres alanından düşük adres alanına doğru büyüme gösterir.

![upload-image](/assets/img/x86basics/memory_segments_tr.png)

Yukarıda bahrettiğimiz hafıza alanları ile aşağıdaki kod parçacığına baktığımız zaman daha iyi anlaşılır zannedersem.
Bu kod parçacığının değişlen adres değerlerine bakalım. GDB ile kodu çalıştırıp değşken adreslerini elde edelim.


GDB Kullanarak çalışan uygulama üzerinde değişken adreslerini görebiliyoruz. Bu durumda yazmış olduğumuz kod ile yukarıda gösterdiğimiz şekli ilişkilendirebiliriz. Bu şekil ile değişkenlerin hafızadaki konumları daha iyi anlaşılabilir.

![upload-image](/assets/img/x86basics/memory_segments_with_addresses_tr.png)


Bu yazıda yaptıklarımızı kendiniz de bir linux makine üzerinde gerçekleştirebilirsiniz. Registerlar, GCC ve GDB kullanımı gibi bazı konulara ileride değinedeğim. Soru ve yorumlarınız için bu sayfanın altına yorumlarınızı yazabilirsiniz.

# Kaynaklar:
* http://duartes.org/gustavo/blog/post/anatomy-of-a-program-in-memory/

