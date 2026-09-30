# Servidor HTTP local para ITAD Core (sin Python ni Node)
param(
  [int]$Port = 8888,
  [switch]$AllowLan,
  [switch]$RegisterUrl
)

$Root = $PSScriptRoot
if (-not $Root) { $Root = Get-Location.Path }

function Get-LocalIPv4 {
  Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.IPAddress -notlike '127.*' -and
      $_.PrefixOrigin -ne 'WellKnown' -and
      $_.InterfaceAlias -notmatch 'vEthernet|WSL|Loopback'
    } |
    Sort-Object -Property InterfaceMetric |
    Select-Object -First 1 -ExpandProperty IPAddress
}

function Get-MimeType([string]$Path) {
  switch ([System.IO.Path]::GetExtension($Path).ToLowerInvariant()) {
    '.html' { 'text/html; charset=utf-8' }
    '.js'   { 'application/javascript; charset=utf-8' }
    '.css'  { 'text/css; charset=utf-8' }
    '.json' { 'application/json; charset=utf-8' }
    '.png'  { 'image/png' }
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.pdf'  { 'application/pdf' }
    default { 'application/octet-stream' }
  }
}

function Register-ItadUrlAcl([int]$Port) {
  $user = "$env:USERDOMAIN\$env:USERNAME"
  $url = "http://+:$Port/"
  Write-Host "Registrando $url para $user ..." -ForegroundColor Cyan
  $null = netsh http delete urlacl url=$url 2>$null
  netsh http add urlacl url=$url user=$user
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Fallo. Ejecute este script como ADMINISTRADOR." -ForegroundColor Red
    exit 1
  }
  Write-Host "Listo. Ya puede usar -AllowLan sin admin (puerto $Port)." -ForegroundColor Green
}

if ($RegisterUrl) {
  Register-ItadUrlAcl -Port $Port
  exit 0
}

function Start-ItadListener([bool]$lan) {
  $listener = New-Object System.Net.HttpListener
  if ($lan) {
    $listener.Prefixes.Add("http://+:$Port/")
  } else {
    $listener.Prefixes.Add("http://127.0.0.1:$Port/")
  }
  $listener.Start()
  return $listener
}

$lanIp = Get-LocalIPv4
$listener = $null
$lanActive = $false

try {
  if ($AllowLan) {
    $listener = Start-ItadListener -lan $true
    $lanActive = $true
  } else {
    $listener = Start-ItadListener -lan $false
  }
} catch {
  Write-Host "Error al iniciar el puerto $Port." -ForegroundColor Red
  Write-Host $_.Exception.Message
  Write-Host ""
  if ($AllowLan) {
    Write-Host "Wi-Fi / telefono requiere permiso en Windows (Acceso denegado)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opcion A (recomendada, una sola vez):" -ForegroundColor Cyan
    Write-Host "  Clic derecho REGISTRAR-ITAD-WIFI.bat -> Ejecutar como administrador"
    Write-Host ""
    Write-Host "Opcion B: PowerShell COMO ADMINISTRADOR:" -ForegroundColor Cyan
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\serve-itad.ps1 -AllowLan -Port $Port"
    Write-Host ""
    Write-Host "En el TELEFONO use http://${lanIp}:$Port/  (NO use 127.0.0.1 ni localhost)" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Reintentando solo en esta PC (127.0.0.1)..." -ForegroundColor Yellow
    try {
      $listener = Start-ItadListener -lan $false
      $lanActive = $false
    } catch {
      Write-Host $_.Exception.Message -ForegroundColor Red
      exit 1
    }
  } else {
    Write-Host "Pruebe otro puerto: -Port 9090" -ForegroundColor Cyan
    exit 1
  }
}

Write-Host ""
Write-Host "ITAD Core listo:" -ForegroundColor Green
Write-Host "  PC:       http://127.0.0.1:$Port/"
if ($lanActive -and $lanIp) {
  Write-Host ""
  Write-Host "  TELEFONO (misma Wi-Fi, copie esta URL):" -ForegroundColor Cyan
  Write-Host "  http://${lanIp}:$Port/" -ForegroundColor White -BackgroundColor DarkBlue
  Write-Host ""
  Write-Host "  NO abra 127.0.0.1 ni :8765 en el telefono — eso es solo esta PC." -ForegroundColor Yellow
} elseif ($AllowLan) {
  Write-Host "  Telefono: NO disponible (falta permiso Wi-Fi). Vea mensajes arriba." -ForegroundColor Red
} else {
  Write-Host "  Telefono: agregue -AllowLan (y permiso Wi-Fi) o use INICIAR-ITAD-TELEFONO.bat" -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "Ctrl+C para detener." -ForegroundColor DarkGray

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $rel = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath)
    if ($rel -eq '/') { $rel = '/index.html' }

    $safeRel = $rel.TrimStart('/') -replace '\.\.+', ''
    $filePath = Join-Path $Root ($safeRel -replace '/', [IO.Path]::DirectorySeparatorChar)

    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
      $response.StatusCode = 404
      $bytes = [Text.Encoding]::UTF8.GetBytes('404 Not Found')
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $bytes = [System.IO.File]::ReadAllBytes($filePath)
      $response.StatusCode = 200
      $response.ContentType = Get-MimeType $filePath
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $response.OutputStream.Close()
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
