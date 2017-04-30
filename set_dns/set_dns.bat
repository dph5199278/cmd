COLOR 0A
CLS
@ECHO off&setlocal enabledelayedexpansion
Title SET DNS

ECHO Auto convert dhcp dns to static dns, one moment please... 

set info=
for /f "tokens=*" %%i in ('ver') do (
 set "info=%%i"
)
echo %info%|findstr /i /c:"5.1" && goto :xp
echo %info%|findstr /i /c:"6.1" && goto :win7
goto :end

:xp
:win7
rem count all network adapters
rem init network adapters' name variable
rem init network adapters' dns variable
set index1=1
set index2=1
set count=0
for /f "tokens=*" %%a in ('netsh interface ip show dns') do (
 for /f "tokens=1*" %%j in ('echo %%a^|find """"') do (
  set /a count+=1
  for /f tokens^=1*^ delims^=^" %%x in ("%%k") do (
   rem set name variable
   if not defined name!index1! (
    set "name!index1!=%%x"
	set /a index1+=1
   )
  )
 )

 for /f "tokens=1,2* delims=:" %%x in ('echo %%a^|find /i "DNS"') do (
  rem set dns variable
  if not defined dns!index2! (
   echo %%x|findstr /v /i /c:"DHCP" && set "dns!index2!=%%y" || set "dns!index2!=NONE"
   set /a index2+=1
  )
 )

)

for /l %%i in (1,1,%count%) do (
 for /f "usebackq tokens=2 delims==" %%j in (`set dns%%i`) do (
  set dns=%%j

  rem replace left space and right space
  for /f "tokens=1*" %%x in ("%%j") do set dns=%%x

  set "dns%%i=!dns!"
  echo 0 dns%%i
  echo 1 !dns!
 )
)

for /l %%i in (1,1,%count%) do (
 if defined dns%%i (
  for /f "usebackq tokens=2 delims==" %%j in (`set dns%%i`) do (
   echo %%j | findstr /v /i "^[0-9]" && set "flag=ok" || set "flag=1"
   if "ok" == "!flag!" (
    for /f "usebackq tokens=2 delims==" %%x in (`set name%%i`) do (
     netsh interface ip set dns "%%x" static 8.8.8.8 primary
     netsh interface ip add dns "%%x" 114.114.114.114
     echo set stattic DNS: %%x
    )
   )
  )
 )
)

ECHO set over, press any key to exit...
pause>nul
exit

:end
ECHO No need to set, press any key to exit...
pause>nul
exit