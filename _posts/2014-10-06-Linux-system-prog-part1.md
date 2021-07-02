---
title: Linux System Programming - Part 1
author: Cihat Yildiz
date: 2014-10-06 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

This notes has been created in “Linux System Programming” course that taken from “C and System programmers Accosiaion” in early 2014. Kaan Arslan was the lecturer in this course.

Bu yazida, daha once yayinlamis oldugum linux sistem programlama kursunda almis oldugum kurs notlarini tekrar bir araya getirdim. Bu kurs C ve System programcilari dernegi tarafindan 2014 yili nosan ayinda alinisti.

Unix/Linux Sistemlerinin Tarihsel Gelisimi
------------------------------------------

Unix 1969-1970 yıllarında AT&T Bell Lab tarafından DEC-PDP 7 makinaları için üretilmiştir. Unix projesinden önce AT&T MIT gibi üniversitelerle işbirliği yaparak MULTICS isimli bir işletim sistemi geliştirme projesinde çalışıyordu. Daha sonra grup çeşitli haklı gerekçelerle bu projeden çekilmiştir. Unix ismi B. Kernighan tarafından Multics sözcüğünden kelime oyunu yaparak uydurulmuştur. ilk Unix sistemi tamamen PDP makinalarının sembolik makine dilinde yazılmştı. Oyıllara kadar tüm işletim sistemleri zaten sembolik makine dilinde yazılıyordu. Unix işletim sistemi geliştirilirken Ken Thompson bir işletim sisteminin ciddi bir sistem olabilmesi için yüksek seviyeli bir derleyiciye sahip olması gerektiğini düşünüyordu.

Thompson, önceleri Fortran üzerinde durduysa da daha sonra BCPL gibi bir sistemin daha uygun olduğuna karar vermiştir. Bundan sonra Thompson BCPL’nin benzeri olan B dilinin tasarımında da çalşmştır. B bir yorumlayıcı sistemdi ve yavaş çalışıyordu. B programlama dili proje grubu tarafından yerel bir biçimde ve bazı sistem programlarında kullanılmştır. Proje grubu K.Thompson, D.Ritche, B.Kernighan gibi önemli kişilerden oluşuyordu. Grubun asıl amaçlarından biri Unix sistemini yüksek seviyeli bir dille yeniden yazmaktı. D.Ritche, B programlama dilini geliştirerek ilk kez 1971 yılında C programlama dilini tanımlamştir. 1973 yılında Unix işletim sistemi DEC-PDP 11 için çok büyük oranda C ile yeniden yazılmştır. Unix yüksek seviyeli bir programlama diliyle yazılmş olan ilk işletim sistemidir. Bu durum Unix işletim sisteminin farklı platfromlarda yazılmasını çok kolaylaştırmştır. AT&T Unix işletim sisteminin kaynak kodlarını pekçok araştırma grubu ve üniversitelere dağıtmştır. Bu durum C programlama dilinin tanınmasına yol açarken Unix sistemlerinin taşınabilirliğinin bozulması sonucunu da doğurmuştur. Çünkü kaynak kodları ele geçiren kurumlar orijinal Unix sistemlerinde değişiklikler yaparak farklı Unix sistemleri oluşturmuşlardır. Bu sistemlerin en önemlilerinden biri Berkeley Sistemleridir, bu sistemler BSD (Berkeley software distrubition) olarak bilinmektedir. BSD’nin FreeBSD, NetBSD ve OpenBSD biçiminde versiyonları vardır. AT&T kendi Unix sistemlerine de numara vermiştir. Örneğin, system III, systemV gibi…

Bugün Unix sistemlerinin en temel biçimi SVR4 (system 5 release 4 ) sürümüdür. Bundan sonra AT&T’nin çeşitli Unix sistemleri çıktıysa da, SVR4 bir standart anlatan özellik olmuştur. 80’li yıllarda pekçok özel firmada kendi Unix sistemlerini yazmaya başlamştır. Örneğin; Sun firmasının Solaris, HP firmasının HP-UX, SCO firmasının SCO\_UNIX, IBM firmasının AIX örnek olarak verilebilir.

AT&T 80 liyıllarının başında Unix sistemlerine telif uygulamaya başlamştır. Bu durumdan tedirgin olan üniversiteler ve araştırıcılar bedava Unix sistemleri geliştirme yönünde motive olmuşlardır. Bunun üzerine Hollandali profesor A. Tanenbaum işletim sistemi derslerinde kullanmak üzere MINIX isminde mini bir Unix sistemi yazmştır. MINIX ticari amaçla çeşitli kesimler tarafından kullanılmş olsa da ciddi bir yaygınlık kazanmamştir. Fakat kaynak kodları pekçok geliştiriciye ilham vermiştir. 1985 yılında Richard Stallman FSF (Free Software Foundation) isimli bir kurum altında serbest yazılım fikrini atmştır. Serbest yazılım bedava yazılımdan daha çok geliştirmede özgürlüğü belirtmektedir. Yani , programcı yazdığı programı kaynak koduyla birlikte verir, kaynak kodu sahiplenip değişti rilmesini engelleyemez. Kaynak kodu elde eden programcı orijinal yazardan alıntı yaptığını belirterek kodu değiştirebilir. Serbest yazılım bedava olabilirde olmayabilir de, fakat serbest yazılım parayla satılsa bile kaynak kodu verilmek zorundadır. Richard Stallman FSF kurumunu oluşturduktan sonra GNU isimli bir proje oluşturmuştur. GNU (GNU’ not UNIX) bir işletim sistemi ve yardımcı ek programlar oluşturmayı hedefleyen bir projedir. Bu proje hala devam etmektedir (www.fsf.org). GNU projesi kapsamında pek çok yararlı programlar yazılmştır (gcc derleyicisi ). Ancak maalesef işletim sisteminin kendisi yazılamamştır. 1990 yılında Linus Torvalds GNU lisansı altında MINIX ve UNIX sistemlerinden alıntılarla serbest bir Unix sistemi oluşturmuştur. Bugün Linux sistemlerindeki yazılımlar GNU lisanslı yazılımlardır. Yani, Linux sistemleri çekirdeği Linus Torvalds tarafından tasarlanmş olan yaralı programları GNU projesi kapsamıyla elde edilmiş olan bir sistemdir. Pekçok kişi bugün kullanılan bu sisteme Linux yerine GNU/Linux denmesinin daha uygun olacağını düşünmektedir. 1980’li yılların sonlarına doğru UNIX sistemleri standart hale getirilmeye çalışılmştır. Bunun için IEEE bünyesinde stadardizasyon ekibi kurulmuş ve POSIX standartları diye bilinen standartlar oluşturulmuştur. POSIX bir grup standartlardan oluşan bir standartlar topluluğudur. Bu grup içerisindeki herbir standart POSIX 1003.X biçiminde isimlendirilmiştir. Örneğin, 1003.1 POSIX uyumlu UNIX sistemlerinin C’de bulundurması gereken sistem fonksiyonlarına ayrılmştır. 1003.2 Shell programlarının kullandığı standart komutları tanımlamaktadır.

(Bu yazının tarihsel gelişim bölümü C ve sistem programcıları derneğinin Unix/Linux sistem programlama dökümanının giriş ksımından aynen kopyalanmıştır. Dökümana buradan erişim sağlayabilirsiniz.)

Giriş
-----

Sistem fonksiyonları user mod’da uygulamayı donanıma en yakın yapan fonksiyonlardır. Sistem çekirdeği içerisinde 2 türlü programlama yapilir. Kernel modülü yazmak Kernel yapısını degiştirerek yeniden kerneli derlemek Standat C fonksiyonlari, POSIX fonksiyonlari, Sistem fonksiyonları Standat C fonksiyonları bütün C derleyicilerinde olmasi gereken fonksiyonlardır ve bu fonksiyonlar en alt seviyeli fonksiyonlardir. POSIX fonksiyonlarıda butun POSIX sistemlerde var olan fonksiyonlardır ve bütün Unix/Linux sistemler icin kullanilabilir fonksiyonlardır. Sistem fonksiyonlari da biraz daha sisteme ozellestirilmis fonksiyonlardir. Yazılımda genel olarak kod tekrarı istenmez. Cünkü kod tekrarı hem fazla yer kaplar hemde bakımı zordur. Bu nedenle yazılım sistemleri katman katman oluşturulur. Yani yeni bir katman başka bir katmanın var olduğu fikriyle oradaki fonksiyonlari cağırarak yapılır. Yazılımsal olarak en asağı katman işletim sisteminin dış dünyaya sunduğu aşagi seviyeli sistem fonksiyonlaridır.

Örnek bir C kodu:

```c
void add(a, b)
{
    return a+b;
}

int main(void)
{
    int a=10, b=20, c;
    c = add(a,b);
    ...    
}
```

Bu C kodunun Assembler karşılığı;

```c
main proc near:
    push ebp
    mov ebp, esp
    sub ebp,12
    mov [ebp-4], 10
    mov [ebp-8], 20
    mov eax,[ebp-4]
    push ecx
    mov
```

Fakat sistem fonksiyonları isim ve parametrik yapı bakımından sistemden sisteme değisir. Hatta versiyondan versiyona bile değisir. Bunun yerine sistem fonksiyonalrını cağiran daha taşınabilir fonksiyon katmanı bulunmaktadır. Buna windows dünyasinda Windows API fonksiyonları, Unix/Linux dunyasinda POSIX fonksiyonları denilmektedir. POSIX fonksiyonları yalnızca linux sistemlerinde bulunmaktadir. Windows sistemlerde bulunmamaktadır. Standart C fonksiyonları ise tum C derleyicilerinde bulunmaktadır. Java gibi .NET gibi QT gibi pekcok platfrom ve kütüphane kendi dünyasinda daha yüksek seviyeli ve taşınabilir fonksiyonlar ve sınıflar bulundurmaktadırlar. Bazı POSIX fonksiyonları doğrudan bir sistem fonksiyonunu cağırmaktadir. Bazıları ise birden fazla sistem fonksiyonunu cagirir, bazıları ise hiçbir sistem fonksiyonunu cağırmayabilir. Bu durum Windows API fonksiyonları için de geçerlidir.

Linux sistemlerde trapgate mekaniması için aşağıdaki link bağlantıları faydalı olabilir.

*   [Intel x86 vs x64 interrupt call](http://stackoverflow.com/questions/15168822/intel-x86-vs-x64-interrupt-call)
*   [For signal in linux who calls int 0x80](http://stackoverflow.com/questions/9111039/for-signal-in-linux-who-calls-int-0x80)

İşlemcilerin Sunduğu Koruma Mekanizması
---------------------------------------

Koruma mekanizması bir processin zararli etkilerinden diğer procesleri ve isletim sistemini korumak icin olusturulmus bir mekanizmadır. Birinci elden işlemci tarafından uygulanır. Koruma mekanizmasının iki yönü vardır; bellek korumasi komut korumasi Bellek koruması; bir processin kendi sınırlarının dışına erişip erişmediğini denetler. Komut koruması ise sistemi çökertecek komutların kullanılmasını yasaklamaktadir. Bu koruma mekanizmaları işletim sisteminin kullanıcı moduna (user modda) geçerli korumalardır. Prosesler kernel ve user mod olmak üzere iki moddan birinde çalışır. Normal programlar user modda çalıştırılırlar. İşletim sisteminin kodlari ve aygıt sürücüler kernel modda çalışırlar. Kernel modda ise koruma mekanizmasi uygulanmaz. Hersey yapilabilmektedir.

Bir proses sürekli user modda kalmayabilir. Bir sistem fonksiyonu cağırıldığında proses user moddan gecici olarak kernel moda gecer. Sistem fonksiyonu kernel modda çalıştırılır. Sonra yeniden user moda geri dönülür.

Unix/Linux Sistemlerde Prosesler
--------------------------------

Çalışmakta olan programlara proses denir. Her prosesin kernel alanı içerisinde oluşturulmuş olan bir process kontrol bloğu vardır. Tipik olarak process kontrol bloğu’nun icinde şu bilgiler bulunur.

*   Processin yetkilendirme bilgileri
*   Processin ID’si
*   Processin bellek alanının nerede olduğu
*   Processin erişim hakları
*   Processin çalisma dizini
*   Processin açmis olduğu dosyalar
*   Processin istatistiksel bilgileri (örneğin process yaşamının ne kadarını kernel, ne kadarını user modda geçirmiştir)
*   Processin kesilme sırasındaki yazmaç (register) bilgileri
*   Processin Thread’leri hakkında bilgiler

* * *

Bir process oluşturulurken, user modda oluşturulan hafıza alanının yanısıra bir de kernel alanı icerisinde (kernel stack) de bir alan ayırılır. lxr.linux.no : linux kaynak kodlarını görebilecegimiz bir navigator. Versiyonlar arasında karşılaştırma da yapabilmektedir. Linux sistemlerde kullanılan sistem çağrılarını http://docs.cs.up.ac.za/programming/asm/derick\_tut/syscalls.html linkinden görebiliriz.

Linux sistemlerde proses kontrol bloğu task\_struct ile temsil edilmektdir. Proses kontrol bloğu dallı budaklı bir yapı biçiminde olabilir. Yani, bazı büyük bilgiler ayrı veri yapılarındadırlar. Proses konrtol bloğundan oralar (büyük veri alanları) göstericiler ile gösterilmektedir. Bir bilginin process kontrol blogunda olmasi demek ona proses kontrol blığu ile erişilebiliyor demekdir.

Not : proc dosya sisteminde procese ait bilgi silinir ise processi ps komutundan gizleyebiliriz Not : Windows ile ilgili dokümante edilmemiş bazı yapıları reactos.org adresinden görebilir ve inceleyebiliriz. Windows’da EPROCESS yapısı ile process kontrol blok tanımlanabilir. Bu yapı içerisinde PEB tanımlanmıştır.

Linux’da threadler’i processler gibi yapmislar. Kendi proses kontrol bloğu bulunmaktadır. Unix/Linux sistemlerinde her prosesin sistem genelinde tek olan bir ID değeri vardır. Prosesler arasıda altlık/üstlük (parent/child) ilişkisi söz konusudur. Her proses başka bir proses tarafından yaratılır. Örneğin UNIX/Linux sistemlerindeki komut satırı da aslında bir programdır. Yani bir processdir (/bin/bash). Sistem Boot Edildiğinde Proseslerin Durumu Nedir? Bootdan gelen akış ilk prosesi oluşturur. Buna swapper yada pager denilmektedir ve bu prosesin ID degeri 0’dir. Bu proses init denilen prosesi yaratır ve artık swapper birşey yapmadan arka planda bekler. Sonra bir dizi olaylar sırasında akış shell’e kadar gelir.

Kernel kendini yükledikten sonra try\_to\_run\_init\_process fonksiyonu ile baslangıç prosesini çalıştırır.İşletim sistemi aslında bir kod yığınının hazırda beklemesidir.

### Proses’in UserID ve GroupID Değerleri

Her prosesin proses kontrol bloğunda saklanan UserId ve GroupID degerleri vardır. UserId ve GroupId değerleri birer sayı olmasına karşın bunlara birer yazı da karşılık düşürülmüştür. Kernel işlemlerini bu isimlerin sayısal değerleri ile gerçeklestirmektedir. Ancak kullanıcı ve grup isimleri daha akılda kalıcıdır. Geleneksel olarak UserID’nin isimsel karşılığı /etc/passwd dosyasında GroupID’nin ise isimsel karşılığı /etc/group dosyasında tutulmalıdır. Aynı zamanda her prosesin effective UserID (etkin kullanici id’si) ve effective GrupID değeri de vardır. Normalde UserID ile etkin UserID, GrupID ile etkin GroupID aynı değerdedir. Fakat bazı seyrek durumlarda bunlar farklılaşabilmektedir. Fakat test işlemini her zaman etkin UserID ve etkin GrupID sokulur. Processin UserID, GrupID,etkin UserID,etkin GrupID değerleri proses yaratılırken üst prosesden aktarılır. Biz shell’den bir program çalıştırdığımızda shell’de bir process olduğuna gore çalıştırdığımız prosesin UserID ve GroupID değerleri shell’inki ile aynı olur.

Shell üzerinden “id” isimli komut o anda shell processinin etkin UserID ve etkin GroupID değerlerini bize verir. Biz xWindow sistemi veya terminal yolu ile sisteme giriş yaptığımızda ilk UserID ve GroupID nasıl oluşturulmaktadır? Işte bize, sisteme login olunurken bir kullanıcı ve parola sorulur. Dogrulama yapılır ve /etc/passwd’de gösterilen bir program bu user ve group id ile calistirilir.

Uygulamanin calisma sirasi su sekilde

1.  boot
2.  Kernel
3.  init
4.  tty
5.  login

0 numarali user id değerine sahip prosese süper proses yada root prosesi denilmektedir. Pekcok linux dağıtımında işin başında ismi root olan ve userId değeri 0 olan bir kullanıcı da /etc/passwd dosyasında yaratılmıştır. Aslında /etc/passwd dosyasının kendisi, init programı ve login programı kernel kodlarına dahil değildir. Fakat kernel kodları prosesin etkin kullanıcı ve grup id’lerine bakacak şekilde yazılmıştır. Biz /etc/passwd dosyasını silersek login programı calıştığında bu dosyanın ici boş olduğu icin giriş işlemi yapılamayacaktır. Prosesin UserID ve GroupId Değerlerinin Anlamı Processin UserId ve GrupId’si buyuk ölçüde dosya sistemlerine ilişkin teste sokulurlar. Unix/Linux sistemlerinde bir dosyanın açılması ve yaratılması işlemleri yalnızca open isimli POSIX fonksiyonu ile yapılmaktadır. Bu fonksiyon linuxda sys\_open fonksiyonunu cağırmaktadır.  
Glibc kütüphanesinin kaynak kodu içerisinde POSIX fonksiyonlarının kaynak kodları bulunmaktadır.

Unix/Linux sistemlerinde her dosyanın user/group id değerleri vardir. Bir dosyanın userId’si o dosyayi yaratan prosesin yani open fonksiyonunu cağıran processin etkin user id’si olarak alınır. Dosyanın grup id değeri ise sistemden sisteme değişebilecek biçimde iki seçenekten birisi olabilir.

*   Dosyayı yaratan prosesin etkin GrupID’si olarak
*   Dosyanın içinde yaratıldığı dizinin etkin GrorpID’si olarak

Linux’da default durum dosyanın group id’sinin onu yaratan processin etkin group idsi biçiminde alınmasıdır. Fakat bu durum çesitli koşullarda değiştirilebilmektedir.

Dosya erişim kontrolü şöyle yapılır.

*   Önce Open fonksiyonunu çağıran prosesin root olup olmadığına bakılır. root ise hiçbir kontrol yapılmaz. Erişim kabul edilir.
*   Değil ise ikinci erişim istenen processin etkin UserID’sinin dosyanın UserID’si ile ayni olup olmadığına bakılır. Eğer aynı ise erişim haklarından owner kısmı dikkate alınır. Değil ise 3. maddeye geçilir.
*   Erişmek isteyen prosesin etkin grupid’sinin dosyanın grupid’si ile aynı olup olmadığına bakılır. Aynı ise grup haklar dikkate alınır. Değil ise 4. maddeye geçilir.
*   Bu durumda dosyanın other bilgileri dikkate alınır.

Belirli bir yıldan sonra bir prosesin tek bir gruba ait olması yetersiz görülmüştür. Çünkü bir kişi birden fazla projede çalışabilmektedir. işte bu durumda ek grupid kavramı ortaya çıkmıştır. Bugünkü sistemde bir prosesin bir tane gerçek grupid’si ve etkin grupid’si vardır. Fakat birden fazla ek gruba da sahiptir.

Ek gruplar tamamen yukarıdaki 3. madde sırasında prosesin etkin grupid ile dosyanın grupid’si karşılaştırılırken etkin grupid ile ayni değerde karşılaştırılmaktadır. Kullanıcının ek gruplari /etc/group dosyasında belirtilmektedir.

POSIX Programlamada Kullanılan Önemli Bazı Bilgiler
---------------------------------------------------

POSIX fonksiyonları standart C fonksiyonları ile birlikte glibc/libc diye bilinen kütüphanenin içerisindedir ve GCC sistemi bu kütüphaneye bakmaktadır. Fakat fonksiyonların prototipleri çeşitli baslık dosyası içinde olabilir. Bunların ayrıca include edilmedi gerekmektedir.

POSIX Fonksiyonlarının çok büyük bolumu basari durumunda 0 başarısızlık durumunda -1 değerine geri dönerler. Programcı programın başarısızlığını test etmelidir. Tabi başarısızlığın da bir sebebi vardır. iste başarısızlığın nedeni int türden global errno isimli bir değişkene yerleştirilmiştir. Fonksiyon basarisiz olduğunda bu değişkenin içine bakarsak neden basarisiz olduğunu anlayabiliriz. Tüm başarısızlık değerleri errno.h dosyası içinde EXXX bicimde sembolik sabitlerle define edilmiştir. Programı isterse doğrudan bu sembolik sabitleri kullanabilir.

```c
if( open(.........) ){
    if(errno == ENOENT)
    {
         ......
    }
}
```

POSIX Standartlarında her posix fonksiyonu için başarısızlık durumunda her fonksiyon için errno değişkeninin alabileceği tüm değerler listelenmiştir.

Fonksiyon basarisiz olduğunda uygun mesajın verilmesi zahmetli olabilir. Bunun için perror ve strerror fonksiyonları bulunmaktadır. perror bizden bir yazı alır önce o yazıyı yazdırır. Sonra bir iki nokta üst üste karakteri yazdırır sonra da o anki errno değerine bakarak ona karsı gelen yazıyı yazdırır (stderr dosyasina). stderror fonksiyonu ise bizden bir hata kodunu alarak. Ona karşı gelen yazıyı verir. Bu durumda tipik kontrol su şekilde yapılabilir.

```c
if(open(...) == -1){
    perror("open");
    exit(EXIT_FAILURE);
}
```

Dosya İşlemleri Yapan Temel POSIX Fonksiyonları
-----------------------------------------------

#### Open Fonksiyonu

```c
#include <fcntl.h>
int open(const char *path, int oflags, ...);
```

Fonksiyonun birinci parametresi açılacak olan dosyanın yolunu alır. İkinci parametresi açış modunu belirtir. Açış modu fcntl.h içerisinde tanımlanmış olan O\_XXXX biçimindeki sabitlerin bit OR işlemi ile birleştirilmesi ile olur. Açış modu şunlardan yalnızca birini içermek zorundadır.

* O_RDONLY
* O_WRONLY
* O_RDWR
* O_CREAT dosya yok ise yarat, var ise bir şey yapma anlamına gelmektedir. 

O_TRUNC, O_RDONLY ya da O_RDWR ile birlikte kullanılmak zorundadır. Bu durumda dosya varsa sıfırlanır ve açılır. O_EXCL, O_CREAT ile birlikte kullanılmak zorundadır. Bu birlikte kullanım sadece yeni bir dosya yaratmak ve açmak için kullanılır. Dosya var ise open fonksiyonu başarısız olur. O_APPEND, Tüm yapılan yazma işlemlerinin dosyanın sonuna eklenmesi gerektiği anlamına gelmektedir. Bu durumda dosyanın herhangi bir yerinden okuma yapılabilir. Fakat herhangi bir yerine yazılamaz. Her yazılan sonuna eklenir. Open fonksiyonunda ikici parametrede O_CREAT kullanılmışsa bu durumda dosyanın yaratılması gibi bir durum oluşur. Artık programcının da dosyanın erişim haklarını üçüncü parametresi belirtmesi gerekir. Fonksiyonun 3. parametresinde belirtilecek erişim hakları sys/stat.h dosyasında belirtilen sembolik sabitlerin bit OR işlemi ile birleştirilmesi ile oluşturulur. Bu sembolik sabitlerin isimleri su şekilde oluşturulmuştur.

|   | R | USR |
| S_I | W | GRP | 
|   | X | OTH | 

Bu gösterimin kombinasyonları olacak şekilde olur. Örnegin;

*   S\_IRUSR -> User’a read hakki verir
*   S\_IXGRP -> Gruba calistirma haki verir

Örnek bir uygulama:
```c
/*-----------------------------------------------------------------------------------
 open fonksiyonunun kullanýmý
------------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(void)
{
 int fd;

 if ((fd = open("a.dat", O_RDWR|O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)) == -1) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 printf("success...\n");

 return 0;
}
```

Open fonksiyonu basari durumunda dosya betimleyicisi (file descriptor) denilen bir handle değerine geri döner. Bu handle değeri diğer fonksiyonlarda parametre olarak kullanılacaktır. Başarısızlık durumunda fonksiyon -1 değerine geri döner.

```c
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcnlt.h>
#include <sys/stat.h>

int main(void)
{
    int fd;
   
    if((fd = open("a.dat", O_RDWR)) == -1){
        fprintf(stderr, "Error ")       
    }
    return 0;
}
```

### Close Fonksiyonu

```c
#include <unistd.h>
int close(int fd);
```
Açılan her dosya bir biçim de kapatılmalıdır. Çünkü açım sırasında bir takım kaynaklar tahsis edilmiş olur. Kapatma sırasında bu kaynaklar geri bırakılır. Ancak dosyayı biz hiç kapatmasak bile process kapandığında bile dosya kesinlikle kapatılmalıdır. Fakat artık kullanılmayacak olan bir dosyanın kapatılması iyi bir tekniktir.

posix fonksiyonlarının bir çoğu unistd.h dosyası içerisinde tanımlanmıştır.

Fonksiyon parametre olarak open fonksiyonu ile dosyanın betimleyicisini alır. Başarılı ise 0 değil ise -1 ile geri dönüş yapar.

```c
/*-------------------------------------------------------------------------------------
 close fonksiyonu
-------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(void)
{
 int fd;

 if ((fd = open("a.dat", O_RDWR)) == -1) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 close(fd);

 return 0;
}
```

#### Dosya Göstericisi Kavramı

Dosyadaki her bir byte’in bir ofset numarası vardır. Dosya göstericisi imleç görevindedir. Bir ofset belirtir. Okuma ve yazma işleminin dosyanın hangi noktasından itibaren yapılacağını belirtir. Dosya açıldığında dosya göstericisi 0. ofsettedir. Okunan ya da yazılan miktar kadar otomatik ilerletilir. Dosya göstericisinin dosyanın son byte’indan sonraki byte’ı gösterme durumuna EOF durumu denir. Bu durumda okuma yapılamaz ancak yazma yapılabilir. Bu dosyaya ekleme anlamına gelir.

### Read ve Write Fonksiyonları

Read fonksiyonunun prototipi şu şekildedir

```c
#include <unistd.h>
ssize_t read(int fd, void *buf, size_t count);
```

Fonksiyonun birinci parametresi dosya betimleyicisini, ikinci parametresi okunan bilgilerin yerleştirileceği adresi, üçüncü parametresi ise okunacak byte sayısını belirtir. Read fonksiyonu ile olandan daha fazla okunmak istenebilir bu durumda fonksiyon okuyabildiği kadar byte’i okur okuyabildiği byte sayısına geri döner. read IO hatası dolaysı ile hiç okuma yapamaz ise -1 değerine EOF’dan dolayı hiçbir şey okuyamaz ise 0 değerine geri döner.

```c
/*-------------------------------------------------------------------------------------
 read fonksiyonunun kullanim ornegi
--------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(void)
{
 int fd;
 char buf[30 + 1];
 ssize_t n;

 if ((fd = open("sample.c", O_RDONLY)) == -1) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 if ((n = read(fd, buf, 30)) == -1) {
  perror("read");
  exit(EXIT_FAILURE);
 }

 buf[n] = '\0';
 puts(buf);

 close(fd);

 return 0;
}
```

Write fonksiyonunun prototipi şu şekildedir.

```c
#include <unistd.h>
ssize_t write(int fd, const void *buf, size_t count);
```

Fonksiyonun birinci parametresi dosya betimleyicisini, ikinci parametresi dosyaya yazılacak bilgilerin bulunduğu bellek adresini, üçüncü parametresi ise yazılacak byte miktarını belirtir. Fonksiyon başarılı ise yazılabilen byte sayısına basarisiz ise -1 değerine geri döner.

```c
/*-------------------------------------------------------------------------------------
 Dosya kopyalama
-------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFSIZE  8192

int main(int argc, char *argv[])
{
 int fds, fdd;
 char buf[BUFSIZE];
 ssize_t n;

 if (argc < 3) {
  fprintf(stderr, "wrong number of argument!..\n");
  fprintf(stderr, "usage: mycp <source fie> <dest file>\n");
  exit(EXIT_FAILURE);
 }

 if ((fds = open(argv[1], O_RDONLY)) < 0) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 if ((fdd = open(argv[2], O_WRONLY|O_CREAT|O_TRUNC,
                 S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)) < 0) {
  perror("open");
  exit(EXIT_FAILURE);
 }

 while ((n = read(fds, buf, BUFSIZE)) > 0)
  if (write(fdd, buf, n) < 0) {
   perror("write");
   exit(EXIT_FAILURE);
  }

 if (n < 0) {
  perror("read");
  exit(EXIT_FAILURE);
 }

 printf("1 file copied...\n");

 close(fds);
 close(fdd);

 return 0;
}
```


Bu örnekte okuma yaptigimiz konksiyonun yetkilerini alip hedef dosyaya eklemek icin stat fonksiyonunu kullanmak gerekiyor.

### lseek fonksiyonu

lseek fonksiyonunun prototipi su sekildedir

```c
#include <sys/types.h> // bu dosya include edilmek zorunda deiliz. Edilirse guzel olur.
#include <unistd.h>
off_t lseek(int fd, off_t offset, int whence);
```

Fonksiyonun birinci parametresi dosya betimleyicisi ikinci parametresi konumlandırma ofseti, üçüncü parametresi konumlandırma orijinini belirtir. Üçüncü parametre 3 değerden birini alabilir. SEEK\_SET (0) konumlandırmanın baştan itibaren yapılacağını belirtir. Bu durumda ofset parametresi >= 0 olmak zorundadır. SEEK\_CUR (1) konumlandırmanın dosyanın göstericisinin konumu nerede ise ona göre yapılacağı anlamına gelir. Bu durumda ikinci parametre pozitif, negatif ya da 0 olabilir. Nihayet SEEK\_END (2) konumlandırmanın EOF pozisyonuna göre yapılacağı anlamına gelmektedir. Bu durumda ikinci parametre =< 0 olmak zorundadır. Fonksiyon basari durumunda dosya göstericisinin yeni konumuna başarısızlık durumunda -1 değerine geri döner.

```c
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>

int main()
{
        int file=0;
        if((file=open("testfile.txt",O_RDONLY)) < -1)
                return 1;

        char buffer[19];
        if(read(file,buffer,19) != 19)  return 1;
        printf("%s\n",buffer);

        if(lseek(file,10,SEEK_SET) < 0) return 1;

        if(read(file,buffer,19) != 19)  return 1;
        printf("%s\n",buffer);

        return 0;
}
```

Bu örnekde exitsys fonksiyonunu kendi yazdığımız uygulamalarda direk kullanabiliriz. lseek komutu ile örneğin 5 bayt uzunluğunda bir dosya 15. bayttan itibaren veri yazabiliyoruz. Buna dosya deliği denilmektedir. (File hole) Bu konu ile ilgili http://www.kaanaslan.com/resource/article/display\_article.php?id=64 adresinden ayrıntılı bilgi elde edilebilir.

Dosya baytlardan oluşmaktadır. Fakat halk arasında içinde yalnızca yazı olan dosyalara text dosyalar, içinde yazının dışında başka şeyler de olabilen dosyalara binary dosyalar denilmektedir. Ayrıca test dosyalarda her bir karakterin hangi tablo ile kodlandığını bilmek gerekir. Buna karakter kodlaması denilmektedir.

| Unix / Linux | Windows |
| a\\nb | a\\r\\nb |
| LF | CR/LF |

Windows da test editörler aşağı satıra geçiş için CR ve LF karakterlerini (0D ve 0A) kullanır. Fakat Unix/Linux’ta yalnızca LF karakteri kullanılmaktadır. Bu da uyumsuzluğa yol açmaktadır. Bu karışıklığı çözmek için ve özellikle text okuma ve yazmaları kolaylaştırmak için C ve bazı başka dillerde dosyayı açarken text mode ve binari mode seklinde yapay seçenekler oluşturulmuştur. Bir dosyayı text modda açtığımız zaman şunlar olur;

*   Dosyadan 1 bayt okurken eğer dosya göstericisi Windows da CR karakterinin üzerinde ise CR ve LF karakterlerinin ikisini de okur fakat bize fonksiyon LF karakteri okumuş gibi geri döner.
*   Biz dosyaya text modda açılmışsa \\n karakterini yazdırdığımızda aslında Windows da aslında CR/LF biçiminde 2 byte yazılmaktadır. Biz dosyayı binary modda açtığımız zaman hangi karakteri yazdırırsak yalnızca onu yazar. Görüldüğü gibi Unix/Linux sistemlerinde dosyanın text mode veya binary modda açılması arastanda hiçbir fark yoktur.

Text Mode / Binary Mode Örnekleri

```c
/*-------------------------------------------------------------------------------------
                C'de text mode / binary mode'
-------------------------------------------------------------------------------------*/

#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
                FILE *f;

                if ((f = fopen("a.txt", "w")) == NULL) {
                               fprintf(stderr, "cannot open file!\n");
                               exit(EXIT_FAILURE);
                }

                fprintf(f, "a\nb");                           /* Windows'ta 4 byte UNIX/Linux'ta 3 byte */

                fclose(f);

                return 0;
}

/*-----------------------------------------------------------------------------------
                C'de text mode / binary mode'
------------------------------------------------------------------------------------*/

#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
                FILE *f;

                if ((f = fopen("a.txt", "wb")) == NULL) {
                               fprintf(stderr, "cannot open file!\n");
                               exit(EXIT_FAILURE);
                }

                fprintf(f, "a\nb");                           /* Windows'ta 3 byte UNIX/Linux'ta 3 byte */

                fclose(f);

                return 0;
}
```