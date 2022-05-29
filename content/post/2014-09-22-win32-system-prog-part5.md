---
title: Win32 System Programming - Part 5
author: Cihat Yildiz
date: 2014-09-29 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Islemcilerin Sayfalama Mekanizmasi
----------------------------------

*   Modern guclu masaustu islemcileri ve guclu mobil islemciler sayfalama (paging) mekanizmasina sahiptir.
*   Bu sistemde fiziksel RAM sayfa denilen bloklara ayrilmistir. Sayfa uzunluklari sistemden sisteme degisebilir.
*   INTEL de 4K (4096 Byte) tir. Bu durumda ornegin bellegin n numarali sayfasi n\*4096 inci byte den baslan ve 4096 byte surer
*   Islemci sayfa tablosu (page table) denilen bir tabloya bakarak calisir..
*   Program icerisinde kullandigimiz adresler gercek fiziksel ram de yer belirtmez. Bunlara sanal adres denir. Sayfa tablosu sanal adresleri fiziksel adreslere sayfa temelinde donusturmektedir.
*   Her processin ayri bir sayfa tablosu olmaktadir.
*   Ornek bir satfa tablosu soyle olabilir.

```asm
a = 10;
b = 20;

MOV [2629652], 10
MOV [0009652], 20

Sanal sayfa no  Fiziksel sayfa no

0  302
1  512
..  ..
..  ..
642  715
643  819
..  ..
```

Ornegin islemci programi isletirken decimal olarak 2629652 numarali adresle karsilasmis olsun. Once islemci bunun kacinci sanal sayfada oldugunu hesaplar. Sonra bu sanal sayfanin kacinci ofsetinde oldugunda hesaplar. b adresi 4096 ya bolersek (12 kere shift) sanal sayfa numarasini bolumunden elde edilen kalan ise ofset numarasini verir. Islemci bundan sonra 642 inci sanal sayfanin sayfa tablosunda hangi fiziksel sayfaya yonlendirildigini bulur ve offseti ona ekleyerek gercek fiziksel adresi elde eder. Goruldugu gibi programin sanal adres alani ardisil oldugu halde fiziksel alani ardisil olmak zorunda degildir. Multi processing calismada isletim sistemi her process icin ayri bir sayfa tablosu olusturur. Ve processler arasi gecis olustugunda islemcinin baktigi sayfa tablosu da degistirilir. Sayfa tablolarini isletim sistemi olusturur ve isletim sistemi bu tablolardaki fiziksel tablolari cakistirmazsa proseslerin bellek alanlari tamamen izole edilmis olur. Yani iki farkli processdeki iki sanal adres aslinda fiziksel ram de tamamen farkli yerler belirtebilir. Boyle bir sistemde bir process istese bile digerinin bellek alanina zaten erisemez.

```
swap in
swap out
page falt
```

Sayfalama mekanizma sayesinde de sanal bellek mekanizmasi da aktif hale getirilmektedir. Sanal bellek Programlarin yalnizca bir bolumunun fiziksel ram a yuklenerek disk ile ram arasinda yer degistirmeli olarak calistirmasina denir. Islemci bir mantiksal sayfaya bir fiziksel sayfa karsilik getirilmedigini gordugunde icsel bir kesme olusturur. Bu icsel kesmeye intel teminolojisinde page fault denilmektedir. INTEL Terminolojisinde fault denildiginde bir komutun bir problemden dolayi bir kesme olusturdugu, fakat bu kesmede cikilinca islemcinin probleme yol acan komutun kendisi ile devam ettigi dutumlar anlasilmaktadir. Sanal bellek kullanimi sirasinda programin kucuk bir bolumu fiziksel ram a yuklenir. Boylece sayfa tablosunda cok buyuk kisim icin bir fiziksel sayfa numarasi atanmamis olur. Program calisirken kod yada data bakimindan fiziksel karsiligi olmayan bir sanal adrese erisildiginde page fault olusur. Kontrolu isletim sistemi ele alir. Isletim sistemi hangi sanal sayfaya erisildiginden hareketle programin o kismini diskten ceker ve fiziksel sayfaya yukler. sonra sayfa tablosunu duzeltir ve calisma devam eder. Genellikle fiziksek ram tikabasa doldurulmus durumdasdir. bir programin 4K lik bir parcasini fiziksel ramdan bir sayfanin cikartilmasi gerekmektedir. Bu sirada isletim sistemini iyi bir karar vermesi gerekir. En az kullanilan sayfanin cikartilmasi kullanilmasi uygun olur. Eger fiziksel ram dan cikartilacak sayfa update edilmis ise, bu durumda bu sayfayi fiziksel ram dan cikartirken bu sayfayi yeniden diste bir yere yazmak gerekmektedir. Fakat update edilmemis ise yazmaya gerek yoktur. isletim sistemelri genel olarak mumkun oldugunca calistirilabilen dosyanin kendisini swap amacli da kullanmak ister(windows boyle yapar). Fakat update edilmis sayfalar icin ayri bir page dile duzenlemesinin yapilmasi gerekmektedir. Ornegin isletim sistemlerindeki paylasilan bellek alanlari (shared memory) sayfa tablolari ile gerceklestirilir. p1 ve p1 process leri bu bicimde haberlesecek olsunlar. sistem p1 procesinin 917 inci sayfasi ile p2 procesinin 645 inci sayfasini varsayalim ki ayni fiziksel adrese yonlendirebioir. Boylece p1 procesinin 917 sayfaya yazdilarini p2 procesi 645. sayfadan okuyabilir. Copy on write Sanal bellek kullanimindaki onemli kullanimlardan biri de copy in write ozelligidir. Ayni program birden fazla kez calistirildiginda yada bir dll farkli processler tarafindan kullanildiginda isletim sistemi gereksiz bir bicimde bunlari yeniden yeniden fiziksel ram a yuklemez. Baslangicta sayfalari 1 kez yukler. ve her processin sayfa tablosunda ayni sayfalari kullanir. Fakat bir process yazma yaptigi zamana digerlerinin bundan etkilenmemesi gerekir. Bunun icin tipik olarak sayfa ozellikleri read only olarak ayarlanir. boylece bir sayfaya yazma yapildiginda pagefault olusur. isletim sistemi de o sayfanin o an kopkasindan cikartarak paylasilmakta olan fiziksel sayfalari birbirinden ayirir. Boylece sayfalarin bastan degil gerektiginde kopyalari cikartilmis olur. http://www.kaanaslan.com/resource/article/display\_article.php?id=87 makalesi okunabilir. Ayni attribute sajip bir veya birden fazla ardisik sayfa topluluguna section denir.

Processlerin Haberlesme yontemleri (Inter Process Communication – IPC)
----------------------------------------------------------------------

Processler arasi haberlesme, bir processin diger bir procese bir bayt yigini gondermesi ve digerinin de bunu alarak kullanmasi anlamina gelmektedir.

```
Hoca sonra anlatacak.
```

Isletim sisteminin asagi seviyeli disk cache sistemi

*   Cache sistemleri bilgisayar sisteminin cesitli yerinde cesitli amacla kullanilailmektedir. En oneli cache sistemlerinden biri de disk cache sistemidir. Buna ozellikel Unix /Linux dunyasinda “Buffer Cache” de denilmektedir.
*   Isletim sistemi son erisilen disk bloklarini fiziksel ram da bir cache de tutarak. diske erisimi azaltmak ister.
*   Boylece bir dosya islemi yapilirken akis kernel moda gecer. Kernel fonksiyonlari okunacak veya yazilacak disk blogunun hangisi olduguna karar verir ve onu once cache de arar. Cache de bulamaz ise blok diskde aranir.
*   Standart C fonksiyonlarinin uyguladigi cache sistemi. Cache kelime hizlandirma amaci ile kullaniliyor. buffer kelime si de STandart C Fonksiyonlarinin kullandigi cache sistemi
*   Standart C fonksiyonlari aslinda Jva ve C# dosya siniflari da tamamen boyle davranir, < > bura da cache yerine buffered IO fonksiyonu denlmektedir. Boylece biz bir standar C fonksiyonu ile 1 Byte bile okuyacak olsak. Bu fonksiyon once isletim sisteminin okuma yapan api (windows da readFIle, linux da read) fonksiyonunu cagirir. Oradan bir grup bilgiyi cache e tasir ve diger olumanalari cache den karsilar.
*   Olusturulan cache read/write bir sistemdir. Yani bilgi yazildiginda cache a yazilir.
*   Bu cache calisma sirasinda yada en kotu olasilikla dosya kapatilirken. Flash edilmektedir. Fakat programci da istedigi zaman Fflush islemi yapabilir. Aygitlar ve Dosyalar
*   WIndows sistemlerinde ve UNIX /Linux sistemlerinde aygitlar da birer dosya gibi degerlendirilmelidir. Aygitlari aygit suruculer kontrol eder. Aygit suruculer de dosya fonksiyonlari ile acilip isleme sokulurlar.
*   Ornegin ekran aslinda bir aygittir ve bir aygit surucu ile erisilir. Biz ilgili aygit surucuyu acip ona writefile api fonksiyonu ile birseyler yapsak, yazdiklarimizi bu aygit surucu ekrana cikartir,
*   Bu sayede biz aygitlara birer dosyaymis gibi erisiriz ve onlari cok daha basit algilar ve kullaniriz.
*   Standart C fonksiyonun olusturdugu cache sistemi aygitlar icin de gecerlidir. Yani biz stdout aygitini kullanarak fprintf gibi bir fonksiyon ile ekrana birseyler yazmak istesek aslinda o once tanpona yazilacak. oradan aktarilacaktir.
*   Konu ile ilgili ayrintili bigiyi http://www.kaanaslan.com/resource/article/display\_article.php?page=2&id=83 adresinden okunmali Processlerin Hand Tablosu
*   Geri donus degeri HANDLE turunden olan kernel tarafindan organize edilen bir grup veri yapisina kernel nesnesi denilmektedir.
*   Processler , threadler, dosyalar, somaforlar, mutexler birer kernel nesnesidir.
*   Kernel Nesneleri CreateXxxx ile olusturulur CloseHandle fonksiyonu yok edilir.
*   Her Processin bir process handle taplosu vardir. Aslinda bir handle processin handle tablosunda bir index belirtir. Gercek nesnenin adresi bu indexdeki elemanda saklanir.
*   KErnel nesneleri processler arasinda paylasilabilir.
    1.  Processlerin handler degerleri processe ozgudur ve gorelidir. Yani biz birhandle degeri baska bir perocesse gonderdigimizde o handle degeri ile o process baska bir nesneye erisebilir. yada o handle degeri o process icin anlamli degildir.
    2.  Farkli processlerdeki farkli handle degerleri ayni nesneyi gosteriyor olabilir
    3.  Threadlerin handle tablosuyoktur processlerin va
    4.  cREATE PROCESS islemi sirasinda ust process in process handle tablosu tamamen alt processe aktarilir. Boylece ust process ile alt process ayni handle degerleri ile ayni kernel nesnelerine erisir.
    5.  Aslinda ust process create process fonksiyonunu uygularken alt process e handle aktarimini engelleyebilir. Bunun icin create process fonksiyonunun ana salter gorevindeki. bInheritHandles parametresi kullanilir. Ayrica her kernel nesnesinin yaratimi sirasinda o nesnenin alt process e aktarilip aktarilmayacagi da belirlenebilir.
    6.  Bu belirleme security attribute parametresi ile yapilir. (Bu parametre NULL gecilebilir o zaman aktarim yapilmaz.)
    7.  UNIX / Linux sistemlerinde tamamen benzer bir sistem kullanilmaktadir. Bu sistemlerde process handle tablosu yerine dosya betimleyici tablosu (file dicriptor table) verdir. Handle yerine dosya betimleyicisi (File discriptor table)

###########################
---------------------------

1.  UNIX / Linux sistemlerinde windows sistemlerindeki gibi bir kernel nesnesi kavrami yoktur. (Kernel nesnesi vardir ama process dosya betimleyici tablosu ile ilgili degildir)
2.  Unix / Linux sistemlerinde dosya betimleyici tablosunda yanlizca dosya betimleyicileri vardir. DuplucateHandle Fonksiyonu
    *   DuplucateHandle fonksiyonu bir process in process handle tablosundaki bir girisi, yani bir handle degerini parametre olarak alir. O handle degerinin kosterdigi kernel nesnesini gosteren o processde yada baska bir process de yeni bir handle olusturur.
    *   Fonksiyon bizden kaynak process i ve kaynak process deki kopyasi cikartilacak handle degerini parametre olarak alir. Hedef processi de parametre olarak alir. hedef processin process handle tablosunda bir giris olusturur. Olusturulan girisi de bize verir.
    *   O anda calismakta olan kendi processimizin handle degerii GetCurrentProcess api fonksiyonu ile alabiliriz.
        *   Bu fonksiyonun verdigi handle process handke tablosunda giris belirtmez ozel bir degerdir. Bu ozel degeri fonksiyonlara verdigimizde fonksiyonlar process handle tablosuna hic bakmazlar. zaten kernel o anda calismakta olan procesi not aldigi icin dogrudan ona giderler.
        *   Suphesiz duplicatehandle ile baska process icin hadle kopyalamasi yaptigimizda o process yeni handle degerini bilmedigi icin kullanamaz. Ayrica bu yeni handle degerini o process e iletmemiz gerekmektedir.

```c
/*------------------------------------------------------------------------------
    DuplicateHandle fonksiyonu ile bir file handle'ın kopyasının çıkarılması
-------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    HANDLE hFile, hFileDup;
    char buf[] = "This is a test";
    char buf2[1024];
    DWORD dw;


    if ((hFile = CreateFile("test.dat", GENERIC_READ|GENERIC_WRITE, 0,
                        NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)) == INVALID_HANDLE_VALUE)
        ExitSys("CreateFile", EXIT_FAILURE);

    if (!DuplicateHandle(GetCurrentProcess(), hFile, GetCurrentProcess(),
                        &hFileDup, 0, FALSE, DUPLICATE_SAME_ACCESS))
        ExitSys("DuplateHandle", EXIT_FAILURE);


    WriteFile(hFile, buf, sizeof(buf) - 1, &dw, NULL);
    SetFilePointer(hFile, 0, 0, 0);
    if (!ReadFile(hFileDup, buf2, 1024, &dw, NULL))
        ExitSys("ReadFile", EXIT_FAILURE);
    buf2[dw] = '\0';
    puts(buf2);

    CloseHandle(hFile);
    CloseHandle(hFileDup);

    return 0;
}

void ExitSys(LPCTSTR lpszMsg, int status)
{
    DWORD dwLastError = GetLastError();
    LPTSTR lpszErr;
    
    if (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, NULL, dwLastError,
                    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR) &lpszErr, 0, NULL)) {
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}
```

### Handle Yonlendirme islemleri

Handle yonlendirme islemi (IO Redirection – IO Yonlendirme) cok sik kullanilan islemlerdir. Bundan amac ozellikle bir alt processin kendini bir dosyaya yazdigini sanirken hedef yonlendirerek onun baska bir yere yazmasini saglamaktir. Ayni sey okuma durumu icin de soz konusudur. UNIX / Linux sistemlerinde her zaman klavyeye iliskin aygitin betimleyicisi 0, ekrana iliskin aygitin betimleyicisi 1 dir. Fakat windows sistemlerinde boyle olmak zorunda degildir. Bu handle degerleri getstdhandle api fonksiyonu ile alinir ve istenirse setstdhandle fonksiyonu ile set edilir. Ornegin Linux sistemlerinde tipik olarak calistiracagimiz bir programin stdout dosyasini bir dosyaya yonlendireceksek sunlar yapilir

*   Ust process for islemi yaparak alt processi yaratir.
*   Ust process dup2 fonksuyonunu uygulayarak, 1 numarali betimleyicinin acmis oldugu dosyayi gostermesini saylar.
*   exec islemi uygulayarak yeni programi calistirir. bu isleme IO Redirection denilmektedir. Artik yeni calistirilan programin ekrana yazdiklari ilgili dosyaya yazilmis olur. Cunku ekrana yazan butun fonksiyonlar 1 numarali betimleyiciyi kullanirlar. O da dosya yerine ekrana yazmis olur. Ayni islem windows da soyle yapilmaktadir.
*   Yonlendirme isleminin yapilacagi dosya createFile fonksiyonu ile yaratilir. Ancak bu dosyanin yaratilirken alt processe aktarilabilirligini saglamak gerekmektedir. (Security attribute = TRUE ve ….. yaparak) set handle information
*   CreateProcess fonksiyonu ile alt proces yaratilmadan once fonksiyonun startupinfo parametresi uygun bicimde doldurulmalidir. Buradaki startup info yapisi, acilmis olan dosyanin handle ini gosterecek bicimde ayarlanmalidir.
*   Nihayet createProcess fonksiyonu ile bu startupinfo struct i parametre olarak kullanilarak alt process yaratilir.

```c
/*----------------------------------------------------------------------------
    Windows'ta stdout dosyasının child process'te yönlendirilmesi örneği
------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    HANDLE hFile;
    STARTUPINFO si  = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    SECURITY_ATTRIBUTES sa = {sizeof(SECURITY_ATTRIBUTES), NULL, TRUE};
    char cmdLine[] = "E:\\Dropbox\\Tubitak-SGE-Ankara\\Test\\Debug\\Test.exe";

    if ((hFile = CreateFile("test.txt", GENERIC_WRITE, 0, &sa, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)) == NULL)
        ExitSys("CreateFile", EXIT_FAILURE);

    /* SetHandleInformation(hFile, HANDLE_FLAG_INHERIT, TRUE);  */

    si.dwFlags |= STARTF_USESTDHANDLES;
    si.hStdOutput = hFile;
    si.hStdError = hFile;
    si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi))
        ExitSys("CreateProcess", EXIT_FAILURE);

    WaitForSingleObject(pi.hProcess, INFINITE);

    return 0;
}

void ExitSys(LPCTSTR lpszMsg, int status)
{
    DWORD dwLastError = GetLastError();
    LPTSTR lpszErr;
    
    if (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, NULL, dwLastError,
                    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR) &lpszErr, 0, NULL)) {
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}
/*------------------------------------------------------------------------------
        Windows'ta stdout dosyasının child process'te yönlendirilmesi örneği 
        (komut satırı argümanlarıyla)
------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(int argc, char *argv[])
{
    HANDLE hFile;
    STARTUPINFO si  = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    SECURITY_ATTRIBUTES sa = {sizeof(SECURITY_ATTRIBUTES), NULL, TRUE};

    if (argc != 3) {
        fprintf(stderr, "Wrong number of arguments!..\n");
        exit(EXIT_FAILURE);
    }

    if ((hFile = CreateFile(argv[2], GENERIC_WRITE, 0, &sa, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL)) == NULL)
        ExitSys("CreateFile", EXIT_FAILURE);

    /* SetHandleInformation(hFile, HANDLE_FLAG_INHERIT, TRUE);  */

    si.dwFlags |= STARTF_USESTDHANDLES;
    si.hStdOutput = hFile;
    si.hStdError = hFile;
    si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);

    if (!CreateProcess(NULL, argv[1], NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi))
        ExitSys("CreateProcess", EXIT_FAILURE);

    WaitForSingleObject(pi.hProcess, INFINITE);

    return 0;
}

void ExitSys(LPCTSTR lpszMsg, int status)
{
    DWORD dwLastError = GetLastError();
    LPTSTR lpszErr;
    
    if (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, NULL, dwLastError,
                    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR) &lpszErr, 0, NULL)) {
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}
```

### STDERR Dosyasinin Anlami

Programlarin error mesajlari genellikle stderr disyasina yazdirilir. Pekcok sistemde isin basinda default olarak stderr dosyasi da tamamen stdout gibi ekrana yyonlendirilmistir. Fakat daha sonra programci stderrdosyasini baska bir dosyaya vs yonlendirebilir. bBoylece programin hata mesajlari ile normal mesajlarini programi calistiran kisi birbirinden ayirabilir. Hata mesajlarinin her zaman stderr dosyasina yazdirilmasi iyi bir tekniktir.