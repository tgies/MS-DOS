<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">   

# MS-DOS v1.25, v2.0, v4.0 Source Code

This repo contains the original source-code and compiled binaries for MS-DOS v1.25 and MS-DOS v2.0, plus the source-code for MS-DOS v4.00 jointly developed by IBM and
Microsoft.

The MS-DOS v1.25 and v2.0 files [were originally shared at the Computer History Museum on March 25th, 2014]( http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) and are being (re)published in this repo to make them easier to find, reference-to in external writing and works, and to allow exploration and experimentation for those interested in early PC Operating Systems.  

# License

All files within this repo are released under the [MIT License]( https://en.wikipedia.org/wiki/MIT_License) as per the [LICENSE file](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) stored in the root of this repo.

# For historical reference

The source files in this repo are for historical reference and will be kept static, so please **don’t send** Pull Requests suggesting any modifications to the source files, but feel free to fork this repo and experiment 😊.  

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).  For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# Building MS-DOS 4.0

This fork includes build scripts and CI workflows for MS-DOS 4.0. The build produces bootable disk images.

## Requirements

- dosemu2
- mtools
- mkfatimage16 (from dosemu2)

## Quick Start

```bash
cd v4.0
./mak.sh              # Build DOS 4 (takes ~10-15 minutes)
./mkhdimg.sh          # Create 64MB hard disk image
./mkhdimg.sh --floppy # Create 1.44MB boot floppy
```

## Build Flavors

The source code supports three build configurations via `src/INC/VERSION.INC`:

| Flavor | IBMVER | IBMCOPYRIGHT | System Files | Description |
|--------|--------|--------------|--------------|-------------|
| **Clone** | TRUE | FALSE | IO.SYS, MSDOS.SYS | OEM version for IBM-compatible PCs (default) |
| IBM PC-DOS | TRUE | TRUE | IBMBIO.COM, IBMDOS.COM | Official IBM version |
| MS-DOS (portable) | FALSE | FALSE | IO.SYS, MSDOS.SYS | For non-IBM-compatible hardware |

The default build produces the **Clone** flavor, which is what OEMs like Compaq and HP shipped as "MS-DOS 4.01" on their IBM-compatible PCs. This uses IBM PC hardware assumptions but MS-DOS branding.

## Disk Image Options

```bash
# Hard disk images
./mkhdimg.sh                    # 64MB FAT16 image
./mkhdimg.sh --size 32          # 32MB image

# Floppy images (all sizes)
./mkhdimg.sh --floppy           # 1.44MB minimal (system files only)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB with utilities
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB with utilities
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB with utilities
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB with utilities
```

## Known Limitations

- **DOS Shell not included**: The DOS Shell (DOSSHELL) source code was not open-sourced, so SELECT.EXE (the installer) cannot be built.
- **MS-DOS portable build**: The `IBMVER=FALSE` configuration may have build issues (needs investigation).

# Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
