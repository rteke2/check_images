param(
  [Parameter(Mandatory=$true)][string]$Root,
  [string]$OutList = "fail_1.txt",
  [int]$TimeoutSec = 120
)

# 譌｢蟄倥ｒ豸医＠縺ｦ譁ｰ隕丈ｽ懈・
Remove-Item $OutList -ErrorAction SilentlyContinue

# 蟇ｾ雎｡繝輔ぃ繧､繝ｫ蛻玲嫌・域僑蠑ｵ蟄千┌隕厄ｼ・$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue

foreach ($f in $files) {
  $path = $f.FullName

  # magick 繧貞挨繝励Ο繧ｻ繧ｹ縺ｧ螳溯｡鯉ｼ医ワ繝ｳ繧ｰ蟇ｾ遲・ timeout・・  $p = Start-Process -FilePath "magick" -ArgumentList @(
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

