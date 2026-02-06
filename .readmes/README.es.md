<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Código Fuente de MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Este repositorio contiene el código fuente original y binarios compilados para MS-DOS v1.25 y MS-DOS v2.0, más el código fuente de MS-DOS v4.00 desarrollado conjuntamente por IBM y Microsoft.

Los archivos de MS-DOS v1.25 y v2.0 [fueron originalmente compartidos en el Museo de Historia de la Computación el 25 de marzo de 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) y están siendo (re)publicados en este repositorio para que puedan ser encontrados más fácilmente, referenciados en escritos y trabajos externos, y permitir la exploración y experimentación para aquellos interesados en sistemas operativos para PC tempranos.

# Acerca de este fork

Este fork añade un sistema de construcción funcional y un pipeline de CI para el código fuente de MS-DOS 4.0. Compila las fuentes originales en ensamblador 8086 y C en un sistema operativo completo y arrancable -- tanto las variantes OEM **MS-DOS** como **IBM PC-DOS**.

La compilación produce imágenes de disco listas para usar (disco duro de 64MB y disquetes de época desde 360KB hasta 1.44MB) que arrancan en QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, o en hardware vintage real. Las imágenes precompiladas están disponibles en la página de [Releases](https://github.com/tgies/MS-DOS/releases).

Este trabajo se beneficia enormemente del trabajo previo realizado por otros para conseguir que el código fuente de MS-DOS 4.0 compile, limpiando algunos problemas menores en el árbol de código fuente liberado (rutas de archivos incorrectas y codificaciones de caracteres dañadas), incluyendo, pero sin limitarse a, [ecm](https://hg.pushbx.org/ecm/msdos4) y [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Pruébalo

Descarga `msdos4.img` desde el [último release](https://github.com/tgies/MS-DOS/releases) y arráncalo:

```bash
qemu-system-i386 -hda msdos4.img
```

O con DOSBox, inicia DOSBox normalmente y luego arranca la imagen (omite `-l C` si usas una imagen de disquete):

```bash
BOOT msdos4.img -l C
```

O con dosemu (descarga `msdos4-dosemu.img`, que tiene un encabezado especial para dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licencia

Todos los archivos contenidos en este repositorio fueron liberados bajo la [Licencia MIT](https://es.wikipedia.org/wiki/Licencia_MIT) según el [archivo LICENSE](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) almacenado en la raíz de este repositorio.

# Para referencia histórica

> **NOTA:** Esta sección se preserva del README.md original de Microsoft que acompaña la liberación del código fuente. Los scripts de construcción y herramientas en este repositorio se mantienen separadamente del código fuente histórico. Los pull requests para mejoras al sistema de construcción son bienvenidos.

Los archivos fuente en este repositorio son para referencia histórica y permanecerán estáticos, así que por favor **no envíes** Pull Requests sugiriendo modificación alguna a los archivos de código fuente, pero siéntete libre de bifurcar (fork) este repositorio y experimentar 😊.

Este proyecto ha adoptado el [Código de Conducta de Código Abierto de Microsoft](https://opensource.microsoft.com/codeofconduct/). Para más información consulta las [Preguntas Frecuentes del Código de Conducta](https://opensource.microsoft.com/codeofconduct/faq/) o contacta [opencode@microsoft.com](mailto:opencode@microsoft.com) con cualquier pregunta o comentario adicional.

# Compilación de MS-DOS 4.0

Las imágenes de disco precompiladas están disponibles en la página de [Releases](https://github.com/tgies/MS-DOS/releases). Para compilar desde el código fuente:

## Requisitos

- dosemu2
- mtools
- mkfatimage16 (de dosemu2)

> [!IMPORTANT]
> **Se requiere comcom64 0.4-0~202602051302 o posterior.** comcom64 es el reemplazo de command.com usado por dosemu2. Algunas versiones anteriores tienen un [bug en el comando `COPY`](https://github.com/dosemu2/comcom64/pull/117) que rompe la concatenación de archivos (`copy /b a+b dest`) cuando se invoca a través de `COMMAND /C`, que nmake usa para ejecutar comandos de makefile. Esto causa que la compilación de IO.SYS falle silenciosamente.
>
> Verifica tu versión con `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) o consulta tu gestor de paquetes. Si tienes una versión anterior:
> - **Recomendado:** Actualiza comcom64 a 0.4-0~202602051302 o posterior
> - **Solución alternativa:** Compila comcom64 desde el código fuente: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (asegúrate de que `make install` instale sobre tu `command.efi` existente)

## Inicio Rápido

```bash
cd v4.0
./mak.sh              # Compila DOS 4
./mkhdimg.sh          # Crea imagen de disco duro de 64MB
./mkhdimg.sh --floppy # Crea disquete de arranque de 1.44MB
```

## Variantes de Compilación

El código fuente soporta múltiples configuraciones de compilación. Usa la bandera `--flavor`:

```bash
./mak.sh                    # Compila MS-DOS (predeterminado)
./mak.sh --flavor=pcdos     # Compila IBM PC-DOS
```

| Variante | Archivos del Sistema | Descripción |
|--------|---------------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | MS-DOS OEM para PCs compatibles con IBM (predeterminado, recomendado) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (para precisión histórica) |

Ambas variantes incluyen código específico para hardware de IBM PC (BIOS de video INT 10H, PIC 8259, soporte de cartucho ROM de PCjr).

**Importante:** La variante **msdos** contiene más correcciones de bugs que **pcdos**. Presumiblemente, Microsoft podía aplicar correcciones a MS-DOS OEM más rápido de lo que el proceso de aprobación de IBM permitía para PC-DOS. Se sabe que IBM esencialmente tomó el control del desarrollo de DOS temporalmente alrededor de DOS 3.3 hasta DOS 4.0, así que una posible teoría es que PC-DOS fue esencialmente considerado congelado cuando el código fue devuelto a Microsoft, quien encontró varios bugs que corrigieron en MS-DOS OEM sin tocar PC-DOS.

Diferencias notables:
- Corrección en el manejo de INT 24 (error crítico) del kernel de DOS
- Protección contra desbordamiento de enteros en FDISK para discos grandes
- Búferes EMS más grandes en FASTOPEN
- Mejor validación de entrada en EXE2BIN

La variante predeterminada **msdos** es lo que los OEM como Compaq, Dell y HP distribuyeron como "MS-DOS" en sus PCs compatibles con IBM. Esta liberación de código fuente parece derivar del OAK (OEM Adaptation Kit) -- el código que Microsoft proporcionaba a los OEM para permitirles personalizar MS-DOS para su hardware.

## Opciones de Imagen de Disco

```bash
# Imágenes de disco duro (produce msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Imagen FAT16 de 64MB
./mkhdimg.sh --size 32          # Imagen de 32MB

# Imágenes de disquete (todos los tamaños)
./mkhdimg.sh --floppy           # 1.44MB mínimo (solo archivos del sistema)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB con utilidades
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB con utilidades
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB con utilidades
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB con utilidades
```

Las imágenes de disco duro se producen en dos formatos: `msdos4.img` es una imagen de disco cruda que funciona con QEMU, VirtualBox, bochs y la mayoría de emuladores. `msdos4-dosemu.img` es el formato hdimage de dosemu (encabezado de 128 bytes). Las imágenes de disquete son crudas y funcionan en todas partes.

## Limitaciones Conocidas

- **DOS Shell no incluido**: El código fuente de DOS Shell (DOSSHELL) no fue liberado como código abierto. SELECT.EXE (el instalador) comparte algo de código con DOSSHELL y no puede ser compilado.
- **Branding de PC-DOS incompleto**: La compilación `--flavor=pcdos` usa nombres de archivos de sistema de IBM (IBMBIO.COM, IBMDOS.COM) y algunas rutas de código específicas de PC-DOS, pero aún muestra "MS-DOS" en VER y el banner de inicio. Esto es porque el archivo de mensajes de IBM (`usa-ibm.msg` o similar) no fue liberado como código abierto—solo el `usa-ms.msg` con marca de Microsoft fue liberado.
- **Compilación no compatible con IBM**: Existe una tercera configuración (`IBMVER=FALSE`) en el código fuente para hardware no compatible con IBM, pero no compila exitosamente. Parece que esta configuración es para algunos de los PCs x86 no compatibles con IBM de corta duración de principios de los 1980s -- específicamente evita ciertas rutas de código específicas de compatibles con IBM relacionadas con hardware como el BIOS, PIC, PIT, etc. Se necesita más investigación, pero es probable que este árbol de código fuente esté incompleto y le falte el código específico de hardware (cosas de IO.SYS) que necesitaría proporcionarse para implementar servicios DOS en tal hardware.

# Marcas Registradas

Este proyecto puede contener marcas registradas o logos de proyectos, productos o servicios. El uso autorizado de marcas registradas o logos de Microsoft está sujeto y debe seguir las [Directrices de Marcas Registradas y Marca de Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
El uso de marcas registradas o logos de Microsoft en versiones modificadas de este proyecto no debe causar confusión o implicar patrocinio de Microsoft.
Cualquier uso de marcas registradas o logos de terceros está sujeto a las políticas de esos terceros.
