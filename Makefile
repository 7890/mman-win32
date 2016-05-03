#
# mman-win32 (mingw32) Makefile
#
#include config.mak

CC=i686-w64-mingw32-gcc
AR=i686-w64-mingw32-ar
RANLIB=i686-w64-mingw32-ranlib
STRIP=i686-w64-mingw32-strip

BUILD_STATIC=yes
BUILD_SHARED=yes
BUILD_MSVC=

PREFIX=output
bindir=$(PREFIX)/bin
libdir=$(PREFIX)/lib
incdir=$(PREFIX)/include/sys

LIBCMD=echo ignoring lib

CFLAGS=-Wall -O3 -fomit-frame-pointer

ifeq ($(BUILD_STATIC),yes)
	TARGETS+=libmman.a
	INSTALL+=static-install
endif

ifeq ($(BUILD_SHARED),yes)
	TARGETS+=libmman.dll
	INSTALL+=shared-install
endif

ifeq ($(BUILD_MSVC),yes)
	SHFLAGS+=-Wl,--output-def,libmman.def
	INSTALL+=lib-install
endif

all: $(TARGETS)

mman.o: mman.c mman.h
	$(CC) -o mman.o -c mman.c $(CFLAGS)

libmman.a: mman.o
	$(AR) cru libmman.a mman.o
	$(RANLIB) libmman.a

libmman.dll: mman.o
	$(CC) -shared -o libmman.dll mman.o -Wl,--out-implib,libmman.dll.a

header-install:
	mkdir -p $(DESTDIR)$(incdir)
	cp mman.h $(DESTDIR)$(incdir)

static-install: header-install
	mkdir -p $(DESTDIR)$(libdir)
	cp libmman.a $(DESTDIR)$(libdir)

shared-install: header-install
	mkdir -p $(DESTDIR)$(libdir)
	cp libmman.dll.a $(DESTDIR)$(libdir)
	mkdir -p $(DESTDIR)$(bindir)
	cp libmman.dll $(DESTDIR)$(bindir)

lib-install:
	mkdir -p $(DESTDIR)$(libdir)
	cp libmman.lib $(DESTDIR)$(libdir)

install: $(INSTALL)

test.exe: test.c mman.c mman.h
	$(CC) -o test.exe test.c -L. -lmman

test: $(TARGETS) test.exe
	wine test.exe

clean::
	rm -f mman.o libmman.a libmman.dll.a libmman.dll libmman.def libmman.lib test.exe *.dat

distclean: clean
	rm -f config.mak

.PHONY: clean distclean install test
