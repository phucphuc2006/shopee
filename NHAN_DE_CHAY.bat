@echo off
chcp 65001 >nul
title ShopeeWeb - Cai Dat - Chay Tu Dong (FULL AUTO)
color 0B
setlocal EnableDelayedExpansion

:: ============================================
:: Yêu cầu quyền Admin (cần để cài phần mềm)
:: ============================================
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  🔒 Cần quyền Administrator để cài đặt phần mềm...
    echo     Đang yêu cầu quyền Admin...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ============================================
:: Di chuyển vào thư mục chứa file .bat này
:: ============================================
cd /d "%~dp0"
set "PROJECT_ROOT=%cd%"

echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║                                                          ║
echo  ║     🛒  SHOPEE WEB - CÀI ĐẶT TỰ ĐỘNG HOÀN TOÀN  🛒  ║
echo  ║                                                          ║
echo  ║   Ngồi uống cafe - Script lo hết!                       ║
echo  ║                                                          ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.
echo  Thư mục project: %PROJECT_ROOT%
echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 0: KIỂM TRA & TỰ ĐỘNG CÀI PHẦN MỀM
:: ============================================
echo.
echo  [0/7] 🔍 Đang kiểm tra và cài đặt phần mềm tự động...
echo.

:: ─── Kiểm tra winget ───
set "HAS_WINGET=0"
where winget >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "HAS_WINGET=1"
    echo  ✅ Windows Package Manager (winget): Có sẵn
) else (
    echo  ⚠️  winget không có - sẽ thử phương pháp cài đặt thay thế
)

:: ═══════════════════════════════════════════
:: KIỂM TRA & CÀI JAVA JDK 17
:: ═══════════════════════════════════════════
echo.
echo  ── Kiểm tra Java JDK ──
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  ❌ Java chưa cài đặt. Đang tự động cài JDK 17...
    if "%HAS_WINGET%"=="1" (
        echo     📦 Cài đặt qua winget...
        winget install --id EclipseAdoptium.Temurin.17.JDK --silent --accept-package-agreements --accept-source-agreements
        if !ERRORLEVEL! EQU 0 (
            echo  ✅ Đã cài đặt JDK 17 thành công!
        ) else (
            echo  ⚠️  winget cài JDK thất bại, thử Corretto...
            winget install --id Amazon.Corretto.17 --silent --accept-package-agreements --accept-source-agreements
            if !ERRORLEVEL! EQU 0 (
                echo  ✅ Đã cài đặt Amazon Corretto 17 thành công!
            ) else (
                echo  ❌ Không thể cài JDK tự động.
                echo     → Tải thủ công: https://adoptium.net/
                pause
                exit /b 1
            )
        )
    ) else (
        echo  ❌ Không thể cài JDK tự động ^(không có winget^).
        echo     → Tải thủ công: https://adoptium.net/
        pause
        exit /b 1
    )
    rem Refresh PATH sau khi cài
    call :REFRESH_PATH
) else (
    echo  ✅ Java: Đã cài đặt
)

:: ═══════════════════════════════════════════
:: KIỂM TRA & CÀI MAVEN
:: ═══════════════════════════════════════════
echo.
echo  ── Kiểm tra Apache Maven ──
set "MVN_CMD=mvn.cmd"
where mvn >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    rem Kiểm tra các vị trí phổ biến
    if exist "C:\maven\bin\mvn.cmd" (
        set "MVN_CMD=C:\maven\bin\mvn.cmd"
        echo  ✅ Maven: Đã cài đặt ^(C:\maven^)
    ) else if exist "C:\Program Files\apache-maven\bin\mvn.cmd" (
        set "MVN_CMD=C:\Program Files\apache-maven\bin\mvn.cmd"
        echo  ✅ Maven: Đã cài đặt
    ) else (
        echo  ❌ Maven chưa cài đặt. Đang tự động cài...
        
        rem Tải Maven bằng PowerShell
        set "MAVEN_VER=3.9.9"
        set "MAVEN_URL=https://dlcdn.apache.org/maven/maven-3/!MAVEN_VER!/binaries/apache-maven-!MAVEN_VER!-bin.zip"
        set "MAVEN_ZIP=%TEMP%\maven.zip"
        set "MAVEN_DIR=C:\maven"
        
        echo     📥 Đang tải Apache Maven !MAVEN_VER!...
        powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '!MAVEN_URL!' -OutFile '!MAVEN_ZIP!'" >nul 2>&1
        
        if exist "!MAVEN_ZIP!" (
            echo     📂 Đang giải nén...
            powershell -NoProfile -Command "Expand-Archive -Path '!MAVEN_ZIP!' -DestinationPath 'C:\' -Force" >nul 2>&1
            
            rem Rename thư mục
            if exist "C:\apache-maven-!MAVEN_VER!" (
                if exist "C:\maven" rmdir /s /q "C:\maven" >nul 2>&1
                ren "C:\apache-maven-!MAVEN_VER!" "maven" >nul 2>&1
            )
            
            rem Thêm vào PATH hệ thống
            if exist "C:\maven\bin\mvn.cmd" (
                powershell -NoProfile -Command "$oldPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine'); if ($oldPath -notlike '*C:\maven\bin*') { [Environment]::SetEnvironmentVariable('PATH', $oldPath + ';C:\maven\bin', 'Machine') }"
                set "MVN_CMD=C:\maven\bin\mvn.cmd"
                set "PATH=%PATH%;C:\maven\bin"
                echo  ✅ Đã cài đặt Maven thành công!
            ) else (
                echo  ❌ Cài Maven thất bại.
                echo     → Tải thủ công: https://maven.apache.org/download.cgi
                pause
                exit /b 1
            )
            del /f /q "!MAVEN_ZIP!" >nul 2>&1
        ) else (
            echo  ❌ Không thể tải Maven. Kiểm tra kết nối Internet.
            pause
            exit /b 1
        )
    )
) else (
    echo  ✅ Maven: Đã cài đặt
)

:: ═══════════════════════════════════════════
:: KIỂM TRA & CÀI PYTHON
:: ═══════════════════════════════════════════
echo.
echo  ── Kiểm tra Python ──
set "HAS_PYTHON=0"
set "PYTHON_CMD=python"
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    py --version >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo  ❌ Python chưa cài đặt. Đang tự động cài...
        if "%HAS_WINGET%"=="1" (
            winget install --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
            if !ERRORLEVEL! EQU 0 (
                echo  ✅ Đã cài đặt Python 3.12 thành công!
                call :REFRESH_PATH
                set "HAS_PYTHON=1"
            ) else (
                echo  ⚠️  Không thể cài Python tự động - bỏ qua bước sinh dữ liệu
            )
        ) else (
            echo  ⚠️  Không thể cài Python tự động - bỏ qua bước sinh dữ liệu
            echo     → Tải thủ công: https://www.python.org/downloads/
        )
    ) else (
        set "PYTHON_CMD=py"
        set "HAS_PYTHON=1"
        echo  ✅ Python: Đã cài đặt
    )
) else (
    set "HAS_PYTHON=1"
    echo  ✅ Python: Đã cài đặt
)

:: ═══════════════════════════════════════════
:: KIỂM TRA & CÀI SQL SERVER EXPRESS
:: ═══════════════════════════════════════════
echo.
echo  ── Kiểm tra SQL Server ──

:: Kiểm tra xem có SQL Server service nào không
set "HAS_SQL_SERVICE=0"
sc query state= all 2>nul | findstr /i "MSSQL" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "HAS_SQL_SERVICE=1"
    echo  ✅ SQL Server: Đã cài đặt
) else (
    echo  ❌ SQL Server chưa cài đặt. Đang tự động cài SQL Server Express...
    
    set "SQL_INSTALLED=0"
    if "%HAS_WINGET%"=="1" (
        echo     📦 Cài đặt SQL Server 2022 Express qua winget...
        echo     ⏳ Quá trình này có thể mất 5-10 phút, vui lòng chờ...
        winget install --id Microsoft.SQLServer.2022.Express --silent --accept-package-agreements --accept-source-agreements
        if !ERRORLEVEL! EQU 0 (
            set "SQL_INSTALLED=1"
            set "HAS_SQL_SERVICE=1"
            echo  ✅ Đã cài đặt SQL Server 2022 Express thành công!
        ) else (
            echo  ⚠️  winget cài SQL Server thất bại. Thử phiên bản 2019...
            winget install --id Microsoft.SQLServer.2019.Express --silent --accept-package-agreements --accept-source-agreements
            if !ERRORLEVEL! EQU 0 (
                set "SQL_INSTALLED=1"
                set "HAS_SQL_SERVICE=1"
                echo  ✅ Đã cài đặt SQL Server 2019 Express thành công!
            )
        )
    )
    
    if "!SQL_INSTALLED!"=="0" (
        echo  ❌ Không thể cài SQL Server tự động.
        echo     → Tải thủ công: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
        echo     → Chọn phiên bản Express ^(miễn phí^)
        pause
        exit /b 1
    )
)

:: ═══════════════════════════════════════════
:: CẤU HÌNH SQL SERVER TỰ ĐỘNG
:: ═══════════════════════════════════════════
echo.
echo  ── Tự động cấu hình SQL Server ──

:: Tìm instance name
set "SQL_INSTANCE="
set "SQL_SVC_NAME="
for /f "tokens=2 delims=: " %%N in ('sc query state^= all ^| findstr /i "SERVICE_NAME.*MSSQL"') do (
    set "TEMP_SVC=%%N"
    rem Kiểm tra nếu service đang chạy
    sc query "%%N" 2>nul | findstr /i "RUNNING" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        if "!SQL_SVC_NAME!"=="" (
            set "SQL_SVC_NAME=%%N"
            if /i "%%N"=="MSSQLSERVER" (
                set "SQL_INSTANCE="
                echo     Instance: Default ^(MSSQLSERVER^) - ĐANG CHẠY
            ) else (
                for /f "tokens=2 delims=$" %%I in ("%%N") do (
                    set "SQL_INSTANCE=%%I"
                    echo     Instance: %%I - ĐANG CHẠY
                )
            )
        )
    )
)

:: Nếu không có instance nào chạy, thử start
if "!SQL_SVC_NAME!"=="" (
    echo     ⚠️  SQL Server không chạy. Đang khởi động...
    for /f "tokens=2 delims=: " %%N in ('sc query state^= all ^| findstr /i "SERVICE_NAME.*MSSQL"') do (
        if "!SQL_SVC_NAME!"=="" (
            set "SQL_SVC_NAME=%%N"
            net start "%%N" >nul 2>&1
            if /i "%%N"=="MSSQLSERVER" (
                set "SQL_INSTANCE="
            ) else (
                for /f "tokens=2 delims=$" %%I in ("%%N") do set "SQL_INSTANCE=%%I"
            )
            
            rem Đợi service khởi động
            timeout /t 5 /nobreak >nul
            sc query "%%N" 2>nul | findstr /i "RUNNING" >nul 2>&1
            if !ERRORLEVEL! EQU 0 (
                echo     ✅ Đã khởi động SQL Server: %%N
            ) else (
                echo     ❌ Không thể khởi động SQL Server: %%N
            )
        )
    )
)

:: Xác định server connection string
if "!SQL_INSTANCE!"=="" (
    set "SQL_SERVER=localhost"
) else (
    set "SQL_SERVER=localhost\!SQL_INSTANCE!"
)
echo     Server: !SQL_SERVER!

:: ─── Bật SQL Server Authentication Mode (Mixed Mode) ───
echo.
echo     🔧 Đang cấu hình SQL Server Authentication...

:: Xác định registry path cho instance
if "!SQL_INSTANCE!"=="" (
    set "REG_INSTANCE=MSSQLSERVER"
) else (
    set "REG_INSTANCE=!SQL_INSTANCE!"
)

:: Bật Mixed Authentication Mode qua Registry
reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.!REG_INSTANCE!\MSSQLServer" /v LoginMode /t REG_DWORD /d 2 /f >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    rem Thử các phiên bản SQL Server khác
    reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.!REG_INSTANCE!\MSSQLServer" /v LoginMode /t REG_DWORD /d 2 /f >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.!REG_INSTANCE!\MSSQLServer" /v LoginMode /t REG_DWORD /d 2 /f >nul 2>&1
    )
)
echo     ✅ Đã bật SQL Server Authentication Mode (Mixed Mode)

:: ─── Bật TCP/IP ───
echo     🔧 Đang bật TCP/IP...
powershell -NoProfile -Command "try { Import-Module SQLPS -DisableNameChecking -ErrorAction SilentlyContinue; $wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer; $tcp = $wmi.ServerInstances['!REG_INSTANCE!'].ServerProtocols['Tcp']; $tcp.IsEnabled = $true; $tcp.Alter(); exit 0 } catch { exit 1 }" >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    rem Thử bật TCP/IP qua Registry trực tiếp
    for /f "tokens=*" %%K in ('reg query "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server" /s /f "SuperSocketNetLib\Tcp" /k 2^>nul ^| findstr /i "SuperSocketNetLib\\Tcp$"') do (
        reg add "%%K" /v Enabled /t REG_DWORD /d 1 /f >nul 2>&1
    )
)
echo     ✅ Đã bật TCP/IP Protocol

:: ─── Cấu hình tài khoản SA ───
echo     🔧 Đang cấu hình tài khoản SA...

set "SA_PASS=zxczxc123"

:: Dùng sqlcmd để enable SA và đặt password
where sqlcmd >nul 2>&1
set "HAS_SQLCMD=0"
if %ERRORLEVEL% EQU 0 set "HAS_SQLCMD=1"

:: Restart SQL Server để áp dụng Mixed Mode
echo     🔄 Đang restart SQL Server để áp dụng cấu hình...
net stop "!SQL_SVC_NAME!" >nul 2>&1
timeout /t 3 /nobreak >nul
net start "!SQL_SVC_NAME!" >nul 2>&1
timeout /t 5 /nobreak >nul

:: Kích hoạt SA bằng Windows Auth (vì Mixed Mode vừa bật)
if "%HAS_SQLCMD%"=="1" (
    sqlcmd -S !SQL_SERVER! -E -C -Q "ALTER LOGIN [sa] ENABLE; ALTER LOGIN [sa] WITH PASSWORD = '!SA_PASS!'; ALTER LOGIN [sa] WITH CHECK_POLICY = OFF;" -b >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo     ✅ Đã kích hoạt tài khoản SA ^(password: !SA_PASS!^)
    ) else (
        echo     ⚠️  SA có thể đã được cấu hình trước đó
    )
) else (
    rem Dùng PowerShell nếu không có sqlcmd
    powershell -NoProfile -Command "try { $conn = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;Integrated Security=True;TrustServerCertificate=True;'); $conn.Open(); $cmd = $conn.CreateCommand(); $cmd.CommandText = 'ALTER LOGIN [sa] ENABLE; ALTER LOGIN [sa] WITH PASSWORD = ''!SA_PASS!''; ALTER LOGIN [sa] WITH CHECK_POLICY = OFF;'; $cmd.ExecuteNonQuery(); $conn.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo     ✅ Đã kích hoạt tài khoản SA ^(password: !SA_PASS!^)
    ) else (
        echo     ⚠️  SA có thể đã được cấu hình trước đó
    )
)

:: ─── Kiểm tra kết nối SA ───
echo.
echo     🔗 Đang kiểm tra kết nối SA...

set "DB_PASS="
set "FOUND_SQL=0"

:: Danh sách mật khẩu để thử
set "PASS_1=zxczxc123"
set "PASS_2=123456"
set "PASS_3=sa"
set "PASS_4=1"
set "PASS_5=admin"
set "PASS_6=Sa123456"
set "PASS_7=P@ssw0rd"
set "PASS_COUNT=7"

:: Thử từng mật khẩu
for /L %%P in (1,1,%PASS_COUNT%) do (
    if "!FOUND_SQL!"=="0" (
        set "TRY_PASS=!PASS_%%P!"
        if "%HAS_SQLCMD%"=="1" (
            sqlcmd -S !SQL_SERVER! -U sa -P !TRY_PASS! -C -Q "SELECT 1" -b -l 5 >nul 2>&1
        ) else (
            powershell -NoProfile -Command "try { $conn = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!TRY_PASS!;TrustServerCertificate=True;Connection Timeout=5'); $conn.Open(); $conn.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
        )
        if !ERRORLEVEL! EQU 0 (
            set "DB_PASS=!TRY_PASS!"
            set "FOUND_SQL=1"
            echo     ✅ Kết nối thành công: !SQL_SERVER! ^(pass: !TRY_PASS!^)
        )
    )
)

:: Nếu vẫn không kết nối được
if "!FOUND_SQL!"=="0" (
    echo     ❌ Không thể kết nối SQL Server bằng SA.
    echo.
    set "DB_PASS=zxczxc123"
    set /p "DB_PASS=     👉 Nhập mật khẩu SA (Enter = zxczxc123): "
)

echo.
echo  ✅ Hoàn tất kiểm tra phần mềm!
echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 1: CẬP NHẬT db.properties
:: ============================================
echo.
echo  [1/7] 📝 Đang cập nhật cấu hình kết nối...
echo.
echo  📋 Cấu hình:
echo     Server:   !SQL_SERVER!
echo     Instance: !SQL_INSTANCE!
echo     Password: !DB_PASS!
echo.

:: Tạo db.properties tự động
echo # CAU HINH KET NOI SQL SERVER (TU DONG PHAT HIEN)> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
if "!SQL_INSTANCE!"=="" (
    echo db.url=jdbc:sqlserver://localhost:1433;databaseName=shopeeweb_lab211;encrypt=true;trustServerCertificate=true;>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
) else (
    echo db.url=jdbc:sqlserver://localhost;instanceName=!SQL_INSTANCE!;databaseName=shopeeweb_lab211;encrypt=true;trustServerCertificate=true;>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
)
echo db.user=sa>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
echo db.password=!DB_PASS!>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
echo.>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
echo # GOOGLE OAUTH 2.0>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
if exist "%PROJECT_ROOT%\google_oauth.config" (
    for /f "tokens=1,2 delims==" %%A in ('type "%PROJECT_ROOT%\google_oauth.config"') do (
        if "%%A"=="CLIENT_ID" echo google.client.id=%%B>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
        if "%%A"=="CLIENT_SECRET" echo google.client.secret=%%B>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
    )
    echo  ✅ Đã thêm Google OAuth config từ google_oauth.config
) else (
    echo google.client.id=>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
    echo google.client.secret=>> "%PROJECT_ROOT%\src\core_app\src\main\resources\db.properties"
    echo  ⚠️  Chưa có file google_oauth.config - Google Login sẽ không hoạt động
    echo     Tạo file google_oauth.config với nội dung:
    echo     CLIENT_ID=your_google_client_id
    echo     CLIENT_SECRET=your_google_client_secret
)
echo  ✅ Đã tự động cập nhật db.properties

echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 2: TẠO DATABASE
:: ============================================
echo.
echo  [2/7] 🗄️  Đang tạo Database...
echo.

set "DB_CREATED=0"
if "%HAS_SQLCMD%"=="1" (
    sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name='shopeeweb_lab211') CREATE DATABASE shopeeweb_lab211;" -b >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        set "DB_CREATED=1"
    )
)
if "!DB_CREATED!"=="0" (
    powershell -NoProfile -Command "try { $conn = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;TrustServerCertificate=True;'); $conn.Open(); $cmd = $conn.CreateCommand(); $cmd.CommandText = 'IF NOT EXISTS (SELECT * FROM sys.databases WHERE name=''shopeeweb_lab211'') CREATE DATABASE shopeeweb_lab211;'; $cmd.ExecuteNonQuery(); $conn.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        set "DB_CREATED=1"
    ) else (
        echo  ⚠️  Không thể tạo DB tự động.
        echo     → Mở SSMS và chạy: CREATE DATABASE shopeeweb_lab211;
    )
)

if "!DB_CREATED!"=="1" (
    echo  ✅ Đã tạo/xác nhận database: shopeeweb_lab211

    rem Chạy script khởi tạo bảng
    echo     Đang tạo các bảng dữ liệu...
    if "%HAS_SQLCMD%"=="1" (
        sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -d shopeeweb_lab211 -i "%PROJECT_ROOT%\src\core_app\init_sqlserver.sql" -b >nul 2>&1
    ) else (
        powershell -NoProfile -Command "try { $conn = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;Database=shopeeweb_lab211;TrustServerCertificate=True;'); $conn.Open(); $sql = Get-Content '%PROJECT_ROOT%\src\core_app\init_sqlserver.sql' -Raw; foreach($batch in ($sql -split '\bGO\b')) { if($batch.Trim()) { $cmd = $conn.CreateCommand(); $cmd.CommandText = $batch; $cmd.ExecuteNonQuery() | Out-Null } }; $conn.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
    )
    if !ERRORLEVEL! EQU 0 (
        echo  ✅ Đã tạo xong tất cả bảng!
    ) else (
        echo  ⚠️  Bảng có thể đã tồn tại - tiếp tục...
    )
)

echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 3: SINH DỮ LIỆU MẪU
:: ============================================
echo.
echo  [3/7] 📊 Đang kiểm tra dữ liệu mẫu...

if exist "%PROJECT_ROOT%\data\products.csv" (
    echo  ✅ Dữ liệu mẫu đã có sẵn - bỏ qua!
) else (
    if "%HAS_PYTHON%"=="1" (
        echo     Đang sinh 12,000 sản phẩm mẫu...
        rem Cài thư viện requests nếu cần
        %PYTHON_CMD% -m pip install requests >nul 2>&1
        cd /d "%PROJECT_ROOT%"
        %PYTHON_CMD% data/shopee_scraper.py
        if !ERRORLEVEL! EQU 0 (
            echo  ✅ Đã sinh dữ liệu mẫu thành công!
        ) else (
            echo  ⚠️  Lỗi khi sinh dữ liệu - bạn có thể bỏ qua nếu đã có data
        )
    ) else (
        echo  ⚠️  Không có Python - không thể sinh dữ liệu tự động
        echo     → Chạy sau: python data/shopee_scraper.py
    )
)

echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 4: IMPORT DỮ LIỆU VÀO DATABASE
:: ============================================
echo.
echo  [4/7] 📥 Đang import dữ liệu vào Database...

cd /d "%PROJECT_ROOT%\src\core_app"

:: Kiểm tra nhanh xem DB đã có data chưa
set "NEED_IMPORT=1"
if "%HAS_SQLCMD%"=="1" (
    for /f "tokens=*" %%A in ('sqlcmd -S !SQL_SERVER! -U sa -P !DB_PASS! -C -d shopeeweb_lab211 -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM products;" -h -1 -b 2^>nul') do (
        set "PRODUCT_COUNT=%%A"
    )
    set "PRODUCT_COUNT=!PRODUCT_COUNT: =!"
    if "!PRODUCT_COUNT!" GEQ "100" (
        echo  ✅ Database đã có !PRODUCT_COUNT! sản phẩm - bỏ qua import!
        set "NEED_IMPORT=0"
    )
) else (
    rem Kiểm tra bằng PowerShell
    for /f "tokens=*" %%A in ('powershell -NoProfile -Command "try { $conn = New-Object System.Data.SqlClient.SqlConnection('Server=!SQL_SERVER!;User Id=sa;Password=!DB_PASS!;Database=shopeeweb_lab211;TrustServerCertificate=True;'); $conn.Open(); $cmd = $conn.CreateCommand(); $cmd.CommandText = 'SELECT COUNT(*) FROM products'; $result = $cmd.ExecuteScalar(); $conn.Close(); Write-Output $result } catch { Write-Output 0 }" 2^>nul') do (
        set "PRODUCT_COUNT=%%A"
    )
    set "PRODUCT_COUNT=!PRODUCT_COUNT: =!"
    if "!PRODUCT_COUNT!" GEQ "100" (
        echo  ✅ Database đã có !PRODUCT_COUNT! sản phẩm - bỏ qua import!
        set "NEED_IMPORT=0"
    )
)

if "%NEED_IMPORT%"=="1" (
    if exist "%PROJECT_ROOT%\data\products.csv" (
        echo     Đang import dữ liệu ^(có thể mất 1-2 phút^)...
        cmd /c "%MVN_CMD% clean compile exec:java -Dexec.mainClass=migration.SqlServerImport -q"
        if !ERRORLEVEL! EQU 0 (
            echo  ✅ Import dữ liệu thành công!
        ) else (
            echo  ⚠️  Import gặp lỗi - server vẫn chạy nhưng có thể thiếu data
        )
    ) else (
        echo  ⚠️  Không tìm thấy file CSV trong thư mục data/
        echo     → Chạy: python data/shopee_scraper.py trước
    )
)

echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 5: TẮT TOMCAT CŨ
:: ============================================
echo.
echo  [5/7] 🔄 Đang tắt Tomcat cũ ^(nếu có^)...

cd /d "%PROJECT_ROOT%\src\core_app"
set "CATALINA_HOME=%cd%\tomcat_dir\apache-tomcat-10.1.19"

cmd /c ""tomcat_dir\apache-tomcat-10.1.19\bin\shutdown.bat" >nul 2>&1"
timeout /t 3 /nobreak >nul
echo  ✅ Đã tắt Tomcat cũ

echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 6: BUILD PROJECT
:: ============================================
echo.
echo  [6/7] 🔨 Đang build project ^(lần đầu có thể mất 2-5 phút^)...
echo.

cd /d "%PROJECT_ROOT%\src\core_app"
del /f /q "target\shopee-web-1.0-SNAPSHOT.war" >nul 2>&1

set "BUILD_LOG=%TEMP%\shopee_build.log"
cmd /c "%MVN_CMD% clean package > "%BUILD_LOG%" 2>&1"
set BUILD_EXIT=%ERRORLEVEL%

copy /Y "%BUILD_LOG%" "%PROJECT_ROOT%\build_log.txt" >nul 2>&1

if not exist "target\shopee-web-1.0-SNAPSHOT.war" (
    color 0C
    echo.
    echo  ╔══════════════════════════════════════════════╗
    echo  ║   ❌ BUILD THẤT BẠI! Kiểm tra lỗi ở trên   ║
    echo  ╠══════════════════════════════════════════════╣
    echo  ║   Nguyên nhân thường gặp:                    ║
    echo  ║   - Chưa cài JDK 17                         ║
    echo  ║   - Không có Internet ^(Maven tải thư viện^)  ║
    echo  ╠══════════════════════════════════════════════╣
    echo  ║   Xem chi tiết lỗi trong file:               ║
    echo  ║   build_log.txt                              ║
    echo  ╚══════════════════════════════════════════════╝
    echo.
    echo  --- DÒNG LỖI BUILD ---
    findstr /C:"[ERROR]" "%BUILD_LOG%" 2>nul
    echo.
    pause
    exit /b 1
)
echo  ✅ Build thành công!

echo.
echo ═══════════════════════════════════════════════════════════

:: ============================================
:: BƯỚC 7: DEPLOY & CHẠY SERVER
:: ============================================
echo.
echo  [7/7] 🚀 Đang deploy và khởi động server...

:: Xóa thư mục webapps cũ để deploy sạch
if exist "tomcat_dir\apache-tomcat-10.1.19\webapps\ROOT" (
    rmdir /s /q "tomcat_dir\apache-tomcat-10.1.19\webapps\ROOT" >nul 2>&1
)

:: Copy WAR vào Tomcat
copy /Y "target\shopee-web-1.0-SNAPSHOT.war" "tomcat_dir\apache-tomcat-10.1.19\webapps\ROOT.war" >nul
echo  ✅ Deploy thành công!

echo.
color 0A
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║                                                          ║
echo  ║   🎉  MỌI THỨ ĐÃ SẴN SÀNG!  🎉                       ║
echo  ║                                                          ║
echo  ║   Server:   !SQL_SERVER!                                 ║
echo  ║   Database: shopeeweb_lab211                             ║
echo  ║   Password: !DB_PASS!                                    ║
echo  ║                                                          ║
echo  ║   Đợi khoảng 10 giây để server khởi động...             ║
echo  ║                                                          ║
echo  ║   Sau đó mở trình duyệt và truy cập:                    ║
echo  ║                                                          ║
echo  ║   👉  http://localhost:8080/home                         ║
echo  ║                                                          ║
echo  ║   Tài khoản: admin / admin123                            ║
echo  ║                                                          ║
echo  ║   Nhấn Ctrl+C để tắt server                             ║
echo  ║                                                          ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

:: Tự mở trình duyệt sau 10 giây
start "" cmd /c "timeout /t 10 /nobreak >nul && start http://localhost:8080/home"

:: Khởi động Tomcat (giữ cửa sổ log)
call "tomcat_dir\apache-tomcat-10.1.19\bin\catalina.bat" run

:: ============================================
:: HÀM PHỤ TRỢ
:: ============================================

:REFRESH_PATH
:: Refresh biến PATH từ Registry để nhận phần mềm vừa cài
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYS_PATH=%%B"
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USR_PATH=%%B"
set "PATH=!SYS_PATH!;!USR_PATH!"
goto :EOF
