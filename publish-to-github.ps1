# accesso Portal — GitHub Pages Publisher
# Run this in PowerShell from the folder containing index.html
# Requires Git for Windows: https://git-scm.com/download/win

$GH_USER = "jasonashwell"
$REPO    = "accesso-portal-poc"
$PAT     = Read-Host "Paste your GitHub Personal Access Token" -AsSecureString
$PlainPAT = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
              [Runtime.InteropServices.Marshal]::SecureStringToBSTR($PAT))

Write-Host "`n1. Creating GitHub repository..." -ForegroundColor Cyan
$headers = @{
  Authorization = "Bearer $PlainPAT"
  Accept        = "application/vnd.github+json"
}
$body = @{ name = $REPO; description = "accesso Customer Portal – Proof of Concept"; private = $false } | ConvertTo-Json
try {
  Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json" | Out-Null
  Write-Host "   Repository created: https://github.com/$GH_USER/$REPO" -ForegroundColor Green
} catch {
  Write-Host "   Repository may already exist — continuing." -ForegroundColor Yellow
}

Write-Host "`n2. Initialising git and pushing..." -ForegroundColor Cyan
$remote = "https://${PlainPAT}@github.com/$GH_USER/$REPO.git"

git init
git add index.html
git commit -m "Add accesso customer portal POC"
git branch -M main
git remote remove origin 2>$null
git remote add origin $remote
git push -u origin main

Write-Host "`n3. Enabling GitHub Pages..." -ForegroundColor Cyan
$pagesBody = @{ source = @{ branch = "main"; path = "/" } } | ConvertTo-Json
try {
  Invoke-RestMethod -Uri "https://api.github.com/repos/$GH_USER/$REPO/pages" -Method Post -Headers $headers -Body $pagesBody -ContentType "application/json" | Out-Null
  Write-Host "   GitHub Pages enabled!" -ForegroundColor Green
} catch {
  Write-Host "   Pages may already be enabled — check Settings > Pages in your repo." -ForegroundColor Yellow
}

Write-Host "`n✅ Done! Your portal will be live in ~60 seconds at:" -ForegroundColor Green
Write-Host "   https://$GH_USER.github.io/$REPO" -ForegroundColor White

# Security: clear the token from memory
$PlainPAT = $null; $PAT = $null
