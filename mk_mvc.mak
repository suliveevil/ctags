#
# Makefile for Win32 using Microsoft Visual Studio 2013
#
# To use from the command line:
# 1. From the Start Menu "Visual Studio 2013" -> "Visual Studio Tools" -> "VS2013 x86 Native Tools Command Prompt"
# 2. In the command prompt that opens goto the directory containing the sources
# 3. Execute: nmake -f mk_mvc.mak
#

include source.mak

OBJEXT = obj
DEFINES = -DWIN32 -DHAVE_REGCOMP -D__USE_GNU -Dstrcasecmp=stricmp -DHAVE_PACKCC -DHAVE_REPOINFO_H -DSIZE_T_FMT_CHAR=\"I\"
REGEX_DEFINES = -Dbool=int -Dfalse=0 -Dtrue=1 $(DEFINES)
INCLUDES = -I. -Imain -Ignu_regex -Ifnmatch -Iparsers
OPT = /O2 /WX
PACKCC = packcc.exe
REGEX_OBJS = $(REGEX_SRCS:.c=.obj)
FNMATCH_OBJS = $(FNMATCH_SRCS:.c=.obj)
WIN32_OBJS = $(WIN32_SRCS:.c=.obj)
PEG_OBJS = $(PEG_SRCS:.c=.obj)
PACKCC_OBJS = $(PACKCC_SRCS:.c=.obj)
ALL_OBJS = $(ALL_SRCS:.c=.obj) $(REGEX_OBJS) $(FNMATCH_OBJS) $(WIN32_OBJS) $(PEG_OBJS)
READTAGS_OBJS = $(READTAGS_SRCS:.c=.obj)

!if "$(WITH_ICONV)" == "yes"
DEFINES = $(DEFINES) -DHAVE_ICONV
LIBS = $(LIBS) /libpath:$(ICONV_DIR)/lib iconv.lib
INCLUDES = $(INCLUDES) -I$(ICONV_DIR)/include
!endif

!ifdef DEBUG
DEFINES = $(DEFINES) -DDEBUG
PDB = yes
!endif

!ifdef PDB
OPT = $(OPT) /Zi
PDBFLAG = /debug
!else
PDBFLAG =
!endif

# Generate repoinfo.h.
!if [win32\gen-repoinfo.bat $(REPOINFO_HEADS)]
!endif

.SUFFIXES: .peg

{main}.c{main}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fomain\ /c $<
{optlib}.c{optlib}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fooptlib\ /c $<
{parsers}.c{parsers}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Foparsers\ /c $<
{parsers\cxx}.c{parsers\cxx}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Foparsers\cxx\ /c $<
{read}.c{read}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Foread\ /c $<
{win32\mkstemp}.c{win32\mkstemp}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fowin32\mkstemp\ /c $<
{peg}.peg{peg}.c::
	$(PACKCC) $<
{peg}.c{peg}.obj::
	$(CC) $(OPT) $(DEFINES) $(INCLUDES) /Fopeg\ /c $<

all: $(PACKCC) ctags.exe readtags.exe

ctags: ctags.exe

ctags.exe: $(ALL_OBJS) $(ALL_HEADS) $(PEG_HEADS) $(PEG_EXTRA_HEADS) $(REGEX_HEADS) $(FNMATCH_HEADS) $(WIN32_HEADS) $(REPOINFO_HEADS)
	$(CC) $(OPT) /Fe$@ $(ALL_OBJS) /link setargv.obj $(LIBS) $(PDBFLAG)

readtags.exe: $(READTAGS_OBJS) $(READTAGS_HEADS)
	$(CC) $(OPT) /Fe$@ $(READTAGS_OBJS) /link setargv.obj $(PDBFLAG)

$(REGEX_OBJS): $(REGEX_SRCS)
	$(CC) /c $(OPT) /Fo$@ $(INCLUDES) $(REGEX_DEFINES) $(REGEX_SRCS)

$(FNMATCH_OBJS): $(FNMATCH_SRCS)
	$(CC) /c $(OPT) /Fo$@ $(INCLUDES) $(DEFINES) $(FNMATCH_SRCS)

$(PACKCC_OBJS): $(PACKCC_SRCS)
	$(CC) /c $(OPT) /Fo$@ $(INCLUDES) $(DEFINES) $(PACKCC_SRCS)

$(PACKCC): $(PACKCC_OBJS) $(PACKCC_HEADS)
	$(CC) $(OPT) /Fe$@ $(PACKCC_OBJS) /link setargv.obj $(PDBFLAG)

main\repoinfo.obj: main\repoinfo.c main\repoinfo.h

peg\varlink.c peg\varlink.h: peg\varlink.peg $(PACKCC)


clean:
	- del *.obj main\*.obj optlib\*.obj parsers\*.obj parsers\cxx\*.obj gnu_regex\*.obj fnmatch\*.obj misc\packcc\*.obj peg\*.obj read\*.obj win32\mkstemp\*.obj main\repoinfo.h
	- del ctags.exe readtags.exe $(PACKCC)
	- del tags
