@echo off
setlocal EnableDelayedExpansion

echo 1. Dang tim ten Dich vu SQL Server...
set "SQL_SVC_NAME="
for /f "tokens=2 delims=: " %%N in ('sc query state^= all ^| findstr /i "SERVICE_NAME.*MSSQL"') do (
    set "SQL_SVC_NAME=%%N"
)

if "%SQL_SVC_NAME%"=="" (
    echo Khong tim thay SQL Server!
    pause
    exit /b
)
echo Tim thay: %SQL_SVC_NAME%

echo.
echo 2. Dang tat SQL Server...
net stop "%SQL_SVC_NAME%"

echo.
echo 3. Khoi dong SQL Server che do Single-User (Giam ho...
start "" /b net start "%SQL_SVC_NAME%" /m

echo.
echo 4. Chuan bi cong cu vao SQL Server...
timeout /t 5 /nobreak >nul

:: Lay ten thuc te cua Instance
if "%SQL_SVC_NAME%"=="MSSQLSERVER" (
    set "SQL_SERVER=localhost"
) else (
    for /f "tokens=2 delims=$" %%I in ("%SQL_SVC_NAME%") do set "SQL_SERVER=localhost\%%I"
)

echo Dang ket noi vao: %SQL_SERVER%

echo.
echo 5. Dang sua chua tai khoan SA va quyen Admin...
sqlcmd -S %SQL_SERVER% -E -Q "EXEC sp_addsrvrolemember '%USERDOMAIN%\%USERNAME%', 'sysadmin'; ALTER LOGIN [sa] WITH PASSWORD='zxczxc123', CHECK_POLICY=OFF; ALTER LOGIN [sa] ENABLE;"
if %ERRORLEVEL% EQU 0 (
    echo THANH CONG! Da cap loi quyen Admin cho ban va doi mat khau SA thanh 'zxczxc123'
) else (
    echo THAT BAI! Co the SQL Server dang bi ket.
)

echo.
echo 6. Tat che do Single-User...
net stop "%SQL_SVC_NAME%"
timeout /t 3 /nobreak >nul

echo.
echo 7. Khoi dong lai SQL Server binh thuong...
net start "%SQL_SVC_NAME%"

echo.
echo HOAN TAT. Bay gio hay vao SSMS bang Windows Authentication.
echo Hoac dang nhap bang sa / zxczxc123.
pause
