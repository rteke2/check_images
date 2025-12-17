param(
  [Parameter(Mandatory=$true)][string]$Root,
  [string]$OutList = "C:\Git\repos\check_images\fail_1.txt",
  [int]$TimeoutSec = 120
)

# 既存を消して新規作成
Remove-Item $OutList -ErrorAction SilentlyContinue
Write-Host "Output file: $OutList"
Write-Host "Scanning: $Root"

# 対象ファイル列挙（拡張子無視）
$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue
Write-Host "Total files: $($files.Count)"

$count = 0
$failCount = 0

foreach ($f in $files) {
  $count++
  $path = $f.FullName

  if ($count % 1000 -eq 0) {
    Write-Host "Processed: $count / $($files.Count), Failed: $failCount"
  }

  # magick を別プロセスで実行（ハング対策: timeout）
  $args = @($path, "-strip", "-write", "NUL:", "+delete")
  $p = Start-Process -FilePath "magick" -ArgumentList $args -NoNewWindow -PassThru

  if (-not $p.WaitForExit($TimeoutSec * 1000)) {
    try { $p.Kill() } catch {}
    Add-Content -LiteralPath $OutList -Value $path
    $failCount++
    continue
  }

  if ($p.ExitCode -ne 0) {
    Add-Content -LiteralPath $OutList -Value $path
    $failCount++
  }
}

Write-Host "DONE. Total: $count, Failed: $failCount"
Write-Host "Failed list: $OutList"
