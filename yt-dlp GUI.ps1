function Download-Video {
    Clear-Host
    Write-Host "==========================="
    Write-Host "   Agregar Formato y Descargar Video  "
    Write-Host "==========================="
    $url = Read-Host "Ingresa la URL del video"

    if ([string]::IsNullOrEmpty($url)) {
        Write-Host "No se ingreso ninguna URL, intenta de nuevo."
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Download-Video
    }

    Write-Host "URL ingresada: $url"

    Clear-Host
    Write-Host "==========================="
    Write-Host "    Formatos Disponibles    "
    Write-Host "==========================="

    # Ejecución del comando yt-dlp para mostrar formatos
    try {
        yt-dlp.exe -F $url
    } catch {
        Write-Host "Hubo un error al intentar recuperar los formatos. Por favor, verifica la URL o la conexion a Internet."
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
    }

    $format = Read-Host "Ingresa el nombre completo del formato o deja en blanco para usar el mejor video y audio combinados"

    # Si el formato está en blanco, usar bestvideo+bestaudio
    if ([string]::IsNullOrEmpty($format)) {
        $format = "bestvideo+bestaudio"
    }

    # Descargar el video usando el formato especificado o la combinación automática
    try {
        yt-dlp.exe -f $format $url
        Write-Host "Descarga completada." -ForegroundColor Green
    } catch {
        Write-Host "Hubo un error al descargar el video. Por favor, verifica el formato seleccionado y vuelve a intentarlo."
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
    Write-Host "Presiona cualquier tecla para continuar..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "==========================="
        Write-Host "          MENU             "

        # Verificar la existencia de yt-dlp.exe y obtener la versión
        $ytDlpPath = Get-Command yt-dlp.exe -ErrorAction SilentlyContinue
        if ($null -eq $ytDlpPath) {
            Write-Host "yt-dlp.exe no instalado" -ForegroundColor Red
        } else {
            $ytDlpVersion = & yt-dlp.exe --version
            Write-Host "yt-dlp.exe = $ytDlpVersion" -ForegroundColor Green
        }

        # Verificar la existencia de ffmpeg y obtener la versión
        $ffmpegPath = Get-Command ffmpeg -ErrorAction SilentlyContinue
        if ($null -eq $ffmpegPath) {
            Write-Host "ffmpeg no instalado" -ForegroundColor Red
        } else {
            $ffmpegVersion = & ffmpeg -version | Select-String "ffmpeg version" | ForEach-Object { $_.Line }
            $ffmpegVersionNumber = $ffmpegVersion -replace "^ffmpeg version ([\d\.]+).*", '$1'
            Write-Host "ffmpeg = $ffmpegVersionNumber" -ForegroundColor Green
        }

        Write-Host "==========================="
        Write-Host "1. Descargar video"
        Write-Host "2. Verificar yt-dlp.exe"
        Write-Host "3. Verificar ffmpeg"
        Write-Host "4. Instalar ffmpeg"
        Write-Host "5. Salir"
        Write-Host "==========================="
        $option = Read-Host "Selecciona una opcion"

        switch ($option) {
            "1" { Download-Video }
            "2" { Check-YtDlp }
            "3" { Check-Ffmpeg }
            "4" { Install-Ffmpeg }
            "5" { Exit-Script }
            default { Write-Host "Opcion no valida. Intentalo de nuevo."; Write-Host "Presiona cualquier tecla para continuar..."; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
        }
    }
}

function Check-Ffmpeg {
    Clear-Host
    Write-Host "==========================="
    Write-Host "        Verificar ffmpeg    "
    Write-Host "==========================="
    $ffmpegPath = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($null -eq $ffmpegPath) {
        Write-Host "ffmpeg no esta instalado." -ForegroundColor Red
    } else {
        Write-Host "ffmpeg esta instalado." -ForegroundColor Green
        ffmpeg -version
    }
    Write-Host "Presiona cualquier tecla para continuar..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

function Check-YtDlp {
    Clear-Host
    Write-Host "==========================="
    Write-Host "      Verificar yt-dlp.exe  "
    Write-Host "==========================="
    $ytDlpPath = Get-Command yt-dlp.exe -ErrorAction SilentlyContinue
    if ($null -eq $ytDlpPath) {
        Write-Host "yt-dlp.exe no esta instalado." -ForegroundColor Red
    } else {
        Write-Host "yt-dlp.exe esta instalado." -ForegroundColor Green
        yt-dlp.exe --version
    }
    Write-Host "Presiona cualquier tecla para continuar..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}

function Install-Ffmpeg {
    Clear-Host
    Write-Host "==========================="
    Write-Host "      Instalando ffmpeg     "
    Write-Host "==========================="
    $downloadUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z"
    $destinationPath = "$([environment]::GetFolderPath('MyDocuments'))\ffmpeg-release-full.7z"
    $extractPath = "$([environment]::GetFolderPath('MyDocuments'))\ffmpeg"

    # Descargar ffmpeg manualmente con simulación de progreso
    Write-Host "Descargando ffmpeg desde $downloadUrl ..."
    try {
        $response = Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath -UseBasicParsing -TimeoutSec 3600
        Write-Host "Descarga completada." -ForegroundColor Green
    } catch {
        Write-Host "Error durante la descarga: $_" -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    # Verificar si el archivo se ha descargado correctamente
    if (-not (Test-Path $destinationPath) -or (Get-Item $destinationPath).Length -eq 0) {
        Write-Host "Error: La descarga fallo o el archivo esta vacio." -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    # Verificar si 7z.exe esta instalado
    $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $sevenZipPath)) {
        Write-Host "7-Zip no esta instalado o no se encontro en la ruta predeterminada. Instalalo antes de continuar." -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    # Descomprimir ffmpeg usando 7z.exe
    Write-Host "Descomprimiendo ffmpeg en $extractPath ..."  -ForegroundColor Green
    $command = "& `"$sevenZipPath`" x `"$destinationPath`" -o`"$extractPath`" -y"
    Invoke-Expression $command

    # Verificar si la descompresión fue exitosa
    $binPath = Get-ChildItem -Path $extractPath -Recurse -Directory | Where-Object { $_.Name -eq "bin" }

    if (-not $binPath) {
        Write-Host "Error: No se encontro la carpeta esperada después de la descompresion." -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    # Agregar ffmpeg al PATH
    $ffmpegBinPath = $binPath.FullName
    if ($env:Path -notlike "*$ffmpegBinPath*") {
        Write-Host "Agregando ffmpeg al PATH ..."  -ForegroundColor Green
        [Environment]::SetEnvironmentVariable("Path", "$env:Path;$ffmpegBinPath", [EnvironmentVariableTarget]::User)
        Write-Host "ffmpeg se ha agregado al PATH."  -ForegroundColor Green
    } else {
        Write-Host "ffmpeg ya esta en el PATH."  -ForegroundColor Green
    }

    Write-Host "Instalacion completada. Cerrar el script" -ForegroundColor Green
    Write-Host "Presiona cualquier tecla para continuar..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Exit
}

function Exit-Script {
    Exit  # Cierra el script inmediatamente
}

# Inicia el menú principal
Show-Menu
