$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
python tool/bootstrap_android.py
if ($LASTEXITCODE -ne 0) { throw 'Android bootstrap failed' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed' }
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) { throw 'Static analysis failed' }
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Tests failed' }
flutter build apk --debug
if ($LASTEXITCODE -ne 0) { throw 'APK build failed' }
Write-Host 'APK: build/app/outputs/flutter-apk/app-debug.apk'
