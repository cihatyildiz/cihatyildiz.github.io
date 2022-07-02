---
title: Linux System Programming - Part 7
author: Cihat Yildiz
date: 2014-12-01 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Modern ve Yeni Paylaşılan Bellek Alanı Fonksiyonları
----------------------------------------------------

Daha önceden de belirtildiği gibi paylaşılan bellek alanlarıiçin iki grup fonksiyon kullanılabilmektedir Bunlardan biri klasik ve eski SystemV fonksiyonlarıdır. Diğeri yeni fonksiyonlardır. Bu yeni fonksiyonlara POSIX paylaşılan bellek alanı fonksiyonları da denilmektedir. Fakat her her iki fonksiyon grubu da posix standartlarınca tescil edilmiş fonksiyonlardır. POSIX Paylaşılan bellek alanı fonksiyonları şöyle kullanılmaktadır.

1.  shm\_open fonksiyonu ile sankipaylaşılan bellek alanı bir dosyaymış gibi yaratılır yada oluşturulur.`#include <sys/mman.h> int shm_open(const char *name, int oflag, mode_t mode);` fonksiyonun birinci parametresi paylaşılan bellek alanının ismini belirtir. posix standartları bu ismin kök dizinde bir isim olarak verilmesini tavsiye etmiştir. Fakat bazı sistemlerde her herhangi bir dizin altında verilebilir. Fonksiyonun ikinci parametresi open fonksiyonunda olduğu gibidir. Üçüncü parametre de yine open fonksiyonundaki gibidir. Fonksiyon başarı durumunda dosya betimleyicisine başarısızlık durumunda -1 değerine geri döner.
2.  Paylaşılan bellek alanı yaratıldıktan sonra ftruncate fonksiyonu ile bunun için alan ayrılması gerekmektedir.`#include <unistd.h> int ftruncate(int fd, off_t length);` ftruncate bir dosyayı büyütüp küçültmeye yarayan bir dosya fonksiyonudur. Fonksiyonun birinci parametresi dosya betimleyicisini, ikinci parametresi dosyanın yeni uzunluğunu belirtir. Fonksiyon başarılı ise 0 değerine, başarısız ise -1 değerine geri döner.
3.  Paylaşılan bellek alanı yaratıldıktan sonra ikinci aşamada mmap isimli fonksiyon ile bellek alanı tahsisatı yapılır (Bu fonksiyon shm\_at fonksiyonuna karşılık gelmektedir)`#include <sys/mman.h> void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);` Fonksiyon birinci parametresi yine önerilen adresi belirtir. Bu parametre NULL geçilebilir. İkinci parametre paylaşılan bellek alanının uzunluğunu belirtir (pekçok sistem bunu sayfa uzunluğuna göre yukarıya doğru yuvarlamaktadır fakat standart bir davranış değildir). Üçüncü parametre aşağıdakilerden oluşturulur.`PROT_READ PROT_WRITE PROT_EXEC PROT_NONE` bu parametre tipik olarak “PROT\_READ | PROT\_WRITE” biçiminde kullanılmaktadır. Dördüncü parametre 0 geçilebilir yada MAP\_SHARED, MAP\_PRIVATE, MAP\_FIX geçilebilir. Beşinci parametre dosya betimleyicisini belirtmektedir. Tipik olarak biz shm\_open fonksiyonundan elde edilen betimleyiciyi buraya geçirebiliriz. Fonksiyonun son parametresi eğer bellek tabanlı dosya sözkonusu ise dosyanın hangi offsetinden itibaren işlemin yapılacağını belirtir. Paylaşılan bellek alanı için buraya 0 girebiliriz. Nihayet fonksiyon geri dönüş değeri başarı durumunda map edilen adres, başarısızlık durumunda NULL olarak geri döner.
4.  Map edilen ve tahsis edilen adres alanı munmap fonksiyonu ile geri bırakılır. Bu SystemV’in shm\_dh fonksiyonuna karşılık gelmektedir.`#include <sys/mman.h> int munmap(void *addr, size_t length);`

Fonksiyonun birinci parametresi unmap edilecek yerin başlangıç adresini, ikinci parametresi bunun uzunluğunu belirtmektedir. Fonksiyon başarı durumunda 0, başarısızlık durumunda -1 değeri ile geri döner.

1.  Nihayet paylaşılan bellek alanına ilişkin dosya shm\_unlink fonksiyonu ile silinir.

```c
#include <sys/mman.h>
int shm_unlink(const char *name);
```

Fonksiyon parametre olarak shm\_open fonksiyonunda verilen ismi alır. Başarı durumunda 0 başarısızlık durumunda -1 değerine geri döner.

POSIX IPC nesneleri sistemlere daha sonradan eklendiği için bunlar başka bir kütüphanenin içine yerleştirilmiştir. bu nedenle derleme işlemi yapılırken librt.a kütüphanesinin eklenmesi gerekiyor bunun için gcc’ye parametre olarak -lrt girilmesi gerekmektedir.

“-l” ile derleme yapılırken kütüphanenin baında yazan “lib” atılarak kullanılır

```c
/* shmposixproc1.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>

void exitsys(const char *msg);

int main(void)
{
    int fdmem;
    char *buf;
    
    if ((fdmem = shm_open("/ThisIsATest", O_RDWR|O_CREAT, 
                               S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)) < 0)
        exitsys("shm_open");
    
    if (ftruncate(fdmem, 4096) < 0)
        exitsys("ftruncate");
    
    if ((buf = (char *) mmap(NULL, 4096, PROT_READ|PROT_WRITE, 
                                    MAP_SHARED, fdmem, 0)) == NULL)
        exitsys("mmap");
    
    strcpy(buf, "This is a test");
    
    printf("Press ENTER to continue...\n");
    getchar();
    
    if (munmap(buf, 4096) < 0)
        exitsys("munmap");
    
    if (shm_unlink("/ThisIsATest") < 0)
        exitsys("shm_unlink");
    
    close(fdmem);
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
/* shmposixproc2.c */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>

#define SHMKEY        0x12345678

void exitsys(const char *msg);

int main(void)
{
    int fdmem;
    char *buf;
    
    if ((fdmem = shm_open("/ThisIsATest", O_RDWR|O_CREAT, 
                            S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)) < 0)
        exitsys("shm_open");
        
    if ((buf = (char *) mmap(NULL, 4096, 
                                PROT_READ|PROT_WRITE, MAP_SHARED, fdmem, 0)) == NULL)
        exitsys("mmap");
    
    printf("Press ENTER to continue...\n");
    getchar();
    
    puts(buf);
    
    if (munmap(buf, 4096) < 0)
        exitsys("munmap");
    
    close(fdmem);
        
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

Kullanımı ise şu şekilde olacaktır. Konsol -1

```terminal
root@kali:~# gcc -o shmposixproc1 shmposixproc1.c -lrt
root@kali:~# gcc -o shmposixproc2 shmposixproc2.c -lrt
root@kali:~# ./shmposixproc1
Press ENTER to continue...
```

Konsol-2

```terminal
root@kali:~# ./shmposixproc2
Press ENTER to continue...

This is a test
root@kali:~#
```

Bellek Tabanlı Dosyalar
-----------------------

Bellek tabanlı dosyalar eskiden beri (1992’den beri) 32 bit windpws sistemlerde bulunan bir özellikdi. Unix türevi sistemlere bellek tabanlı dosyalar daha sonra realtime extension eklentileri ile girmiştir. bazı unix türevi sistemler bunları çok sonra desteklemeye başlamıştır. Artık pekçok POSIX uyumlu sistem bunları desteklemektedir.

#### Bellek Tabanlı dosya ne anlama gelmektedir?

Bir dosyanın belleğe okunması ve artık onunla bellek üzerinde işlem yapılması anlamına gelmektedir. Yani read ve write işlemleri ile değil, gösterici işlemleri ile işlemler gerçekleştirilebilir. Dosyayı belleğe çektiğimizde artık biz bellekteki bilgileri değiştirdiğimizde bu değişiklik diske otomatik olarak yansıtılmaktadır. Bellek tabanlı dosyalar ile işlemler oldukça pratiktir. UNIX Türevi sistemlerde bellek tabanlı dosyaların kullanınmı yine modern POSIX paylaşılan bellek alanları fonksiyonları ile yapılmaktadır. Bellek tabanlı dosyalar tipik olarak şoyle kullanılmaktadır; ilgili dosya normal bir biçimde open fonksiyonu ile açıklmaktadır. mmap fonksiyonu ile dosyanın istenilen kısmı belleğe map edilir. Sonra işlem bitince yine munmap fonksiyonu ile tahsis edilen bellek alanı boşaltılır. en sonunda normal dosya kapatılır ve artık bütün değişiklikler dosyaya yansıtılmış olur. Mmap fonksiyonunda bayrak parametresi olarak MAP\_PRIVATE gecişirse dosya üzerinde update yapılamaz. MAP\_SHARED yapılırsa yapılabilir. Normal olarak bellek tabanlı bir dosya üzerinde update yaptığımızda bunun ne zaman dosyaya yansıtılacağı belli değildir (fakat en kötü olasılıkla dosya kapatıldığında yada munmap uygulandığında). Biz istediğimiz bir anda yaptığımız değişikliklerin dosyaya yansımasını istiyorsak msync fonksiyonunu çağırmalıyız.

```c
#include <sys/mman.h>
int msync(void *addr, size_t length, int flags);
```

Fonsiyonun birinci parametresi flush edilecek yerin başlangıç adresini belirtir (Bellekteki tüm dosyanın flush edilmesi zorunlu değildir). İkinci parametre alalnın uzunluğunu belirtir. üçüncü parametre MS\_SYNC yada ms\_ASYNC olarak geçilebilir. MS\_SYNC Flush işlemi bitene kadar fonksiyonun geri dönmemesini sağlar. MS\_ASYNC ise fonksiyonu hemen sonlandırır ve arka planda flush işlemine devam eder. Ayrıca bunlardan biri ile MS\_INVALIDATE kombine edilebilri. MS\_INVALIDATE bayrağı kullanıldığında eğer dosyayı birden fazla kişi map etmiş ise onların belleğinde de o anda değişim görünür. Bir bellek tabanlı dosya uygulaması gerçekleştirelim;

Dosyamızı oluşturuyoruz.

```c
root@kali:~# ls -l > test.txt
root@kali:~# cat test.txt
total 48
drwxr-xr-x 2 root root 4096 Mar  6 01:40 Desktop
drwxr-xr-x 4 root root 4096 Mar  6 07:41 peda
drwxr-xr-x 2 root root 4096 Mar  6 08:51 peda_work
-rw-r--r-- 1 root root 2315 Feb  7 16:19 rogue-wireless.sh
-rw-r--r-- 1 root root  136 Mar 10 10:36 salla.c
-rw-r--r-- 1 root root 1645 Mar 11 07:41 sample.c
-rw-r--r-- 1 root root 1004 Mar 12 06:18 shmposixproc1.c
-rw-r--r-- 1 root root  852 Mar 12 06:16 shmposixproc2.c
-rw-r--r-- 1 root root  767 Mar 12 04:19 shmproc1.c
-rw-r--r-- 1 root root  645 Mar 12 04:19 shmproc2.c
-rw-r--r-- 1 root root   16 Mar 10 10:36 stderr.txt
-rw-r--r-- 1 root root    0 Mar 12 08:12 test.txt
-rw-r----- 1 root root  362 Mar 10 09:21 text.txt
root@kali:~#
```

```c
/*------------------------------------------------------------
    Bellek tabanlı dosyalar
-------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>

void exitsys(const char *msg);

int main(void)
{
    int fd;
    void *faddr;
    char *str;
    off_t size;
    int i;
    
    if ((fd = open("test.txt",O_RDWR)) < 0)
        exitsys("open");
    
    size = lseek(fd, 0, SEEK_END);
    /* lseek(fd, 0, SEEK_SET); */
        
    printf("%ld\n", (long) size);
    
    if ((faddr = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)) == NULL)
        exitsys("mmap");
    
    str = (char *) faddr;

    for (i = 0; i < 100; ++i)
        putchar(*str++);
    putchar('\n');
    
    memcpy(str, "xxxxxx", 6);

    close(fd);
    
    munmap(faddr, size);
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

Sonrasında kodumuzu oluşturalım;

Uygulamayı çalıştıralım ve sonucu görelim.

```terminal
root@kali:~# gcc sample.c -o sample
root@kali:~# ./sample
683
total 48
drwxr-xr-x 2 root root 4096 Mar  6 01:40 Desktop
drwxr-xr-x 4 root root 4096 Mar  6 07:41 p
root@kali:~# cat test.txt
total 48
drwxr-xr-x 2 root root 4096 Mar  6 01:40 Desktop
drwxr-xr-x 4 root root 4096 Mar  6 07:41 pxxxxxxwxr-xr-x 2 root root 4096 Mar  6 08:51 a.dat
-rw-r--r-- 1 root root 2315 Feb  7 16:19 rogue-wireless.sh
-rw-r--r-- 1 root root  136 Mar 10 10:36 salla.c
-rw-r--r-- 1 root root 1645 Mar 11 07:41 sample.c
-rw-r--r-- 1 root root 1004 Mar 12 06:18 shmposixproc1.c
-rw-r--r-- 1 root root  852 Mar 12 06:16 shmposixproc2.c
-rw-r--r-- 1 root root  767 Mar 12 04:19 shmproc1.c
-rw-r--r-- 1 root root  645 Mar 12 04:19 shmproc2.c
-rw-r--r-- 1 root root   16 Mar 10 10:36 stderr.txt
-rw-r--r-- 1 root root    0 Mar 12 08:12 test.txt
-rw-r----- 1 root root  362 Mar 10 09:21 text.txt
root@kali:~#
```

### Mesaj Kuyrukları

mesaj kuyrukları da kendi içlerinde senkronizasyon içeren ve çok kullanılan prosesler arası haberleşme yöntemleridir. Bunların da uygulanması için eski SystemV ve modern posix versiyonları vardır. Mesaj kuyrukları adeta datagram soket haberleşmesine benzetilmektedir. Halbuki boru haberleşmeleri stream tarzı TCP haberleşmeye benzemektedir. Klasik SystemV Mesaj Kuyruklarının Kullanımı Kullanım tipik olarak şöyle gerçekleştirilmektedir.

1.  msgget fonksiyonu ile mesaj kuyrukları yaratılır.`#include <sys/ipc.h> #include <sys/msg.h> int msgget(key_t key, int msgflg);` Fonsksiyonun birinci parametresi iki prosesin anlaşmış olduğu anahtar değerdir. ikinci parametre yanlızca O\_CREAT yada “O\_CREAT | O\_EXCL” geçilebilir. Aynı zamanda bu parametre için erişim hakları da verilmelidir. Fonksiyon başarı durumunda 0 başarısızlık durumunda -1 değerine geri döner.
2.  Artık sıra mesaş alıp vermeye gelmştir. Mesaj göndermek için msgsnd fonksiyonu kullanılır.`#include <sys/ipc.h> #include <sys/msg.h> int msgsnd(int msqid, const void *msgp, size_t msgsz, int msgflg);` Fonksiyonun birinci parametresi mesaj kuyruğunun handle değeridir. İkinci parametre göderilecek mesajın başlangıç adresini belirtir. Gönderilecek mesajın başında kesinlikle long türden bir alan olmak zorundadır. Bu alan mesajın türünü belirtir. Mesaj türü olarak 0 sayısı kullanılmaz. fonksiyonun üçüncü parametresigönderilecek mesajın byte uzunluğudur. bu uzunluğa mesajın başındaki long alan dahil değildir. Son parametre 0 geçilebilir yada IPC\_NOWAIT geçilebilir. 0 geçilir ise mesaj gönderilene kadar mesaj blokede bekler. IPC\_NOWAIT geçilir ise o zaman mesaj kuyruğunun dolu olmasından dolayı mesajın gönderilememesi durumunda fonksiyon başarısız olur ve errno değeri EAGAIN ile set edilir. Fonksiyon başarı durumunda 0 başarısızlık durumunda -1 geri döner.
3.  Mesajı almak için msgrcv fonksiyonu kullanılır.`#include <sys/ipc.h> #include <sys/msg.h> ssize_t msgrcv(int msqid, void *msgp, size_t msgsz, long msgtyp, int msgflg);` Fonksiyonun birinci parametresi mesaj kuyruğunun id değerini alır. İkinci parametre mesaj bilgilerinin yerleştirileceği bellek alanının adresini alır. Üçüncü parametre mesajın uzunluğunu belirtmektedir. Buradaki değer mesajın gerçek uzunluğundan büyük ise bu durumda sorun oluşmaz. Fonksiyon tüm mesajı okur. Okuduğu mesajın byte sayısı ile geri döner (long alan mesaj uzunluğuna dahil değil). Eger buradaki değeri mesajın uzunluğundan küçük girersek fonksiyon başarısız olur. Fakat fonksiyonun son parametresi olan flag parametresinde MSG\_NOERROR değeri girilir ise fonksiyon başarısız olmaz. Mesaj kırpılarak alınır. Fonksiyonun dördüncü parametresi alınacak mesajın türünü belirtir. Boruya eğer 0 girilir ise türü ne olursa olsun sıradaki ilk mesaj alınır. Eğer bıraya sıfırdan büyük bir değer girilir ise fonksiyon yalnızca bu tür değerine sahip mesajı alır. Eğer buraya sıfırdan küçük bir değer girilir ise o zaman fonksiyon buraya girilen değerin mutlak değerinden küçük yada ona eşit olan ilk mesajı alır. Fonksiyonun son parametresin yine IPC\_NOWAIT yada 0 yada IPC\_NOERROR değerleri ile kombile edilebilir. IPC\_NOWAIT blokesiz çalışma anlamına gelmektedir. Bu durumda fonksiyon kuyrukta mesaj yoksa beklemez. Fonksiyon başarı durumunda okunan mesajın uzunluğuna (tür alanı dahil değildir) başarısızlık durumunda -1 değerine geri döner.
4.  İşlem bittikten sonra yine önce kuyruğa yazan tarafın işlemi sonlandırması uygun olur. Kuyruk msgctl fonksiyonu ile yok edilmiş ise önce msgrcv uygulayan program fonksiyondan başarısızlıkla çıkar
5.  En sonunda mesaj kuyruğu yine msgctl fonksiyonu ile yok edilir. Fakat yaratım ve yok etme işlemi dışardan da yapılabilmektedir. msgctl fonksiyonu şu şekildedir.`#include <sys/ipc.h> #include <sys/msg.h> int msgctl(int msqid, int cmd, struct msqid_ds *buf);`

Fonksiyonun birinci parametresi mesaj kuyruğunun handle değeridir. İkinci parametre silme işlemi için IPC\_RMID biçiminde girilmelidir. Üçüncü parametre ise NULL girilebilir. Fonksiyon başarı durumunda 0 değerine başarısızlık durumunda -1 değerine geri döner.

İnternette yapılan bazı bazı testlere dayanılarak IPC mekanizmaları arasında iyiden kötüye doğru hız performansı şöyle dizilmektedir.

1.  Paylaşılan bellek alanları
2.  Boru haberleşmesi
3.  Mesaj kuyrukları
4.  Unix domain soketler

Örnek olarak kendi aralarında haberleşen 2 C programı.

```c
/*--------------------------------------------------------
    System V Mesaj kuyruklarý
--------------------------------------------------------*/

/* mqueueproc1.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#define MSGKEY        0x12345678

void exitsys(const char *msg);

typedef struct tagMSG {
    long type;
    char buf[1024];
} MSG;

int main(void)
{
    int msgid;
    MSG msg;
    
    if ((msgid = msgget(MSGKEY, IPC_CREAT|0644)) < 0)
        exitsys("msgget");
    
    msg.type = 1;
    for (;;) {
        printf("text:");
        fflush(stdout);
        gets(msg.buf);
        if (msgsnd(msgid, &msg, strlen(msg.buf), 0) < 0)
            exitsys("msgsnd");
        if (!strcmp(msg.buf, "quit"))
            break;
    }
    
    if (msgctl(msgid, IPC_RMID, NULL) < 0)
        exitsys("msgctl");
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}

/* mqueueproc2.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#define MSGKEY        0x12345678

void exitsys(const char *msg);

typedef struct tagMSG {
    long type;
    char buf[1024];
} MSG;

int main(void)
{
    int msgid;
    MSG msg;
    ssize_t len;
    
    if ((msgid = msgget(MSGKEY, IPC_CREAT|S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP)) < 0)
        exitsys("msgget");
    
    while ((len = msgrcv(msgid, &msg, 1024, 0, 0)) > 0) {
        msg.buf[len] = '\0';
        if (!strcmp(msg.buf, "quit"))
            break;
        puts(msg.buf);
    }
    if (len < 0)
        exitsys("msgrcv");
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

POSIX Mesaj Kuyrukları
----------------------

Mesaj kuyruklarının yeni versiyonları da vardır. Burada mesaj kuyrukları mq\_open fonksiyonu ile açılır,

```c
#include <fcntl.h>           /* For O_* constants */
#include <sys/stat.h>        /* For mode constants */
#include <mqueue.h>
mqd_t mq_open(const char *name, int oflag);
mqd_t mq_open(const char *name, int oflag, mode_t mode, struct mq_attr *attr);
```

daha sonra mq\_send fonksiyonu ile mesaj gönderilir,

```c
#include <mqueue.h>
int mq_send(mqd_t mqdes, const char *msg_ptr,size_t msg_len, unsigned msg_prio);
```

mq\_receive ile mesaj alınır,

```c
#include <mqueue.h>
ssize_t mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned *msg_prio);
```

Nihayet mq\_unlink fonksiyonu ile de mesaj kuyruğu silinir.

```c
#include <mqueue.h>
int mq_unlink(const char *name);
```
