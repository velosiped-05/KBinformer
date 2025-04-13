Set-Location "C:\KBinformer\webapp"
if (git status --porcelain) {
    git add .
    git commit -m "Auto-sync $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git push origin main
}
