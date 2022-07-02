---
title: Win32 System Programming - Part 4
author: Cihat Yildiz
date: 2014-09-22 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

Proseslerin komut satiri argumanlari (Command line arguments of a process)
--------------------------------------------------------------------------

*   Programlari komut satirindan calistirirken program isminin yanina yazilan yazilara komut satiri argumanlari denir. Windows sistemlerinde komut satiri argumanlari createProcess fonksiyonunda parametre olarak girilmektedir.
*   windows da komut satiri argumanlari createProcess in ikinci parametresi olarak girilir. ve tek bir yazi seklindedir.
*   Processin komut satiri argumanlari GetCommandLine api fonksiyonu ile elde dilebilir.
*   Derleyilerin baslangic kodlari bu api yi kullanarak komut satirini elde eder. Sonra onu boskuk karakterlerinden parse ederek ayirir ve main fonksiyonuna gecirir.
*   UNIX / Linux sistemlerin komut satiri argumanlari tek tek exec fonksiyonlarinda verilmektedir.
*   komut satiri argumanlari process kontrol blogunda saklanmaktadir.

### GNU Stili komut satiri argumanlari

Klasik GNU sisteminde komut satiri argumanalari 3 bicimde olabilir.

1.seceneksiz arguman 2.yalnizca secenek 3.secenekli arguman

*   secenek bir tire ve tek bir karakterden olusur. (orn, ls -l -a)
*   secenekler birlestirilebilir. (orn. ls -la)
*   Eger secenek birden fazla karakterden olusuyor ise secenek karakteri (–) ile belirtilir.(ornegin –login gibi )

Unix/ Lionux sistemlerinde komut satiri argumanlarini parse etmek icin getopt ve getopt\_long isimli fonksiyonlar vardir. [http://www.csystem.org/makaleler/programlar%C4%B1n-komut-sat%C4%B1r%C4%B1-arg%C3%BCmanlar%C4%B1](http://www.csystem.org/makaleler/programlar%C4%B1n-komut-sat%C4%B1r%C4%B1-arg%C3%BCmanlar%C4%B1) makalesini oku.

```c
/*----------------------------------------------------------
    Proseslerin komut satırı argümanları 
    (Parse işlemi düzeltilmiş versiyon)
------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <tchar.h>
#include <Windows.h>
#include <Psapi.h>

/* Symbolic Constants */

#define MAX_CMD_LINE                1024
#define MAX_CMD_PARAMS                32

/* Type Declarations */

typedef struct tagCMD {
    const char *name;
    void (*Proc)(void);
} CMD;

/* Function Prototypes */

void ExitSys(LPCTSTR lpszMsg, int status);
void PrintSysErr(void);
void Parse(void);
void DirProc(void);
void ClsProc(void);
void ChDirProc(void);
void GetEnvProc(void);
void SetEnvProc(void);
void RunProcess(void);
void TrimCmd(char *trimmed);
void ExitProc(void);

/* Global Data Definitions */

char g_cmd[MAX_CMD_LINE];
char *g_params[MAX_CMD_PARAMS];
int g_nparams;
CMD g_cmds[] = {
    {"dir", DirProc},
    {"cls", ClsProc},
    {"cd", ChDirProc},
    {"getenv", GetEnvProc},
    {"setenv", SetEnvProc},
    {"exit", ExitProc},
    {NULL, NULL},
};

/* Function Definitions */

int main(void)
{
    char cwd[1024];
    int i;

    for (;;) {
        if (GetCurrentDirectory(1024, cwd) == 0)
            ExitSys("GetCurrentDirectory", EXIT_FAILURE);
        printf("%s>", cwd);
        gets(g_cmd);
        Parse();
        if (g_nparams == 0)
            continue;
        for (i = 0; g_cmds[i].name != NULL; ++i)
            if (!strcmp(g_cmds[i].name, g_params[0])) {
                g_cmds[i].Proc();
                break;
            }
        if (g_cmds[i].name == NULL)
            RunProcess();

        if (!strcmp(g_cmd, "quit"))
            break;
    }
        
    return 0;
}

void Parse(void)
{
    char *str, *beg;
    str = g_cmd;
    
    for (g_nparams = 0;; ++g_nparams) {
        while (isspace(*str))
            ++str;
        if (*str == '\0')
            break;
        beg = str;
        while (!isspace(*str) && *str != '\0') {
            if (*str == '\"') {
                ++str;
                while (*str != '\"' && *str != '\0')
                    ++str;
                if (*str == '\"')
                    ++beg;
                if (*str == '\0')
                    break;
                *str = '\0';
            }
            ++str;
        }
        g_params[g_nparams] = beg;
        if (*str == '\0')
            break;
        *str++ = '\0';
    }

    ++g_nparams;
}

void DirProc(void)
{
    printf("dir\n");
}

void ClsProc(void)
{
    if (g_nparams > 1) {
        printf("too many arguments...\n\n");
        return;
    }
    system("cls");
}

void ChDirProc(void)
{
    char cwd[1024];

    if (g_nparams == 1) {
        if (GetCurrentDirectory(1024, cwd) == 0)
            ExitSys("GetCurrentDirectory", EXIT_FAILURE);
        printf("%s\n\n", cwd);
        return;
    }

    if (g_nparams > 2) {
        printf("too many arguments...\n\n");
        return;
    }

    if (!SetCurrentDirectory(g_params[1]))
        PrintSysErr();
}

void GetEnvProc(void)
{
    char buf[1024];
    char *envs;

    if (g_nparams == 1) {
        if ((envs = GetEnvironmentStrings()) == NULL)
            ExitSys("GetEnvironmentStrings", EXIT_FAILURE);

        while (*envs != '\0') {
            puts(envs);
            envs += strlen(envs) + 1;
        }
        printf("\n");
        return;
    }

    if (g_nparams > 2) {
        printf("too many arguments..\n\n");
        return;
    }

    if (!GetEnvironmentVariable(g_params[1], buf, 1024)) {
        PrintSysErr();
        return;
    }

    printf("%s\n\n", buf);
}

void SetEnvProc(void)
{
    if (g_nparams == 1) {
        printf("argument missing...\n\n");
        return;
    }

    if (g_nparams > 3) {
        printf("too many arguments..\n\n");
        return;
    }

    if (!SetEnvironmentVariable(g_params[1], g_nparams == 3 ? g_params[2] : NULL)) {
        PrintSysErr();
        return;
    }
}

void RunProcess(void)
{
    STARTUPINFO si = {sizeof(STARTUPINFO)};
    PROCESS_INFORMATION pi;
    char cmdLine[MAX_CMD_LINE];

    TrimCmd(cmdLine);
    printf(":%s:\n", cmdLine);
    if (!CreateProcess(NULL, cmdLine, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi)) {
        PrintSysErr();
        return;
    }

    CloseHandle(pi.hProcess);
    printf("\n");
}

void ExitProc(void)
{
    exit(EXIT_SUCCESS);
}

void TrimCmd(char *trimmed)
{
    char *str1 = g_cmd;
    char *str2 = g_cmd + strlen(g_cmd) - 1;

    while (isspace(*str1))
        ++str1;
    if (*str1 == '\0') {
        *trimmed = '\0';
        return;
    }
    
    while (isspace(*str2))
        --str2;

    do {
        *trimmed++ = *str1++;
    } while (str1 <= str2);
    *trimmed = '\0';
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

void PrintSysErr(void)
{
    DWORD dwLastError = GetLastError();
    LPTSTR lpszErr;
    
    if (FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, NULL, dwLastError,
                    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR) &lpszErr, 0, NULL)) {
        fprintf(stderr, "%s\n", lpszErr);
        LocalFree(lpszErr);
    }
}
```

UNIX /Linux Sistemlerinin Tarihsel Gelisimi
-------------------------------------------

Ken Thomson ile roportaj

*   Unix isletim sistemi 1969 1970 yillarindan AT&T bell labs da Ken thomson, Brian Kernigan ve Dennis Ricchi tarafondan dec makinalari icin yazilmistir.
*   Deniss R. bu gruptan bagimsiz olarak unix yaziminda kullanilan Ken Thaomson’in B programlama dilinden hareketle C yi gelistirmistir.
*   Unix 1973 yilinda yeniden C ile yazildi. Bundan sonra Unix in kaynak kodlari pekcok universite ve arastirma kurumlarina dagitildi. Onlar da C ogrenerek UNIX varyantlari olusturmaya basladilar.
*   1970 li yillarin ortalarinda berkeley deki kaliforniya universitesi Orjinal UNIX kodlarini degistirerek BSD sistemlerini cikartti.
*   Soket sistemi, sanal bellek, tcpip hep ilk olarak bsd de deneniyor.
*   zamanla pekcok unix turevi sistem olusturuldu.
*   80 li yillarin ortalarinda R Stallman ponerisi ile farkli unix turevi sistemler POSIX ismi ile standardize edilmistir.
*   POSIX standartlari birkac bolumden olusmaktadir. Bolumlerden biri Shell komutlarini aciklari.

Digeri C den kullanabilecegimiz api fonksiyonunu aciklar.

*   Bugun LINUX, BSD, SOLARIS gibi sistemlerin hepsi POSIX uyumludur.
*   PCBSD bsd surumu olarak kullanilabilir.
*   WMS ve openWMS
*   opengroup dernegi
*   80 li yillarin basindan Sichard S FSF isminde bir xx kurdu. ve Free software akimini kurdu.
*   FSF ayni zamanda GNU projesini baslatti, Bu projenin amaci acik bir isletim sistemi ve gelistirme araclarini yazmakti.
*   Ozgur yazilimi temsil eden lisansn GPL lisansidir. Bu lisansa copyright yerine copyleft denilmektedir.
*   90 li yillarin basinda Linus torvalds linux u gelistirmeye basladi.
*   Linux sistemleri bugn icin acik kaynak kodlu posix uyumlu unix turevi sistemlerdir.

Standart C Fonksiyonlari, POSIX Fonksiyonlari ve SIstem Fonksiyonlari
---------------------------------------------------------------------

*   Standar C fonksiyonlari C derleyicisinin bulundugu her yerde olan fonksiyonlardir. Microcontroller olsa bile bu fonksiyonlar bulunmaktadirlar
*   POSIX Fonksiyonlari POSIX Standartlarina uyan UNIX turevi sistemlerde var olan fonksiyonlardir.
*   Sistem fonksiyonlari ise i isletim sistemine ozgu fonksiyonlardir.
    *   Windows dunyasinda standard C fonksiyonlari ve windows api fonksiyonlari vardir.
    *   LINUX
        *   fopen —> open —> sys\_open
        *   cdeki fopen fonksiyonu POSIX fonksiyonu olan open fonksiyonunu cagirir. Bu da sistem fonksiyonu olan sys\_open fonksiyonunu cagirir.
    *   Windows
        *   fopen —> CreateFile Windows daki c fonksiyonu olan fopen cagirildigi zaman, API fonsiyonu olan createFile fonksiyonu cagirilir,

Windows Dosya Sistemi
---------------------

*   DIsk organizasyon tarafi
*   Bellek organizasyon tarafi bulunmaktafir.
*   Bir isletim sisteminin dosya sisteminin iki yonu vardir. Disk tarafi ve bellek tarafi.
*   Sistemin disk tarafi, Yapilan disk organizasyonuna iliskindir. Yani sektorlerin dosyalari tutacak bicimde nasil organize olacagi ile ilgilidir.
*   Bellek tarafi denilince diskteki bu dosyalarin idare edilmedi icin olusturulan veri yapilari akla gelmetedir.
*   isletim sisteminin dosya sistemi diskteki sektorleri bize bagimsiz dosyalarmis gibi gosterir.
*   Biz de dosya islemlerini api fonksiyonleri ile yapariz.
*   BIrcok sistemdi device driver ler dosya olarak tanimlanir ve sistem bu dosyalara okuma yazma yaparak bu driverlari kullanirlar.
*   Windows sistemlerinde temel dosya apileri sunlardir.
    *   CreateFile : help dosyası ıcerısınde ıncele
    *   ReadFile :
    *   WriteFile :
    *   SetFilePointer : Dosya kullnici icin bytelerdan olusan brttopluluk. Bir de file pointer diye bir sayi. O anda hagi dosya ile ilgili islem yapilacgini anlatiyor.http://www.kaanaslan.com/resource/article/display\_article.php?id=64 makalesini oku
    *   CloseHandle :

CreateFile fonksıyonu basarısız olursa invalid handle value isimliozel bir isme geri doner read file fonksiyonunu kullanirken sunlara dikkat etmek gerekmektedir.

*   Dosya gostericisiinin bulundu yerden itibaren kalan byte miktarindan daha fazla miktarda okuma yapmak normak bir durumdur. BU durumda fonksiyon basarisiz olmaz. Okunabilen byte okunur. ve kac byte okundugu bize verilir.
*   ReadFile IO hatasi olustugunda yada gecersiz parametre girildiginde basarisiz olur.
*   EOF durumunda okuma yapmaya calisirsak 0 byte okuruz ancak fonksiyon basarisiz olmaz. UNIX Linux dunyasinda IO hatasinda -1 ve EOF durumunda 0 dinus yapar. WriteFile Fonksiyonu
*   dosyalarin handle degerleri process kontrol blogunda da bulunmaktadir. biz bir disyayi papatmamasak bile process sonlandiginda isletim sistemi butun dosalari bizim icin kapatir. (Terminate process dahil olmak uzere) . Fakat bir dosya ile isimizi bitirmissek onu mumkun oldugunca kapatmak iyi bir tekniktir. Set file pointer — http://www.kaanaslan.com/resource/article/display\_article.php?id=64


```c
/*--------------------------------------------------------------------------
    CreateFile, ReadFile, WriteFile örneği
----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    HANDLE hFile;
    char buf[1024 + 1];
    DWORD dwRead, dwWritten;

    if ((hFile = CreateFile("test.dat", GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_ALWAYS,
                        FILE_ATTRIBUTE_NORMAL, NULL)) == INVALID_HANDLE_VALUE)
        ExitSys("CreateFile", EXIT_FAILURE);

    if (!ReadFile(hFile, buf, 1024, &dwRead, NULL))
        ExitSys("ReadFile", EXIT_FAILURE);

    buf[dwRead] = '\0';
    puts(buf);

    strcpy(buf, "xxxxx");

    if (!WriteFile(hFile, buf, 5, &dwWritten, NULL))
        ExitSys("WriteFile", EXIT_FAILURE);

    CloseHandle(hFile);

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

Yardimci Dosya fonksiyonlari
----------------------------

read wite yapmayan ancak dosya sistemi ile ilgili islemler yapam fonksiyonlar

*   CopyFile ve CopyFileEx fonksiyonlari dosya kopyalamakta kopyalanir.

DeleteFile Fonksiyonu dosya silmekte kullnilir.

*   GetFileAttribule fonksiyonu ile bir dosyanin ozellik bilgisi elde edilebilir.
*   GetFileSize ve GetFileSizeEx fonksiyonu dosya uzunlugunu elde etmekte kullanilir.
*   MoveFile ve MoveFileEx dosyayi tasimakta gullanilir.
*   CreateDirectory ve CreateDirectoryEx fonksiyonlari yeni bir dizin yaratmak icin kullanilir
*   RemoveDirectory Fonksiyonu bos bor klasoru silebilir.
*   Ici dolu kladoru tek hamlede silen bir API fonsiyonu yoktur ancak shell fonksiyonu vardir.

### Dizin Iceriginin elde edilmesi

*   Windows da bir dizin icerigini elde etmek icin 3 API fonksiyonu kullanilir.
*   Bunlar FindFirsFile, FindNextFile ve FileClose fonksiyonlaridir.
*   fonksiyonlar su sekilde kullanilirlar.
    *   Once bir kes findfirstfile kullanilir. birden fazla dosyanin elde edilmesi hedeflenmisse bu fonksiyon bize ilk dosyanin bilerini verir.
    *   Bundan sonra bir dongu icerisinde find next file cagirilarak diger dosyalarin bilgileri elde edilebilir.
    *   En sonunda da FindClose cagirilarak islem sonlandirilir.
    *   Bı fonksıyonlarda tum dızın ıcerıgını elde ederız. Her dizinin icerisinde nokta ve cift nokta dizinleri bulunur. Bular dizin yaratilirken olusur ve bunlar istense de silinemezler.
    *   Dizinler de dosya gibi islem gorurler. Yani biz bu fonksiyonlarla dizinleri de bulabiliriz.

```c
/*-----------------------------------------------------------------------------
    Dosyanın sonuna ekleme yapmak
-------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    HANDLE hFile;
    DWORD dwWritten;

    if ((hFile = CreateFile("test.dat", GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_ALWAYS,
                        FILE_ATTRIBUTE_NORMAL, NULL)) == INVALID_HANDLE_VALUE)
        ExitSys("CreateFile", EXIT_FAILURE);

    SetFilePointer(hFile, 0, 0, FILE_END);

    if (!WriteFile(hFile, "ankara", 6, &dwWritten, NULL) )
        ExitSys("WriteFile", EXIT_FAILURE);

    CloseHandle(hFile);

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
Oz yinelemeli olarak dizin agacini dolasasn bir fonksiyon yazilacak\
/*-----------------------------------------------------------------------------------------------------------
    Dizin içerğinin elde edilmesi
-----------------------------------------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    HANDLE hFind;
    WIN32_FIND_DATA fd;
    char path[MAX_PATH];

    printf("Path:");
    gets(path);

    hFind = FindFirstFile(path,  &fd);
    if (hFind == INVALID_HANDLE_VALUE)
        ExitSys("FindFirstFile", EXIT_FAILURE);

    do {
        printf("%-30s %lu\n", fd.cFileName, fd.nFileSizeLow);
    } while (FindNextFile(hFind, &fd));

    FindClose(hFind);

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
/*----------------------------------------------------------------
    Dizin ağacının dolaşılması
------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);
void WalkDir(LPCTSTR path);
void WalkDirRecur(LPCTSTR path);

int main(void)
{
    char path[MAX_PATH];

    printf("Path:");
    gets(path);

    WalkDir(path);


    return 0;
}

void WalkDir(LPCTSTR path)
{
    char cwd[1024];

    if (!GetCurrentDirectory(1024, cwd))
        ExitSys("GetCurrentDirectory", EXIT_FAILURE);

    WalkDirRecur(path);

    if (!SetCurrentDirectory(cwd))
        return;
}

void WalkDirRecur(LPCTSTR path)
{
    HANDLE hFind;
    WIN32_FIND_DATA fd;

    if (!SetCurrentDirectory(path))
        return;
    
    hFind = FindFirstFile("*.*",  &fd);
    if (hFind == INVALID_HANDLE_VALUE)
        return;

    do {
        if (!strcmp(fd.cFileName, ".") || !strcmp(fd.cFileName, ".."))
            continue;
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            WalkDirRecur(fd.cFileName);
            if (!SetCurrentDirectory(".."))
                return;
        }
        else
            printf("%-30s %lu\n", fd.cFileName, fd.nFileSizeLow);
    } while (FindNextFile(hFind, &fd));

    FindClose(hFind);
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

/*------------------------------------------------------------
    Dizin ağacının ağaç biçiminde yazdırılması
-------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

void ExitSys(LPCTSTR lpszMsg, int status);
void WalkDir(LPCTSTR path);
void WalkDirRecur(LPCTSTR path);

int main(void)
{
    char path[MAX_PATH];

    printf("Path:");
    gets(path);
    printf("\n");

    WalkDir(path);

    return 0;
}

void WalkDir(LPCTSTR path)
{
    char cwd[1024];

    if (!GetCurrentDirectory(1024, cwd))
        ExitSys("GetCurrentDirectory", EXIT_FAILURE);
    
    WalkDirRecur(path, 0);

    if (!SetCurrentDirectory(cwd))
        return;
}

void WalkDirRecur(LPCTSTR path, int space)
{
    HANDLE hFind;
    WIN32_FIND_DATA fd;
    int i;

    if (!SetCurrentDirectory(path))
        return;
    
    hFind = FindFirstFile("*.*",  &fd);
    if (hFind == INVALID_HANDLE_VALUE)
        return;

    do {
        if (!strcmp(fd.cFileName, ".") || !strcmp(fd.cFileName, ".."))
            continue;
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            for (i = 0; i < space; ++i)
                putchar(' ');
            printf("%s\n", fd.cFileName);
            space += 4;
            WalkDirRecur(fd.cFileName, space);
            space -= 4;
            if (!SetCurrentDirectory(".."))
                return;
        }

    } while (FindNextFile(hFind, &fd));

    FindClose(hFind);
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
