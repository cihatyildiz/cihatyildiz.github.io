---
title: Win32 System Programming - Part 3
author: Cihat Yildiz
date: 2014-09-15 20:55:00 +0800
categories: [Notes]
tags: [writing]
pin: false
---

VirtualBox da share mount etmek:
```
sudo mount -t vboxsf EDrive EDrive
```

*   Unix ve linux sistemlerinde process yaratan tek bir fonksiyon vardir o da fork isimli fonksiyondur. pid\_t fork(void)
*   Fork processin ozdes kopyasindan cikartir. Fakat ust e alt processler arasinda artik bundan sonra hicbir iliski yoktur. Bunlarin gecmisleri aynidir. Ayni kod bolmune sahiptirler. Fakat artik bu kodun ayni bolumunu calistirmak zorunda degildirler.
*   Yani fork fonksiyonuna tek bir proses akisi girer ancak iki process cikar.
*   http://linux.die.net/man/2/fork Adresinden ayrintili bilgi edinilebilir.
*   Fork fonksiyonundan ust process yaratmis oldugu alt processin ID degeri ile Alt process de 0 degeri ile cikar.

```c
pid_t pid; 
if((pid = fork())== -1){
   perror("Fork");   exit(EXIT_FAILURE)
 } 
if(pid == 0){ // child   
    /// Your code will be here.... 
}
```

*   UNIX ve Linux sstemlerinde bir programi calistiran bir grup exec fonksiyonu vardir. bu fonksiyonlar mevcut processin bellek alanini bosaltarak yeni bir programi yuklerler ve mevcut processi baska bir program gibi calistirirlar.
*   Yani exec isleminden sonra process kontrol blogu degismez. Processin butun haklari ayni kalir.

```c
/*---------------------------------------------------------------
    UNIX/Linux sistemlerinde fork işlemi
-----------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    pid_t pid;
    
    if ((pid = fork()) == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    }
    
    if (pid == 0) {
        printf("child\n");
    }
    else {
        printf("parent\n");
    }
    
    printf("ends..\n");
    
    return 0;
}
/*-------------------------------------------------------------------
   UNIX/Linux sistemlerinde exec işlemleri
---------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    if (execl("/bin/ls", "/bin/ls", "-l", (char *) NULL) == -1) {
        perror("execl");
        exit(EXIT_FAILURE);
    }
    
    printf("unreachable code!...\n");
    
    return 0;
}

/*-------------------------------------------------------------
    Tipik bir fork / exec kalıbı
---------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    pid_t pid;
    
    if ((pid = fork()) == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    }
    
    if (pid == 0)
        if (execl("/bin/ls", "/bin/ls", "-l", (char *) NULL) == -1) {
            perror("execl");
            exit(EXIT_FAILURE);
        }
    
    /* only parent executes this code... */
    
    {
        int i;
        
        for (i = 0; i < 10; ++i) {
            printf("%d\n", i);
            sleep(1);
        }
    }
    
    return 0;
}
```

### Process Listesinin Elde Edilmesi

*   Windows da sistemdeki processlerin listesini alabilmek icin iki grup apiden faydalanilabilmektedir. Birincisi eski stil toolhelp apileridir. ikincisi yeni stil psapi isimli api grubudur. Bu fonksiyonlarla biz processlerin ID lerini elde ederiz IDleri handle degerlerine donusturebiliriz.
    *   toolhelp
    *   psapi
*   Unix linux sistemlerde proc dosya sistemie bakilmasi gerekmektedir. /proc
*   Unix/linux sistemlerinde prosess listesini veren standart fonksiyonlar yoktur. Bu nedenle ps komutunun bazi sistemlerde nasil yazildigi bilinmemektedir. Fakat modern unix turevi sistemler proc dosya sistemini desteklemektedir. Process listesi dogrudan proc dosya sisteminden alinabilir.

```csharp
/*-------------------------------------------------------------
    .NET'te proses listesinin elde edilmesi
---------------------------------------------------------------\*/

using System;
using System.Diagnostics;

namespace CSD
{
    class App
    {
        public static void Main()
        {
            foreach (Process proc in Process.GetProcesses())
                Console.WriteLine(proc.ProcessName);
        }
    }
}
```

Windows da tum processlerin listesinin elde edilmesi konusunda bazi problemler vardir. Ornegin 64 bit bir process de EnumProcesses fonksiyonu 32 bit processleri tam olarak elde edememekte 32 de 64 bit processleri tam olarak elde edememektedir. bu nedenle tum listeyi almak icin hem 32 hem 64 bit uygulama calistirilmasi gereklmektedir.

```c
/*------------------------------------------------------------------------
    Proses listesinin PSAPI fonksiyonlarıyla elde edilmesi
--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>
#include <Psapi.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    DWORD pids[8192];
    DWORD dwCount;
    HANDLE hProcess;
    HMODULE hMod;
    DWORD cbNeeded;
    char szProcessName[MAX_PATH] = "<unknown>";
    int i;

    if (!EnumProcesses(pids, 8192, &dwCount))
        ExitSys("EnumProcesses", EXIT_FAILURE);

    for (i = 0; i < dwCount / sizeof(DWORD); ++i) {
        if ((hProcess = OpenProcess(PROCESS_QUERY_INFORMATION|PROCESS_VM_READ, 
                                            FALSE, pids[i])) == NULL)
            continue;
        
        if (EnumProcessModules( hProcess, &hMod, sizeof(hMod), &cbNeeded))
            GetModuleBaseName( hProcess, hMod, szProcessName,
                               sizeof(szProcessName)/sizeof(TCHAR) );
        printf("%s\n", szProcessName);

    }
    printf("\n");
    
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
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}
```

### Processlerin calisma dizinleri

*   Her processin bir calisma dizini vardir. Calisma dizini goreli yol ifadelerinin (path name) cozulmesi icin kullanilir. Process calisirken calisma dizini degistirilebilir.
*   Windows da process in calisma dizini process yaratilirken createProcess fonksiyonunda belirtirlir. Eger ilgili parametee NULL gecilirse alt processin calisma dizini ust proccess ile ayni olur.
*   UNIX ve Linux Sistemlerinde process in calisma dizini Fork islemi sirasinda dogrudan ust processs den alinoir biz bu sistemlerde calistiracagimiz programin calisma dizinini belirlemek istiyorsak once bir kez fork yapariz. Alt process de henuz exec yapmadan calisma dizinini degistiririz. sonra exec yapariz.
*   Kaan aslanin http://www.kaanaslan.com/resource/article/display\_article.php?page=1&id=79 adresindeki makale okunmali
*   Bir processin calisma dizini get current directory fonksiyonu ile elde edilebilir.

```c
DWORD WINAPI GetCurrentDirectory(
 _In_   DWORD nBufferLength,
 _Out_  LPTSTR lpBuffer 
);
``` 

windowsda path olarak 260 karakterden fazla girilemez. Eger daha uzun path lere erisim saglamak istiyorsak o zaman bir yere kadar path degisimi yapilir ve sonra tekrar path degisimi yapilir. Cok uzun yollardabu yontem izlenmelidir. Processin calisma dizini degistirmek icin windows da SetCurrentDirectory api fonksiyonu kullanilir.

```
BOOL WINAPI SetCurrentDirectory(
  \_In\_  LPCTSTR lpPathName
);
```

UNIX / Linux sistemlerinde processin calisma dizini getcwd api fonksiyonu ile alinir. Processin calisma dizinini degistirmek icin de chdir fonksiyonu kullanilir.

*   UNIX / Linux sistemlerinde bir surucu kavrami yoktur. Ancak windows sistemlerinde bu kavram vardir.
*   Windows cevre degiskenleri yolu ile her surucu icin ayri bir default calisma dizini tutmaktadir. Ayrica processine iliskin surucu aktif surucudur. Eger yol ifadesinde surucuden sonra bir ter bolu () isareti kullanimamissa bu gorev yol ifadesidir. Dolayisi ile processin calismadizininden itibaren yer belirtir.
*   Ancak yol ifadesi surucu icerdigi halde ilk ters bolu () yu icermiyor ise (oldugu gibi) bizim gecerli dizinimiz, aktif surucunmuz ne olursa olsun belirtilen surucudeki default dizinden hareket edilerek yol cozulur.

```c
/*---------------------------------------------------------------------
    Prosesin çalışma dizininin elde edilmesi
-----------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <Windows.h>
#include <Psapi.h>

void ExitSys(LPCTSTR lpszMsg, int status);

int main(void)
{
    char cwd[1024];

    if (GetCurrentDirectory(1024, cwd) == 0)
        ExitSys("GetCurrentDirectory", EXIT_FAILURE);

    printf("%s\n", cwd);
    
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
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}
```

Bir komut yorumlayicisinin catisi
---------------------------------

```c
/*-----------------------------------------------------
    Bir komut yorumlayıcının çatısı
-------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
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
void ExitProc(void);

/* Global Data Definitions */

char g_cmd[MAX_CMD_LINE];
char *g_params[MAX_CMD_PARAMS];
int g_nparams;
CMD g_cmds[] = {
    {"dir", DirProc},
    {"cls", ClsProc},
    {"cd", ChDirProc},
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
            printf("'%s' is not recognized as an internal or external command, \n
                        operable program or batch file.\n\n", g_params[0]);
        if (!strcmp(g_cmd, "quit"))
            break;
    }
        
    return 0;
}

void Parse(void)
{
    char *param;

    g_nparams = 0;
    for (param = strtok(g_cmd, " \t"); param != NULL; param = strtok(NULL, " \t"))
        g_params[g_nparams++] = param;
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

void ExitProc(void)
{
    exit(EXIT_SUCCESS);
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
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}

void PrintSysErr(void)
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
        fprintf(stderr, "%s\n", lpszErr);
        LocalFree(lpszErr);
    }
}
```

Processlerin Cevre Degiskenleri
-------------------------------

*   Cevre degiskenleri (Environment variables) anahtar deger ciftlerini tutan bir cesit sozluk tarzi veri yapisidir.
*   Biz anahtari verdigimizde bize deger geri verilir.
*   Processin bir degisken listesi vardir.
*   Cevre degiskenleri cekirdek tarafindan genellikle process kontrol blogunda yada processin bellek alaninda tutulur. Yani process e ozgudur.
*   Processin cevre degiskenleri windows da process yaratilirken createProcess api fnksiyonu ile belirlenir. Eger ilgili parametre NULL ecilirse alt processin cevre degisken takimi ust process ile ayni olur.
*   UNIX / Linux sistemlerinde cevre degiskenleri fork islemi sirasinda ust processten tamamen kopyalanir. Fakat exec yaparken tipki windowsda oldugu gibi istege bagli olarak degistirilebilmektedir.
*   Windows da bir cevre degiskeni degerini almak icin GetEnvironmentVarible Api fonksiyonu kullanilir.
*   Windows sistemlwerde komut satirinda cevre degiskeni verip anahtar elde etmek icin %%, linux sistemlerde de $ kalibi kullanilir.
*   Windows sistemlerde komut satirindda komt satiri cevre degikenine ekleme yapmak icin set c=y komutu kullanilir. UNIX/Linux sistemlrede export x = y komutu kullanilir.
*   Windows sistemlerde yeni cevre degiskeni eklemek icin setEnvironmentVeriable fonksiyonu kullanilir.
*   Processin tum cevre degiskenlerinin elde edilmesi gerekebilir bu islem GetEnvironmentStrings api fonksiyonu ile yapilmaktadir.
*   [http://www.csystem.org/makaleler/proseslerin-%C3%A7evre-de%C4%9Fi%C5%9Fkenleri](http://www.csystem.org/makaleler/proseslerin-%C3%A7evre-de%C4%9Fi%C5%9Fkenleri) makalesi incelenmeli.

**NOT:** Bir sistem fonksiyonu cagirildigi zamanan stack uzerinde normal calismasi gerektigi gibi calisir ancak bir kernel fonksiyonu cagirilsa kernel fonksiyonu kullanilan stack yapisina guvenmedigi icin kendisi stack uzerindeki alani kernel icin guvenli bir alana kopyalar. Isi bittikte sonra geri stake donus yapar. NOT: Unix/Linux sistemlerinde bir cevre degiskenini elde etmek icin get env standart c fonksiyonu kullanilir. Process e yeni bir cevre degiskeni eklemek icin setenv fonksiyotnu kullanilir. Procesin tum cevre degislenini elde etmek icin environ global pointer i kullanilir.

*   Bir cevre degiskenini kaliciligini saglamak icin Unix ve Linx da shell processinin calistirdigi betiklerin icersinde set islemleri yapilabilir. Windows da benzer bicimde ayni islem denetim masasindan yapilmaktadir.
*   Cevre degiskenrleri neden kullanilmaktadir?
*   BaZEN PROGRAMLARDAKI cesitli ayarlarin hicbirsey yapilmadan kujllaicilar tarafindan degistirilmesi istenebilir. Ornegin bir data dosyasinin yerini programci bir cevre degiskeninden alabilir. Kullanici da o cevre degiskenini degistirerek data dosyasini istedigi yere yerlestirebilir.
*   Bazi sistem fonksiyonlarida bazi sistem degiskenlerine bakmaktadir.
*   Ornegin createProcess birinci parametresi null gecilirse ve ikinci parametresindeki dosya isminde hicbir ters bolu karakteri kullannilmamissa. ilgili exe dosyayi sirasiyla belirli yerlerde arar en sonunda PATH cevre degiskeni ile belirtilen dizinlerde tek tek arar.
*   Windows isletim sistemlerinde cevre degiskenlerinin buyuk/kucuk harf duyarliligi yoktur. fakat unix ve linux sistemlerinde vardir.

```c
/*------------------------------------------------------------------------
      Prosesin çevre değişkenleri
      (GetEnvPros ve SetEnvProc fonksiyonlarının yazımlarına bakınız)
------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
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
            printf("'%s' is not recognized as an internal or external command, 
                    operable program or batch file.\n\n", g_params[0]);

        if (!strcmp(g_cmd, "quit"))
            break;
    }
        
    return 0;
}

void Parse(void)
{
    char *param;

    g_nparams = 0;
    for (param = strtok(g_cmd, " \t"); param != NULL; param = strtok(NULL, " \t"))
        g_params[g_nparams++] = param;
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

void ExitProc(void)
{
    exit(EXIT_SUCCESS);
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
        fprintf(stderr, "%s: %s", lpszMsg, lpszErr);
        LocalFree(lpszErr);
    }
    
    exit(status);
}

void PrintSysErr(void)
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
        fprintf(stderr, "%s\n", lpszErr);
        LocalFree(lpszErr);
    }
}
/*------------------------------------------------------------------------------
    UNIX/Linux sistemlerine prosesin tüm çevre
    değişkenlerinin yazdırılması
-------------------------------------------------------------------------------*/

#include <stdio.h>

extern char **environ;

int main(void)
{
    int i;
    
    for (i = 0; environ[i] != NULL; ++i)
        puts(environ[i]);
    
    return 0;
}

/*----------------------------------------------------------------------
    CreateProcess PATH çevre değişkenlerine bakmaktadır

    (RunProcess)
---------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
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
        if (g_cmds[i].name == NULL) {
            RunProcess();
            //printf("'%s' is not recognized as an internal or external command, operable program or batch file.\n\n", g_params[0]);
        }

        if (!strcmp(g_cmd, "quit"))
            break;
    }
        
    return 0;
}

void Parse(void)
{
    char *param;

    g_nparams = 0;
    for (param = strtok(g_cmd, " \t"); param != NULL; param = strtok(NULL, " \t"))
        g_params[g_nparams++] = param;
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

    if (!CreateProcess(NULL, g_params[0], NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, &si, &pi)) {
        PrintSysErr();
        return;
    }

    CloseHandle(pi.hProcess);
}

void ExitProc(void)
{
    exit(EXIT_SUCCESS);
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