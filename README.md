# Video Downloader con yt-dlp y PowerShell

## Descripción

Este script en PowerShell es una herramienta interactiva para descargar videos desde una URL utilizando `yt-dlp`. Permite al usuario seleccionar el formato de video/audio deseado y verifica que las dependencias necesarias (`yt-dlp` y `ffmpeg`) estén correctamente instaladas en el sistema. Además, incluye la opción para instalar `ffmpeg` automáticamente si no está presente.

## Características

- **Descarga de videos**: Selecciona el formato deseado o utiliza la mejor calidad de video y audio combinados automáticamente.
- **Verificación de dependencias**: El script comprueba si `yt-dlp` y `ffmpeg` están instalados y, si no es así, te avisa.
- **Instalación automática de `ffmpeg`**: Si `ffmpeg` no está instalado, el script lo descarga, descomprime y lo agrega al `PATH` del sistema.
- **Menú interactivo**: Incluye un menú sencillo con opciones para descargar videos, verificar instalaciones, instalar `ffmpeg`, y salir del script.
- **Manejo de errores**: Gestiona errores como URL no válidas, problemas de descarga, y rutas incorrectas, con mensajes claros para el usuario.

## Requisitos

- Windows con PowerShell instalado.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) instalado.
- [7-Zip](https://www.7-zip.org/) para descomprimir `ffmpeg`.

## Instalación

1. Clona este repositorio:
    ```bash
    git clone https://github.com/!wernser412!/nombre-del-repositorio.git
    ```

2. Asegúrate de tener `yt-dlp` instalado en tu sistema:
    - Puedes descargarlo desde [aquí](https://github.com/yt-dlp/yt-dlp#installation).

3. Ejecuta el script en PowerShell:
    ```bash
    .\nombre-del-script.ps1
    ```

## Uso

1. Ejecuta el script.
2. Selecciona la opción deseada en el menú.
3. Ingresa la URL del video cuando se te pida.
4. Selecciona el formato o usa la opción predeterminada.
5. El video se descargará en la carpeta actual.

## Notas

- El script requiere una conexión a internet para descargar `ffmpeg` si no está instalado.
- Asegúrate de que `7-Zip` esté instalado y accesible en la ruta predeterminada (`C:\Program Files\7-Zip\7z.exe`).

