---
title: Linux System Programming - Part 2
author: Cihat Yildiz
date: 2014-10-13 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Dosya Sistemine İlişkin Yardımcı POSIX Fonksiyonları
----------------------------------------------------

### chmod ve fchmod fonksiyonları

```c
#include <sys/stat.h>
int chmod(const char *path, mode_t mode);
int fchmod(int fd, mode_t mode);
```

Yaratılmış bir dosyanın erişim hakları open fonksiyonunda ilk kez belirlenir. Ancak bu fonksiyonlarla daha sonra değiştirilebilir. chmod fonksiyonu yol ifadesinden hareketle fchmod fonksiyonu dosya betimleyicisinden hareketle modu değiştirir. Bir prosesin bir dosyanın erişim haklarını değiştirebilmesi için ya root olması ya da prosesin etkin userid’sinin dosyanın sahibi ile ayni olması gerekir.

root hakkı, ya hep ya hiç biçiminde bir haktır. Yani root proses her şeyi yapabilir. Diğerleri sadece kendilerine yönelik şeyleri yapabilir. Bu nedenle bazı sistemlerde proses root olmadığı halde bazı işlemleri yapabilecek durum oluşturulmuştur. Prosesin bu yetkilendirme bilgisi ilgili sistemlerde proses kontrol bloğunda saklanır. Fakat her sistem bunu desteklememektedir.

Ayrıca komut satırında chmod isimli bir komutta vardır.

```c
/*--------------------------------------------------------------------------------------
 chmod örneği
-------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 int arights;
 int i, k;
 int aflags[] = {S_IXOTH, S_IWOTH, S_IROTH, S_IXGRP, S_IWGRP,
                     S_IRGRP, S_IXUSR, S_IWUSR, S_IRUSR};
 int mflag;

 if (argc < 3) {
  fprintf(stderr, "wrong number of arguments!..\n");
  fprintf(stderr, "usage: mychmod <access rights> <file>\n");
  exit(EXIT_FAILURE);
 }

 sscanf(argv[1], "%o", &arights);

 for (i = 2; i < argc; ++i) {
  mflag = 0;
  for (k = 0; k < 9; ++k)
   if (arights & aflags[k])
    mflag |= aflags[k];
  if (chmod(argv[i], mflag) < 0)
   exitsys("chmod");
 }

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

### chown ve fchown Fonksiyonu

```c
#include <unistd.h>
int chown(const char *path, uid_t owner, gid_t group);
int fchown(int fd, uid_t owner, gid_t group);
int lchown(const char *path, uid_t owner, gid_t group);
```

Chown fonksiyonu bir dosyanin sahiplik bilgilerini degistirir. Fonksiyonun prototipi yukaridaki gibidir. Fonksiyonunlarin birinci parametresi ilfili dosyanin yol ifadesi yada dosya betimleyicisidir. Ikinci parametresi dosyanin yeni sahibinin id’sini, ucuncu parametre de dosyanin yeni grubunun id’sini alir. Ancak root processi bis dosyanin sahiplik bilgisini degistirebilir. Dosyanin sahibinin sahiplik bilgisini yada grup bilgisini degistirebilmesi bazi unix turevi sistemlede mumkundur. Bazilarinda ise degildir. POSIX bunu isletim sisteminin istegine birakmistir. Linux’da default durumda dosyanin sahibi sahipligini baska birisine devredemez. Fakat genel olarak dosyanin sahibi dosyanin grubunu degistirmektedir. Ancak dosyanin sahibi dosyanin grubunu POSIX standartlarina gore herhangi bir grup olarak degistiremez. Kendi etkin grupid’si olarak yada ek gruplarindan biri olarak degistirebilir.

POSIX Standartlarinda degisik baslik dosyalarinda xxx\_t biciminde typedef edilmis bazi tur isimleri vardir. BU turlerin gercekte hangi tur olarak typedef edilecegibazi kosullar altinda isletim sistemini yazanlara birakilmistir. Bunlarin hepsi ayrica bir grup olarak /sys/types.h dosyasi icinde tanimlanmistir. Tipik xxx\_t turleri sunlardir: -> mode\_t, nlink\_t, uid\_t, gid\_t, id\_t bir tamsayi olarak typedef edilmek zorundadir. -> blksize\_t, pid\_t, ssize\_t, blkcnt\_t ve off\_t isaretli tamsayi olacak bicimde typedef edilmek zorundadir. -> size\_t isaretsiz bir tamsayi turu olarak typedef edilmek zorundadir. -> time\_t ve clock\_t tam sayi yada gercek sayio turunden typedef edilmek zorundadir.

### stat ve fstat fonksiyonlari

Fonksiyonun prototipi su sekildedir.

```c
#include <sys/stat.h>
int stat(const char *path, struct stat *buf);
int fstat(int fd, struct stat *buf);
```

Fonksiyonlarin birinci parametreleri bilgisi elde edilecek olan dosyani yol ifadesini yada betimleyicisini almaktadir. ikinci parametre sys/types.h dosyasinda bildirilmis olan stat isimli bir yapi turunden nesnenin adresini alir. Fonksiyon basari durumunda 0 basarisizlik durumunda -1 degerine geri doner.

Stat yapisinin icerisinde su bilgiler vardir.

*   Dosyanin icinde bulundugu aygitin aygit numarasi.
*   Dosyanin inode numarasi
*   Dosyanin erisim bilgileri
*   Dosyanin userid ve groupid bilgileri
*   Dosyanin uzunlugu
*   Dosyani son erisim, son degistirilme, son statu degisimine iliskin tarih ve zaman bilgisi
*   Kopyalama gibi islemlerdeki etkin tampon buyuklugu
*   Bu dosya icin kac disk blogu tahsis edildigi

Bir dosyanin kac bloktan olustugu bilgisi belirtilirken bir blogun kac byte uzunlugunda oldugu sistemden sisteme degisebilmektedir. Block kavrami Linux sistemlerde biraz lastik hale getirilmistir. Stat fonksiyonunda ise block 512 byei temsil eder,. Halbulki baska yarlerde de bloack terimi kullanilmaktadir ve baska uzunlugu gostermektedir. Sonuc olarak linux sistemiinde block terinide karsilasildiginda, o baglamda blogun kac byte dan olustugu bilgisini de edinmek gerekmektedir.

```c
/*-----------------------------------------------------------------------------------
 stat fonksiyonu
------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>

void exitsys(const char *msg);

int main(int argc, char *argv[])
{
 struct stat finfo;
 struct passwd *pwd;
 struct group *grp;
 struct tm *ftime;

 if (argc != 2) {
  fprintf(stderr, "cannot get stat info\n");
  exit(EXIT_FAILURE);
 }

 if (stat(argv[1], &finfo) < 0)
  exitsys("stat");

 if ((pwd = getpwuid(finfo.st_uid)) == NULL)
  exitsys("getpwuid");
 if ((grp = getgrgid(finfo.st_gid)) == NULL)
  exitsys("getgrgid");

 printf("%s\n", argv[1]);
 printf("User: %s(%lu)\n", pwd->pw_name, (unsigned long) finfo.st_uid);
 printf("Group: %s(%lu)\n", grp->gr_name, (unsigned long) finfo.st_gid);
 printf("Length: %lu\n", (unsigned long) finfo.st_size);
  
 ftime = localtime(&finfo.st_atime);
 printf("Access time: %02d/%02d/%04d %02d:%02d:%02d\n", ftime->tm_mday,
         ftime->tm_mon + 1, ftime->tm_year + 1900,ftime->tm_hour,
         ftime->tm_min, ftime->tm_sec);

 ftime = localtime(&finfo.st_mtime);
 printf("Modification time: %02d/%02d/%04d %02d:%02d:%02d\n", ftime->tm_mday,
         ftime->tm_mon + 1, ftime->tm_year + 1900,
         ftime->tm_hour, ftime->tm_min, ftime->tm_sec);

 ftime = localtime(&finfo.st_ctime);
 printf("Status time: %02d/%02d/%04d %02d:%02d:%02d\n", ftime->tm_mday,
         ftime->tm_mon + 1, ftime->tm_year + 1900,
         ftime->tm_hour, ftime->tm_min, ftime->tm_sec);

 return 0;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

/etc/passwd ve /etc/group dosyalarinin formatlari sistemden sisteme farkli olacilir/ Bilindigi gibi sistemler icsel olarak hep sayilarla calisirlar. Ornegin stat fonksiyonundan elde etmis oldugumuz userid ve groupid degerleri sayisal degerlerdir. Bunlari ancak biz /etc/passwd ve /etc/group dosyalarina bakarak isme donusturebiliriz. Iste bu isi yapan birkac posix fonksiyonu bulundurulmustur. getpwuid ve getgrgid fonksiyonlari parametre olarak bizden userid ve groupid degerini alir. ve bize passwd ve group isimli yapi adresi ile geri doner. Bu yapilar, /tec/passwd ve /etc/group dosyalarindaki satirlari temsil etmektedir. tipik olarak bu fonksiyonlar sayisal userid ve gruopid degerlerini user ve group isimlerine donusturmek icin kullanilir. Bu islemin tersini yapan yani isimlerden sayi elde edilmesini saglayan getpwnam ve getgrnam fonksiyonlari vardi

Geri donus degeri pointer olan fonksiyonlarda hata durrumunda geri donus -1 degil NULL pointerdir. Fonksiyon geri donusunu kontrol etmek icin NULL olup olmadigina bakmamiz omenlidir.

Stat fonksiyonu ile verilen tarihler bize 1.1.1970 tarihinden gecen saniye sayisi olarak verilmektedir. Stat yapisinin icerisinde erisim haklari st\_mode icerisine bit bit kodlanmistir. Buradan dosyanin turunu almak icin s\_isxxx biciminde makrolar bulundurulmustur. ayrica ilgili hakkin olup olmadigini anlamak icin daha once gorulmus olan S\_IXXXX sembolik sabitleri ile bit end islem olusturmak gerekir.

```c
/*------------------------------------------------------------------------------------
 dosya bilgilerinin ls -l tarzýnda elde edilmesi
-------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>

void exitsys(const char *msg);
char *getls(const char *path, const struct stat *finfo);

int main(int argc, char *argv[])
{
 struct stat finfo;

 if (argc != 2) {
  fprintf(stderr, "cannot get stat info\n");
  exit(EXIT_FAILURE);
 }

 if (stat(argv[1], &finfo) < 0)
  exitsys("stat");

 puts(getls(argv[1], &finfo));

 return 0;
}

char *getls(const char *path, const struct stat *finfo)
{
 char static buf[4096];
 int index;
 int i;
 int aflags[] = {S_IRUSR, S_IWUSR, S_IXUSR, S_IRGRP, S_IWGRP, S_IXGRP,
                     S_IROTH, S_IWOTH, S_IXOTH};
 char *rights = "rwx";
 struct passwd *pwd;
 struct group *grp;
 char *months[] = {"Oca", "Þub", "Mar", "Nis", "May", "Haz", "Tem", "Aðu", "Eyl", "Eki",
                     "Kas", "Ara"};
 struct tm *ftime;

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

 index += sprintf(&buf[index], "%lu", (unsigned long) finfo->st_nlink);
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

 index += sprintf(&buf[index], "%ld", (long) finfo->st_size);
 buf[index++] = ' ';

 ftime = localtime(&finfo->st_mtime);
 index += sprintf(&buf[index], "%s %d %02d:%02d %s", months[ftime->tm_mon],
             ftime->tm_mday,ftime->tm_hour, ftime->tm_min, path);

 buf[index] = '\0';

 return buf;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Dizin icindeki dosyalarin ele gecirilmesi
Bir dizin icerisindeki dosyalarin elde edilmesi su sekilde yapilir. 
Dizin opendir fonksiyonu ile acilir. Fonksiyon basari durumunda DIR isimli bir yapi turunden handle gorevi yapa bir adres verir.basarisizlik durumunde NULL adres verir.

```c
#include <dirent.h>
DIR *opendir(const char *name);
DIR *fdopendir(int fd);
```

Readdir isimli fonksiyon her cagirildiginda bize siradaki dosyanin isminin ve inode numarasinin bulundugu dirent isimli bir yapinn adresini verir. Dizinin sonuna gelindiginde fonksiyon NULL adres verir.

```c
#include <dirent.h>
struct dirent *readdir(DIR *dirp);
```

Nihayet acilmis olan dizin closedir fonksiyonu ile kapatilir.

```c
#include <dirent.h>
int closedir(DIR *dirp);
```

bir onceki konuda yapilan ls komutu ornegini dizindeki dosyalar icin yapilandiralim

```c
/*---------------------------------------------------------------------------------
 Dizin içerisindeki dosyalarýn elde edilmesi
----------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>
#include <dirent.h>

void exitsys(const char *msg);
char *getls(const char *path);

int main(int argc, char *argv[])
{
 struct stat finfo;
 DIR *dir;
 struct dirent *dire;
 char path[1024];

 if (argc != 2) {
  fprintf(stderr, "wrong number of arguments\n");
  exit(EXIT_FAILURE);
 }

 if ((dir = opendir(argv[1])) == NULL)
  exitsys("opendir");

 while ((dire = readdir(dir)) != NULL) {
  sprintf(path, "%s/%s", argv[1], dire->d_name);
  printf("%s\n", getls(path));
 }
  
 closedir(dir);

 return 0;
}

char *getls(const char *path)
{
 char static buf[4096];
 struct stat finfo;
 int index;
 int i;
 int aflags[] = {S_IRUSR, S_IWUSR, S_IXUSR, S_IRGRP, S_IWGRP,
                     S_IXGRP, S_IROTH, S_IWOTH, S_IXOTH};
 char *rights = "rwx";
 struct passwd *pwd;
 struct group *grp;
 char *months[] = {"Oca", "Þub", "Mar", "Nis", "May", "Haz",
                     "Tem", "Aðu", "Eyl", "Eki", "Kas", "Ara"};
 struct tm *ftime;
 char *fname;

 if (stat(path, &finfo) < 0)
  return NULL;
  
 if ((fname = strrchr(path, '/')) == NULL)
  return NULL;

 index = 0;
 if (S_ISREG(finfo.st_mode))
  buf[index] = '-';
 else if (S_ISDIR(finfo.st_mode))
  buf[index] = 'd';
 else if (S_ISCHR(finfo.st_mode))
  buf[index] = 'c';
 else if (S_ISBLK(finfo.st_mode))
  buf[index] = 'b';
 else if (S_ISFIFO(finfo.st_mode))
  buf[index] = 'p';
 else if (S_ISLNK(finfo.st_mode))
  buf[index] = 'l';
 else if (S_ISSOCK(finfo.st_mode))
  buf[index] = 's';

 ++index;

 for (i = 0; i < 9; ++i)
  buf[index++] = (finfo.st_mode & aflags[i]) ? rights[i % 3] : '-';
 buf[index++] = ' ';

 index += sprintf(&buf[index], "%lu", (unsigned long) finfo.st_nlink);
 buf[index++] = ' ';

 if ((pwd = getpwuid(finfo.st_uid)) == NULL)
  index += sprintf(&buf[index], "%lu", (unsigned long) finfo.st_uid);
 else
  index += sprintf(&buf[index], "%s", pwd->pw_name);
 buf[index++] = ' ';

 if ((grp = getgrgid(finfo.st_gid)) == NULL)
  index += sprintf(&buf[index], "%lu", (unsigned long) finfo.st_gid);
 else
  index += sprintf(&buf[index], "%s", grp->gr_name);
 buf[index++] = ' ';

 index += sprintf(&buf[index], "%ld", (long) finfo.st_size);
 buf[index++] = ' ';

 ftime = localtime(&finfo.st_mtime);
 index += sprintf(&buf[index], "%s %d %02d:%02d %s", months[ftime->tm_mon],
                     ftime->tm_mday,
      ftime->tm_hour, ftime->tm_min, fname + 1);

 buf[index] = '\0';

 return buf;
}

void exitsys(const char *msg)
{
 perror(msg);
 exit(EXIT_FAILURE);
}
```

Recursive olarak bir dizin icindeki bilgilerin elde edilmesi

Dizin agacini dolasabilmek icin ozyinelemeli (recursive) bir dolasim gerekmektedir. Tipik islem su sekilde yapilir.Kok dizinden dosyalar bulunarak ilerlenir. Bulunan dosyanin normal bir dosya mi yoksa bir dizin dosyasi mi olduguna bakilir. Eger Bir dosya dizin dosyasi ise chdir fonksiyonu ile prosesin calisma dizini degistirilip fonksiyonun kendisini cagirmasi saglanir. Dizin bittiginde yine chdir fonksiyonu ile ust dizine gecilir. Her alt dizin icerisinde nokta (.) ve nokta nokta (..) isimli iki dizin otomatik olarak olusturulur. bunlarin dikkate alinmamasi gerekir.

C Programlama icerisinde yer alan recursive algoritmalar konusuna goz alilmasi gerekmektedir. sdasd

```c
/*-------------------------------------------------------------------------------------
                Dizin agacinin dolasilmasi
-------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>

void exitsys(const char *msg);
void walktree(const char *path);

int main(int argc, char *argv[])
{
                if (argc != 2) {
                               fprintf(stderr, "wrong number of arguments\n");
                               exit(EXIT_FAILURE);
                }
               
                walktree(argv[1]);
               
                return 0;
}

void walktree(const char *dirpath)
{
                struct stat finfo;
                DIR *dir;
                struct dirent *dire;
                char filepath[1024];
                              
                if ((dir = opendir(dirpath)) == NULL) {
                               perror("opendir");
                               return;
                }
               
                while ((dire = readdir(dir)) != NULL) {
                               if (!strcmp(dire->d_name, ".") || !strcmp(dire->d_name, ".."))
                                               continue;
                               sprintf(filepath, "%s/%s", dirpath, dire->d_name);
                               if (lstat(filepath, &finfo) < 0) {
                                               perror("stat");
                                               continue;
                               }
                               printf("%s\n", filepath);
                              
                               if (S_ISDIR(finfo.st_mode))
                                               walktree(filepath);
                }
                                              
                closedir(dir);
}

void exitsys(const char *msg)
{
                perror(msg);
                exit(EXIT_FAILURE);
}
```