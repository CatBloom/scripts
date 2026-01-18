@echo off
setlocal EnableDelayedExpansion

rem プレフィックス入力
set /p prefix=連番のプレフィックスを入力してください（例: image）: 

if "%prefix%"=="" (
  echo プレフィックスが空のため終了します。
  goto :EOF
)

echo.
echo 連番の開始番号を入力してください（例: 1, 01, 001）:
set /p startNo=開始番号: 

if "%startNo%"=="" (
  echo 開始番号が空のため終了します。
  goto :EOF
)

rem 数値部分を取得（先頭の0は無視されるが、桁数は別で保持）
set /a startNum=%startNo% 2>nul
if errorlevel 1 (
  echo 数字以外が含まれているため終了します。
  goto :EOF
)

rem 入力された開始番号文字列の桁数を取得
call :StrLen width "%startNo%"
if "%width%"=="" set "width=1"

rem この bat が置いてあるフォルダに移動
pushd "%~dp0"

set cnt=0

rem フォルダ直下のファイルを更新日時の古い順(/od)で処理
for /f "delims=" %%F in ('dir /a-d /b /od') do (
  rem 自分自身(bat)はスキップ
  if /I not "%%~nxF"=="%~nx0" (
    rem 連番の値を計算
    set /a numVal=startNum+cnt
    set /a cnt+=1

    rem 桁数に応じてゼロ埋め
    call :FormatNumber num !numVal! %width%

    rem 拡張子を取得
    set "ext=%%~xF"
    if "!ext!"=="" (
      set "newname=!prefix!_!num!"
    ) else (
      set "newname=!prefix!_!num!!ext!"
    )

    echo "%%F" ^> "!newname!"
    ren "%%F" "!newname!"
  )
)

popd
endlocal
echo 完了しました。
pause
goto :EOF


rem === 文字列長を取得するサブルーチン ===
rem 使い方: call :StrLen 変数名 "文字列"
:StrLen
setlocal EnableDelayedExpansion
set "s=%~2"
set /a len=0
:strlen_loop
if defined s (
  set "s=!s:~1!"
  set /a len+=1
  goto :strlen_loop
)
endlocal & set "%~1=%len%"
goto :EOF


rem === 数値を桁数指定でゼロ埋めするサブルーチン ===
rem 使い方: call :FormatNumber 出力変数 数値 桁数
:FormatNumber
setlocal EnableDelayedExpansion
set "val=%~2"
set "w=%~3"
set "res=!val!"

rem val の桁数を取得
set "tmp=!val!"
set /a len=0
:fmt_len_loop
if defined tmp (
  set "tmp=!tmp:~1!"
  set /a len+=1
  goto :fmt_len_loop
)

rem 桁数が足りない場合だけゼロ埋め
if !len! LSS !w! (
  set "pad=00000000000000000000!val!"
  rem w 桁分だけ末尾を取り出す
  call set "res=%%pad:~-!w!%%"
)

endlocal & set "%~1=%res%"
goto :EOF