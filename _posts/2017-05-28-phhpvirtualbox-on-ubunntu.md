---
title: Using Virtualbox/phpVirtualbox on Ubuntu Server
author: Cihat Yildiz
date: 2017-05-28 20:55:00 +0800
categories: [writeup]
tags: [writing]
pin: false
---

Bu yazıda Ubuntu Server LTS üzerine Virtualbox sanallaştırma ortamı ve bu sanallaştırma ortamını web üzerinden yönetebilmek için geliştirilen phpVirtualbox sisteminin kurulumundan bahsedeceğiz.
Öncelikle yapılması gerelen bir ubuntu server kurulumu gerçekleştirmek. Kurulum işlemleri tamamlandıktan sonra gerekli paketlerin sisteme kurulumlarını gerçekleştirelim.

SSH sunucusunun kurulmasi uzaktan erisim icin onemli

```
#apt-get install ssh openssh-server
```

Sonrasinda makinanin guncellenmesi gerekiyor.
```
#apt-get update
#apt-get upgrade
#reboot
```

Sistem web uzerinden hizmet verecegi icin web sunucu ortaminin da kurulmasi gerekmektedir.
```
apt-get install apache2 apache2.2-common apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-mod-php5 php5 php5-common php5-gd php5-mysql php5-imap phpmyadmin php5-cli php5-cgi libapache2-mod-fcgid apache2-suexec php-pear php-auth php5-curl php5-mcrypt mcrypt php5-imagick imagemagick libapache2-mod-suphp libruby libapache2-mod-ruby libapache2-mod-python libapache2-mod-perl2
```

# Oracle Virtualbox Kurulumu

Virtualbox kurulumu islemine gecebiliriz. Bunun icin https://www.virtualbox.org/wiki/Linux_Downloads adresinden istedigimiz uygulama surumunu indirebiliriz. Yada paket kaynagina ekleme yapabiliriz. Ben burada paket kaynagini eklemeyi tercih ediyorum. Asagidaki kaynagi /etc/apt/sources.lst icerisine ekliyorum
```
deb http://download.virtualbox.org/virtualbox/debian precise contrib
```

Oracle’in apt icin kullanilan acik anahtarini sisteme eklemeliyiz.

```
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
```

Sonrasinda Virtualbox uygulamasini rahatlikla indirip kurabiliriz. Ben phpvirtualbox ile uyumlu olmasi icin 4.2 versiyonunu kullanmayi tercih ediyorum.

```
sudo apt-get update
sudo apt-get install virtualbox-4.2
```

VMware host icin gerekli olan kernel modullerini de ayrica kurmamiz gerekmektedir.

```
sudo apt-get install dkms
```

Burada unutulmamasi gereken bir diger islem de virtualbox’u webservis uzerinden kontrol edebilmek icin bir eklenti kurmak. Bunun için kullandığım virtualbox versiyonu için extension pack aşağıdaki gibi indirilir ve kurulur.

```
wget http://download.virtualbox.org/virtualbox/4.2.24/Oracle_VM_VirtualBox_Extension_Pack-4.2.24-92790.vbox-extpack
VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.2.24-92790.vbox-extpack
```

# phpVirtualbox kurulumu
Virtualbox kurulumunu tamamladiktan sonra, virtualbox sistemimizi uzaktan yonetmemizi saglayacak olan phpvirtualbox web uygulamasini kuralim.

Öncelile uygulamayi web sayfasindan indirelim.

```
wget http://downloads.sourceforge.net/project/phpvirtualbox/phpvirtualbox-4.2-8.zip
```

bundan sonra yapilmasi gereken sadece config.php dosyasi icerisinde virtualbox sistemini kullanacak olan kullanıcı bilgilerinin eklenmesi gerekmektedir.
```
var $username = 'vbox';
var $password = 'pass4vbox';
```
simdi web browser uzerinde sunucu baglantisini gerceklestirelim. Bu sistemin varsayilan kullanıcı ve parolası admin/admin şeklinde olacaktır.

![upload-image](/assets/img/sample/phpVirtualBox-Web-Console.png)

Sisteme giriş yaptıktan sonra kullanmaya başlayabilirsiniz.

![upload-image](/assets/img/sample/phpVirtualBox-VirtualBoxWebConsole2.png)