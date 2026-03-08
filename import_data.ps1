# ============================================
# ShopeeWeb - Import CSV Data to SQL Server
# ============================================
param(
    [string]$Server,
    [string]$Password,
    [string]$DataDir
)

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "  === IMPORT DATA FROM CSV ===" -ForegroundColor Cyan
Write-Host "  Server:  $Server"
Write-Host "  DataDir: $DataDir"
Write-Host ""

try {
    $connStr = "Server=$Server;User Id=sa;Password=$Password;Database=shopeeweb_lab211;TrustServerCertificate=True;"
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Host "  [OK] Connected to DB!" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Cannot connect to DB: $_" -ForegroundColor Red
    exit 1
}

# --- 1. Import Shops ---
$shopsFile = Join-Path $DataDir 'shops.csv'
if (Test-Path $shopsFile) {
    Write-Host "  Importing shops..." -NoNewline
    $shops = Import-Csv $shopsFile
    $shopCount = 0
    foreach ($s in $shops) {
        try {
            $cmd = $conn.CreateCommand()
            $shopName = $s.shop_name -replace "'","''"
            $cmd.CommandText = "SET IDENTITY_INSERT shops ON; IF NOT EXISTS (SELECT 1 FROM shops WHERE id=$($s.id)) INSERT INTO shops (id, owner_id, shop_name, rating) VALUES ($($s.id), 1, N'$shopName', $($s.rating)); SET IDENTITY_INSERT shops OFF;"
            $cmd.ExecuteNonQuery() | Out-Null
            $shopCount++
        } catch {}
    }
    Write-Host " $shopCount shops [OK]" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] shops.csv not found" -ForegroundColor Yellow
}

# --- 2. Import Products ---
$productsFile = Join-Path $DataDir 'products.csv'
if (Test-Path $productsFile) {
    Write-Host "  Importing products..."

    $reader = [System.IO.StreamReader]::new($productsFile, [System.Text.Encoding]::UTF8)
    $header = $reader.ReadLine()
    $prodCount = 0
    $errorCount = 0

    $cmdOn = $conn.CreateCommand()
    $cmdOn.CommandText = 'SET IDENTITY_INSERT products ON'
    $cmdOn.ExecuteNonQuery() | Out-Null

    while ($null -ne ($line = $reader.ReadLine())) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        $parts = $line -split ',', 6
        if ($parts.Count -ge 6) {
            try {
                $cmd2 = $conn.CreateCommand()
                $pname = $parts[2] -replace "'","''"
                $pdesc = $parts[3] -replace "'","''"
                $pimg = $parts[5] -replace "'","''"
                $cmd2.CommandText = "IF NOT EXISTS (SELECT 1 FROM products WHERE id=$($parts[0])) INSERT INTO products (id,shop_id,name,description,price,image_url) VALUES ($($parts[0]),$($parts[1]),N'$pname',N'$pdesc',$($parts[4]),'$pimg')"
                $cmd2.ExecuteNonQuery() | Out-Null
                $prodCount++

                if ($prodCount % 2000 -eq 0) {
                    Write-Host "     -> $prodCount products..."
                }
            } catch {
                $errorCount++
            }
        }
    }
    $reader.Close()

    $cmdOff = $conn.CreateCommand()
    $cmdOff.CommandText = 'SET IDENTITY_INSERT products OFF'
    $cmdOff.ExecuteNonQuery() | Out-Null

    Write-Host "  [OK] Imported $prodCount products (errors: $errorCount)" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] products.csv not found" -ForegroundColor Yellow
}

# --- 3. Import Product Variants ---
$variantsFile = Join-Path $DataDir 'product_variants.csv'
if (Test-Path $variantsFile) {
    Write-Host "  Importing product_variants..."

    $reader2 = [System.IO.StreamReader]::new($variantsFile, [System.Text.Encoding]::UTF8)
    $header2 = $reader2.ReadLine()
    $varCount = 0
    $errorCount2 = 0

    $cmdOn2 = $conn.CreateCommand()
    $cmdOn2.CommandText = 'SET IDENTITY_INSERT product_variants ON'
    $cmdOn2.ExecuteNonQuery() | Out-Null

    while ($null -ne ($line2 = $reader2.ReadLine())) {
        if ([string]::IsNullOrWhiteSpace($line2)) { continue }

        $p2 = $line2 -split ',', 7
        if ($p2.Count -ge 6) {
            try {
                $cmd3 = $conn.CreateCommand()
                $stock = [Math]::Max(0, [int]$p2[4])
                $price = [double]$p2[5]
                if ($price -le 0) { $price = 50000 }
                $note = ''
                if ($p2.Count -ge 7) { $note = $p2[6] -replace "'","''" }
                $cmd3.CommandText = "IF NOT EXISTS (SELECT 1 FROM product_variants WHERE id=$($p2[0])) INSERT INTO product_variants (id,product_id,color,size,stock,price,note) VALUES ($($p2[0]),$($p2[1]),N'$($p2[2])',N'$($p2[3])',$stock,$price,N'$note')"
                $cmd3.ExecuteNonQuery() | Out-Null
                $varCount++

                if ($varCount % 5000 -eq 0) {
                    Write-Host "     -> $varCount variants..."
                }
            } catch {
                $errorCount2++
            }
        }
    }
    $reader2.Close()

    $cmdOff2 = $conn.CreateCommand()
    $cmdOff2.CommandText = 'SET IDENTITY_INSERT product_variants OFF'
    $cmdOff2.ExecuteNonQuery() | Out-Null

    Write-Host "  [OK] Imported $varCount variants (errors: $errorCount2)" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] product_variants.csv not found" -ForegroundColor Yellow
}

# --- Done ---
$conn.Close()
Write-Host ""
Write-Host "  === IMPORT COMPLETE ===" -ForegroundColor Green
Write-Host ""
exit 0
