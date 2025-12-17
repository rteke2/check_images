param(
  [Parameter(Mandatory=$true)][string]$InList,
  [string]$OutList = "fail_next.txt",
  [int]$TimeoutSec = 120
)

Remove-Item $OutList -ErrorAction SilentlyContinue

# 空行除去・重複除去
$paths = Get-Content -LiteralPath $InList | Where-Object { $_ -and $_.Trim() -ne "" } | Select-Object -Unique

foreach ($path in $paths) {
  if (-not (Test-Path -LiteralPath $path)) {
    # 途中で見えなくなってるケース：次にも回す（通信断/同期遅延の可能性）
    Add-Content -LiteralPath $OutList -Value $path
    continue
  }

  $p = Start-Process -FilePath "magick" -ArgumentList @(
    $path,
    "-strip",
    "-write", "NUL:",
    "+delete"
  ) -NoNewWindow -PassThru -RedirectStandardError "NUL" -RedirectStandardOutput "NUL"

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
