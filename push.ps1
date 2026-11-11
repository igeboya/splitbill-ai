# Push repo ke GitHub. Jalankan:  .\push.ps1 namagithub
param([Parameter(Mandatory=$true)][string]$User)
$repo = "splitbill-ai"
git remote remove origin 2>$null
git remote add origin "https://github.com/$User/$repo.git"
git branch -M main
git push -u origin main
Write-Host ""
Write-Host "Selesai. Buka https://github.com/$User/$repo" -ForegroundColor Green
Write-Host "Jangan lupa: About -> gear -> License: MIT License" -ForegroundColor Yellow
