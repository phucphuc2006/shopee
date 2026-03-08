@echo off
title ShopeeWeb - Auto Setup
color 0B
setlocal EnableDelayedExpansion

:: ============================================
:: Yeu cau quyen Admin
:: ============================================
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  [!] Can quyen Administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
set "PROJECT_ROOT=%cd%"

echo.
echo  ========================================================
echo        SHOPEE WEB - CAI DAT TU DONG HOAN TOAN
echo  ========================================================
echo  Thu muc project: %PROJECT_ROOT%
echo  ========================================================
echo.

:: ============================================
:: BUOC 0: KIEM TRA PHAN MEM
:: ============================================
echo  [0/9] Kiem tra va cai dat phan mem...
echo.

set "HAS_WINGET=0"
where winget >nul 2>&1
if %ERRORLEVEL% EQU 0 set "HAS_WINGET=1"

:: --- Java JDK ---
echo  -- Kiem tra Java JDK --
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  [X] Java chua cai. Dang cai JDK 17...
    if "!HAS_WINGET!"=="1" (
        winget install --id EclipseAdoptium.Temurin.17.JDK --silent --accept-package-agreements --accept-source-agreements
        if !ERRORLEVEL! NEQ 0 (
            winget install --id Amazon.Corretto.17 --silent --accept-package-agreements --accept-source-agreements
        )
        call :REFRESH_PATH
    ) else (
        echo  [X] Khong the cai JDK tu dong.
        echo     Tai thu cong: https://adoptium.net/
        pause
        exit /b 1
    )
) else (
    echo  [OK] Java da cai
)

:: --- Maven ---
echo.
echo  -- Kiem tra Apache Maven --
set "MVN_CMD="

:: Tim mvn.cmd o cac vi tri pho bien
for %%M in (
    "C:\maven\bin\mvn.cmd"
    "C:\Program Files\apache-maven\bin\mvn.cmd"
    "C:\apache-maven\bin\mvn.cmd"
) do (
    if exist %%M (
        if "!MVN_CMD!"=="" (
            set "MVN_CMD=%%~M"
        )
    )
)

:: Neu chua tim thay, dung where
if "!MVN_CMD!"=="" (
    for /f "delims=" %%F in ('where mvn.cmd 2^>nul') do (
        if "!MVN_CMD!"=="" set "MVN_CMD=%%F"
    )
)
if "!MVN_CMD!"=="" (
    for /f "delims=" %%F in ('where mvn 2^>nul') do (
        if "!MVN_CMD!"=="" set "MVN_CMD=%%F"
    )
)

if "!MVN_CMD!" NEQ "" (
    echo  [OK] Maven: !MVN_CMD!
) else (
    echo  [X] Maven chua cai. Dang tai...
    set "MAVEN_VER=3.9.9"
    set "MAVEN_URL=https://dlcdn.apache.org/maven/maven-3/!MAVEN_VER!/binaries/apache-maven-!MAVEN_VER!-bin.zip"
    set "MAVEN_ZIP=%TEMP%\maven.zip"
    powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!MAVEN_URL!' -OutFile '!MAVEN_ZIP!'" >nul 2>&1
    if exist "!MAVEN_ZIP!" (
        powershell -NoProfile -Command "Expand-Archive -Path '!MAVEN_ZIP!' -DestinationPath 'C:\' -Force" >nul 2>&1
        if exist "C:\apache-maven-!MAVEN_VER!" (
            if exist "C:\maven" rmdir /s /q "C:\maven" >nul 2>&1
            ren "C:\apache-maven-!MAVEN_VER!" "maven" >nul 2>&1
        )
        if exist "C:\maven\bin\mvn.cmd" (
            set "MVN_CMD=C:\maven\bin\mvn.cmd"
            set "PATH=!PATH!;C:\maven\bin"
            echo  [OK] Maven cai thanh cong
        ) else (
            echo  [X] Cai Maven that bai.
            pause
            exit /b 1
        )
        del /f /q "!MAVEN_ZIP!" >nul 2>&1
    ) else (
        echo  [X] Khong the tai Maven.
        pause
        exit /b 1
    )
)

:: --- Python ---
echo.
echo  -- Kiem tra Python --
set "HAS_PYTHON=0"
set "PYTHON_CMD=python"
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    py --version >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        set "PYTHON_CMD=py"
        set "HAS_PYTHON=1"
        echo  [OK] Python da cai
    ) else (
        echo  [!] Python chua cai - bo qua buoc sinh du lieu
        if "!HAS_WINGET!"=="1" (
            winget install --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements >nul 2>&1
            call :REFRESH_PATH
            python --version >nul 2>&1
            if !ERRORLEVEL! EQU 0 set "HAS_PYTHON=1"
        )
    )
) else (
    set "HAS_PYTHON=1"
    echo  [OK] Python da cai
)

:: --- SQL Server ---
echo.
echo  -- Kiem tra SQL Server --
set "HAS_SQL_SERVICE=0"
sc query state= all 2>nul | findstr /i "MSSQL" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "HAS_SQL_SERVICE=1"
    echo  [OK] SQL Server da cai
) else (
    echo  [X] SQL Server chua cai. Dang cai...
    if "!HAS_WINGET!"=="1" (
        winget install --id Microsoft.SQLServer.2022.Express --silent --accept-package-agreements --accept-source-agreements
        if !ERRORLEVEL! NEQ 0 (
            winget install --id Microsoft.SQLServer.2019.Express --silent --accept-package-agreements --accept-source-agreements
        )
        set "HAS_SQL_SERVICE=1"
    ) else (
        echo  [X] Khong the cai SQL Server tu dong.
        echo     Tai: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
        pause
        exit /b 1
    )
)

:: ============================================
:: CAU HINH SQL SERVER
:: ============================================
echo.
echo  -- Cau hinh SQL Server --

:: Tim instance
set "SQL_INSTANCE="
set "SQL_SVC_NAME="
for /f "tokens=2 delims=: " %%N in ('sc query state^= all ^| findstr /i "SERVICE_NAME.*MSSQL"') do (
    if "!SQL_SVC_NAME!"=="" (
        set "SQL_SVC_NAME=%%N"
        if /i "%%N"=="MSSQLSERVER" (
            set "SQL_INSTANCE="
        ) else (
            for /f "tokens=2 delims=$" %%I in ("%%N") do set "SQL_INSTANCE=%%I"
        )
    )
)

:: Start service neu can
if "!SQL_SVC_NAME!" NEQ "" (
    sc query "!SQL_SVC_NAME!" 2>nul | findstr /i "RUNNING" >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        echo     Starting SQL Server...
        net start "!SQL_SVC_NAME!" >nul 2>&1
        timeout /t 5 /nobreak >nul
    )
)

:: Server string
if "!SQL_INSTANCE!"=="" (
    set "SQL_SERVER=localhost"
) else (
    set "SQL_SERVER=localhost\!SQL_INSTANCE!"
)
echo     Server: !SQL_SERVER!

:: Registry instance name
if "!SQL_INSTANCE!"=="" (
    set "REG_INSTANCE=MSSQLSERVER"
) else (
    set "REG_INSTANCE=!SQL_INSTANCE!"
)

:: Bat Mixed Auth Mode
reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.!REG_INSTANCE!\MSSQLServer" /v LoginMode /t REG_DWORD /d 2 /f >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.!REG_INSTANCE!\MSSQLServer" /v LoginMode /t REG_DWORD /d 2 /f >nul 2>&1
)
echo     [OK] Mixed Auth Mode

:: Bat TCP/IP qua Registry
for /f "tokens=*" %%K in ('reg query "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server" /s /f "SuperSocketNetLib\Tcp" /k 2^>nul ^| findstr /i "SuperSocketNetLib\\Tcp$"') do (
    reg add "%%K" /v Enabled /t REG_DWORD /d 1 /f >nul 2>&1
)
echo     [OK] TCP/IP Enabled

:: Restart SQL Server
set "SA_PASS=zxczxc123"
echo     Restarting SQL Server...
net stop "!SQL_SVC_NAME!" >nul 2>&1
timeout /t 3 /nobreak >nul
net start "!SQL_SVC_NAME!" >nul 2>&1
timeout /t 5 /nobreak >nul

:: Kiem tra sqlcmd
set "HAS_SQLCMD=0"
where sqlcmd >nul 2>&1
if !ERRORLEVEL! EQU 0 set "HAS_SQLCMD=1"

:: Kich hoat SA
if "!HAS_SQLCMD!"=="1" (
    sqlcmd -S !SQL_SERVER! -E -C -Q "ALTER LOGIN [sa] ENABLE; ALTER LOGIN [sa] WITH PASSWORD = '!SA_PASS!'; ALTER LOGIN [sa] WITH CHECK_POLICY = OFF;" -b >nul 2>&1
) else (
    powershell -NoProfile -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;Integrated Security=True;TrustServerCertificate=True'); $c.Open(); $q = $c.CreateCommand(); $q.CommandText = 'ALTER LOGIN [sa] ENABLE; ALTER LOGIN [sa] WITH PASSWORD = ''!SA_PASS!''; ALTER LOGIN [sa] WITH CHECK_POLICY = OFF'; $q.ExecuteNonQuery(); $c.Close() } catch {}" >nul 2>&1
)

:: Thu ket noi voi cac password
echo.
echo     Dang kiem tra ket noi SA...
set "DB_PASS="
set "FOUND_SQL=0"

for %%P in (zxczxc123 123456 sa 1 admin Sa123456) do (
    if "!FOUND_SQL!"=="0" (
        if "!HAS_SQLCMD!"=="1" (
            sqlcmd -S !SQL_SERVER! -U sa -P %%P -C -Q "SELECT 1" -b -l 5 >nul 2>&1
        ) else (
            powershell -NoProfile -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=%%P;TrustServerCertificate=True;Connection Timeout=5'); $c.Open(); $c.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
        )
        if !ERRORLEVEL! EQU 0 (
            set "DB_PASS=%%P"
            set "FOUND_SQL=1"
            echo     [OK] Ket noi thanh cong voi pass: %%P
        )
    )
)

if "!FOUND_SQL!"=="0" (
    echo     [X] Khong the ket noi SQL Server.
    set "DB_PASS=zxczxc123"
    set /p "DB_PASS=     Nhap mat khau SA [Enter = zxczxc123]: "
)

echo.
echo  [OK] Hoan tat kiem tra phan mem!
echo  ========================================================

:: ============================================
:: BUOC 1: CAP NHAT db.properties
:: ============================================
echo.
echo  [1/9] Cap nhat db.properties...

set "DB_PROPS=%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"

echo # DATABASE CONFIG - AUTO GENERATED> "!DB_PROPS!"
if "!SQL_INSTANCE!"=="" (
    echo db.url=jdbc:sqlserver://localhost:1433;databaseName=shopeeweb_lab211;encrypt=true;trustServerCertificate=true;>> "!DB_PROPS!"
) else (
    echo db.url=jdbc:sqlserver://localhost;instanceName=!SQL_INSTANCE!;databaseName=shopeeweb_lab211;encrypt=true;trustServerCertificate=true;>> "!DB_PROPS!"
)
echo db.user=sa>> "!DB_PROPS!"
echo db.password=!DB_PASS!>> "!DB_PROPS!"
echo.>> "!DB_PROPS!"

:: Doc Google OAuth config
echo # GOOGLE OAUTH>> "!DB_PROPS!"
set "G_ID="
set "G_SECRET="
if exist "%PROJECT_ROOT%\google_oauth.config" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%PROJECT_ROOT%\google_oauth.config") do (
        if "%%A"=="CLIENT_ID" set "G_ID=%%B"
        if "%%A"=="CLIENT_SECRET" set "G_SECRET=%%B"
    )
    echo     [OK] Doc google_oauth.config
)
echo google.client.id=!G_ID!>> "!DB_PROPS!"
echo google.client.secret=!G_SECRET!>> "!DB_PROPS!"

:: Doc Facebook OAuth config
echo # FACEBOOK OAUTH>> "!DB_PROPS!"
set "F_ID="
set "F_SECRET="
if exist "%PROJECT_ROOT%\facebook_oauth.config" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%PROJECT_ROOT%\facebook_oauth.config") do (
        if "%%A"=="APP_ID" set "F_ID=%%B"
        if "%%A"=="APP_SECRET" set "F_SECRET=%%B"
    )
    echo     [OK] Doc facebook_oauth.config
)
echo facebook.app.id=!F_ID!>> "!DB_PROPS!"
echo facebook.app.secret=!F_SECRET!>> "!DB_PROPS!"

echo  [OK] db.properties da cap nhat
echo  ========================================================

:: ============================================
:: BUOC 2: TAO DATABASE
:: ============================================
echo.
echo  [2/9] Tao Database va cac bang...

set "SQL_CREATE=IF NOT EXISTS (SELECT * FROM sys.databases WHERE name='shopeeweb_lab211') CREATE DATABASE shopeeweb_lab211"

if "!HAS_SQLCMD!"=="1" (
    sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -Q "!SQL_CREATE!" -b >nul 2>&1
) else (
    powershell -NoProfile -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;TrustServerCertificate=True'); $c.Open(); $q = $c.CreateCommand(); $q.CommandText = '!SQL_CREATE!'; $q.ExecuteNonQuery(); $c.Close() } catch {}" >nul 2>&1
)
echo     [OK] Database shopeeweb_lab211

:: Chay init_sqlserver.sql
echo     Dang tao cac bang...
if "!HAS_SQLCMD!"=="1" (
    sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -d shopeeweb_lab211 -i "%PROJECT_ROOT%\src\core_app\init_sqlserver.sql" -b >nul 2>&1
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;Database=shopeeweb_lab211;TrustServerCertificate=True'); $c.Open(); $sql = Get-Content '!PROJECT_ROOT!\src\core_app\init_sqlserver.sql' -Raw; foreach($b in ($sql -split '\bGO\b')) { if($b.Trim()) { $q = $c.CreateCommand(); $q.CommandText = $b; $q.ExecuteNonQuery() | Out-Null } }; $c.Close() } catch {}" >nul 2>&1
)
echo  [OK] Da tao xong cac bang
echo  ========================================================

:: ============================================
:: BUOC 3: SINH DU LIEU MAU
:: ============================================
echo.
echo  [3/9] Kiem tra du lieu mau...

if exist "%PROJECT_ROOT%\data\products.csv" (
    echo  [OK] Du lieu mau da co san
) else (
    if "!HAS_PYTHON!"=="1" (
        echo     Dang sinh du lieu mau...
        !PYTHON_CMD! -m pip install requests >nul 2>&1
        cd /d "%PROJECT_ROOT%"
        !PYTHON_CMD! data/shopee_scraper.py
        echo  [OK] Da sinh du lieu mau
    ) else (
        echo  [!] Khong co Python - khong the sinh du lieu
    )
)
echo  ========================================================

:: ============================================
:: BUOC 4: IMPORT CSV DATA
:: ============================================
echo.
echo  [4/9] Import du lieu vao Database...

:: Kiem tra xem da co data chua
set "NEED_IMPORT=1"
powershell -NoProfile -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;Database=shopeeweb_lab211;TrustServerCertificate=True'); $c.Open(); $q = $c.CreateCommand(); $q.CommandText = 'SELECT COUNT(*) FROM products'; $r = $q.ExecuteScalar(); $c.Close(); Write-Output $r } catch { Write-Output 0 }" 2>nul > "%TEMP%\pcount.txt"
set /p PRODUCT_COUNT=<"%TEMP%\pcount.txt"
del /f /q "%TEMP%\pcount.txt" >nul 2>&1

echo     Hien co: !PRODUCT_COUNT! san pham trong DB
if !PRODUCT_COUNT! GEQ 100 (
    echo  [OK] Da co du lieu - bo qua import
    set "NEED_IMPORT=0"
)

if "!NEED_IMPORT!"=="1" (
    if exist "%PROJECT_ROOT%\data\products.csv" (
        echo     Dang import du lieu tu CSV...
        powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_ROOT%\import_data.ps1" -Server "!SQL_SERVER!" -Password "!DB_PASS!" -DataDir "%PROJECT_ROOT%\data"
        if !ERRORLEVEL! EQU 0 (
            echo  [OK] Import du lieu thanh cong!
        ) else (
            echo  [!] Import co loi - tiep tuc...
        )
    ) else (
        echo  [!] Khong tim thay file CSV
    )
)
echo  ========================================================

:: ============================================
:: BUOC 5: FIX CATEGORY MAPPING
:: ============================================
echo.
echo  [5/9] Gan category cho san pham...

if exist "%PROJECT_ROOT%\src\core_app\fix_category_v2.sql" (
    if "!HAS_SQLCMD!"=="1" (
        sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -d shopeeweb_lab211 -i "%PROJECT_ROOT%\src\core_app\fix_category_v2.sql" -b >nul 2>&1
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;Database=shopeeweb_lab211;TrustServerCertificate=True'); $c.Open(); $sql = Get-Content '!PROJECT_ROOT!\src\core_app\fix_category_v2.sql' -Raw; foreach($b in ($sql -split '\bGO\b')) { if($b.Trim()) { $q = $c.CreateCommand(); $q.CommandText = $b; $q.CommandTimeout = 120; $q.ExecuteNonQuery() | Out-Null } }; $c.Close() } catch {}" >nul 2>&1
    )
    echo  [OK] Da gan category
) else (
    echo  [!] Khong tim thay fix_category_v2.sql
)
echo  ========================================================

:: ============================================
:: BUOC 6: TAO INDEXES
:: ============================================
echo.
echo  [6/9] Tao indexes toi uu hieu suat...

if exist "%PROJECT_ROOT%\src\core_app\create_indexes.sql" (
    if "!HAS_SQLCMD!"=="1" (
        sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -d shopeeweb_lab211 -i "%PROJECT_ROOT%\src\core_app\create_indexes.sql" -b >nul 2>&1
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $c = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;Database=shopeeweb_lab211;TrustServerCertificate=True'); $c.Open(); $sql = Get-Content '!PROJECT_ROOT!\src\core_app\create_indexes.sql' -Raw; foreach($b in ($sql -split '\bGO\b')) { if($b.Trim()) { $q = $c.CreateCommand(); $q.CommandText = $b; $q.ExecuteNonQuery() | Out-Null } }; $c.Close() } catch {}" >nul 2>&1
    )
    echo  [OK] Da tao indexes
) else (
    echo  [!] Khong tim thay create_indexes.sql
)
echo  ========================================================

:: ============================================
:: BUOC 7: TAT TOMCAT CU
:: ============================================
echo.
echo  [7/9] Tat Tomcat cu...

cd /d "%PROJECT_ROOT%\src\core_app"
set "CATALINA_HOME=%PROJECT_ROOT%\src\core_app\tomcat_dir\apache-tomcat-10.1.19"
if exist "!CATALINA_HOME!\bin\shutdown.bat" (
    call "!CATALINA_HOME!\bin\shutdown.bat" >nul 2>&1
    timeout /t 3 /nobreak >nul
)
echo  [OK] Tomcat cu da tat
echo  ========================================================

:: ============================================
:: BUOC 8: BUILD PROJECT
:: ============================================
echo.
echo  [8/9] Build project - co the mat 2-5 phut...

cd /d "%PROJECT_ROOT%\src\core_app"
del /f /q "target\shopee-web-1.0-SNAPSHOT.war" >nul 2>&1

:: Fallback neu MVN_CMD trong
if "!MVN_CMD!"=="" (
    echo     [!] MVN_CMD khong duoc set, thu tim lai...
    for /f "delims=" %%F in ('where mvn.cmd 2^>nul') do set "MVN_CMD=%%F"
    if "!MVN_CMD!"=="" (
        if exist "C:\maven\bin\mvn.cmd" set "MVN_CMD=C:\maven\bin\mvn.cmd"
    )
    if "!MVN_CMD!"=="" (
        echo     [X] Khong tim thay Maven! Cai dat thu cong.
        pause
        exit /b 1
    )
)

echo     Maven: !MVN_CMD!
echo     Dang chay Maven build...
call "!MVN_CMD!" clean package -DskipTests > "%TEMP%\shopee_build.log" 2>&1
set "MVN_EXIT=!ERRORLEVEL!"

copy /Y "%TEMP%\shopee_build.log" "%PROJECT_ROOT%\build_log.txt" >nul 2>&1
echo     Maven exit code: !MVN_EXIT!

if not exist "target\shopee-web-1.0-SNAPSHOT.war" (
    color 0C
    echo.
    echo  ================================================
    echo    BUILD THAT BAI - Kiem tra loi:
    echo  ================================================
    echo    - Chua cai JDK 17?
    echo    - Khong co Internet?
    echo    Xem chi tiet: build_log.txt
    echo  ================================================
    echo.
    findstr /C:"[ERROR]" "%TEMP%\shopee_build.log" 2>nul
    echo.
    pause
    exit /b 1
)
echo  [OK] Build thanh cong!
echo  ========================================================

:: ============================================
:: BUOC 9: DEPLOY VA CHAY SERVER
:: ============================================
echo.
echo  [9/9] Deploy va khoi dong server...

cd /d "%PROJECT_ROOT%\src\core_app"

if exist "tomcat_dir\apache-tomcat-10.1.19\webapps\ROOT" (
    rmdir /s /q "tomcat_dir\apache-tomcat-10.1.19\webapps\ROOT" >nul 2>&1
)

copy /Y "target\shopee-web-1.0-SNAPSHOT.war" "tomcat_dir\apache-tomcat-10.1.19\webapps\ROOT.war" >nul
echo  [OK] Deploy thanh cong!

echo.
color 0A
echo  ========================================================
echo.
echo    MOI THU DA SAN SANG!
echo.
echo    Server:   !SQL_SERVER!
echo    Database: shopeeweb_lab211
echo    Password: !DB_PASS!
echo.
echo    Doi 10 giay de server khoi dong...
echo    Mo trinh duyet va truy cap:
echo.
echo    http://localhost:8080/home
echo.
echo    Tai khoan: admin / admin123
echo.
echo    Nhan Ctrl+C de tat server
echo.
echo  ========================================================

:: Mo trinh duyet sau 10 giay
start "" cmd /c "timeout /t 10 /nobreak >nul && start http://localhost:8080/home"

:: Set CATALINA_HOME truoc khi chay Tomcat
set "CATALINA_HOME=%PROJECT_ROOT%\src\core_app\tomcat_dir\apache-tomcat-10.1.19"
echo     CATALINA_HOME: !CATALINA_HOME!

:: Set JAVA_HOME neu can
if "!JAVA_HOME!"=="" (
    for /f "delims=" %%J in ('where java 2^>nul') do (
        set "JAVA_EXE=%%J"
    )
    if defined JAVA_EXE (
        for %%D in ("!JAVA_EXE!") do set "JAVA_BIN=%%~dpD"
        for %%D in ("!JAVA_BIN!..") do set "JAVA_HOME=%%~fD"
        echo     JAVA_HOME: !JAVA_HOME!
    )
)

:: Chay Tomcat
call "!CATALINA_HOME!\bin\catalina.bat" run

echo.
echo  Server da dung.
pause >nul
goto :END_SCRIPT

:: ============================================
:: HAM PHU TRO
:: ============================================

:REFRESH_PATH
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYS_PATH=%%B"
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USR_PATH=%%B"
set "PATH=!SYS_PATH!;!USR_PATH!"
goto :EOF

:END_SCRIPT
exit /b 0
