<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 Quellcode

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Dieses Repository enthält den ursprünglichen Quellcode und die kompilierten Binärdateien für MS-DOS v1.25 und MS-DOS v2.0, sowie den Quellcode für MS-DOS v4.00, das gemeinsam von IBM und Microsoft entwickelt wurde.

Die Dateien für MS-DOS v1.25 und v2.0 [wurden ursprünglich am 25. März 2014 mit dem Computer History Museum geteilt](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) und werden in diesem Repository (erneut) veröffentlicht, um sie leichter auffindbar zu machen, das Referenzieren in Texten und Arbeiten zu vereinfachen und Auseinandersetzung sowie Experimente für diejenigen zu ermöglichen, die sich für frühe PC-Betriebssysteme interessieren.

# Über diesen Fork

Dieser Fork fügt ein funktionierendes Build-System und eine CI-Pipeline für den MS-DOS 4.0 Quellcode hinzu. Er erstellt aus den originalen 8086-Assembly- und C-Quellen ein vollständiges, bootfähiges Betriebssystem -- sowohl in der OEM-**MS-DOS**- als auch in der **IBM PC-DOS**-Variante.

Der Build erzeugt einsatzbereite Disk-Images (64MB-Festplatte und zeitgenössisch korrekte Disketten von 360KB bis 1,44MB), die in QEMU, VirtualBox, bochs, dosemu, 86Box, PCem oder auf echter Vintage-Hardware booten. Vorgefertigte Images sind auf der Seite [Releases](https://github.com/tgies/MS-DOS/releases) verfügbar.

Diese Arbeit profitiert erheblich von früheren Arbeiten anderer, die den MS-DOS 4.0-Quellcode durch Behebung kleinerer Probleme im veröffentlichten Quellbaum (falsche Dateipfade und beschädigte Zeichenkodierungen) zum Laufen gebracht haben, einschließlich, aber nicht beschränkt auf, [ecm](https://hg.pushbx.org/ecm/msdos4) und [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Ausprobieren

Laden Sie `msdos4.img` vom [neuesten Release](https://github.com/tgies/MS-DOS/releases) herunter und booten Sie es:

```bash
qemu-system-i386 -hda msdos4.img
```

Oder mit DOSBox: Starten Sie DOSBox normal und booten Sie dann das Image (lassen Sie `-l C` weg, wenn Sie ein Floppy-Image verwenden):

```bash
BOOT msdos4.img -l C
```

Oder mit dosemu (laden Sie `msdos4-dosemu.img` herunter, das einen speziellen Header für dosemu2 hat):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Lizenz

Alle Dateien in diesem Repository werden unter der [MIT-Lizenz](https://de.wikipedia.org/wiki/MIT-Lizenz) gemäß der [LICENSE-Datei](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) im Stammverzeichnis dieses Repositorys veröffentlicht.

# Für historische Referenz

> **HINWEIS:** Dieser Abschnitt ist aus Microsofts ursprünglicher README.md erhalten, die die Quellcode-Veröffentlichung begleitete. Die Build-Skripte und Werkzeuge in diesem Repository werden getrennt vom historischen Quellcode gepflegt. Pull Requests für Verbesserungen am Build-System sind willkommen.

Die Quelldateien in diesem Repository dienen als geschichtliche Referenz und bleiben unverändert. Bitte sende **keine** Pull Requests, die Änderungen an den Quelldateien vorschlagen, aber zögere nicht, dieses Repository zu forken und zu experimentieren 😊.

Dieses Projekt übernimmt den [Microsoft Open Source Verhaltenskodex](https://opensource.microsoft.com/codeofconduct/). Weitere Informationen finden Sie im [Verhaltenskodex FAQ](https://opensource.microsoft.com/codeofconduct/faq/) oder kontaktieren Sie [opencode@microsoft.com](mailto:opencode@microsoft.com) mit zusätzlichen Fragen oder Kommentaren.

# MS-DOS 4.0 erstellen

Vorgefertigte Disk-Images sind auf der Seite [Releases](https://github.com/tgies/MS-DOS/releases) verfügbar. Um aus dem Quellcode zu erstellen:

## Voraussetzungen

- dosemu2
- mtools
- mkfatimage16 (aus dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 oder neuer ist erforderlich.** comcom64 ist der command.com-Ersatz, der von dosemu2 verwendet wird. Einige frühere Versionen haben einen [Bug im `COPY`-Befehl](https://github.com/dosemu2/comcom64/pull/117), der die Dateiverkettung (`copy /b a+b dest`) beschädigt, wenn sie über `COMMAND /C` aufgerufen wird, was nmake zum Ausführen von Makefile-Befehlen verwendet. Dies führt dazu, dass der IO.SYS-Build stillschweigend fehlschlägt.
>
> Überprüfen Sie Ihre Version mit `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) oder prüfen Sie Ihren Paketmanager. Wenn Sie eine ältere Version haben:
> - **Empfohlen:** Aktualisieren Sie comcom64 auf 0.4-0~202602051302 oder neuer
> - **Workaround:** Erstellen Sie comcom64 aus dem Quellcode: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (stellen Sie sicher, dass `make install` über Ihre bestehende `command.efi` installiert)

## Schnellstart

```bash
cd v4.0
./mak.sh              # DOS 4 erstellen
./mkhdimg.sh          # 64MB-Festplatten-Image erstellen
./mkhdimg.sh --floppy # 1,44MB-Boot-Diskette erstellen
```

## Build-Varianten

Der Quellcode unterstützt mehrere Build-Konfigurationen. Verwenden Sie das Flag `--flavor`:

```bash
./mak.sh                    # MS-DOS erstellen (Standard)
./mak.sh --flavor=pcdos     # IBM PC-DOS erstellen
```

| Variante | Systemdateien | Beschreibung |
|----------|---------------|--------------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS für IBM-kompatible PCs (Standard, empfohlen) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (für historische Genauigkeit) |

Beide Varianten enthalten IBM-PC-hardwarespezifischen Code (INT 10H Video-BIOS, 8259 PIC, PCjr ROM-Cartridge-Unterstützung).

**Wichtig:** Die **msdos**-Variante enthält mehr Bugfixes als **pcdos**. Vermutlich konnte Microsoft Korrekturen schneller in OEM MS-DOS einbringen, als IBMs Genehmigungsprozess für PC-DOS zuließ. Es ist bekannt, dass IBM etwa zwischen DOS 3.3 und DOS 4.0 vorübergehend im Wesentlichen die DOS-Entwicklung übernahm. Eine mögliche Theorie ist, dass PC-DOS als im Wesentlichen eingefroren betrachtet wurde, als der Code an Microsoft zurückgegeben wurde, die dann eine Reihe von Fehlern fanden, die sie in OEM MS-DOS behobenen, ohne PC-DOS anzutasten.

Bemerkenswerte Unterschiede:
- DOS-Kernel INT 24 (kritischer Fehler) Behandlungsfix
- FDISK Integer-Überlaufschutz für große Festplatten
- Größere EMS-Puffer in FASTOPEN
- Bessere Eingabevalidierung in EXE2BIN

Die Standard-**msdos**-Variante ist das, was OEMs wie Compaq, Dell und HP als "MS-DOS" auf ihren IBM-kompatiblen PCs auslieferten. Diese Quellcode-Veröffentlichung scheint tatsächlich vom OAK (OEM Adaptation Kit) abzustammen -- dem Code, den Microsoft OEMs zur Verfügung stellte, um ihnen die Anpassung von MS-DOS an ihre Hardware zu ermöglichen.

## Disk-Image-Optionen

```bash
# Festplatten-Images (erzeugt msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # 64MB FAT16-Image
./mkhdimg.sh --size 32          # 32MB-Image

# Disketten-Images (alle Größen)
./mkhdimg.sh --floppy           # 1,44MB minimal (nur Systemdateien)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB mit Dienstprogrammen
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB mit Dienstprogrammen
./mkhdimg.sh --floppy=1200 --floppy-full  # 1,2MB mit Dienstprogrammen
./mkhdimg.sh --floppy=1440 --floppy-full  # 1,44MB mit Dienstprogrammen
```

Festplatten-Images werden in zwei Formaten erstellt: `msdos4.img` ist ein Raw-Disk-Image, das mit QEMU, VirtualBox, bochs und den meisten Emulatoren funktioniert. `msdos4-dosemu.img` ist das dosemu-hdimage-Format (128-Byte-Header). Disketten-Images sind raw und funktionieren überall.

## Bekannte Einschränkungen

- **DOS Shell nicht enthalten**: Der Quellcode der DOS Shell (DOSSHELL) wurde nicht als Open Source veröffentlicht. SELECT.EXE (der Installer) teilt einigen Code mit DOSSHELL und kann nicht erstellt werden.
- **PC-DOS-Branding unvollständig**: Der `--flavor=pcdos`-Build verwendet IBM-Systemdateinamen (IBMBIO.COM, IBMDOS.COM) und einige PC-DOS-spezifische Codepfade, zeigt aber immer noch "MS-DOS" in VER und dem Startbanner an. Dies liegt daran, dass IBMs Nachrichtendatei (`usa-ibm.msg` oder ähnlich) nicht als Open Source veröffentlicht wurde -- nur die Microsoft-gebrandete `usa-ms.msg` wurde freigegeben.
- **Nicht-IBM-kompatibler Build**: Eine dritte Konfiguration (`IBMVER=FALSE`) existiert im Quellcode für nicht-IBM-kompatible Hardware, aber sie lässt sich nicht erfolgreich erstellen. Es scheint, dass diese Konfiguration für einige der kurzlebigen nicht-IBM-kompatiblen x86-PCs der frühen 1980er Jahre gedacht ist -- sie umgeht ausdrücklich bestimmte IBM-kompatible-spezifische Codepfade, die sich mit Hardware wie BIOS, PIC, PIT usw. befassen. Weitere Untersuchungen sind notwendig, aber es ist wahrscheinlich, dass dieser Quellbaum unvollständig ist und der hardwarespezifische Code (IO.SYS-Material) fehlt, der bereitgestellt werden müsste, um DOS-Dienste auf solcher Hardware zu implementieren.

# Markenzeichen

Dieses Projekt kann Markenzeichen oder Logos für Projekte, Produkte oder Dienstleistungen enthalten. Die autorisierte Verwendung von Microsoft-Markenzeichen oder -Logos unterliegt und muss den [Microsoft-Marken- und Markenrichtlinien](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general) folgen.
Die Verwendung von Microsoft-Markenzeichen oder -Logos in modifizierten Versionen dieses Projekts darf keine Verwirrung stiften oder Microsoft-Sponsoring implizieren.
Jegliche Verwendung von Markenzeichen oder Logos Dritter unterliegt den Richtlinien dieser Dritten.
