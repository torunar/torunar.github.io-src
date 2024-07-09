# Minimalist PSP SDK + Code::Blocks в Linux

* * *
Писать на C++ под PSP? С <del>Жирафиком Рафиком</del> Minimalist PSP SDK это так просто!
* * *

### Необходимые пакеты

1. CodeBlocks и магия

        $ sudo apt-get install autoconf automake bison flex gcc libmpfr-dev libncurses5-dev libreadline-dev libusb-dev make patch subversion texinfo wget zlib1g-dev ligmp3c2 libgmp3-dev codeblocks


2. Minimalist PSP SDK

Последнюю версию можно найти на странице проекта на Sourceforge: [minpspw](http://sourceforge.net/projects/minpspw/)

  
### Hастройка Code::Blocks

1. Setting → Compiler and debugger…<.p>2\. В поле Selected complier выбрать GNU GCC Compiler, нажать Copy

3. Ввести имя компилятора (например, PSP-GCC)

4. Выбрать созданный компилятор, перейти на вкладку Toolchain executables

    1. Compiler’s directory: /opt/pspsdk/

    2. На вкладке Program Files:
    
    **C compiler:** psp-gcc  
    **C++ compiler:** psp-g++  
    **Linker for dynamic libs:** psp-g++  
    **Linker for static libs:** psp-ar  
    **Debugger:**   
    **Resource compiler:**  
    **Make program:** make

    3. Перейти на вкладку Search directories

5. На вкладке Complier добавить:

        /opt/pspsdk/include
        /opt/pspsdk/psp/include
        /opt/pspsdk/psp/sdk/include

6. На вкладке Linker добавить:

        /opt/pspsdk/lib
        /opt/pspsdk/psp/lib
        /opt/pspsdk/psp/sdk/lib

### Makefile

Также понадобится этот makefile:

    TARGET = main
    OBJS = main.o
    
    INCDIR = 
    CFLAGS = -O2 -G0 -Wall
    CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
    ASFLAGS = $(CFLAGS)
    
    LIBDIR =
    LDFLAGS =
    
    EXTRA_TARGETS = EBOOT.PBP
    PSP_EBOOT_TITLE = HelloWorld
    
    PSPSDK=$(shell psp-config --pspsdk-path)
    include $(PSPSDK)/lib/build.mak

Его нужно поместить в папку с проектом Code::Blocks.

  
### Проект

1. File → New → Project → Console Application

2. Выбрать язык и размещение проекта

3. Compiler: тот, что был создан (PSP-GCC)

4. Project → Properties

5. В поле Makefile указать имя созданного ранее makefile и отметить “This is a custom makefile”

6. На вкладке Build targets:

    **Output filename:** bin/Debug/psp.elf (для Debug)  
    **Output filename:** bin/Debug/psp.elf (для Release)

7. Project → Properties → Project’s build options

8. На вкладке “Make” commands удалить переменную $target из Debug и Release
 
В результате билда в папке будет создан EBOOT.PBP, который можно будет запустить на PSP.

Для проверки можно воспользоваться этим исходником, который выводит классический “Hello World”: [main.tar.gz](./bin/main.tar.gz)