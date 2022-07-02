---
title: Linux System Programming - Part 5
author: Cihat Yildiz
date: 2014-11-03 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Dosya Betimleyicilerinin Anlami
-------------------------------

BIr dosya acildiginda kernel o dosya ile ilgili islem yapabilmek icin bir veru yapisi olusturur. Buna dosya nesnesi (File object) denilmektedir. Bu dosya nesnesinin adresi dosya betimleyici tablosu denilen bir tabloya yazilir. Dosya betimleyici tablosu bir gosterici dizisidir. Dosya betimleyici tablosunun adresi de proses kontrol blogunda saklanmaktadir.

![upload-image](/assets/img/sample/linux_sys_prg_fd_yapisiapisi.png)

Iste dosya betimleyicisi dosya betimleyicisi tablosunda bir index belirtir. O halde dosya betimleyicisini kullanan bir fonksiyonu cagirdigimizda (read fonksiyonu gibi) sirasiyla sunlar olur.

*   Kernel o andaki aktif prosesin proses kontrol bloguna erisir.
*   Kernel oradan fonksiyonu cagiran prosesin dosya betimleyici tablosuna erisir.
*   Kernel buradan da dosya betimleyicisini index olarak kullanarak dosya nesnesine erisir.
*   dosya ile ilgili islem yapmak icin gerekli butun bilgiler dosya nesnesi icerisindedir. Sistem bu islem ile veri okunanin dosya mi yoksa bir device mi bunu bilemez. Bu duruma virtual file system denilmektedir.

Bir dosya nesnesi bir disk dosyasina iliskin olabilecegi gib bir aygit surucuye iliskin de olabilir. Aslinda okuma-yazma gibi temel islemleri yapan fonksiyonlarin adresleri dosya nesnesinin icindeki bir dizide tutulmaktadir. Iste eger dosya nesnesi bir aygit surucuye iliskin ise burada aygit surucunun read ve write fonksiyonlarina adresleri bulunur. Eger dosya nesnesi bir disk dosyasina iliskin ise burada diskten okuma yazma yapacak fonksiyonlarin adresleri bulunur. Bu durumda ornegin biz read fonksiyonunu cagirdigimizda read fonksiyonu da dosya nesnesi icerisinde bulunan adresteki fonksiyonu cagirir. Yani aslinda read fonksiyonu bile nereden okuma yaptigini bilmemektedir.

#### Peki close fonksiyonu ile bir dosya kapatildiginda ne olur?

Dosya nesnesinin sayaci 1 eksiltilir. Sayac sifira dusmus ise dosya nesnesi silinir ve dosya betimleyici tablosundaki giris de silinir. Boylece zamanla dosya betimleyici tablosunun bazi girisleri dolu bazi girisleri bos olur. POSIX Standartlerinda open fonksiyonunun ilk bos betimleyiciyi (yani sayisal degeri en dusuk olan ilk betimleyiciyi) verecegi garanti edilmistir. Bir proses yaratildiginda dosya betimleyici tablosunnun ilk uc betimleyici dolu durumdadir. (Bu uc betimleyicinin neden dolu oldugu aciklanacaktir.) Sifir numarali betimleyici klavyayi temsil eden dosya nesnedini, 1 ve 2 numarali betimleyiciler ekrani temsil eden dosya nesnesini gosterir. Boylece biz 0 numarali betileyiciyi kullanarak okuma yaptigimizda klavyeden okuma yapmus oluruz. 1 ve 2 numarali betimleyicileri kullanarak yazdirma yaparsak ekrana yazdirmis oluruz.

I/O Yonlendirmesinin Temeli
---------------------------

Biz 0,1 yada 2 numarali betimleyiciyi close fonksiyonu ile kapatip hemen arkasindan open fonksiyonu uygularsak open fonksiyonu bize eldeki bos betimleyiciyi verecegi icin bu kapattigimiz betimleyiciyi verecektir. Ornegin close(1) isleminden sonra open fonksiyonu ile bir dosya acmis olalim. Open bize 1 numarali betimleyiciyi verecektir. Bunun sonucu olarak 1 numarali betimleyicinin gosterdigi dosya nesnesi bizim dosyamiza iliskin olacaktir. Bu durumda biz printf gibi ekrana yazan fonksiyonlari kullandigimizda bu fonksiyonlar hep nihayetinde 1 numarali betimleyici kullandiklari icin yazilanlar ekrana degil ilgili dosyaya yapilacaktir.

```c
/*------------------------------------------------------------------------
 stdout dosyasinin yönlendirilmesi
-------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
    int fd;
    int i;
    
    close(1);
    
    if ((fd = open("a.txt", O_WRONLY|O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP)) < 0)
        exitsys("open");
    
    for (i = 0; i < 100; ++i)
        printf("%d\n", i);
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

Bu konunun duzenli anlatimini icin [buradaki](http://www.csystem.org/sites/default/files/makale/aslank/unix_linux_sistemlerinde_dosya_betimleyicilerinin_anlami.pdf) makalenin okunmasi gereklidir.

### Dosya Nesnelerinin Paylasimi

Her open cagrisi kesinlikle farkli bir dosya nesnesinin yaratilmasina yol acmaktadir. Yani ayni dosya iki kere open ile actigimizda biz diskte ayni dosyayi goren iki farkli dosya nesnesi olusturmus oluruz.

> Dosya gostericisinin konumu dosya nesnesinin icerisinde oldugu icin bir betimleyicide dosya betimleyicini konumlandirdigimizda bu digerini etkilemez. POSIX Standartlarinda read, write gibi fonksiyonlarin sistem genelinde atomik oldugu acikca belirtilmistir. Yani bir proses digerinin ya tum etkisini gorur yada digeri onun tum etkisini gorur. Ornegin iki proses ayni anda dosyanin ayni bolgesinden okuma ve yazma ypiyor olsunlar. okuyan proses bozuk bir bilgi okumaz. Ya digerinin yazmasindan once olan bilgiyi okur yada yazmasindan sonraki bilgiyi okur. Fakat bir kismi once bir kismi sonraki bilgiyi okumaz. Fakat suphesiz iki ayri dosya islemi (iki ayri write) atomik degildir. Yani bu iki islemin arasina baska prosesin bir islemi girebilir .ista bu nedenle bu tur operasyonlarda onlemi programcinin kendisi almalidir. Bu tur islemleri etkin bir bicimde saglamak icin dosya kilitlemesi (file locking) mekanizmasi sunulmustur. Bazen ayni dosya nesnesini goren ikinci bir betimleyici olusturmak isteyebiliriz. Bu ayni dosyayi iki kere acmakla ayni sey degildir.

![upload-image](/assets/img/sample/linux_sys_prg_linux_fd_table.png)

Burada fd1 ile fd2 ayni dosya nesnesini gostermektedir. Dolayisi ile bu iki betimleyicileri kullanmak arasinda bir farklilik yoktur. Bu islem dup fonksiyonu ile yapilmaktadir. Fonksiyonun prototipi su sekildedir;

```c
#include <unistd.h>
int dup(int oldfd);
int dup2(int oldfd, int newfd);
```

Dosya parametresi acilmis bir dosyaya iliskin dosya betimleyicisifdir. Fonksiyon arguman olarak verdigimiz dosya betimleyicisi ile ayni dosya nesnesini goren yeni bir betimleyici olusturur ve bize o betimleyiciniin degerini verir.

![upload-image](/assets/img/sample/linux_sys_prg_dup_function.png)

Fonksiyon basarisiz olabilir. bu durumda -1 degerine geri doner.

```c
/*----------------------------------------------------------------
    dup fonksiyonun kullanimi
-----------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
    int fdnew;
   
    if ((fdnew = dup(1)) < 0)
        exitsys("dup");
      
    write(fdnew, "test\n", 5);
    close(fdnew);
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

Linux’da normal bir kullanicinin ayni anda elde edebilecegi betimleyici sayisi (yani acik olarak tutabilecegi dosya sayisi) 1024’dur. Bu ayni zamanda dosya betimleyici tablosunun uzunlugudur.

```c
/*-------------------------------------------------------------
    Dosya betimleyici tablonun uzunlugu nedir?
--------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
    int i;
    int fd;
    
    for (i = 1;; ++i) {
        if ((fd = open("sample.c", O_RDONLY)) < 0)
            break;
        printf("count = %d, fd = %d\n", i, fd);
    }
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

Prosesin pekcok limiti gibi dosya betimleyici tablosunun uzunlugu da root prosesi tarafindan degistirilebilir. Bir prosesin o anki limitlerini elde etmek icin getrlimit, set etmek icin ise setrlimit fonksiyonlari kullanilmaktadir. Ayni dosya nesnesini gosteren irden fazla betimleyici olabilecegine gore bir betimleyiciyi close fonksiyonu ile kapattigimizda dosya nesnesinin silinmemesi gerekir. iste tipik olarak kernel dosya nesnesinin icerisinde bir sayac tutar. close islemi sirasinda sayaci 1 eksiltir. Sayac 0’a duserse dosya nesnesini siler.

#### Fork islemi sirasinda Dosya betimleyici tablosunun alt prosese aktarilmasi

Fork islemi yapildiginda alt proses icin yeni bir proses kontrol blogu olusturulur ve ust prosesin proses kontrol blogunun icerigi birkac istisma disinda alt prosesin kontrol bloguna kopyalanir. iste bu sirada ust prosesin dosya betimleyici tablosu da alt prosesin dosya betimleyici tablosuna kopyalanmaktadir. yani ust prosesin dosya betimleyici tablosundaki dosya nesnelerinin adresleri kopyalanmakatdir. Boylece ust prosesin dosya betimleyici tablosundaki girisler ile alt prosesin dosya betimleyici tablosundaki girisler ayni dosya nesnelerini gosteriyor durumda olur. (Tabi dosya nesnelerinin sayaclari da 1 artirilir) Buradan su sonuclar cikartilabilir:

*   fork islemi sirasinda ust prosesteki dolu olan betimleyicilerin hepsi alt proseste de gecerli olarak kullanilabilir. Baska bir degis ile biz ust proseste bir dosyayi acip fork yaptigimiz zaman o dosya alt proseste de acik durumdadir.
*   Ust proses ile alt proses ayni dosya nesnelerini paylastigi icin, ornegin ust proses dosya nesnesini degistirir ise alt proses bunu degismis olarak gorur.
*   Fork isleminden sonra artik iki prosesin daha sonra acacagi dosyalar paylasilmayacaktir.

![upload-image](/assets/img/sample/linux_sys_prg_process_ctl_block.png)

Fork isleminden sonra exec yapilacak ise cogu kez (fakat her zaman degil) eski betimleyicilerin yani calistirilan program icin bir anlami olmaz. Yani yeni calistiirlan program zaten bunlardan habersizdir ve bu betimleyiciler bosuna yer kaplar durumda olabilirler. Iste exec yaparken istediginiz bir dosyanin otomayik kapatilmasini sistemden isteyebiliriz. Buna dosyanin “close on exec” bayragi denir. dosya temelinde bu bayrak acilip kapatilabilmektedir. Varsayilan olarak bu bayrak false durumdadir. yani exec yaparken dosya kapatilmaz.

### I/O Yönlendirmelerinde dup2 fonksiyonunun kullanılması

Yönlendirme işlemlerinde önce close uygulayıp sonra open uyguladığımızda bu iki işlem arasında hibir dosyanın açılmaması gerekir. Şüphesiz programcı bu koşulu sağlayabilir. Fakat bazı durumlarda bu zor olabilir. Ayrıca yüksek numaralı bir betimleyicini bu biçimde yönlendirilmesi mümkün olmayabilir. işte bunun için dup2 fonksiyıonu tasarlanmıştır.

```c
#include <unistd.h>
int dup2(int oldfd, int newfd);
```

dup2 fonksiyonu ikinci parametresi ile belirtilen betimleyiciyi açıksa önce onu kapatır. Sonra birinci parametresi ile belirtilen betimleyici açık ise onu kapatır. Sonra ikinci parametresi ile belirtilen betimleyicinin birinci parametresi ile belirtilen betimleyici ile aynı dosya nesnesini göstermesini sağlar. Başarı durumunda ikinci parametre ile belirtilen betimleyiciye başarısızlık durumunda -1 ile geri döner. Şüphesiz dup2 bu işemleri atomik yapmaktadır.

Yönlendirmelerde dup yerine dup2 kullanılması iyi bir tekniktir.

```c
/*-----------------------------------------------------------------------
 dup2 fonksiyonu ile IO yönlendirmesi
------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 int fd;
 int i;
 
 if ((fd = open("test.txt", O_WRONLY|O_CREAT, 
                             S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)) < 0)
  exitsys("open");
  
 if (dup2(fd, STDOUT_FILENO) < 0) 
  exitsys("dup2");
 
 for (i = 0; i < 10; ++i)
  printf("%d\n", i);
 
 close(fd);
 
 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

### Alt Prosesin Yönlendirilmesi

Komut satırında > stdout dosyasına yönlendirmek için, < stdin dosyasına yönlendirmek için, n> veya n< bir dosyaya yönlendirmek için kullanılmaktadır. Komut satırı bu yönlendirmeyi tipik olarak şu şekilde yapmaktadır.

*   önce üst proses (yani komut saturı prosesi) bir kez fork yapar,
*   alt prosesi oluşturur,
*   sonra henüz exec uygulamadan yönlendirmeyi yapar ve exec uygular.

```c
/*----------------------------------------------------------------
    alt proseste IO yönlendirmesine örnek
----------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

void exitsys(const char *msg);

/* Usage: direct  <file path> <executable path> */

int main(int argc, char *argv[])
{
    pid_t pid;
    int fd;
    
    if (argc < 3) {
        fprintf(stderr, "wrong number of arguments!..\n");
        exit(EXIT_FAILURE);
    }
    
    if ((pid = fork()) < 0)
        exitsys("fork");
    
    if (pid == 0) {
        if ((fd = open(argv[1], O_WRONLY|O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IRGRP)) < 0)
            exitsys("open");
        
        if (dup2(fd, STDOUT_FILENO) < 0)
            exitsys("dup2");
        
        close(fd);
        
        if (execvp(argv[2], &argv[2]) < 0)
            exitsys("execvp");
        
        /* unreachable code */
    }
    
    if (waitpid(pid, NULL, 0) < 0)
        exitsys("waitpid");
        
    
    return 0;
}

void exitsys(const char *msg)
{
    perror(msg);
    exit(EXIT_FAILURE);
}
```

```terminal
root@kali:~# gcc -o sample sample.c
root@kali:~# ./sample text.txt ls -l
root@kali:~# cat text.txt
......
-rw-r----- 1 root root  362 Mar 10 09:20 text.txt
```

Bir dosya açık iken remove yada unlink fonksiyonu ile dosya silinebilir. Bu durumda dosyanın dizin girişi silinebilir fakat dosyanın inode ve data bloktaki bilgileri silinmez. Fakat not alınır, dosya kapatılınca bu silme de yapılır. STDIN, STDOUT ve STDERR Dosyalarının Yaratılması ve Anlamları Stdin,stdout ve stderr dosyaları aslında mingetty yada benzeri isimde olan terminal kontrol prosesi tarafından yaratılmaktadır. Sonra oradan login prosesine, oradan shell’e, oradan da bizim programlarımıza geçer.

![upload-image](/assets/img/sample/linux_sys_prg_process_flw.png)

Pekçek sistemde login programının shell programını çalıştırması doğrudan exec ile yapılmaktadır. Yani login, yaşamına shell olarak devam etmektedir. Dolayısı ile shell farklı prosesler değil aynı prosestir. Login/shell prosesi mingetty programı tarafından beklenmektedir. Dolayısı ile biz shell’den çıktığımızda yeniden mingetty devreye girer ve o da yeniden login programını çalıştırır.

işin başında stdin dosyası klavyeye, stdout ve sterr’de ekrana yönlendirilmiş durumdadır. Tipik olarak mingetty terminal kontrol programı önce terminal aygıt sürücüsünü open fonksiyonu ile O\_RWONLY payraği ile açar böylece 0 numaralı betimleyici elde edilir. Aynı aygıt sürücüyü bu kez O\_WRONLY mofu ile açar. Bu kez 1 numaralı betimleyici elde edilir. Ve nihayet 1 numaralı betimleyiciyi de dup işlemine sokara stderr için 2 numaralı betimleyiciyi elde eder. Programcı programın normal mesajlarını stout dosyasına error mesajlarını stderr dosyasına yazdırmalıdır. Böylece isterse bunları birbirinden ayırabilir.

```c
#include <stdio.h>

int main(void)
{
    fprintf(stderr,"test for stderr\n");
    fprintf(stdout,"test for stdout\n");
    return 0;
}
```

```terminal
root@kali:~# gcc salla.c -o salla
root@kali:~# ./salla
test for stderr
test for stdout
root@kali:~# ./salla 2> stderr.txt
test for stdout
root@kali:~# cat stderr.txt
test for stderr
root@kali:~#
```