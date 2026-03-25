@echo off
chcp 65001 > nul
setlocal

echo =====================================================
echo   자동판매기 PySide6 GUI 실행기
echo =====================================================
echo.

REM 스크립트 위치로 이동
cd /d "%~dp0"

REM Python 실행 파일 자동 탐색
set PYTHON_EXE=
for %%p in (
    "%~dp0.venv\Scripts\python.exe"
    "%USERPROFILE%\anaconda3\python.exe"
    "%USERPROFILE%\miniconda3\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
) do (
    if exist %%p (
        if not defined PYTHON_EXE set PYTHON_EXE=%%p
    )
)

if not defined PYTHON_EXE (
    REM 마지막 시도: PATH에서 python3 또는 python 찾기
    where python3 > nul 2>&1 && set PYTHON_EXE=python3
    where python > nul 2>&1 && set PYTHON_EXE=python
)

if not defined PYTHON_EXE (
    echo [오류] Python을 찾을 수 없습니다.
    echo Python 3.11 이상을 설치해 주세요: https://www.python.org
    pause
    exit /b 1
)

echo [Python] %PYTHON_EXE%
echo.

echo [1/4] 패키지 설치 중 (pip install -e .) ...
%PYTHON_EXE% -m pip install -e . --quiet
if errorlevel 1 (
    echo [오류] 패키지 설치에 실패했습니다.
    pause
    exit /b 1
)
echo    완료!

echo.
echo [2/4] 데이터 파일 확인 중 ...
if exist "data\vending_machine_gui_demo.xlsx" (
    echo    vending_machine_gui_demo.xlsx 존재 - 초기화 건너뜀
    goto launch
)
if exist "data\vending_machine_template.xlsx" (
    echo    vending_machine_template.xlsx 존재 - 시드만 실행
    goto seed
)

echo    데이터 파일 없음. bootstrap_workbook.py 실행 중 ...
%PYTHON_EXE% scripts\bootstrap_workbook.py
if errorlevel 1 (
    echo [오류] bootstrap_workbook.py 실행 실패
    pause
    exit /b 1
)
echo    완료!

:seed
echo.
echo [3/4] 데모 판매 데이터 생성 중 ...
%PYTHON_EXE% scripts\seed_demo_analytics.py
if errorlevel 1 (
    echo [경고] seed_demo_analytics.py 실행 실패 - 계속 진행
)
echo    완료!

:launch
echo.
echo [4/4] GUI 실행 중 ...
echo.
%PYTHON_EXE% -m vending_machine.presentation.pyside_gui

pause
