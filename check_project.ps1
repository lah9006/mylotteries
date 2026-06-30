# Script de verificación para proyecto Django en Render
$Errores = 0
$Advertencias = 0

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REVISANDO ARCHIVOS REQUERIDOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$archivos = @("manage.py", "requirements.txt", "runtime.txt", "build.sh", "render.yaml",
              "mylotteries/settings.py", "mylotteries/urls.py", "mylotteries/wsgi.py",
              "core/models.py", "core/admin.py", "core/apps.py")

foreach ($a in $archivos) {
    if (Test-Path $a) {
        Write-Host "  OK $a" -ForegroundColor Green
    } else {
        Write-Host "  FALTA: $a" -ForegroundColor Red
        $Errores++
    }
}

if (Test-Path "core/migrations") {
    Write-Host "  OK core/migrations/" -ForegroundColor Green
} else {
    Write-Host "  AVISO: Falta core/migrations/" -ForegroundColor Yellow
    $Advertencias++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REVISANDO SETTINGS.PY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path "mylotteries/settings.py") {
    $s = Get-Content "mylotteries/settings.py" -Raw
    if ($s -match "SECRET_KEY.*os\.getenv") { Write-Host "  OK SECRET_KEY con os.getenv" -ForegroundColor Green } else { Write-Host "  FALTA: SECRET_KEY con os.getenv" -ForegroundColor Red; $Errores++ }
    if ($s -match "DEBUG.*os\.getenv") { Write-Host "  OK DEBUG con os.getenv" -ForegroundColor Green } else { Write-Host "  AVISO: DEBUG no usa os.getenv" -ForegroundColor Yellow; $Advertencias++ }
    if ($s -match "ALLOWED_HOSTS.*\*") { Write-Host "  OK ALLOWED_HOSTS permite *" -ForegroundColor Green } else { Write-Host "  AVISO: ALLOWED_HOSTS no permite *" -ForegroundColor Yellow; $Advertencias++ }
    if ($s -match "dj_database_url\.config") { Write-Host "  OK Base de datos con dj_database_url" -ForegroundColor Green } else { Write-Host "  FALTA: dj_database_url en DATABASES" -ForegroundColor Red; $Errores++ }
    if ($s -match "'core'") { Write-Host "  OK App 'core' en INSTALLED_APPS" -ForegroundColor Green } else { Write-Host "  FALTA: 'core' en INSTALLED_APPS" -ForegroundColor Red; $Errores++ }
    if ($s -match "STATIC_ROOT") { Write-Host "  OK STATIC_ROOT definido" -ForegroundColor Green } else { Write-Host "  AVISO: Falta STATIC_ROOT" -ForegroundColor Yellow; $Advertencias++ }
} else {
    Write-Host "  FALTA: settings.py" -ForegroundColor Red
    $Errores++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REVISANDO REQUIREMENTS.TXT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path "requirements.txt") {
    $r = Get-Content "requirements.txt"
    $deps = @("Django", "gunicorn", "psycopg2-binary", "dj-database-url", "whitenoise")
    foreach ($d in $deps) {
        if ($r -match $d) { Write-Host "  OK $d" -ForegroundColor Green } else { Write-Host "  FALTA: $d" -ForegroundColor Red; $Errores++ }
    }
} else {
    Write-Host "  FALTA: requirements.txt" -ForegroundColor Red
    $Errores++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REVISANDO BUILD.SH" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path "build.sh") {
    $b = Get-Content "build.sh" -Raw
    if ($b -match "pip install") { Write-Host "  OK pip install" -ForegroundColor Green } else { Write-Host "  FALTA: pip install" -ForegroundColor Red; $Errores++ }
    if ($b -match "collectstatic") { Write-Host "  OK collectstatic" -ForegroundColor Green } else { Write-Host "  AVISO: collectstatic no encontrado" -ForegroundColor Yellow; $Advertencias++ }
    if ($b -match "migrate") { Write-Host "  OK migrate" -ForegroundColor Green } else { Write-Host "  FALTA: migrate" -ForegroundColor Red; $Errores++ }
} else {
    Write-Host "  FALTA: build.sh" -ForegroundColor Red
    $Errores++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REVISANDO RENDER.YAML" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path "render.yaml") {
    $y = Get-Content "render.yaml" -Raw
    if ($y -match "type: web") { Write-Host "  OK type: web" -ForegroundColor Green } else { Write-Host "  FALTA: type: web" -ForegroundColor Red; $Errores++ }
    if ($y -match "buildCommand:") { Write-Host "  OK buildCommand" -ForegroundColor Green } else { Write-Host "  FALTA: buildCommand" -ForegroundColor Red; $Errores++ }
    if ($y -match "startCommand:") { Write-Host "  OK startCommand" -ForegroundColor Green } else { Write-Host "  FALTA: startCommand" -ForegroundColor Red; $Errores++ }
    if ($y -match "DATABASE_URL") { Write-Host "  OK DATABASE_URL referenciado" -ForegroundColor Green } else { Write-Host "  AVISO: DATABASE_URL no referenciado" -ForegroundColor Yellow; $Advertencias++ }
    if ($y -match "databases:") { Write-Host "  OK databases definida" -ForegroundColor Green } else { Write-Host "  AVISO: databases no definida" -ForegroundColor Yellow; $Advertencias++ }
} else {
    Write-Host "  FALTA: render.yaml" -ForegroundColor Red
    $Errores++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($Errores -eq 0 -and $Advertencias -eq 0) {
    Write-Host "  TODO PERFECTO - Listo para GitHub y Render" -ForegroundColor Green
} elseif ($Errores -eq 0 -and $Advertencias -gt 0) {
    Write-Host "  OK con $Advertencias advertencias (revisar)" -ForegroundColor Yellow
} else {
    Write-Host "  ERRORES: $Errores, ADVERTENCIAS: $Advertencias" -ForegroundColor Red
    Write-Host "  Corrige los errores en ROJO antes de subir" -ForegroundColor Red
}

Write-Host "`nPASOS SIGUIENTES:"
Write-Host "1. Si todo OK: git add . ; git commit -m 'Listo' ; git push"
Write-Host "2. En Render: New + -> Blueprint -> selecciona repositorio"
Write-Host "3. Crea superusuario en la consola de Render con: python manage.py createsuperuser"

Read-Host "`nPresiona Enter para salir"