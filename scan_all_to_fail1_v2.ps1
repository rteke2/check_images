param(
  [Parameter(Mandatory=$true)][string]$Root,
  [string]$OutList = "C:\Git\repos\check_images\fail_1.txt",
  [int]$TimeoutSec = 120
)

# 既存を消して新規作成
Remove-Item $OutList -ErrorAction SilentlyContinue
Write-Host "Output file: $OutList"

# 対象ファイル列挙（拡張子無視）
$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue

foreach ($f in $files) {
  $path = $f.FullName

  # magick を別プロセスで実行（ハング対策: timeout）
  $args = @($path, "-strip", "-write", "NUL:", "+delete")
  $p = Start-Process -FilePath "magick" -ArgumentList $args -NoNewWindow -PassThru

  if (-not $p.WaitForExit($TimeoutSec * 1000)) {
    try { $p.Kill() } catch {}
    Add-Content -LiteralPath $OutList -Value $path
    continue
  }

  if ($p.ExitCode -ne 0) {
    Add-Content -LiteralPath $OutList -Value $path
  }
}

Write-Host "DONE. Failed list: $OutList"
