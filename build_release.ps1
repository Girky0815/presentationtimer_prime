# --- 色付け用の便利関数 ---
function Log-Info ($message) {
    # 作業中: 水色 (Cyan)
    Write-Host "➜ $message" -ForegroundColor Cyan
}

function Log-Success ($message) {
    # 完了: 緑
    Write-Host "✔ $message" -ForegroundColor Green
}

function Log-Error ($message) {
    # エラー: 赤
    Write-Host "✖ $message" -ForegroundColor Red
}
# ------------------------

# 1. pubspec.yaml からバージョン番号を取得
Log-Info "pubspec.yaml からバージョンを確認中..."
$pubspecContent = Get-Content pubspec.yaml
$versionLine = $pubspecContent | Select-String "version:"

if ($versionLine -match "version:\s+(\d+\.\d+\.\d+)") {
    $version = $matches[1]
    Log-Success "バージョン $version を検出しました"
} else {
    Log-Error "pubspec.yaml にバージョンが見つかりませんでした"
    exit 1
}

# 2. 変数の設定
$appName = "presentationtimerPrime"
$zipName = "${appName}_v${version}_windowsx64.zip"
$buildPath = "build\windows\x64\runner\Release"
$tempFolder = "build\windows\x64\runner\$appName"

# 3. Flutter ビルド実行
Log-Info "Windowsアプリ(.exe)をビルドしています... (時間がかかります)"
flutter build windows

if ($LASTEXITCODE -ne 0) {
    Log-Error "ビルドに失敗しました。エラー内容を確認してください。"
    exit 1
}
Log-Success "ビルド完了！"

# 4. 配布用フォルダの整理
Log-Info "配布用フォルダを作成し、ファイルをコピー中..."
if (Test-Path $tempFolder) { Remove-Item $tempFolder -Recurse -Force }
New-Item -ItemType Directory -Path $tempFolder | Out-Null
Copy-Item -Path "$buildPath\*" -Destination $tempFolder -Recurse

# 5. 圧縮処理
if (Test-Path $zipName) { Remove-Item $zipName }
Log-Info "$zipName に圧縮中..."
Compress-Archive -Path $tempFolder -DestinationPath $zipName

# 6. 後始末
Remove-Item $tempFolder -Recurse -Force

Log-Success "すべての作業が完了しました！"
Log-Success "生成ファイル: $PWD\$zipName"