---
title: Linux System Programming - Part 6
author: Cihat Yildiz
date: 2014-11-17 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Prosesler Arası Haberleşme (Interprocess Communication)
-------------------------------------------------------

Bir prosesin başka bir prosese bilgi gönderip almasına prosesler arası haberleşme denilmektedir. Prosesler arası haberleşme ikiye ayrılmaktadır.

*   Aynı PC’de prosesler arası haberleşme
*   Network altında birbirine bağlı farklı makinaların prosesler arası haberleşme. Aynı makinanın prosesleri arasında haberleşömelerde işletim sistemine özgü çeşitli sistemler kullanılmaktadır. Her nekadar sistemden sisteme değişse de pekcok sistem benzer yöntemleri kullanmaktadır. Farklı makinaların prosesleri arasındaki haberleşmelerde belirlenmiş bir takım kurallara uyulması gerekmektedir. Bunun için pekçok protokol ailesi varsa da en yaygın kullanılan IP ailesidir.

#### Aynı Makinanın Prosesleri Arasında Haberleşme

##### Boru Haberleşmeleri

Boru haberlesmesinde tipik olarak iki proses vardir. Bir proses boruya yazma yapar, digeri de borudan okuma yapar. Eger yazma yapan proses hizli davranir digeri yavas kalirsa boru dolar. Dolu bir boruya yazmak istendiginde write() fonksiyonu bloke olur. Karsi taraf borudan okuma yaptiginda boruda yer acilir ve yazan taraf yazmaya devam eder. Benzer bicimde yazan taraf geri kalmis ise okuyan taraf borunun bos oldugunu gordugunda read fonksiyonunda bloke olusur. Taki diger taraf birseyler yazana kadar. Bu haberlesme once yazan tarafin sonlanmasi ile sonlanmalidir. Bu durumda okuyan taraf once boruda kalanlari okur sonra yazantarafin boruyu kapattigini anlar. O da boruyu kapatir. Borular tamamen dosya mekanizmasi ile iliskilendirilmistir. Yani borular icin birer betimleyici ve dosya nesneleri olusturulur. Dosya fonksiyonlari ile onlar uzerinde islem yapilir. Borular iki gruba ayrilmaktadir.

*   isimsiz yada anonim borular. Bunlar yalnizca ust ve alt proses arasinda kullanilabilirler.
*   Isimli borular, Bunlar ayni makinadaki herhangi iki makina arasinda kullanilabilirler. Unix/Linux sistemlerde isimli borulara FIFO’da denilmektedir.

### İsimsiz Boruların Kullanılması

isimsiz boruların kullanıması sırasıyla şu işlemleri gerçekleştirir.

*   Üst proses pipe fonksiyonu ile boruyu yaratır ve buradan iki betimleyici elde eder.`**#include <unistd.h>** **int** pipe(**int** pipefd[2]);`

> Bu prototip gösteriminde köşeli parantez içindeki 2 değerinin C açısından hiçbir önemi yoktur. Ancak programcı buraya iki elemanlı bir dizinin adresini vermesi gerektiğini bildirmektedir. Aşağıdaki göterim fonksiyon parametresi olarak birbirine eşdeğerdir.

```
void Foo(int pi[2])
void Foo(int pi[])
void Foo(int *pi)
```

Fonsiyon bizden 2 elemanlı bir int dizisinin adresini ister. iki betimleyici oluşturarak bu dizinin içerisine yerleştirir. Fonksiyon başarı durumunda 0 başarısızlık durumunda -1 değerine geri döner. Dizinin sıfıncı indexli elemanında bulunan betimleyici borudan okuma yapma amacıyla 1 numaralı indexinde bulunan betimleyici boruya yazma yapmak için kullanılır.

*   Bu noktada senaryonun belirlenmesi gerekir. proseslerden biri okuma diğeri yazma yapacaktır. Fork işlemi ile alt proses yaratılır. Boru yazma yapacak taraf okuma betimleyicisini okuma yapacak taraf yazma betimleyicisini kapatmalıdır. Yani boruya okuma ve yazma yapacak tek bir betimleyicini bulunması gerekir.
*   Artık herşey hazırdır. Yazma taraf yazan wite fonksiyonunu, okuma yapan taraf da read fonksiyonunu kullanır.
*   Yazan taraf boru tamamen dolu ise okuayan taraf da boru tamamen boş ise bloke olur. Önce yazma yapan tarafın boruyu kapatması gerekir. bu durumda okyan taraf borudakileri okur. En sonunda boruda hiçbirşey kalmadığı zaman read fonksiyonu 0 ile geri döner. Artık okuyan taraf da boruyu kapatır.

```c
/*------------------------------------------------------------------
    Üst ve alt prosesler arasında isimsiz boru haberleşmes
------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);
void do_parent(int fd);
void do_child(int fd);

int main(int argc, char *argv[])
{
    int fds[2];
    pid_t pid;
        
    if (pipe(fds) < 0)
        exitsys("pipe");
    
    if ((pid = fork()) < 0)
        exitsys("fork");
    
    if (pid != 0) {            /* parent yazma yapacak */
        close(fds[0]);        
        do_parent(fds[1]);
        close(fds[1]);
        if (wait(NULL) < 0)
            exitsys("wait");
        
    }
    else {                    /* child okuma yapacak */
        close(fds[1]);        
        do_child(fds[0]);
        close(fds[0]);
    }
        
    return 0;
}

void do_parent(int fd)
{
    int i;
    
    for (i = 0; i < 10; ++i)
        if (write(fd, &i, sizeof(int)) < 0)
            exitsys("write");
}

void do_child(int fd)
{
    ssize_t n;
    int val;
    
    while ((n = read(fd, &val, sizeof(int))) > 0)
        printf("%d ", val);
    printf("\n");
    
    if (n < 0)
        exitsys("read");
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

### Shell Üzerinde Boru işlemleri

Komut satırında a ve b birer program olmak üzere a | b işleminde şunlar olmaktadır; Şhell programı bir boru yaratır. Sonra a ve b programlarını çalıştırır. a programının stdout dosyasını boruya, b programının da stdin dosyasını boruya yönlendirir. Böylece a programın kendisini ekrana yazdığını sanırken aslında boruya yazmaktadır. b programı da kendisini klavyeden okuduğunu sanırken aslında borudan okumaktadır. Böylece a nın ekrana yazdıklarını b klavyeden okuyormuş gibi alır.

> CTRL+D stdin içerisinde EOF manasına gelmektedir.

Komut satırında kullanılan pekçok komutta eğer komut bir dosya argümanı almaz ise varsayılan olarak stdin dosyasından girişi bekler. Böylece biz bu tür komutları borular ile kullanabiliriz.

```
root@kali:~# ls -l | wc
     11      92     510
root@kali:~#
```

yada örneğin

```
root@kali:~# ps -e | grep tty
 2600 tty7     00:00:02 Xorg
 2957 tty1     00:00:00 getty
 2958 tty2     00:00:00 getty
 2959 tty3     00:00:00 getty
 2960 tty4     00:00:00 getty
 2961 tty5     00:00:00 getty
 2962 tty6     00:00:00 getty
root@kali:~# 
```

Komut satırında borulama birden fazla kez yapılabilir. Örneğin;

```
root@kali:~# ps -e | grep ssh | awk '{print $1}'
3280
3544
3562
```

Boru işlemi yapan shell kodlarını biz yazacak olsaydık bununasıl yapardık? Bunun birkaç yöntemi olabilir. Tipik yöntem şudur.

1.  Önce bir boru yaratılır ve iki betimleyici elde edilir.
2.  Her iki program için de fork yapılır.
3.  Bu noktada borudan okuma yazma potansiyeline sahip 3’er betimleyici olur. o halde üst prosesin iki boru betimleyicisini de kapatması gerekir. ve aynı zamanda yine yazacak taraf okuma betimleyicisini okyacak taraf da yazma betimleyicisini kapatır.
4.  Artık dup2 fonksiyonu ile her iki alt proses için de boru yönlendirmesi yapılır.
5.  Artık exec uygulanarak her iki program da çalıştırılır.

```c
/*-------------------------------------------------------------------
    exec'li boru iþlemi (shell boru iþlemlerini nasil yapmaktadir?)
---------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);
void do_child1(const char *path, int fd);
void do_child2(const char *path, int fd);

/* usage cpipe <prog1> <prog2> */

int main(int argc, char *argv[])
{
    int fds[2];
    pid_t pidChild1, pidChild2;
    
    if (argc != 3) {
        fprintf(stderr, "wrong number of arguments!..\n");
        exit(EXIT_FAILURE);
    }
    
    if (pipe(fds) < 0)
        exitsys("pipe");
    
    if ((pidChild1 = fork()) < 0)
        exitsys("fork");
    
    if (pidChild1 != 0) {
        if ((pidChild2 = fork()) < 0)
            exitsys("fork");
        
        if (pidChild2 == 0) {        /* second child */
            close(fds[1]);
            do_child2(argv[2], fds[0]);
        
            /* unreachable code */
        }
    }
    else {        /* first child */
        close(fds[0]);
        do_child1(argv[1], fds[1]);
        
        /* unreachable code */
    }

    close(fds[0]);
    close(fds[1]);
    
    if (waitpid(pidChild1, NULL, 0) < 0)
        exitsys("waitpid");
    
    if (waitpid(pidChild2, NULL, 0) < 0)
        exitsys("waitpid");
    
    
    return 0;
}

void do_child1(const char *path, int fd)
{
    if (dup2(fd, STDOUT_FILENO) < 0)
        exitsys("dup2");
    close(fd);
        
    if (execlp(path, path, (char *) NULL) < 0)
        exitsys("execlp");
}

void do_child2(const char *path, int fd)
{
    if (dup2(fd, STDIN_FILENO) < 0)
        exitsys("dup2");
    close(fd);
    
    if (execlp(path, path, (char *) NULL) < 0)
        exitsys("execlp");
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

```
root@kali:~# gcc sample.c -o sample
root@kali:~# ./sample ls wc
     10      10      91
root@kali:~#
```

### İsimli Boru Haberleşmesi

İsimli boru işlemlerinde şu aşamalar gerçekleştirilir..

*   isimli boru, mkfifo isimli fonksiyonla yaratılır. Prototipi şu şekildedir.`#include <sys/stat.h> int mkfifo(const char *pathname, mode_t mode);`
*   Haberlesecek iki proseste isimli boruyu sanki bir dosya gibi open fonksiyonu ile açar. Yine proselerden birinin yazma rolunde diğerinin de okuma rolunde olması gerekir. Yazma rolünde olan proses boruyu O\_WRONLY modunda okuma yapmak isteyen proses ise O\_RDONLY modunda açmalıdır.
*   Blokeli modda read ve write fonksiyonlarının yanısıra open fonksiyonunun kendisinde de bloke oluşur. Örneğin, proseslerden önce yazma yapan çaıştırılmış olsun. Bu durumda open fonksiyonubaşka bir proses boruyu okuma modunda açana kadar blokede bekler. Benzer biçimce önce okuyan prosesi çalıştırırsak bu kez de okuyan proses open fonksiyonunda başka bir proses boruyu yazma modunda açana kadar beklemektedir.
*   Okuma yazma işlemi yine read ve write fonksiyonları ile isimsiz boruda olduğu gibi yapılır. Yine önce yazan taraf boruyu kapatır. Okuyan taraf boruyu okuduktan sonra o da boruyu kapatır.
*   Borunun yaratılması ve yok edilmesini proseslerden birisi yapabilir. Yada tamamen bu işlemler komut satırından yapılabilir. Haberleşme bittikten sonra da boru dosyası silinmez ise dosya sisteminde kalmaya devam eder.

Birinci Konsol

```
root@kali:~# mkfifo sallama
root@kali:~# ls -la sallama
prw-r--r-- 1 root root 0 Mar 11 07:47 sallama
root@kali:~# ls -la > sallama
```

Ikinci Konsol

```
root@kali:~# cat < sallama
total 176
drwxr-xr-x 18 root root 4096 Mar 11 07:46 .
drwxr-xr-x 22 root root 4096 Jan  8 21:30 ..
drwx------  2 root root 4096 Mar  3 06:50 .aptitude
-rw-------  1 root root 6349 Mar 11 05:55 .bash_history
-rw-r--r--  1 root root 3391 Jan  1 20:28 .bashrc
drwx------  8 root root 4096 Mar 11 05:56 .cache
drwx------  9 root root 4096 Mar  6 01:40 .config
drwx------  3 root root 4096 Jan  8 21:41 .dbus
drwxr-xr-x  2 root root 4096 Mar  6 01:40 Desktop
drwx------  3 root root 4096 Mar 11 05:56 .gconf
-rw-------  1 root root 1322 Mar  6 10:07 .gdb_history
```

#### Read ve Write Fonksiyonlarının Borudaki Davranışları

Read ve write fonksiyonları boru sözkonusu olduğunda blokeli (blocking) ve blokesiz (nonblockking) olmak üzere iki modda çalışabilmektedir. Varsayılan mod blokeli moddur. Blokesiz modda işlem yapabilmek için open fonksiyonuna O\_NONBLOCK bayrağının eklenmesi gerekmektedir.

*   Read fonksiyonunun blokeli moddaki davranışı şu şekildedir:
*   Read fonksiyonu eğer boruda hibir byte yok ise blokede bekler fakat boruda en az 1 byte var ise talep edilen miktarda okumak için beklemez.
*   Olan okur ve olanı bayte sayısına geri döner. Fakat boruda hiçbir bilgi yoksa ve karşı taraf boruyu kapatmış ise 0 ile geri döner.
*   Write fonksiyonunun blokeli moddaki davranışı şöyledir:
*   Eğer boru tüm bilgiyi yazamayacak kadar dolu ise bu durumda write fonksiyonu tüm bilgiyi yazana kadar blokede bekler.
*   Eğer yazılacak miktar borunun toplam uzunluğundan büyük ise bu durumda write bloke olmaz.
*   Boru uzunluğu kadar bilgiyi yazar ve yazdığı byte sayısı ile geri döner. Başka bir deyişle boru uzunluğundan büyük m,ktarda boruya bilgi yazmak istersek bu tek hamlede yapılmaz.
*   Dolayısı ile başka bir proseste boruya yazma yapıyorsa araya girme olabilir.
*   Borunun uzunluğu ilgili sistemde PIPE\_BUF sembolik sabiti ile belirtilmiş durumdadır.
*   Eğer write fonksiyonu ile borunun uzunluğundan daha fazla bilgi yazmak istersek write yine tüm bilgiler boruya aktarılana kadar bekler.
*   Ancak başka proseslerde boruya yazma yapıyor ise araya girme olabilir.
*   Read fonksiyonunun blokesiz moddaki davranışı şöyledir:
*   Bu modda read yine boruda en az 1 bye var ise okyabileceği kadarını okur ve okyabildiği byte sayısı ile geri döner.
*   Fakat boruda hiç bilgi yok ise -1 değeri ile geri döner ve errno EAGAIN deği ile set edilir.
*   Write Fonksiyonunun blokesiz moddaki davranışı şu şekildedir:
*   Bu modda write tüm bilgi yazılana kadar blokede beklemez.
*   Eğer tüm bilginin yazılacağı kadar boruda boş yer var ise tüm bigiyi yazar ve yazdığı byte sayısı ile geri döner.
*   Eğer tüm bilgiyi yazacak kadar boruda yer yoksa -1 değeri ile geri döner ve boruya hiçbir bilgi yazmaz. Bu durumda errno EAGAIN değeri ile set edilir.
*   Eğer write ile biz boru büyüklüğünden daha fazla sayısa byte’ı boruya yazmaya çalışırsak bu durumda write boruya yazabildiği kadar değeri boruya yazar ve yazdığı byte sayısı ile geri döner.
*   Fakat boruda hiç yer yoksa -1 değeri ile geri döner ve errno EAGAIN değeri ile set edilir.

Örnek:

Öncelikle kendi pipe dosyamızı oluşturalım

```
root@kali:~# mkfifo sallama
```

Haberleşen iki uygulamanı kodları şu şekildedir.

```c
/*--------------------------------------------------------
    isimli boru işlemleri
---------------------------------------------------------*/

/* writefifo.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <errno.h>

void exitsys(const char *msg);

int main(void)
{
    int fd;
    char buf[1024];
    
    /*
    if (mkfifo("testfifo", S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH) < 0)
        exitsys("mkfifo");
    */
    
    if ((fd = open("testfifo", O_WRONLY)) < 0)
        exitsys("testfifo");
    
    for (;;) {
        printf("text:");
        fflush(stdout);
        gets(buf);
        if (write(fd, buf, strlen(buf)) < 0)
            exitsys("write");
        if (!strcmp(buf, "quit"))
            break;
    }
    
    close(fd);
    
    /*
    if (unlink("testfifo") < 0)
        exitsys("testfifo");
    */
    return 0;
}    

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
/* readfifo.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>

void exitsys(const char *msg);

int main(void)
{
    int fd;
    char buf[1024];
    ssize_t n;
        
    if ((fd = open("testfifo", O_RDONLY)) < 0)
        exitsys("testfifo");
    
    while ((n = read(fd, buf, sizeof(buf))) > 0) {
        buf[n] = '\0';
        if (!strcmp(buf, "quit"))
            break;
        puts(buf);
    }
    if (n < 0)
        exitsys("read");

    close(fd);
    
    return 0;
}    

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

Yukarıdaki örnekde tek yönlü boru haberleşmesi yapılmıştır eğer iki yönlü haberleşme pşabilmesi için iki ayrı pipe oluşturmak gerekecektir.

Mevcut linux sistemlerinde boru uzunluğu, yani PIPE\_BUF değeri 4096’dır.

### Borularla Client – Server Haberleşmesi

Client Server haberleşmesinde client ve server iki ayrı programdır. Asıl işi server yapar. Client yalnızca istekte bulunur. Server birden fazla client’e hizmet verebilmektedir. Böyle bir haberleşmenin faydaları şöyle özetlenebilir.

*   Server güçlü bir makinada çalışıyor olabilir ve biz bu serverin gücünden faydalanabiliriz.
*   Server bir aygıtı yada bir kaynağı kullanıyor olabilir ve onu paylaştırmak gerekebilir.
*   Server tün client’lar arasında koordinasyon sağlanabilir. (chat programları)
*   Server güvenli bir yerde ve güvenli bir biçinde kaynaklara erişiyor olabilir.
*   Boru kullanılarak client server haberleşmede serverden client’a bilgi aktarımı için her client için boru açılması gerekir. Fakat clientlardan server’a istek belirtmek için tek bir boru yetrlidir.

http://codingfreak.blogspot.com/2008/09/client-server-example-with-pipes.html

Yukarıdaki linkdeki örnek gayet uygun bir örnektir.

### Paylaşılan Bellek Alanları Yöntemi

Paylaşılan bellek alanları (shared memory), hem Unix/Linux hemde windows sistemlerinde benzer sistemde kullanılmaktadır. Bu yöntemde proseslerin bellek alanları birbirinden ayrı olduğu halde ram’de iki prosesinde erişebileceği ortak bir bölge ayrılır. Proseslerden biri oraya yazma yapar, diğeri oradan okuma yapar. Ancak borulardaki gibi bir senkronizasyon mekanizmanın kendi içerisinde yoktur. Senkronizasyonu ayrıca uygulamak gerekmektedir. Paylaşılan bellek alanlarını oluşturmak için iki grup fonksiyon bulunur. Bir tanesi Klasik SystemIPC fonksiyonlarıdır. Bunlar pekçok unix tirevi sistemlerde vardır. İkincisi sonradan eklenmiş modern fonksiyonlardır.

Bu iki grup fonksiyon da POSIX standartlarınca kabul edilmiş fonksiyonlardır. Ayrıca paylaşılan bellek alanları bellek tabanlı dosya oluşturmak için de kullanılmaktadır. Klasik System V Fonksiyonlarıyla Paylaşılan Bellek Alanları Paylaşılan bellek alanları şöyle oluşturulur;

*   Öncelikle bir anahtar belirleyerek paylaşılan bellek alanı shmget fonksiyonu ile oluşturulur. Burada fonksiyonun birinci parametresi iki prosesin ortaklaşa belirleyeceği bir id değeri yada bir anahtar değerdir. Fonksiyonun ikinci parametresi oluşturulacak paylaşılan bellek alanının uzunluğunu belirtir. Buradaki değer PAGE\_SIZE değerine yukarıya doğru yuvarlanmaktadır. Fonksiyonun son parametresi iki değerden bir yada ikisi olabilir.

```c
#include <sys/ipc.h>
#include <sys/shm.h>
int shmget(key_t key, size_t size, int shmflg);
```

IPC\_CREAT: yok ise yarat anlamına gelmektedir.

IPC\_EXCL : var ise oluşturmaz yok ise hata verir. IPC\_CREAT ile kullanılır.  
Nihayet bu parametreye aynı zamanda nesne erişim hakları içinS\_IXXX biçimindeki sembolik sabitler de eklenebilir. Fonksiyon başarı durumunda paylaşılan bellek alanına ilişkin bir handle değerine başarısızlık durumunda -1 değerine geri döner.

Fonksiyonun birinci parametresine anahtar girmek yerine IPC\_PRIVATE girilebilir. Bu durumda sistem anahtar değeri kendisi üretip nesneyi yaratır.

*   Şimdi yaratılan bellek alanı için ram’de bir alanın oluşturulmasına sıra gelmiştir. Bu işlem shmat fonksiyonu ile yapılır.`#include <sys/types.h> #include <sys/shm.h> void *shmat(int shmid, const void *shmaddr, int shmflg);` Fonksiyonun birinci parametresi shmget fonksiyonundan elde edilen id değeridir. ikinci parametre önerilen bellek adresini belirtir. Yani biz kendi prosesimizin bellek alanı içerisinde kendi belirlediğimiz bir alanı bu amaçla kullanabiliriz. Fakat bu parametre NULL geçilebilir. Bu durumda sisitem istediği adresi belirleyebilir (Genellikle bu yöntem uygulanır). Fonksiyonun üçüncü parametresi paylaşılan alanın kullanımını belirleyen bayrakları içerir. Bu parametre SHM\_RND girilebilir. Bu değer ikinci parametredeki adresin aşağıya doğru sayfa sınırlarına yuvarlanacağını belirtir. Fonksiyonun geri dönüş değeri başarı durumunda oluşturulan bellek alanının adresine, başarısızlık durumunda NULL değere gerei döner. Üçüncü parametre 0 geçilebilir.
*   Artık proseslerden biri paylaşılan bellek alanına yazma yapıp diğeri bunu okuyabilir. Yöntem çok hızlıdır. çünkü hiç aracılıksız erişim yapılmaktadır.
*   İşlem bittikten sonra paylaşılan bellek alanı kalmaya devam eder. Onu yok etmek için, yani shmat ile yapılanları geri almak için shmdt fonksiyonunu çağırmak gerekir.`#include <sys/types.h> #include <sys/shm.h> int shmdt(const void *shmaddr);` Fonksiyon parametre olarak shmat fonksiyonundan elde edilen bellek adresini alır. Başarı durumunda 0 başarısızlık durumunda -1 değerine geri dönmektedir. Bir programın başka bir programa bilgi aktarabileceği en hızlı yöntem shared memory dir.
*   işlemler bitince shmctl fonksiyonu ile tüm paylaşılan bellek alanı işlemleri geri alınmalıdır. Shmctl aynı zamanda başka amaçlar için de kullanılabilmektedir. fonksiyon prototipi şu şekildedir.`#include <sys/ipc.h> #include <sys/shm.h> int shmctl(int shmid, int cmd, struct shmid_ds *buf);` fonksiyonun birinci parametresi paylaşılan bellek alanının handle değeri, ikinci parametresi eğer nesne silinecek ise IPC\_RMID biçininde girilir. Üçüncü parametre ikinci parametrenin durumuna göre anlam kazanır. Eğer ikinci parametre IPC\_RMID giriliyorsa bu durumda üçüncü parametre NULL girilebilir. paylaşışlan bellek alanının silinmesi ve yaratılması yine başka bir program yoluı ile yapılabilir. SystemV in klasik IPC nesneleri reboot işlemi yapılana kadar kalıcı olmaktadır. Yani onları yaratan programlar sonlansa bile onlar kalmaya devam eder.

```c
/*---------------------------------------------------
    Paylaşılan bellek alanı uygulaması    
---------------------------------------------------*/

/* shmproc1.c  - Yazma yapan uygulama*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define SHMKEY        0x12345678

void exitsys(const char *msg);

int main(void)
{
    int shmid;
    char *buf;
    
    if ((shmid = shmget(SHMKEY, 4096, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|IPC_CREAT)) < 0)
        exitsys("shmget");
    
    if ((buf = (char *) shmat(shmid, NULL, 0)) < 0)
        exitsys("shmat");
    
    strcpy(buf, "This is a test");
    printf("press ENTER to key to continue...\n");
    getchar();
    
    shmdt(buf);
    
    if (shmctl(shmid, IPC_RMID, NULL) < 0)
        exitsys("shmctl");
        
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

/* shmproc2.c - Okuma yapan uygulama */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define SHMKEY        0x12345678

void exitsys(const char *msg);

int main(void)
{
    int shmid;
    char *buf;
    
    if ((shmid = shmget(SHMKEY, 4096, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|IPC_CREAT)) < 0)
        exitsys("shmget");
    
    if ((buf = (char *) shmat(shmid, NULL, 0)) < 0)
        exitsys("shmat");
    
    printf("Press ENTER to continue...\n");
    getchar();
    
    puts(buf);
    
    shmdt(buf);
        
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```


```
root@kali:~# ./shmproc1
press ENTER to key to continue...
```

yukarıdaki işlemde bellek alanına yazma yapar ve bekler. Aşağıdaki komut ile de bellek alanına yazılan bilgi ekrana basılmaktadır.

```
root@kali:~# ./shmproc2
Press ENTER to continue...

This is a test
root@kali:~#
```

O anda sistemde yaratılmış bütün IPC nesneleri, ipcs komutu ile görülebilmektedir. bir ipc nesnesi anahtar veya handle değeri ile ipcrm shell komutu ile silinebilir.
