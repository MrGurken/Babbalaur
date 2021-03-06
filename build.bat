@echo off

IF NOT EXIST ..\..\build\ mkdir ..\..\build\
pushd ..\..\build\

REM Compile main program
cl.exe -nologo -Zi -EHsc -DDEBUG -Febabbalaur.exe X:/code/Babbalaur/win_main.cpp /IC:\GLEW\include /IC:\SDL2\SDL\include /IC:\SDL2\Image\include /IC:\SDL2\TTF\include /IC:\GLM\ /IC:\GLM\detail /IC:\GLM\gtc /IC:\GLM\gtx /MD /link /INCREMENTAL:NO /SUBSYSTEM:CONSOLE /LIBPATH:C:\GLEW\lib\Release\Win32\ /LIBPATH:C:\SDL2\SDL\lib\ /LIBPATH:C:\SDL2\Image\lib\x86\ /LIBPATH:C:\SDL2\TTF\lib\x86\ SDL2.lib SDL2main.lib SDL2_image.lib SDL2_ttf.lib opengl32.lib glew32.lib

if %errorlevel% == 0 (
REM Compile font maker
cl.exe -nologo -Zi -EHsc -DDEBUG -Fefont_maker.exe X:/code/Babbalaur/fontmaker_main.cpp /IC:\GLEW\include /IC:\SDL2\SDL\include /IC:\SDL2\TTF\include /IC:\SDL2\Image\include /MD /link /INCREMENTAL:NO /SUBSYSTEM:CONSOLE /LIBPATH:C:\GLEW\lib\Release\Win32\ /LIBPATH:C:\SDL2\SDL\lib\ /LIBPATH:C:\SDL2\TTF\lib\x86\ /LIBPATH:C:\SDL2\Image\lib\x86\ SDL2.lib SDL2main.lib SDL2_ttf.lib SDL2_image.lib opengl32.lib glew32.lib

REM Compile unit tests
cl.exe -nologo -Zi -EHsc -DDEBUG -Fetests.exe X:/code/Babbalaur/win_tests.cpp /IC:\GTEST\include /IC:\GLEW\include /IC:\SDL2\SDL\include /IC:\SDL2\Image\include /IC:\SDL2\TTF\include /IC:\GLM\ /IC:\GLM\detail /IC:\GLM\gtc /IC:\GLM\gtx /MDd /link /SUBSYSTEM:CONSOLE /LIBPATH:C:\GTEST\lib /LIBPATH:C:\GLEW\lib\Release\Win32\ /LIBPATH:C:\SDL2\SDL\lib\ /LIBPATH:C:\SDL2\Image\lib\x86\ /LIBPATH:C:\SDL2\TTF\lib\x86\ gtestd.lib gtest_maind.lib SDL2.lib SDL2main.lib SDL2_image.lib SDL2_ttf.lib opengl32.lib glew32.lib
)

popd