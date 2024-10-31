function Download-Video {
    $url = ""
    $format = ""
    $subtitlesOption = ""
    $cookiesOption = ""

    while ($true) {
        Clear-Host
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "   Agregar Formato y Descargar Video  " -ForegroundColor Green
        Write-Host " Codigo:  " -NoNewline

        # Mostrar el comando completo con los parámetros actuales
        if ($url -and $format) {
            Write-Host "yt-dlp.exe -f" -ForegroundColor Cyan -NoNewline
            Write-Host " $format" -ForegroundColor Yellow -NoNewline
            Write-Host " $url" -ForegroundColor Yellow -NoNewline
            if ($subtitlesOption) {
                Write-Host " $subtitlesOption" -ForegroundColor Magenta -NoNewline
            }
            if ($cookiesOption) {
                Write-Host " --cookies $cookiesOption" -ForegroundColor Cyan -NoNewline
            }
        } else {
            Write-Host "(Pendiente de ingresar datos)" -ForegroundColor DarkGray
        }

        Write-Host ""
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "*. (Opcional) Ingresar archivo de cookies" -ForegroundColor Cyan
        Write-Host "1. Ingresar la URL del video y formato" -ForegroundColor Yellow
        Write-Host "2. Ingresar Subtitulo del video" -ForegroundColor Magenta
        Write-Host "3. Iniciar descarga" -ForegroundColor Yellow
        Write-Host "4. Atras" -ForegroundColor Yellow
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "Selecciona una opcion:" -ForegroundColor Yellow
        $option = Read-Host

        switch ($option) {
            "*" {
                # Opcional: Seleccionar archivo de cookies
                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "   Archivo de Cookies    " -ForegroundColor Green
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "1. Ingresar archivo de cookies (.txt)" -ForegroundColor Cyan
                Write-Host "2. Atras" -ForegroundColor Cyan
                Write-Host "Selecciona una opcion:" -ForegroundColor Yellow
                $cookieOption = Read-Host

                switch ($cookieOption) {
                    "1" {
                        # Usar OpenFileDialog para seleccionar el archivo de cookies
                        Add-Type -AssemblyName System.Windows.Forms
                        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
                        $fileDialog.Filter = "Archivos de texto (*.txt)|*.txt"
                        $fileDialog.Title = "Selecciona el archivo de cookies (.txt)"

                        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                            $cookiesPath = $fileDialog.FileName
                            $cookiesOption = $cookiesPath
                            Write-Host "Archivo de cookies seleccionado: " -ForegroundColor Green -NoNewline
                            Write-Host "$cookiesPath" -ForegroundColor Cyan
                        } else {
                            Write-Host "No se seleccionó ningún archivo. Intenta de nuevo." -ForegroundColor Red
                            Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                            continue
                        }
                    }
                    "2" { continue }
                    default {
                        Write-Host "Opcion no valida. Intentalo de nuevo." -ForegroundColor Red
                        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    }
                }
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "1" {
                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "    Formatos Disponibles    " -ForegroundColor Green
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "Ingresa la URL del video:" -ForegroundColor Yellow
                $url = Read-Host

                if ([string]::IsNullOrEmpty($url)) {
                    Write-Host "No se ingreso ninguna URL, intenta de nuevo." -ForegroundColor Red
                    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    continue
                }

                Write-Host "URL ingresada: " -ForegroundColor Green -NoNewline
                Write-Host "$url" -ForegroundColor Yellow

                try {
                    # Usar el archivo de cookies si está disponible al listar los formatos
                    if ($cookiesOption) {
                        yt-dlp.exe -F $url --cookies "$cookiesOption"
                    } else {
                        yt-dlp.exe -F $url
                    }
                } catch {
                    Write-Host "Hubo un error al intentar recuperar los formatos. Por favor, verifica la URL o la conexion a Internet." -ForegroundColor Red
                    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    continue
                }

                Write-Host "Ingresa el nombre completo del formato o deja en blanco para usar el mejor video y audio combinados:" -ForegroundColor Yellow
                $format = Read-Host

                if ([string]::IsNullOrEmpty($format)) {
                    $format = "bestvideo+bestaudio"
                }

                Write-Host "Formato seleccionado: " -ForegroundColor Green -NoNewline
                Write-Host "$format" -ForegroundColor Yellow
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "2" {
                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "    Subtítulos Disponibles    " -ForegroundColor Green
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "Buscando subtítulos para la URL ingresada..." -ForegroundColor Yellow
                
                try {
                    # Ejecutar yt-dlp para buscar subtítulos usando cookies si están configuradas
                    if ($cookiesOption) {
                        yt-dlp.exe --list-subs $url --cookies "$cookiesOption"
                    } else {
                        yt-dlp.exe --list-subs $url
                    }
                } catch {
                    Write-Host "Hubo un error al intentar recuperar los subtítulos. Por favor, verifica la URL o la conexion a Internet." -ForegroundColor Red
                    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    continue
                }

                Write-Host "Ingresa el nombre de los subtítulos que deseas descargar o deja en blanco para omitir:" -ForegroundColor Yellow
                $subtitlesOption = Read-Host
                if ([string]::IsNullOrEmpty($subtitlesOption)) {
                    $subtitlesOption = ""
                } else {
                    $subtitlesOption = "--sub-lang $subtitlesOption --write-sub"
                }
                
                Write-Host "Subtítulo seleccionado: " -ForegroundColor Green -NoNewline
                Write-Host "$subtitlesOption" -ForegroundColor Yellow
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }

            "3" {
                if (-not $url) {
                    Write-Host "No se ha ingresado ninguna URL. Selecciona la opcion 1 primero." -ForegroundColor Red
                    continue
                }

                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "  Ejecutando : el codigo dinamico" -ForegroundColor Cyan
                Write-Host "===========================" -ForegroundColor Green

                try {
                    $completeCommand = "yt-dlp.exe -f $format $subtitlesOption --cookies ""$cookiesOption"" $url"
                    Write-Host "Comando ejecutado: $completeCommand" -ForegroundColor Green

                    # Ejecutar el comando y capturar la salida
                    Invoke-Expression $completeCommand

                    Write-Host "Descarga completada." -ForegroundColor Green
                } catch {
                    Write-Host "Ocurrio un error durante la descarga. Detalles: $_" -ForegroundColor Red
                }
                
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }

            "4" {
                # Atras
                return
            }

            default {
                Write-Host "Opcion no valida. Intentalo de nuevo." -ForegroundColor Red
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
    }
}


function Install-Ffmpeg {
    Clear-Host
    Write-Host "===========================" -ForegroundColor Green
    Write-Host "      Instalando ffmpeg     " -ForegroundColor Green
    Write-Host "===========================" -ForegroundColor Green
    $downloadUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    $destinationPath = "$([environment]::GetFolderPath('MyDocuments'))\ffmpeg-release-essentials.zip"
    $extractPath = "$([environment]::GetFolderPath('MyDocuments'))\ffmpeg"

    Write-Host "Descargando ffmpeg desde $downloadUrl ..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $destinationPath -UseBasicParsing -TimeoutSec 3600
        Write-Host "Descarga completada." -ForegroundColor Green
    } catch {
        Write-Host "Error durante la descarga: $_" -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    if (-not (Test-Path $destinationPath) -or (Get-Item $destinationPath).Length -eq 0) {
        Write-Host "Error: La descarga fallo o el archivo esta vacio." -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    Write-Host "Descomprimiendo ffmpeg en $extractPath ..."  -ForegroundColor Green
    Expand-Archive -Path $destinationPath -DestinationPath $extractPath -Force

    $binPath = Get-ChildItem -Path "$extractPath\ffmpeg-*" -Recurse -Directory | Where-Object { $_.Name -eq "bin" }

    if (-not $binPath) {
        Write-Host "Error: No se encontro la carpeta esperada despues de la descompresion." -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Show-Menu
        return
    }

    try {
        $env:Path += ";$($binPath.FullName)"
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
        Write-Host "ffmpeg instalado y anadido al PATH del sistema." -ForegroundColor Green
    } catch {
        Write-Host "Hubo un error al anadir ffmpeg al PATH: $_" -ForegroundColor Red
    }

    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Show-Menu
}


function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "   Menu Principal           " -ForegroundColor Green
        Write-Host "===========================" -ForegroundColor Green

        # Mostrar versión de yt-dlp
        try {
            $ytDlpVersion = (yt-dlp --version 2>$null).ToString()
            Write-Host "yt-dlp version: $ytDlpVersion" -ForegroundColor Cyan
        } catch {
            Write-Host "yt-dlp no esta instalado o no se pudo verificar la version." -ForegroundColor Red
        }

        # Mostrar versión de ffmpeg en el formato solicitado
        try {
            $ffmpegVersion = (ffmpeg -version 2>$null | Select-String "ffmpeg version").ToString()
            if ($ffmpegVersion) {
                # Extraer solo el número de versión de ffmpeg, eliminando cualquier texto adicional
                $ffmpegVersion = $ffmpegVersion -replace "^ffmpeg version ([\d\.]+).*", '$1'
                Write-Host "ffmpeg version: $ffmpegVersion" -ForegroundColor Cyan
            } else {
                Write-Host "ffmpeg no esta instalado o no se pudo verificar la version." -ForegroundColor Red
            }
        } catch {
            Write-Host "ffmpeg no esta instalado o no se pudo verificar la version." -ForegroundColor Red
        }

        Write-Host "===========================" -ForegroundColor Green
        Write-Host "1. Descargar video" -ForegroundColor Yellow
        Write-Host "2. Instalar ffmpeg" -ForegroundColor Yellow
        Write-Host "3. Salir" -ForegroundColor Yellow
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "Selecciona una opcion:" -ForegroundColor Yellow
        $option = Read-Host

        switch ($option) {
            "1" {
                Download-Video
            }
            "2" {
                Install-Ffmpeg
            }
            "3" {
                Exit
            }
            default {
                Write-Host "Opcion no valida. Intentalo de nuevo." -ForegroundColor Red
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
    }
}

# Mostrar el menú principal
Show-Menu
