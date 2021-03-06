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
 stdout dosyasinin y??nlendirilmesi
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

Bu konunun duzenli anlatimini icin??[buradaki](http://www.csystem.org/sites/default/files/makale/aslank/unix_linux_sistemlerinde_dosya_betimleyicilerinin_anlami.pdf)??makalenin okunmasi gereklidir.

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

Linux???da normal bir kullanicinin ayni anda elde edebilecegi betimleyici sayisi (yani acik olarak tutabilecegi dosya sayisi) 1024???dur. Bu ayni zamanda dosya betimleyici tablosunun uzunlugudur.

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

Prosesin pekcok limiti gibi dosya betimleyici tablosunun uzunlugu da root prosesi tarafindan degistirilebilir. Bir prosesin o anki limitlerini elde etmek icin getrlimit, set etmek icin ise setrlimit fonksiyonlari kullanilmaktadir. Ayni dosya nesnesini gosteren irden fazla betimleyici olabilecegine gore bir betimleyiciyi close fonksiyonu ile kapattigimizda dosya nesnesinin silinmemesi gerekir. iste tipik olarak kernel dosya nesnesinin icerisinde bir sayac tutar. close islemi sirasinda sayaci 1 eksiltir. Sayac 0???a duserse dosya nesnesini siler.

#### Fork islemi sirasinda Dosya betimleyici tablosunun alt prosese aktarilmasi

Fork islemi yapildiginda alt proses icin yeni bir proses kontrol blogu olusturulur ve ust prosesin proses kontrol blogunun icerigi birkac istisma disinda alt prosesin kontrol bloguna kopyalanir. iste bu sirada ust prosesin dosya betimleyici tablosu da alt prosesin dosya betimleyici tablosuna kopyalanmaktadir. yani ust prosesin dosya betimleyici tablosundaki dosya nesnelerinin adresleri kopyalanmakatdir. Boylece ust prosesin dosya betimleyici tablosundaki girisler ile alt prosesin dosya betimleyici tablosundaki girisler ayni dosya nesnelerini gosteriyor durumda olur. (Tabi dosya nesnelerinin sayaclari da 1 artirilir) Buradan su sonuclar cikartilabilir:

*   fork islemi sirasinda ust prosesteki dolu olan betimleyicilerin hepsi alt proseste de gecerli olarak kullanilabilir. Baska bir degis ile biz ust proseste bir dosyayi acip fork yaptigimiz zaman o dosya alt proseste de acik durumdadir.
*   Ust proses ile alt proses ayni dosya nesnelerini paylastigi icin, ornegin ust proses dosya nesnesini degistirir ise alt proses bunu degismis olarak gorur.
*   Fork isleminden sonra artik iki prosesin daha sonra acacagi dosyalar paylasilmayacaktir.

![upload-image](/assets/img/sample/linux_sys_prg_process_ctl_block.png)

Fork isleminden sonra exec yapilacak ise cogu kez (fakat her zaman degil) eski betimleyicilerin yani calistirilan program icin bir anlami olmaz. Yani yeni calistiirlan program zaten bunlardan habersizdir ve bu betimleyiciler bosuna yer kaplar durumda olabilirler. Iste exec yaparken istediginiz bir dosyanin otomayik kapatilmasini sistemden isteyebiliriz. Buna dosyanin ???close on exec??? bayragi denir. dosya temelinde bu bayrak acilip kapatilabilmektedir. Varsayilan olarak bu bayrak false durumdadir. yani exec yaparken dosya kapatilmaz.

### I/O Y??nlendirmelerinde dup2 fonksiyonunun kullan??lmas??

Y??nlendirme i??lemlerinde ??nce close uygulay??p sonra open uygulad??????m??zda bu iki i??lem aras??nda hibir dosyan??n a????lmamas?? gerekir. ????phesiz programc?? bu ko??ulu sa??layabilir. Fakat baz?? durumlarda bu zor olabilir. Ayr??ca y??ksek numaral?? bir betimleyicini bu bi??imde y??nlendirilmesi m??mk??n olmayabilir. i??te bunun i??in dup2 fonksiy??onu tasarlanm????t??r.

```c
#include <unistd.h>
int dup2(int oldfd, int newfd);
```

dup2 fonksiyonu ikinci parametresi ile belirtilen betimleyiciyi a????ksa ??nce onu kapat??r. Sonra birinci parametresi ile belirtilen betimleyici a????k ise onu kapat??r. Sonra ikinci parametresi ile belirtilen betimleyicinin birinci parametresi ile belirtilen betimleyici ile ayn?? dosya nesnesini g??stermesini sa??lar. Ba??ar?? durumunda ikinci parametre ile belirtilen betimleyiciye ba??ar??s??zl??k durumunda -1 ile geri d??ner. ????phesiz dup2 bu i??emleri atomik yapmaktad??r.

Y??nlendirmelerde dup yerine dup2 kullan??lmas?? iyi bir tekniktir.

```c
/*-----------------------------------------------------------------------
 dup2 fonksiyonu ile IO y??nlendirmesi
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

### Alt Prosesin Y??nlendirilmesi

Komut sat??r??nda > stdout dosyas??na y??nlendirmek i??in, < stdin dosyas??na y??nlendirmek i??in, n> veya n< bir dosyaya y??nlendirmek i??in kullan??lmaktad??r. Komut sat??r?? bu y??nlendirmeyi tipik olarak ??u ??ekilde yapmaktad??r.

*   ??nce ??st proses (yani komut satur?? prosesi) bir kez fork yapar,
*   alt prosesi olu??turur,
*   sonra hen??z exec uygulamadan y??nlendirmeyi yapar ve exec uygular.

```c
/*----------------------------------------------------------------
    alt proseste IO y??nlendirmesine ??rnek
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

Bir dosya a????k iken remove yada unlink fonksiyonu ile dosya silinebilir. Bu durumda dosyan??n dizin giri??i silinebilir fakat dosyan??n inode ve data bloktaki bilgileri silinmez. Fakat not al??n??r, dosya kapat??l??nca bu silme de yap??l??r. STDIN, STDOUT ve STDERR Dosyalar??n??n Yarat??lmas?? ve Anlamlar?? Stdin,stdout ve stderr dosyalar?? asl??nda mingetty yada benzeri isimde olan terminal kontrol prosesi taraf??ndan yarat??lmaktad??r. Sonra oradan login prosesine, oradan shell???e, oradan da bizim programlar??m??za ge??er.

![upload-image](/assets/img/sample/linux_sys_prg_process_flw.png)

Pek??ek sistemde login program??n??n shell program??n?? ??al????t??rmas?? do??rudan exec ile yap??lmaktad??r. Yani login, ya??am??na shell olarak devam etmektedir. Dolay??s?? ile shell farkl?? prosesler de??il ayn?? prosestir. Login/shell prosesi mingetty program?? taraf??ndan beklenmektedir. Dolay??s?? ile biz shell???den ????kt??????m??zda yeniden mingetty devreye girer ve o da yeniden login program??n?? ??al????t??r??r.

i??in ba????nda stdin dosyas?? klavyeye, stdout ve sterr???de ekrana y??nlendirilmi?? durumdad??r. Tipik olarak mingetty terminal kontrol program?? ??nce terminal ayg??t s??r??c??s??n?? open fonksiyonu ile O\_RWONLY payra??i ile a??ar b??ylece 0 numaral?? betimleyici elde edilir. Ayn?? ayg??t s??r??c??y?? bu kez O\_WRONLY mofu ile a??ar. Bu kez 1 numaral?? betimleyici elde edilir. Ve nihayet 1 numaral?? betimleyiciyi de dup i??lemine sokara stderr i??in 2 numaral?? betimleyiciyi elde eder. Programc?? program??n normal mesajlar??n?? stout dosyas??na error mesajlar??n?? stderr dosyas??na yazd??rmal??d??r. B??ylece isterse bunlar?? birbirinden ay??rabilir.

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