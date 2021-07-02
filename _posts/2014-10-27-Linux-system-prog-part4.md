---
title: Linux System Programming - Part 4
author: Cihat Yildiz
date: 2014-10-27 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Unix/Linux Sistemlerde Proseslerle Islemler
-------------------------------------------

Unix/Linux Sistemlerinde her prosesin sistem genelinde tek olan bir id degeri vardir. Bu sostemlerde proses yaratmak icin fork isimli proses kullanilir. vfork isimli bir program vardir. O da fork turevidir. Fork, bir prosesin ozdes bir kopyasindan olusturuluyor. Fork islemi yapildiginda yeni bir proses kontrol blogu yaratilir ve o ust prosesten kopyalanir. Ust prosesin de bellek alaninin bellek alaninin bir kopyasindan cikartilir. Boylece fork fonksiyonuna tek bir akis girer 2 akis cikar. Ust proses’de alt proses’de ayni programin kodlarini calistirmaya devam eder.

```c
#include <unistd.h>
pid_t fork(void);
```

Fork fonksiyonundan ust proses alt prosesin id degeri ile cikar. Alt proses ise 0 degeri ile cikar. Suphesiz alt prosesin de bir id’si vardir ancak fork isleminden boyle cikar. Fork fonksiyonunun kendisi de basarisiz olabilir. Bu durumda -1 ile geri doner.

Tipik bir fork kalibi su sekildedir.

```c
if ((pid = fork() == -1){
    perror("fork");
    exit(EXIT_FAILURE)
}
if ( pid != 0 ){
    /*parent*/
}else{
    /*child*/
}
```

Fork isleminden sonra once ust prosesin mi yoksan alt prosesin mi cizelgelenecegi sistemden sisteme degisebilmektedir.

```c
/*-----------------------------------------------------------
 Üst proses
------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int g_x;

int main(int argc, char *argv[])
{
 pid_t pid;

 if ((pid = fork()) < 0)
  exitsys("fork");

 if (pid != 0) {
  g_x = 10;
  printf("parent process...\n");
 
 }
 else {
  sleep(2);
  printf("child process: %d\n", g_x);  /* 0 yazdýrýlacak */
 }

 printf("ends...\n");

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

### exec Fonksiyonlari

Exec fonksiyonlari calistirilabilen bir dosyanin yol ifadesini parametre olarak alir. Mevcut prosesin bellek alanini tamamen bosaltir. Yerine belirtilen programi yukler ve proses calismasina baska bir program olarak devam eder. Proses kontrol blogu degismez. Dolayisi isle prosesin id’si de degismez.Biz exec cagrisindan sonra birtakim kodlar yazsak bile bu kodlar asla calismayacaktir. Yani exec calismakta olan programin yerine artik baska programin calismasini saglamaktadir. Bu durumda hem kendi programimiznin devam etmesini istiyorsa ve hemde baska bir programi calistirmak istiyorsak tek yapilan sey once fork yapmak sonrasinda child prosesde exec ile istedigimiz uygulamayi calistirmaktir. linux cekirdegi 2.6 surumu ile birlikte preemptive sistemlere gecmistir. Fork isleminden sonra exec yapmak maliyetli olarak algilanabilir. Yani madem alt prosesde exec yapilacak neden ust prosesin bellek alani alt prosese kopyalansin ki? Iste eskiden eger eger forkdan sonra exec yapilacak ise bu maliyeti azaltmak icin vfork isimli bir fonksiyon eklenmisti. vfork fonksiyonu hemen exec yapilacagi fikri ile ust prosesten cok kucuk bir bellek alnini kopyalamaktadir. Ancak bugunku islemci mimarileri dikkate alindiginda zaten fork adeta vfork gibi calismaktadir. Bu nedenle bugun vfork fonksiyonuna gerek kalmamistir.

Execl fonksiyonunun prototipi su sekildedir.

```
#include <unistd.h>
int execl(const char *path, const char *arg, ...);
```

Fonksiyonun birinci parametresi calistirilacak programin yol ifadesini alir. Diger parametresleri programin komut satiri argumanlarini belirtir. Arguman listesinin sonuna NULL adres girilmesi gerekmektedir. Programin ilk komut satiri argumaninin program ismi olmai C standartlarinda zorunludur. Beklenti o yondedor. Ancak gercek hayatta zorunlu degildir. Fonksiyon basarisizlik durumunda -1 degerine geri doner. Basari durumunda zaten geri donmez.

```
*Onemli* : Arguman listasinin sonundaki null adress gosteriye donusturulerek verilmelidir. Aksi taktirde bu argumana karsi uc nokta () karsi gelecegi icin NULL yada 0 int olarak degerlendirilir. Bu da su kosullar altinda sorunlara yol acmaktadir.
 - Null adresin 0 olmamasi durumunda 
 - int turu ile gosterici uzunlugunun ayni olmadigi sistemlerde (64 Bit)
```

Suphesis bu donusturme gerekligi yanlizca prototipde 3 nokta oldugu durumda gecerlidir. Yoksa protatipde NULL yada 0 in karsiliginda acikca bir gosterici var ise derleyici o sifirin zaten null adres anlamina geldigini bilir.

```c
/*-----------------------------------------------------------------
 execl fonksiyonunun uygulanmasý
-----------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 printf("starts...\n");

 if (execl("/bin/ls", "/bin/ls", "-l", (char *) NULL) < 0)
  exitsys("execl");

 printf("unreachable code!..\n");

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Exec fonksiyonlarinin v’li versiyonlari komut satiri argumanlarini bir dizi olarak alir.

```c
#include <unistd.h>
int execv(const char *path, char *const argv[]);
```

Bu dizinin sonunda yine NULL adres sabiti olmalidir. C Standartlarina gore arvg ile belirtilen komut satiri arguman listesinin sonunda null adres bulunmak zorundadir. Bu durumda ornegin biz komut satiri argumanlarini su sekilde de yazdirabilir.

```c
for( i=0 ; argv[i] != 0 ; NULL; ++i){
    puts(argv[i]);
}
```

bir execv ornegi;

```c
/*------------------------------------------------------
    execv fonksiyonu ornegi
------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 char *args[] = {"/bin/ls", "-l", "-i", NULL};

 if (execv("/bin/ls", args) < 0)
  exitsys("execl");

 printf("unreachable code!..\n");

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

komut satirindan girilen bir komutun calistirilmasi uygulamasi;

```c
/*--------------------------------------------------------------
  execv fonksiyonun kullanımı
---------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 if (argc < 2) {
  fprintf(stderr, "wrong number of arguments!..\n");
  exit(EXIT_FAILURE);
 }

 if (execv(argv[1], &argv[1]) < 0)
  exitsys("execl");

 printf("unreachable code!..\n");

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Exec fonksiyonlarinin p’li versiyonlari path cevre degiskenlerine bakmaktadir. execlp ve execvp fonksiyonlarinin prototipleri su sekildedir.

```c
#include <unistd.h>
int execlp(const char *file, const char *arg, ...);
int execvp(const char *file, char *const argv[]);
```

Bu fonksiyonlar su sekilde calismaktadir; Eger calistirilabilen dosyanin yok ifadesinda hivbir / karakteri kullanilmamissa, yani dogrudan program ismi yazilmissa, bu durumda ilgili dosya $PATH cevre degisken ile belirtilen dizinlerde aratilir. Eger yol ifadesinde en az bir bolu karakteri var ise bu durumda yol ifadesi normak kurallara gore $PATH cevre degiskenine bakilmadan calistirilir. Yani bu durumda fonksiyonlarin calismasi execl ve execv’den farkli degildir. Kabuk programlari kabuk uzerinde program calistirilmak istendiginde bu calistirma islemini exec fonksiyonlarinin p’li versiyonlariyla yapmaktadir. Bu nedenle calisma dizinindeki sample programini “sample” diyerek calistiramayiz. Araya bir bolu karakteri yerlestirerek exec fonksiyonlarinin p’li versiyonlarinin $PATH cevre degiskenine bakmasini engelleyebiliriz. Bunu saglamanin enpratik yolu ./sample ifadesi ile programi calistirmaktir.

```c
/*--------------------------------------------------------------
  execv fonksiyonun kullanımı
--------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 if (argc < 2) {
  fprintf(stderr, "wrong number of arguments!..\n");
  exit(EXIT_FAILURE);
 }

 if (execp(argv[1], &argv[1]) < 0)
  exitsys("execl");

 printf("unreachable code!..\n");

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Ayrica bir de exec fonksiyonlarinin e’li versiyonlari vardir. Bu e’li versiyonlari ayrica cevre degiskenleri de alirlar. Bu konu ileride ele alinacaktir.

```c
#include <unistd.h>
int execve(const char *filename, char *const argv[],  char *const envp[]);
```

Fonsiyonun e’li versiyonlari cevre degisken listesini de bizim belirlememe olanak saglar.

Fork ve Exec Fonksiyonlarinin bir arada uygulanmasi Birkez fork yapip alt prosesde exec uygulama kalibi soyle uygulanabilir.

```c
pid_t pid;

if((pid = fork()) < 0){
    perror("fork");
    exit(EXIT_FAILURE);
}

if(pid == 0){
    if(exec(...) < 0){
        perror("exec");
        exit(EXIT_FAILURE);
    }
}
/* parent */

Bu bu kullanim asagidaki kullanim ile tamamen esdegerdir.
if((pid == 0) && (exec(...) < 0)){
    perror("exec");
    exit(EXIT_FAILURE);
}
/* parent */
```

Fork ve exec fonksiyonlarinin birlikte kullanilmasi ornegi;

```c
/*----------------------------------------------------------
   fork ve exec fonksiyonlarinin birlikte kullanilmasi
-----------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 pid_t pid;
 
 if (argc < 2) {
  fprintf(stderr, "wrong number of arguments!..\n");
  exit(EXIT_FAILURE);
 }
 
 if ((pid = fork()) < 0)
  exitsys("fork");
 
 if (pid == 0 && execvp(argv[1], &argv[1]) < 0)
  exitsys("execvp");
 
 printf("parent continues...\n");
 
 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

8 Tane child proses olusturan ve ekrana test yazan bir uygulama

```c
/*------------------------------------------------------------------
// Asağıdaki programda 8 tane alt proses oluşur 
// dolayısıyla ekrana 8 tane "test" yazısı basılır
-------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 if (fork() < 0)
  exitsys("fork");
 
 if (fork() < 0)
  exitsys("fork");
 
 if (fork() < 0)
  exitsys("fork");
 
 printf("test\n");
  
 
 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

ProsesID’lerine iliskin POSIX Fonksiyonlari
-------------------------------------------

getpid fonksiyonu calismakta olan prosesin kendi prosesid’sini bize verir. getppid fonksiyonu ise calismakta olan prosesin ust prosesinin proses id’sii bize verir.

```c
#include <unistd.h>
pid_t getpid(void);
pid_t getppid(void);
```

ps komutu default olarak komutu uygulayan kullanicinin komutun uygulandigi terminale bagli prosesleri listeler. ps -e yada ps -A sistemdeki tum proseseleri listeler. ps -a terminale bagli olmayan yani baska terminale bagli olan prosesleri de listeler (o kullaniciya ait). -l secenegi daha fazla bilgiden olusan bir liste bize verir.

```c
/*----------------------------------------------------------------
 getpid ve getppid fonksiyonlarý
-----------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 pid_t pid;

 if ((pid = fork()) < 0)
  exitsys("fork");

 if (pid == 0)
  printf("(Child Process) pid = %ld, ppid = %ld\n", (long) getpid(), (long) getppid());
 else {
  printf("(Parent Process) pid = %ld, ppid = %ld\n", (long) getpid(), (long) getppid());
  sleep(1);
 }

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Alt proseslerin beklenmesi ve exit kodlarinin elde edilmesi Her proses sonlandiginda sisteme bir exit kodu iletir. Prosesin exit kodu tipik olarak prosesin kontrol blogunda saklanmaktadir. Prosesin hangi degerde sonlandiginin sistem bakimindan bir onemi yoktur. Bundan prosesi yaratan ust proses faydalanabilir. Fakat geleneksel olarak basari durumu icin 0 basarisizlik durumu icin 0 disi degerler ile sonlanir.

Exit standart bir C fonksiyonudur. Prototipi su sekildedir.

```c
#include <stdlib.h>
void exit(int status);
```

Unix/Linux sistemlerinde proses sonlandiran posix fonksiyonu \_exit isimli fonksiyondur.

```c
#include <unistd.h>
void _exit(int status);
```

\_exit fonksiyonu linux sistemlerinde dosgrudan sys\_exit isimli sistem fonksiyonunu cagirmaktadir.

```
  exit ---->  _exit -----> sys_exit
 (Std C)      (POSIX)        (Linux)
```

Biz C programlarinda mumkun oldugunda standart exit fonksiyonunu kullanmaliyiz. Cunku bu fonksiyon standart C kutuphanelerine iliskin geri birakma islemleri yapmaktadir. Ozellikle standad C nin dosya modunda kullanilmissa bu cok onemlidir. Aslinda bir C programinda ilk calisan fonksiyon main fonksiyonu degildir. BIzim yazdigimiz programla birlikte derleyicinin baslangic kodu (startup code) denilen bir kod birlikte link edilir ve calistirilabilen dosyanin baslangic noktasi (entry point) bu baslangic kodunun icerisindedir. Main fonksiyonu baslangic kodundan cagirilmaktadir. Derleyicinin baslangic kodu

```asm
....
....
....
call main
PUSH eax
CALL exit
```

O halde akis main fonksiyonunu bitirirse exit fonksiyonu main fonksiyonunun geri donus degeri ile cagirilmaktadir. Standartlarda programin asagidaki bicimde sonlanmasi gerektigi acikca belirtilmistir.

exit(Main());

C Programlama dilinde Main fonksiyonuna ozgu olarak eger main’de hic return kullanilmaz ise ve akis return gormeden main fonksiyonunu bitirirse main fonksiyonunun 0 ile geri dondugu kabul edilir. Bir proses sonlandiginda o prosesin bellek alanlari ve kullandigi kaynaklar sisteme iade edilir. Fakat proses kontrol blogu dolayisi ile proses id’si ust proses onun exit kodunu alabilir diye bekletilir. Bu durumda gercekte sonlanmis fakat proses kontrol blogu silinmemis, dolayisi ile proses id’si serbert birakilmamis bir durum olusur. Bu duruma dusen proseslere hortlak (Zombie) prosesler denilmektedir. Zombi prosesin engellenmesi icin tipik olarak ust prosesin wait fonksiyonlari ile alt proseslerin exit kodunu almasi gerekmektedir. Birkac senaryo soz konusudur. Once alt proses sonlanmistir. Ust proses alt prosesin exit kodunu henuz almamistir. Bu durumda alt proses zombi durumundadir. Alt proses sonlanmistir. daha sonra ust proses alt prosesin exit kodunu almadan sonlanmistir. Budurumda init proses yardimi ile alt prosesin kontrol blogu bosaltilir. Yani hortlaklik ortadan kalkar. Alt proses devam ederken ust proses sonlanmistir. Bu proseslere oksuz (orphan) proses denilmektedir. Oksuz proseslerin ust prosesligine init proses atanir. Oksuz proses sonlandiginda init proses onun exit kodunu alir. Alt proses zombi olmaktan kurtarilir. O halde hortlaklik alt proses sonlandigi halde ust prosesin onun exit kodunu almadan devam etmesi durumunda ve bu sure zarfinda olusmaktadir.

```c
/*----------------------------------------------------------------------
 30 saniye süresince hortlak oluşturan proses
-----------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 pid_t pid;
 
 if ((pid = fork()) < 0)
  exitsys("fork");
 
 if (pid) {
  sleep(30);  
 }
 else {
  exit(EXIT_SUCCESS);
 }
 
 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

### Wait Fonksiyonlari

En cok kullanilan wait fonksiyonlarinin prototipi su sekildedir.

```c
#include <sys/wait.h>
pid_t wait(int *status);
```

Fonksiyon ilk alt proses sonlanana kadar blokede bekler, onun exit kodunu alir, parametresiyle aldigi adresdeki int turden nesneye yerlestirir. O alt prosesin ID degeri ile geri doner. Parametre NULL gecilebilir. Bu durumda proses exit kodunu alir fakat bize vermez. Alt proses zombilikten kurtulmus olur. Fonksiyon basarisizlik durumunda -1 degerine geri doner. aslinda fonksiyon adresini verdigimiz int nesnenin icerisine yalnizca programin exit kodunu kodlamaz, prosesin neden sonlandigina iliskin bazi bilgileri de bazi bitlere kodlar. WEXITSTATUS isimli makro bize exit kodunu verir. WIFEXITED bize programin normal olarak sonlanip sonlanmadigi bilgisini eririr. WIFSINGLED makrosu bize prosesin bir sinyalle sonlanip sonlanmadigi bildisini verir. Proses normal sonlanmamis ise exit kodunun bir anlamu yoktur. Bu nedenle once programcinin once WIFEXITED makrosu ile kontrol yapmasi gerekmektedir.

```c
/*--------------------------------------------------------------
 wait fonksiyonun kullanımı
---------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 pid_t pid, pidWait;
 int status;
 
 if ((pid = fork()) < 0)
  exitsys("fork");
 
 if (pid != 0) {
  printf("parent is waiting for the child to exit...\n");
  if ((pidWait = wait(&status)) < 0)
   exitsys("wait");
  
  if (WIFEXITED(status))
   printf("Ok, child (%ld) exited with %d\n", (long) pidWait, 
               WEXITSTATUS(status));
  else if (WIFSIGNALED(status))
   printf("child stopped by a signal!\n");
  }
 else {
  sleep(20);
  return 100;
 }
 
 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Waitpid isimli fonksiyon islevsel olarak wait fonksiyonun kapsar. Daha detaylidir.

```c
#include <sys/wait.h>
pid_t waitpid(pid_t pid, int *status, int options);
```

Fonksiyonun birinci parametresi beklenmek istenen prosesin ID degerini belirtir. Fonksiyon birinci parametresi -1 girilir ise Bu durumda ilk sonlanan alt proses beklenir(tipki wait gibi). Birinci parametre 0’dan buyuk bir deger girilir ise o Id’ye sahip bir alt proses beklenir. Birinci parametre 0 ise proses grup id’si waitpid fonksiyonunu cagiran fonksiyon ile ayni olan prosesler beklenir. Nihayet Birinci parametre -1 den kucuk bir deger girilir ise bu degerin mutlak degeri alinir ve proses id’si bu deger olan prosesler beklenir. Fonksiyonun ikinci parametresi yine prosesin exit kodunun yerlestirilecegi nesne adresidir. Bu parametre yine NULL gecilebilir. Nihayet son parametre 0 gecilebilir fakat bazi ozel degerler de gecilebilir. Ornegin WNOHANG gecilir ise fonksiyon hic bekleme yapmaz. Sonlanmis proses var ise onun exit kodunu alir. Yoksa da hemen sonlanir. Fakat bu durumda -1’e geri doner.

Bu durumda asagida gosterilen iki fonsiyon cagrisi tamamen birbirine esdegerdir.

*   wait(&status)
*   waitpid(-1, &status, 0); linux’da geri donus degerleri 1 byte uzunlugundadir.

```c
/*----------------------------------------------------
 waitpid fonksiyonu
-----------------------------------------------------*/

/* sample.c */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 pid_t pid;
 int status;
 
 if ((pid = fork()) < 0)
  exitsys("fork");
 
 if (pid != 0) {
  printf("parent is waiting for the child to exit...\n");
  if (waitpid(pid, &status, 0) < 0)
   exitsys("wait");
  
  if (WIFEXITED(status))
   printf("Ok, child exited with %d\n", WEXITSTATUS(status));
  else if (WIFSIGNALED(status))
   printf("child stopped by a signal!\n");
  }
 else {
  if (execl("testprog", "testprog", (char *) NULL) < 0)
   exitsys("execl");
 }
 
 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}

/* testprog.c */

#include <stdio.h>

int main(void)
{
 printf("testprog starts...\n");
 
 return 250;
}
```
