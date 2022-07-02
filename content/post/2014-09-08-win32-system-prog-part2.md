---
title: Win32 System Programming - Part 2
author: Cihat Yildiz
date: 2014-09-08 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Windows API Programlamaya İlişkin Temel Bilgiler
------------------------------------------------

Windows API programlama yaparken kaynak kodun içerisine windows.h dosyasi include edilmelidir. Bu dosya içerisinde içerisinde gereken pekçok bildirim vardir. Sistem programlamada yazim stili olarak macar notasyonu (hungarian notation) kullanilir. Macar notasyonuna göre;

*   Fonksiyonlar pascal tarzı harflendirilir. Yani her sözcüğün ilk harfi büyüktür. (her sozcugun ilk harfi buyuktur. Fiiller ince kullanilir.)
*   o GetWindowLong(), CreateProcess()
*   Degiskenler genellikle onun turunu belirten bir önek ile başlatılır. Degişkenler deve notasyonu ile isimlendirilir. (camel notation)
*   BYTE, WORD ve DWORD typedef isimleri sırasiyla 1, 2 ve 4 byte lik işaretsiz tam sayı türlerini temsil eder.
*   Typedef isimlerindeki P öneki ve LP öneki gösterici anlamına gelir. (Windows 3.x sistemlerinde farkli anlama gelmektedir.)
*   Word kavramı donanım ve yazılımda farklıdırlar. Yazılımda 2 byte, ama donanimda register uzunlugu olarak adlandirilirlar.
*   Gösterdigi yer const olan const göstericilerde PC veya LPC öneki kullanılır.
*   Yazi türleri (char türden göstericiler) SZ yada LPSZ ile baslatilir.
*   PSTR, LPSTR, LPCSTR yazıyı gösteren gösterici anlamındadır.
*   BOOL türü başarı ve başarısızlığı anlatan bir türdür. INT olarak typedef edilmistir. ( 0 basarisiz, 0 disi basarisiz)
*   fonksiyon tanimlarinda in, ”in\_out”, ve “\_\_out” ifadeleri sirasiyla ver kullanayim, ver icini ben de doldurayim ve ver icicin doldurayim manasinda kullanilir. CreateProcess() fonksiyonunun msdn icerisindeki dokumani icerisinde gorulebilir.
*   kaanaslan.com makale id 49 incele

Not : foldoc.org Güzel bir web sitesi. Online sözlük.

### unicode\_kullanimi

*   www.unicode.org
*   java ve c# da char turu 2 byte tutar. C de ise 1 byte dir.
*   typedef unsigned short wchart;
*   32 bi windows sistemlerine gecildiginde unicode kullanimi da devreye girmistir. Butun yazi parametresi alan fonksiyonlardan aslinda 2 tane bulunmektedir. Sonu A ile birenler ASCII sonu W ile bitenler UNICODE anlamina gelmektedir.
*   Biz program yazarken genellikle A ve W olmayan isimleri kullaniriz bu isimler duruma gore A ve W lu bicime donusturulurler.
*   IDE de bu ayar proje seceneklerinden yapilmaktadir ve default durum UNICODE bicimindedir.
*   CreateProcessA (ascii)
*   CreateProcessW (unicode)

C de ascii string “xxxx” biciminde, unicode string L”xxxxx” biciminde yazilir. Eger programimizi ascci ile unicode arasinda istedigimiz zaman cevirebilecegimiz bicimde yazmak istiyorsak. Butun iki tirnaklari TEXT macrosu ile girmeliyor.

```c
#ifdef UNICODE
#define TEXT() L##S
#else
#define TEXT(,) S
#endif
```

*   Ayrica Standat C fonksiyonlarinin ascii ve unicode versiyonlari vardir. Bunlar arasinda otomatik gecis yapmak icin ozel makrolar kullanilmaktadir. Bu makrolar tchar.h dosyasi icerisinde.
*   Aslinda standartlara gore printf fonksiyonunun ascii ismi printf unicode ismi wprintf dir. Windowsta “\_tprintf” dersek bu ide deki ayara gore wprintf veya printf kullanir

### HANDLE Kavramı

*   BIr veri yapisina erismekte kullanilan anahtar degerlere handle denir.
*   Handle genel olarak bir veri yapisina erismekte kullanilan tekil anahtar degerdir. Handle tipik olarak bir adres formunda bulunabuilir. Bir dizide index belirtiyor olabilir.
*   Handle kullanan kisi onun ne anlam ifade ettigini bilmek zorunda degildir.
*   Bir handle sisteminde tipik olarak handle sistemini yaratan bir fonksiyon bulunur. Bunlar tipik olarak CreateXxxxx veya OpenXxxx olarak adlandirilir
*   Handle sistemini kullanan fonksiyonlar vardir. bunlara biz handle degerini veririz ve giris yaptiririz. Nihayet handle sistemini yok eden fonksiyonalr vardir. Bunlar CloseXxx veya DestroyXxxx olarak adlandirilir.

### Bir Processin Yaratilmasi

*   windows sistemlerinde bir process yaratmak icin CreateProcess api fonksiyonu kullanilir. Bu dosyayi ram a yukler. Process kontrol blogunu olusturur.
*   Ayrica process yaratmak icin shellExecute isimli bir shell apisi de vardir. Fakat shellExecute base bir fonksiiyon degildir. Bu da createProcess fonksiyonunu cagirmaktadir.
*   shellExecute base bir fonksiyon degil. Dosya iliskilerini de ayrica inceliyor.
*   Kernel e en yakin process yaratma fonksiyonu createProcess fonksiyonudur.
*   Process yaratildigi zaman process yaninda bir de thread yaratilir. dwCreationFlags
*   CREATE\_NEW\_CONSOLE – console uygulamasinda yeni bir konsol yaratilmaz. Ancak bu parametre ile yaratilabilir.
*   process ceration class ve priorty class da belirtilebilir.

```c
BOOL WINAPI CreateProcess(
    _In_opt_ LPCTSTR lpApplicationName,
    _Inout_opt_ LPTSTR lpCommandLine,
    _In_opt_ LPSECURITY_ATTRIBUTES lpProcessAttributes,
    _In_opt_ LPSECURITY_ATTRIBUTES lpThreadAttributes,
    _In_ BOOL bInheritHandles,
    _In_ DWORD dwCreationFlags,
    _In_opt_ LPVOID lpEnvirUnordered List Itemonment,
    _In_opt_ LPCTSTR lpCurrentDirectory,
    _In_ LPSTARTUPINFO lpStartupInfo,
    _Out_ LPPROCESS_INFORMATION lpProcessInformation
);
/*------------------------------------------------------------------------
-
    CreateProcess örneği
-------------------------------------------------------------------------
*/

/* Sample.c */

#include <stdio.h>;
#include <stdlib.h>;
#include <Windows.H>;

int main(void)
{
  STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    char cmdLine[] = "Notepad.exe";

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, 
                     CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi)) {
        fprintf(stderr, "Cannot create process!\n);
        exit(EXIT_FAILURE);
    }

    printf("Press ENTER to exit");
    getchar();

    return 0;
}
```

*   Malesef createProcess fonksiyonunun ikinci parametresi fonksiyon tarafindan guncellenmektedir. Yani fonksiyonu buraya birseyler yazip sonra orjinal yaziyi yeniden yuklemektedir. Halbuki C de stringler guncellenemez. Eger edilmeye calisilirsa exception olusur.
*   butun cift tirnaklari TEXT makrosu ile vereceksin
*   unicode uyumlu fonksiyonleri kullanacaksin
*   Char yerine de TCHAR uyumlu olani kullanmakn gerekiyor
*   tchar.h icersiinde TEXT() makrosu yerine “\_T()” makrosu de kullanilarbilir. Tamamiyle ayni anlama gelmektedir.

```c
/*-----------------------------------------------------------------------
    CreateProcess örneği (Bir console programı diğerine
    çalıştırırsa default olarak aynı console ekranını kullanır.
    CREATE_NEW_CONSOLE çalıştırılan uygulama için yeni
    bir console ekranınınm yaratılcağı anlamına gelir)
-------------------------------------------------------------------------*/

/* Sample.c */

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

int main(void)
{
    STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    char cmdLine[] = "E:\\Dropbox\\Test\\Debug\\Test.exe ali veli selami";

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, 
                        CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi)) {
        fprintf(stderr, "Cannot create process!..\n");
        exit(EXIT_FAILURE);
    }

    printf("Press ENTER to exit");
    getchar();

    return 0;
}

/* Test.c */

#include <stdio.h>

int main(int argc, char *argv[])
{
    int i;

    for (i = 0; i < argc; ++i)
        printf("%s\n", argv[i]);

    printf("Press ENTER to exit\n");
    getchar();

    return 0;
}
```

### UNICODE / ASCII uyumlu kullanim

```c
/*--------------------------------------------------------------
    UNICODE / ASCII uyumlu kullanım
--------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>

int main(void)
{
    STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    TCHAR cmdLine[] = TEXT("Notepad.exe");

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, 
                            CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi)) {
        _ftprintf(stderr, TEXT("Cannot create process!..\n"));
        exit(EXIT_FAILURE);
    }

    _tprintf(TEXT("Press ENTER to exit"));
    getchar();

    return 0;
}
/*---------------------------------------------------------------------------
    UNICODE / ASCII uyumlu kullanım 
    (TEXT makrosu yerine _T makrosu da kullanılabilir. UYARI: TEXT
    makrosu için Windows.h yeterlidir, _T makrosu için tchar.h gerekir)
----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>

int main(void)
{
    STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    TCHAR cmdLine[] = _T("Notepad.exe");

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, 
                        CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi)) {
        _ftprintf(stderr, _T("Cannot create process!..\n"));
        exit(EXIT_FAILURE);
    }

    _tprintf(_T("Press ENTER to exit"));
    getchar();

    return 0;
}
```

### Shell Execute

```c
HINSTANCE ShellExecute(
  \_In\_opt\_  HWND hwnd,
  \_In\_opt\_  LPCTSTR lpOperation,
  \_In\_      LPCTSTR lpFile,
  \_In\_opt\_  LPCTSTR lpParameters,
  \_In\_opt\_  LPCTSTR lpDirectory,
  \_In\_      INT nShowCmd
);
```

ShellExecude ile open ile dosya acarken bu dosya ile iliskilendirilmis olan uygulama ile birlikte acar. doc dosyasi acilirsa word acar, png dosyasi ise goruntu editleme programi ile acar.

```c
/*---------------------------------------------------------------
    ShellExecute örneği
---------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>
#include <Shellapi.h>

int main(void)
{
    if ((DWORD) ShellExecute(NULL, TEXT("open"), 
                                TEXT("Notepad.exe"), NULL, NULL, SW_SHOW) < 32) {
        _ftprintf(stderr, TEXT("cannot execute!..\n"));
        exit(EXIT_FAILURE);
    }

    _tprintf(TEXT("Preass ENTER to exit"));
    getchar();

    return 0;
}
/*------------------------------------------------------------
    ShellExecute örneği
    (ShellExecute dosya ilişkilendirmesine bakar.
     Arka planda zaten CreateProcess fonksiyonunu çağırır)
-------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>
#include <Shellapi.h>

int main(void)
{
    if ((DWORD) ShellExecute(NULL, TEXT("open"), TEXT("Test.txt"), 
                                NULL, NULL, SW_SHOW) < 32) {
        _ftprintf(stderr, TEXT("cannot execute!..\n"));
        exit(EXIT_FAILURE);
    }

    _tprintf(TEXT("Preass ENTER to exit"));
    getchar();

    return 0;
}
```

Windows da API Fonksiyonlarinin Hata Kodlarinin Elde edilmesi

*   Bir api fonksiyonu basarisiz oldugunda onun neden basarisiz oldugunu getLastError fonksiyonu ile elde edebiliriz. Butun error kodlarin windows.h iceriosinde ERROR\_XXX sebolik sabitleri ile define edilmistir.
*   Error degerlerini yaziya donusturmak icin formatMessage fonksiyornu kullanilir.

```c
/*----------------------------------------------------------------------
    GetLastError ve FormatMessage fonksiyonları
    (ExitSys bu fonksiyonları çağırarak programı sonlandırır)
-----------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    TCHAR cmdLine[] = TEXT("xxxxx.exe");

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, 
                        CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi))
        ExitSys(TEXT("CreateProcess"), EXIT_FAILURE);

    _tprintf(_T("Press ENTER to exit"));
    getchar();

    return 0;
}

void ExitSys(LPCTSTR lpszMsg, int status)
{
    DWORD dwLastError = GetLastError();
    LPTSTR lpszErr;
    
    if (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, 
                        NULL, dwLastError,
                        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), 
                        (LPTSTR) &lpszErr, 0, NULL)) {
        _ftprintf(stderr, TEXT("%s: %s"), lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}
```

### Process Id ve hadle degerleri

*   process id uzerinden handle degerini elde edebilirsin.
*   Prcesslerin ID degerleri sistem genelinde tekdir.Biz ID degerini verip handle degerini alabiliriz. Process kontrol bloguna erismekte kullanilan deger hendle degeridir.Dolayisiyla API fonksiyonlari bizden handle degerini istemektedir.

### Processlerin Sonlanmasi

*   exit fonksiyonu ile process kendisini sonlandirir. exit standart bir C fonksiyonudur.
*   Process her zaman bir api ile sonlandirilir. Exit fonksiyonu exitProcess fonksiyonunu cagirir.
*   Bir process windowsda aslinda exitProcess api fonksiyonu ile sonlandirilir.
*   C nin statndart exit fonksiyonu aslinda bu api fonksiyonunu cagirir.`VOID WINAPI ExitProcess( _In_ UINT uExitCode );`
*   Aslinda bir C programi calismasina main fonksiyonundan baslamaz. Derleyici tarafindan koda yerlestirilmis olan bir yeden baslar ve main fonksiyonu burdan cagirilir. Main bitince akis bu baslangic koduna geri doner. Iste burada Exit uygulanmistir.

### Processlerin Exit Kodlari

*   Process sonlandiginde isletim sistemine bir exit kodu iletilir.
*   C de main fonksiyonunu geri donus degeri int olmak zorundadir. main fonksiyonunu geri donus degeri exit fonksiyonuna arguman yapilir.
*   Zombi proses incelenecek (windows da zombi process yok. )
*   Proceslerin exit codui process kontrol blogunda saklanir. Dolayisi ile process sonlanip hadle da kapatilis ise artik biz processin exit kodunu alamayiz.
*   Bir processin exit kodu GetExitCodeProcess api fonksiyonu ile alinir.

```
BOOL WINAPI GetExitCodeProcess(
\_In\_ HANDLE hProcess,
\_Out\_ LPDWORD lpExitCode
);
```


*   Calisan processlerin exit codlarini alamayiz. Almaya calisirsak getExitCodeProcess fonksiyonu 259 ozel degerine geri doner.

```c
/*---------------------------------------------------------------------------
    Proseslerin exit kodlarının elde edilmesi
-----------------------------------------------------------------------------*/

/* Sample.c */

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    TCHAR cmdLine[] = _T("E:\\Dropbox\\Test\\Debug\\Test.exe ali veli selami");
    DWORD dwExitCode;
    int result;

    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, 
                        CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi))
        ExitSys(TEXT("CreateProcess"), EXIT_FAILURE);

    _tprintf(TEXT("Press ENTER to continue..."));
    getchar();

    if (!GetExitCodeProcess(pi.hProcess, &dwExitCode))
        ExitSys(TEXT("GetExitCodeProcess"), EXIT_FAILURE);

    if (dwExitCode == STILL_ACTIVE) {
        _tprintf(TEXT("Process still running...\n"));
        exit(EXIT_FAILURE);
    }

    _tprintf(TEXT("Exit code: %lu\n"), dwExitCode);

    return 0;
}

void ExitSys(LPCTSTR lpszMsg, int status)
{
    DWORD dwLastError = GetLastError();
    LPTSTR lpszErr;
    
    if (FormatMessage(  FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, 
                        NULL, 
                        dwLastError,
                        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), 
                        (LPTSTR) &lpszErr, 
                        0, 
                        NULL)) 
    {
        _ftprintf(stderr, TEXT("%s: %s"), lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}

/* Test.c */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    int i;

    for (i = 0; i < argc; ++i)
        printf("%s\n", argv[i]);

    printf("Press ENTER to exit\n");
    getchar();

    exit(100);

    return 0;
}
```