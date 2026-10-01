# Ejecutar al abrir PowerShell en Flow-R2:  . .\ACTIVAR-GIT.ps1
$env:Path = "C:\Program Files\Git\bin;C:\Program Files\Git\cmd;" + $env:Path
Set-Location $PSScriptRoot
Write-Host "Git OK:" (git --version)
Write-Host "Remotos:" 
git remote -v
