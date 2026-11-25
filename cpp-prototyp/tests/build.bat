@echo off
rem Baut die Tests mit MSVC (Pfad zu vcvars64.bat ggf. anpassen) und startet sie.
rem Aufruf aus dem Ordner cpp-prototyp\tests.
call "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
cl /nologo /EHsc /std:c++17 /wd4716 test_gruppe.cc /Fe:test_gruppe.exe /Fo:test_gruppe.obj
cl /nologo /EHsc /std:c++17 /wd4716 szenarien.cc /Fe:szenarien.exe /Fo:szenarien.obj
test_gruppe.exe
szenarien.exe
