---
title: Create an Encrypted File Container by Using Luks
author: Cihat Yildiz
date: 2017-04-11 20:55:00 +0800
categories: [writeup]
tags: [writing]
pin: false
---
```
#dd if=/dev/urandom of=/dosya/yolu/guvenlidosya bs=1M count=500
```

Eger kurumsal veya kendinize ait verileri sifreli bir alanda tutmak icin luks ile sifreli bir alan olusturup verilerinizi bu anda tutabilirsiniz. Burada 500 mb boyutunda bir sifreli dosya alani olusturacagiz.

dosya bir /dev dizini altindaki bir loop surucusune baglanir.
```
#losetup /dev/loop7 guvenlidosya
```

baglanmis olan loop surucusu sifrelenir.
```
#cryptsetup --verbose --verify-passphrase luksFormat /dev/loopX
```
sifrecozulur ve  /dev/mapper/salla ile eslestirilir
```
#cryptsetup luksOpen /dev/loop7 salla;
```
dosya sistemi olusturulur.
```
#mkfs.ext4 /dev/mapper/salla;
```
baglama islemi
```
#mount /dev/mapper/salla /mnt/baglama_noktasi
```
yapilan bu islemleri asagidaki gibi sirasi ile calistirabilir veya script olarak kaydedip bu islemleri gerceklestirilebilinir.

Mount:
```
#losetup /dev/loop7 guvenlidosya
#cryptsetup luksOpen /dev/loop7 salla
#mount /dev/mapper/salla /mnt/baglama_noktasi
```

Umount:
```
#umount /mnt/baglama_noktasi
#cryptsetup luksClose /dev/mapper/salla
#losetup -d /dev/loop7
```
