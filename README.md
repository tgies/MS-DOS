<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 Source Code

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

This repo contains the original source-code and compiled binaries for MS-DOS v1.25 and MS-DOS v2.0, plus the source-code for MS-DOS v4.00 jointly developed by IBM and
Microsoft.

The MS-DOS v1.25 and v2.0 files [were originally shared at the Computer History Museum on March 25th, 2014]( http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) and are being (re)published in this repo to make them easier to find, reference-to in external writing and works, and to allow exploration and experimentation for those interested in early PC Operating Systems.

# About this fork

This fork adds a working build system and CI pipeline for the MS-DOS 4.0 source code. It builds the original 8086 assembly and C sources into a complete, bootable operating system -- both the OEM **MS-DOS** and **IBM PC-DOS** flavors.

The build produces ready-to-use disk images (64MB hard disk and period-correct floppies from 360KB to 1.44MB) that boot in QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, or on real vintage hardware. Pre-built images are available on the [Releases](https://github.com/tgies/MS-DOS/releases) page.

This work benefits greatly from prior work done by others to get the MS-DOS 4.0 source code building by cleaning up some minor issues in the released source tree (wrong file paths and mangled character encodings), including, but not limited to, [ecm](https://hg.pushbx.org/ecm/msdos4) and [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Try it

Download `msdos4.img` from the [latest release](https://github.com/tgies/MS-DOS/releases) and boot it:

```bash
qemu-system-i386 -hda msdos4.img
```

Or with DOSBox, start DOSBox as normal and then boot the image (omit `-l C` if using a floppy image):

```bash
BOOT msdos4.img -l C
```

Or with dosemu (download `msdos4-dosemu.img`, which has a special header for dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# License

All files within this repo are released under the [MIT License]( https://en.wikipedia.org/wiki/MIT_License) as per the [LICENSE file](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) stored in the root of this repo.

# For historical reference

> **NOTE:** This section is preserved from Microsoft's original README.md accompanying the source code release. The build scripts and tooling in this repository are maintained separately from the historical source code. Pull requests for improvements to the build system are welcome.

The source files in this repo are for historical reference and will be kept static, so please **don’t send** Pull Requests suggesting any modifications to the source files, but feel free to fork this repo and experiment 😊.  

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).  For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# Building MS-DOS 4.0

Pre-built disk images are available on the [Releases](https://github.com/tgies/MS-DOS/releases) page. To build from source:

## Requirements

- dosemu2
- mtools
- mkfatimage16 (from dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 or later is required.** comcom64 is the command.com replacement used by dosemu2. Some earlier versions have a [bug in the `COPY` command](https://github.com/dosemu2/comcom64/pull/117) that breaks file concatenation (`copy /b a+b dest`) when invoked via `COMMAND /C`, which nmake uses to execute makefile commands. This causes the IO.SYS build to fail silently.
>
> Check your version with `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) or check your package manager. If you're on an older version:
> - **Recommended:** Update comcom64 to 0.4-0~202602051302 or later
> - **Workaround:** Build comcom64 from source: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (ensure `make install` installs over top of your existing `command.efi`)

## Quick Start

```bash
cd v4.0
./mak.sh              # Build DOS 4
./mkhdimg.sh          # Create 64MB hard disk image
./mkhdimg.sh --floppy # Create 1.44MB boot floppy
```

## Build Flavors

The source code supports multiple build configurations. Use the `--flavor` flag:

```bash
./mak.sh                    # Build MS-DOS (default)
./mak.sh --flavor=pcdos     # Build IBM PC-DOS
```

| Flavor | System Files | Description |
|--------|--------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS for IBM-compatible PCs (default, recommended) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (for historical accuracy) |

Both flavors include IBM PC hardware-specific code (INT 10H video BIOS, 8259 PIC, PCjr ROM cartridge support).

**Important:** The **msdos** flavor contains more bug fixes than **pcdos**. Presumably, Microsoft could push fixes to OEM MS-DOS faster than IBM's approval process allowed for PC-DOS. It's known that IBM essentially took over DOS development temporarily circa DOS 3.3 through DOS 4.0, so one possible theory is that PC-DOS was essentially considered frozen when the code was handed back to Microsoft, who found a number of bugs that they fixed in OEM MS-DOS without touching PC-DOS.

Notable differences:
- DOS kernel INT 24 (critical error) handling fix
- FDISK integer overflow protection for large disks
- Larger EMS buffers in FASTOPEN
- Better input validation in EXE2BIN

The default **msdos** flavor is what OEMs like Compaq, Dell, and HP shipped as "MS-DOS" on their IBM-compatible PCs. This source release actually appears to derive from the OAK (OEM Adaptation Kit) -- the code Microsoft provided to OEMs to allow them to customize MS-DOS for their hardware.

## Disk Image Options

```bash
# Hard disk images (produces msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # 64MB FAT16 image
./mkhdimg.sh --size 32          # 32MB image

# Floppy images (all sizes)
./mkhdimg.sh --floppy           # 1.44MB minimal (system files only)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB with utilities
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB with utilities
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB with utilities
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB with utilities
```

Hard disk images are produced in two formats: `msdos4.img` is a raw disk image that works with QEMU, VirtualBox, bochs, and most emulators. `msdos4-dosemu.img` is the dosemu hdimage format (128-byte header). Floppy images are raw and work everywhere.

## Known Limitations

- **DOS Shell not included**: The DOS Shell (DOSSHELL) source code was not open-sourced. SELECT.EXE (the installer) shares some code with DOSSHELL and cannot be built.
- **PC-DOS branding incomplete**: The `--flavor=pcdos` build uses IBM system file names (IBMBIO.COM, IBMDOS.COM) and some PC-DOS-specific code paths, but still displays "MS-DOS" in VER and the startup banner. This is because IBM's message file (`usa-ibm.msg` or similar) was not open-sourced—only the Microsoft-branded `usa-ms.msg` was released.
- **Non-IBM-compatible build**: A third configuration (`IBMVER=FALSE`) exists in the source for non-IBM-compatible hardware, but it doesn't build successfully. It appears that this configuration is for some of the short-lived non-IBM-compatible x86 PCs from the early 1980s -- it specifically dodges certain IBM-compatible-specific code paths dealing with hardware like the BIOS, PIC, PIT, and so on. Further investigation is necessarily, but it's likely that this source tree is incomplete and missing the hardware-specific code (IO.SYS stuff) that would need to be provided to implement DOS services on such hardware.

# Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
