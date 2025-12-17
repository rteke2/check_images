$testFile = "P:\2\r18\output\books\paywall\あの子はミラクル\あの子はミラクル_data.json"
Write-Host "Testing: $testFile"

$p = Start-Process -FilePath "magick" -ArgumentList @($testFile, "-strip", "-write", "NUL:", "+delete") -NoNewWindow -PassThru -Wait

Write-Host "Exit code: $($p.ExitCode)"
