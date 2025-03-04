Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

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


function Show-FileDialog {
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Archivos de texto (*.txt)|*.txt|Todos los archivos (*.*)|*.*"
    $fileDialog.Title = "Seleccionar archivo de cookies"
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $fileDialog.FileName
    }
    return $null
}

function Show-Menu {
    $url = ""
    $format = "bestvideo+bestaudio"
    $subtitlesOption = ""
    $cookiesFile = ""
    $dynamicCommand = "(Pendiente)"

    while ($true) {
        # Actualizar el código dinámico basado en las opciones ingresadas
        if ($url -and $format) {
            $dynamicCommand = "yt-dlp.exe"
            if ($cookiesFile) {
                $dynamicCommand += " --cookies $cookiesFile"
            }
            $dynamicCommand += " -f $format $subtitlesOption $url"
        } else {
            $dynamicCommand = "(Pendiente)"
        }

        Clear-Host
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "        Menu Principal       " -ForegroundColor Green
        Write-Host "===========================" -ForegroundColor Green

        # Mostrar versión de yt-dlp
        try {
            $ytDlpVersion = (yt-dlp --version 2>$null).ToString()
            Write-Host "yt-dlp version: $ytDlpVersion" -ForegroundColor Cyan
        } catch {
            Write-Host "yt-dlp no esta instalado o no se pudo verificar la version." -ForegroundColor Red
        }

        # Mostrar versión de ffmpeg
        try {
            $ffmpegVersion = (ffmpeg -version 2>$null | Select-String "ffmpeg version").ToString()
            if ($ffmpegVersion) {
                $ffmpegVersion = $ffmpegVersion -replace "^ffmpeg version ([\d\.]+).*", '$1'
                Write-Host "ffmpeg version: $ffmpegVersion" -ForegroundColor Cyan
            } else {
                Write-Host "ffmpeg no esta instalado o no se pudo verificar la version." -ForegroundColor Red
            }
        } catch {
            Write-Host "ffmpeg no esta instalado o no se pudo verificar la version." -ForegroundColor Red
        }

        Write-Host "===========================" -ForegroundColor Green
        Write-Host "Codigo dinamico: " -ForegroundColor Yellow -NoNewline
        Write-Host "$dynamicCommand" -ForegroundColor Cyan
        Write-Host "===========================" -ForegroundColor Green

        Write-Host "0. Agregar cookies: " -ForegroundColor Yellow -NoNewline
        if ($cookiesFile) {
            Write-Host "$cookiesFile" -ForegroundColor Cyan
        } else {
            Write-Host "(Pendiente)" -ForegroundColor DarkGray
        }

        Write-Host "1. Ingresar la URL del video: " -ForegroundColor Yellow -NoNewline
        if ($url) {
            Write-Host "$url" -ForegroundColor Cyan
        } else {
            Write-Host "(Pendiente)" -ForegroundColor DarkGray
        }

        Write-Host "2. Ingresar formato: " -ForegroundColor Yellow -NoNewline
        if ($format) {
            Write-Host "$format" -ForegroundColor Cyan
        } else {
            Write-Host "(Pendiente)" -ForegroundColor DarkGray
        }

        Write-Host "3. Ingresar subtitulo del video: " -ForegroundColor Yellow -NoNewline
        if ($subtitlesOption) {
            Write-Host "$subtitlesOption" -ForegroundColor Cyan
        } else {
            Write-Host "(Pendiente)" -ForegroundColor DarkGray
        }

        Write-Host "4. Iniciar descarga" -ForegroundColor Yellow
        Write-Host "5. Instalar ffmpeg" -ForegroundColor Yellow
        Write-Host "6. Salir" -ForegroundColor Yellow
        Write-Host "===========================" -ForegroundColor Green
        Write-Host "Selecciona una opcion:" -ForegroundColor Yellow
        $option = Read-Host

        switch ($option) {
            "0" {
                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "      Agregar Cookies       " -ForegroundColor Green
                Write-Host "===========================" -ForegroundColor Green
                
                $selectedFile = Show-FileDialog
                if ($selectedFile) {
                    $cookiesFile = $selectedFile
                    Write-Host "Archivo de cookies seleccionado: $cookiesFile" -ForegroundColor Green
                } else {
                    Write-Host "No se selecciono ningun archivo de cookies." -ForegroundColor DarkGray
                }

                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "1" {
                $url = [Microsoft.VisualBasic.Interaction]::InputBox("Ingresa la URL del video:", "Ingresar URL", "")
                if (-not $url) {
                    Write-Host "No se ingreso ninguna URL, intenta de nuevo." -ForegroundColor Red
                } else {
                    Write-Host "URL ingresada: $url" -ForegroundColor Green
                }
            }
            "2" {
                if (-not $url) {
                    Write-Host "Primero debes ingresar una URL en la opcion 1." -ForegroundColor Red
                    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    continue
                }

                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "    Ingresar Formato del video   " -ForegroundColor Green
                Write-Host "===========================" -ForegroundColor Green

                try {
                    $cmd = "yt-dlp.exe"
                    if ($cookiesFile) {
                        $cmd += " --cookies $cookiesFile"
                    }
                    $cmd += " -F $url"
                    Invoke-Expression $cmd
                } catch {
                    Write-Host "Error al listar formatos, verifica la URL o conexion a internet." -ForegroundColor Red
                    continue
                }

                Write-Host "Ingresa el nombre completo del formato o deja en blanco para usar el mejor video y audio combinados:" -ForegroundColor Yellow
                $format = Read-Host

                if ([string]::IsNullOrEmpty($format)) {
                    $format = "bestvideo+bestaudio"
                }

                Write-Host "Formato seleccionado: $format" -ForegroundColor Green
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "3" {
                if (-not $url) {
                    Write-Host "Primero debes ingresar una URL en la opcion 1." -ForegroundColor Red
                    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    continue
                }

                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "   Subtitulos Disponibles   " -ForegroundColor Magenta
                Write-Host "===========================" -ForegroundColor Green

                try {
                    $cmd = "yt-dlp.exe"
                    if ($cookiesFile) {
                        $cmd += " --cookies $cookiesFile"
                    }
                    $cmd += " --list-subs $url"
                    Invoke-Expression $cmd
                } catch {
                    Write-Host "Error al listar subtitulos, verifica la URL o conexion a internet." -ForegroundColor Red
                    continue
                }

                Write-Host "Ingresa el codigo de idioma de los subtitulos (por ejemplo, 'es' para espanol, 'en' para ingles):" -ForegroundColor Magenta
                $subOption = Read-Host

                if ([string]::IsNullOrEmpty($subOption)) {
                    Write-Host "No se seleccionaron subtitulos." -ForegroundColor DarkGray
                } else {
                    $subtitlesOption = "--write-subs --embed-subs --sub-lang $subOption"
                    Write-Host "Subtitulo seleccionado: $subOption" -ForegroundColor Green
                }

                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "4" {
                if (-not $url -or -not $format) {
                    Write-Host "Primero debes ingresar una URL y un formato." -ForegroundColor Red
                    continue
                }

                Clear-Host
                Write-Host "===========================" -ForegroundColor Green
                Write-Host "  Iniciando Descarga  " -ForegroundColor Cyan
                Write-Host "===========================" -ForegroundColor Green

                try {
                    Write-Host "Ejecutando: $dynamicCommand" -ForegroundColor Cyan
                    Invoke-Expression $dynamicCommand
                    Write-Host "Descarga completada." -ForegroundColor Green
                } catch {
                    Write-Host "Hubo un error al descargar el video." -ForegroundColor Red
                }

                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "5" {
                Install-Ffmpeg
            }
            "6" {
                Exit
            }
            default {
                Write-Host "Opcion no valida, intentalo de nuevo." -ForegroundColor Red
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Yellow
                $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
    }
}

# Mostrar el menu principal
Show-Menu
