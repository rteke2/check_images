param([string]$Root = "P:\2\r18\output")

Write-Host "Scanning: $Root"
$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue
Write-Host "Total files found: $($files.Count)"

# 最初の10件表示
$files | Select-Object -First 10 | ForEach-Object {
    Write-Host $_.FullName
}
