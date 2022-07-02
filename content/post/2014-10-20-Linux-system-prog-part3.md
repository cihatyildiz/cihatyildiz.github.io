---
title: Linux System Programming - Part 3
author: Cihat Yildiz
date: 2014-10-20 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Dosya Baglari (linkleri)
------------------------

Dosya baglari siki (hard) ve sembolik olmak uzere ikiye ayrilmaktadir. Hard link sisteminin anlasilabilmesi icin diskin metadata formatinin biliniyor olmasi gerekmektedir. Bir diskte okunabilecek veya yazilabilecek en kucu birim sektordur. Bir sektor varsayilan olarak 512 byte uzunlugundadir. Ancak isletim sistemleri diski sektpor temelinde organize etmek yerine block yada cluster denilen birimler ile organize etmektedir. Bir block yada Cluster ardisil n sektorden olusmaktadir. Bu sektorun sayisi formatlarken belirlenir.

Bir block yada cluster bis dosyanin parcasi olabilen en kucuk birimdir(ornegin 1 byte uzunlugunda bir dosya olusturacak olsak sistemda bu dosya icin 1 block yer ayrilir). Bir volumu ext2, ext3 gibi inode tabanli bir dosya sistemi ile formatlarsak kabaca diskte 3 bolum olusturulur. Bunlar super block, inode block, data block bolumleridir. Super Blok, bolumlerin yerlerini uzunluklarini vesaire tutan bir blogun kaz sektorden olustugunu tutan bolumdur. Volume’nin kalbidir. Inode block, inode elemanlarindan olusur. Her inode elemanina 0’dan baslayarak bir sira numarasi karsilik dusurulmustur. Bir dosyanin butun bigileri, yani stat fonksiyonu ile aldigimiz bilgiler inode elemaninda tutulur. Bir dosya yaratildiginda onun icin bir inode elemani olusturulur. Yani her dosyanin bir inode elemani vardir. Dizinler de birer dosya gibidir. Onlar icin de birer inode elemani vardir. BIr dosyanin inode numarasi demek o dosyanin bilgilerinin inode blogunun kacinci inode elemaninda saklandigi demekdir. dosyanin inode numarasi ls -i ile goruntulenmektedi 0 Numarali inode elemani kok dizinin elemanidir. Dizinler de dosyalar gibi bir dizin dosyasinin icerisinde dosya ismi ve inode numaralarindan olusan kayitlar vardir.

| isim | inode no |
| isim | inode no |
| isim | inode no |
| isim | inode no |
| ... | ... |

Diskin data bolumu ilk blok sifirdan baslayacak sekilde bloklarla numaralandirilmistir. Her dosya data bolumu icerisinde bloklara parcalanmis bir bicimde oradaki bloklarda tutulmustur. Bu bloklar ardisil olmak zorunda degildir. Dosyanin parcalarinin hangi bloklarda oldugu inode elemaninda tutulmaktadir. isletim sisteminin dosya sistemi yol ifadelerinden oncelikle bir bir inode elemani elde etmelidir. Cunku dosyani butun kontrol bilgisi inode elemanindadir. Genel olarak bir yol ifadesinden o dosyaya iliskin inode elemaninin elde edilmesi surecine “Pathname resolution” denilmektedir. Pathname resolution su sekilde gerceklestirilir. Ornegin /home/csd/test.dat dosyasina erisilmek istensin;

*   Sistem 0 numarali inode elemanina gider. Onun bloklarini okur ve orada inode kayitlari vardir. Orada home isminii arar. Bulursa onun inode numarasini elde eder,
*   Eger bulunan home ismi bir dizin dosyasina iliskinse ve erisim hakki varsa onun inode elemanina gide ve onun da bloklarini okur. Orada csd ismini arar ve onun inode numarasini elde eder.
*   Artik csd’nin inode elemaninda onun bloklarina bakilarak bu kez orada test.dat aranir. ve nihayet dosyanin bilgisine erisir.

### Hardlink nedir?

Hardlink farkli dizin girislerinin ayni inode numarasina sahip olmasidir. Boylece iki farkli yol ifadesiyle pathname resolution yapildiginda aslinda ayni dosyaya erisilmis olur. Ornegin

![upload-image](/assets/img/sample/linux-link-table.png)

Goruldugu gibi /home/kaan/b.dat dizin girisi ile /home/ali/y.dat dizin girisi ayni inode elemanini gostermektedir.

#### Peki rm gibi bir komutla bu dosyalardan biri silinse ne olur?

Eger dosyanin inode elemani ve inode bloklar free hale getirilirse diger yol ifadesiyle ardik diger dosyaya erisemiyoruz.iste bunun icin inode elemaninda isletimsistemi hardlink sayisini tutar. Dosya silinmeye calisildiginda once dizin girisini siler. Sonra dosyanin inode elemanina giderek oradaki hardlink sayacini 1 eksiltir. Eger sayac sifira duserse dosyanin inode numarasini ve o inoda bagli data bloklarini siler(metadata alanlari silinmis gibi gosterilir). Inode tabanli dosya sistemlerinde ayrica hangi inode elemanlarinin bos oldugu ve hangi data bloklarinin bos oldugu disk uzerinde bir yerlerde tutulmalidir. Suphesiz her blok yada inode elemani icin 1 bit yeterlidir. Ornegin ext2 dosya sisteminde bu bilgiler hemen superblok’tan asonra block bitmap ve inode bitmap isimleri ile tutulurlar.

Bir dosyanin hardlink’i komut satirinda ln komutu ile olusturulmaktadir.

```terminal
cx@debx86:~$ ls -il a.txt
1061483 -rw-r--r-- 1 cx cx 4 Feb 18 15:10 a.txt
cx@debx86:~$ ln a.txt b.txt
cx@debx86:~$ ls -il *.txt
1061483 -rw-r--r-- 2 cx cx 4 Feb 18 15:10 a.txt
1061483 -rw-r--r-- 2 cx cx 4 Feb 18 15:10 b.txt
cx@debx86:~$
```

Bir dizin olusturuldugu zaman nokta ve nokta nokta isimli iki dizin otomatik yaratilmaktadir. BUnlar aslinda birer hardlink girisleridir. Boylece nokta dizini kendi dizinin hardlink sayacini 1 artirir. ikinokta dizini de ust dizinin harlnik sayacini 1 artirir.

### Sembolik Link Dosyaları

http://www.kaanaslan.com/resource/article/display\_article.php?id=74 adresinden detayli bilgilerin elde edilmesi lazim

Sembolik link dosyalari normal bir dosya gibidir. NOrmal bir dosyanin icerisinde dosyanin bilgileri vardir fakat sembolik link dosyalarinin icerisinde o dosyanin belirtdigi asil dosyanin yol ifadesi vardir. Pekcok sistem ve posix fonksiyonuna biz sembolik bir dosyanin yol ifadesini verdigimizde o aslinda o dosyani belirttigi asil dosya uzerinde islem yapar. Bazen sembolik link izlemek probleme yol acabilir. Ornegin dizin agacini dolasirken biz baska bir dizine bir sembolik link gordugumuzde o dizine gecersek ve o dizin de bizim dizinimizi kapsiyor ise sonsuz dongu olusur. Bu nedenle bazi fonksiyonlari “l” ile baslayan versiyonlari olusturulmustur. Fponksiyonlarin bu “l” ‘li versiyonlari sembolik link dosyasi soz konusu oldugunda o dosyanin kendisi uzerinde islem yapar. Dosyanin gosterdigi dosya uzerinde degil. Ornegin stat fonksiyonunun lstat isimli bir verisonu vardir. Sembolik baglanti dosyasi baska bir sembolik baglanti dosyasini gosterebilir. Hatta dongusel bir durum bile olusabilir. Boyle bir dongusel durumda sistem fonsiyonlar bunu tespit eder ve hata ile donus yapar. errno degiskenine ELOOP degeri set eder. Bazi fonksiyonlar hic sembolik baglantilari izlememektedir. Dogrudan sembolk dosyanin kendisi uzerinde islem yapmaktadir. hardlink dosyasi olusturabilmek icin link isimli bir fonksiyon vardir. Sembolik link olusturabilmek icin symlink isimli fonksiyon kullanilmaktadir.

```c
#include <unistd.h>
int link(const char *oldpath, const char *newpath);
int symlink(const char *oldpath, const char *newpath);
```

Komut satirindan sembolik link dosyalari ln -s komutu ile olusturulurlar. Sembolik dosyanin gosterdigi dosya silinir ise bu duruma danling link denilmektedir. Boylesi bir durumda open fonksiyonu ile bir dosya acmaya calisirsak olmayan bir dosyayi acmayaclisir gibi oluruz. Sembolik linkler ozellikle bazi dizinlere pratik erisim icin tercih edilmektedir.

Pogramin Calisma Dizini
-----------------------

Her prosesin bir calisma dizini vardir. Prosesin calisma dizini prosesin kontrol blogunda saklanmaktadir. Prosesin calisma dizin fork sirasinda ust prosesden aktarilmaktadir. Prosesin calisma dizini goreli yol ifadelerinin cozulmesinde kullanilir. Eger yol ifadesinin ilk karakteri / ise bu mutlak bir yol ifadesidir. Mutlak yol ifadelerinin cozulmesi kok dizinden itibaren yapilir. Eger yol ifadesi / ile baslamiyor ise o zaman prosesin calisma dizininde itibaren belirtilen yolu kullanir. Prosesin calisma dizini goreli yol ifadelerinin cozulmesi icin bir orijin gorevi yapar.?

Peki biz login oldugumuzda shell prosesinin calisma dizini nasil belirlenmektedir?

Biz shell altinda bir program calistirdigimizda calismadizini shell ile ayni olacaktir. iste login programi bize ssiteme sokarken /etc/passwd dosyasindaki belirtilen programi (genellikle /bin/bash ) yine orada belirtilen calisma dizini olarak ayarlayarak calismaktadir. Bir proses calisirken kendi calisma dizinini chdir fonksiyonu ile degistirebilmektedir.

```c
#include <unistd.h>
int chdir(const char *path);
```

fonksiyonun parametresi prosesin yeni calisma dizini olacaktir. Fonksiyon basari durumunda 0 basarisizlik durumunda -1 olarak geri doner. Bir proses baska bir prosesin calisma dizinini degistiremez. Boyle bir sistem fonksiyonu yoktur. Bu durumda ornegin shelin cd komutu aslinda calistirilabilir bir program degildir. shelin icsel komutudur.

Bir prosesin proses kontrol kontrol blogundaki / dizini kaydi degistirilebilir. Boylelikle uygulamayi bir dizin icerisine hapsedebiliriz.

Prosesin calisma dizini getcwd isimli posix fonksiyonu ile alinir. Fonksiyonun prototipi su sekildedir.

```c
#include <unistd.h>
char *getcwd(char *buf, size_t size);
```

Fonksiyonun birinci parametresi calisma dizininin yerlestirilecegi bellek alani adresini ikinci parametresi de dizinin uzunlugunu alir. Fonksiyon basari durumunda birinci parametre ile girilen parametrenin aynisina, basarisizlik durumunda null olarak geri doner.

```c
/*-----------------------------------------------------
 getcwd fonksiyonu
------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 char cwd[1024];

 if (getcwd(cwd, 1024) == NULL)
  exitsys("getcwd");

 puts(cwd);

 return 0;
}


void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Ornek Bir Shell Programi
------------------------

```c
/*--------------------------------------------------------
 Örnek bir shell programi
---------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <dirent.h>
#include <pwd.h>
#include <grp.h>

/* Symbolic Constants */

#define MAX_CMDLINE  1024
#define MAX_CMDPARAMS 100
#define MAX_PATH  4096

/*  Type Declarations */

typedef struct tagCMD {
 char *cmdText;
 void (*proc)(void);
} CMD;

/* Function Prototypes */

void exitsys(const char *msg);
void parse_cmdline(void);
char *getls(const char *path, const struct stat *finfo, int linkSpace, int sizeSpace);
int getdigit_count(int val);

void cmd_remove(void);
void cmd_cp(void);
void cmd_clear(void);
void cmd_ls(void);
void cmd_cd(void);

/* Global Definitions */

char g_cmdLine[MAX_CMDLINE];
char *g_cmdParams[MAX_CMDPARAMS];
int g_nParams;
char g_cwd[MAX_PATH];

CMD g_cmds[] = {
 {"rm", cmd_remove },
 {"cp", cmd_cp },
 {"clear", cmd_clear },
 {"ls", cmd_ls},
 {"cd", cmd_cd},
 {"chdir", cmd_cd},

 {NULL, NULL}
};

/* Function Defitinions */

int main(int argc, char *argv[])
{
 int i;

 for (;;) {
  if (getcwd(g_cwd, MAX_PATH) < 0)
   exitsys("cwd");
  
  printf("CSD:%s>", g_cwd);
  gets(g_cmdLine);
  parse_cmdline();
  if (g_nParams == 0)
   continue;
 
  if (!strcmp(g_cmdParams[0], "exit"))
   break;
 
  for (i = 0; g_cmds[i].cmdText != NULL; ++i)
   if (!strcmp(g_cmdParams[0], g_cmds[i].cmdText)) {
    g_cmds[i].proc();
    break;
   }
  if (g_cmds[i].cmdText == NULL)
   printf("%s: command not found\n", g_cmdParams[0]);
 }


 return 0;
}

void parse_cmdline(void)
{
 char *str;

 g_nParams = 0;
 for (str = strtok(g_cmdLine, " \t"); str != NULL; str = strtok(NULL, " \t"))
  g_cmdParams[g_nParams++] = str;
 g_cmdParams[g_nParams] = NULL;
}

void cmd_remove(void)
{
 printf("remove command...\n\n");
}

void cmd_cp(void)
{
 int fds, fdd;
 char *buf;
 struct stat finfo;
 ssize_t n;

 if (g_nParams != 3) {
  printf("invalid cp command!..\n");
  return;
 }

 if ((fds = open(g_cmdParams[1], O_RDONLY)) < 0) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 if ((fdd = open(g_cmdParams[2], O_WRONLY|O_CREAT|O_TRUNC, 
                     S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)) < 0) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 if (stat(g_cmdParams[1], &finfo) < 0) {
  perror("stat");
  return;
 }

 if ((buf = malloc(finfo.st_blksize)) == NULL) {
  printf("not enough memory!..\n");
  return;
 }
 
 while ((n = read(fds, buf, finfo.st_blksize)) > 0)
  if (write(fdd, buf, n) < 0) {
   perror("write");
   exit(EXIT_FAILURE);
  }

 if (n < 0) {
  perror("read");
  exit(EXIT_FAILURE);
 }

 close(fds);
 close(fdd);

 free(buf);

 printf("1 file copied...\n");
}

void cmd_clear(void)
{
 if (g_nParams > 1) {
  printf("invalid clear command!..\n");
  return;
 }

 system("clear");
}

void cmd_ls(void)
{
 char *path;
 DIR *dir;
 struct dirent *dire;
 char fpath[MAX_PATH];
 int nfiles;
 struct stat *finfos = NULL;
 struct dirent *dirents = NULL;
 int maxLink, maxSize, maxLinkSpace, maxSizeSpace;
 int i;

 if (g_nParams == 1)
  path = g_cwd;
 else if (g_nParams == 2)
  path = g_cmdParams[1];
 else {
  printf("ls: invalid command syntax\n");
  return;
 }

 if ((dir = opendir(path)) < 0) {
  perror("opendir");
  return;
 }

 for (nfiles = 0; (dire = readdir(dir)) != NULL; ++nfiles) {
 
  if (nfiles % 32 == 0) {
   if ((finfos = realloc(finfos, (nfiles + 32) * sizeof(struct stat))) == NULL)
    exitsys("realloc");
   if ((dirents = realloc(dirents, (nfiles + 32) * sizeof(struct dirent))) == NULL)
    exitsys("realloc");
  }
   
  dirents[nfiles] = *dire;
  sprintf(fpath, "%s/%s", path, dire->d_name);
  if (stat(fpath, &finfos[nfiles]) < 0) {
   perror("stat");
   closedir(dir);
   free(finfos);
   return;
  }
 }

 maxLink = maxSize = 0;
 for (i = 0; i < nfiles; ++i) {
  if (maxLink < finfos[i].st_nlink)
   maxLink = finfos[i].st_nlink;
  if (maxSize < finfos[i].st_size)
   maxSize = finfos[i].st_size;
 }

 maxLinkSpace = getdigit_count(maxLink);
 maxSizeSpace = getdigit_count(maxSize);
 
 for (i = 0; i < nfiles; ++i) {
  sprintf(fpath, "%s/%s", path, dirents[i].d_name);
  printf("%s\n", getls(fpath, &finfos[i], maxLinkSpace, maxSizeSpace));
 }

 free(finfos);
 free(dirents);
  
 closedir(dir);
}

char *getls(const char *path, const struct stat *finfo, int linkSpace, int sizeSpace)
{
 char static buf[4096];
 int index;
 int i;
 int aflags[] = {S_IRUSR, S_IWUSR, S_IXUSR, S_IRGRP, 
                     S_IWGRP, S_IXGRP, S_IROTH, S_IWOTH, S_IXOTH};
 char *rights = "rwx";
 struct passwd *pwd;
 struct group *grp;
 char *months[] = {"Oca", "Þub", "Mar", "Nis", "May", 
                        "Haz", "Tem", "Aðu", "Eyl", "Eki", "Kas", "Ara"};
 struct tm *ftime;
 char *lastSlash;
 
 index = 0;
 if (S_ISREG(finfo->st_mode))
  buf[index] = '-';
 else if (S_ISDIR(finfo->st_mode))
  buf[index] = 'd';
 else if (S_ISCHR(finfo->st_mode))
  buf[index] = 'c';
 else if (S_ISBLK(finfo->st_mode))
  buf[index] = 'b';
 else if (S_ISFIFO(finfo->st_mode))
  buf[index] = 'p';
 else if (S_ISLNK(finfo->st_mode))
  buf[index] = 'l';
 else if (S_ISSOCK(finfo->st_mode))
  buf[index] = 's';

 ++index;

 for (i = 0; i < 9; ++i)
  buf[index++] = (finfo->st_mode & aflags[i]) ? rights[i % 3] : '-';
 buf[index++] = ' ';

 index += sprintf(&buf[index], "%*lu", linkSpace, (unsigned long) finfo->st_nlink);
 buf[index++] = ' ';
 
 if ((pwd = getpwuid(finfo->st_uid)) == NULL)
  index += sprintf(&buf[index], "%lu", (unsigned long) finfo->st_uid);
 else
  index += sprintf(&buf[index], "%s", pwd->pw_name);
 buf[index++] = ' ';
 
 if ((grp = getgrgid(finfo->st_gid)) == NULL)
  index += sprintf(&buf[index], "%lu", (unsigned long) finfo->st_gid);
 else
  index += sprintf(&buf[index], "%s", grp->gr_name);
 buf[index++] = ' ';

  index += sprintf(&buf[index], "%*ld", sizeSpace, (long) finfo->st_size);
 buf[index++] = ' ';

 ftime = localtime(&finfo->st_mtime);

 lastSlash = strrchr(path, '/');
 index += sprintf(&buf[index], "%s %d %02d:%02d %s", months[ftime->tm_mon], 
                        ftime->tm_mday,ftime->tm_hour, ftime->tm_min, lastSlash + 1);
 buf[index] = '\0';

 return buf;
}

void cmd_cd(void)
{
 if (g_nParams != 2) {
  printf("cd: invalid command syntax!\n");
  return;
 }

 if (chdir(g_cmdParams[1]) < 0) {
  perror("cmd:");
  return;
 }
}

int getdigit_count(int val)
{
 int count = 0;

 while (val) {
  ++count;
    val /= 10;
 }

 return count;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

bu yazmis oldugumuz shell uygulamasini /etc/passwd icerisinde bir kullanicinin shelli icine yazarsak eger login olan kullanici bizim yazdigimiz shell uygulamasina girer.

```terminal
test:x:1001:1000:test,,,:/home/test:/bin/csdsh
```

Derledigimiz uygulamamizi /bin/sh icerisine ekleyoruz. Bu uygulama icin calistirma yetkisi de vermemiz lazim.

Dosyalarin Silinmesi
--------------------

Dosyayi silmek icin remove ve unlink isimli iki esdeger fonksiyon kullanilabilmektedir. Unlink fonksiyonunu prototipi unistd.h icerisinde, remove fonksiyonunun prototipi stdio.h icerisindedir.her iki fonksiyon da once hardlink sayacini 1 eksiltir. Duruma gore dosyanin inoce bilgilerini siler.Bir dosyayi silebilmek icin yada bir dosyayi yaratabilmek icin o dosyanin icinde bulundugu dizine yazma hakkimizin olmasi gerekmektedir. Ayrica biz baskasinin sahibi oldugu dosyalari silemeyiz. Yani silecegimiz dosyanin userid prosesimizin etkin userid degeri ile ayni olmasi gerekmetedir. Fakat silem islemi icin dosyaya write hakki olmasi gerekmemetedir

```c
#include <unistd.h>
int unlink(const char *pathname);
#include <stdio.h>
int remove(const char *pathname);
```

### Dizinlerdeki x hakki

#### Dizinlerdeki erisim haklari

Bir dosyaya pathname resolution sirasinda erisebilmek icin yol ifadesinde bulunan butun dizinlere x hakkinin olmasi gerekmektedir. Yani dizinlerde x hakki icinden gecmek anlamina gelmektedir. ornegin biz stat fonksiyonu ile yada diger bir fonksiyonla /home/kaan/ali/x.dat dosyasini belirtmek isteyelim. Bizim bu islemi yapabilmemiz icin home, kaan ve ali dizinine x hakkina sahip olmamiz gerekmektedir. Bir dizine write hakkinin olmasi o disin dosyasinin dizin girisleri uzerinde degisiklikler yapilabilmesi denilmektedir. Yani o dizinden dosya yaratma, dosya silmek,rename islemi yapmak bu haklari gerektirir.

Ornegin biz /a/b/c dizininde bir dosya yaratmak isteyelim. Burada bizim a, b ve c dizinlerinin hepsine x hakkimizin olmasi gerekir. fakat c dizinine w hakkimizin olmasi yeterlidir.Bir dizine read hakkinin olmasi demek o dizinin dizin listesinin goruntulenebilmesi demekdir. Teknik olarak bu kontrol opendir fonksiyonu tarafindan yapilmaktadir. Yine /a/b/c/ dizininin listesini almak istediginizde a/b/c ye x hakkimizin olmasi gerekmektedir. Fakat yalnizca c dizinine read hakki olmasi yeterlidir. Ilginc bir nokta su olabilir. Asagidaki open fonksiyonunda tum dizinlere x hakkinin oldugunu dusunelim. Dosyaninda gercekten orada var oldugunu kabul edelim. Dosyanin bulundugu dizine okuma hakkimiz olmadigi halde eger dosyaya okuma hakkimiz var ise bu islem basarilidir.

```c
fd = open("/a/b/c/x.dat", O_RDONLY)
```