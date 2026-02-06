<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 Broncode

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Deze repo bevat de originele broncode en gecompileerde binaries voor MS-DOS v1.25 en MS-DOS v2.0, plus de broncode voor MS-DOS v4.00 die gezamenlijk is ontwikkeld door IBM en Microsoft.

De bestanden voor MS-DOS v1.25 en v2.0 [werden oorspronkelijk gedeeld in het Computer History Museum op 25 maart 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) en worden in deze repo (opnieuw) gepubliceerd om ze gemakkelijker vindbaar te maken, ernaar te verwijzen in externe teksten en werken, en om verkenning en experimenten mogelijk te maken voor diegenen die geïnteresseerd zijn in vroege pc-besturingssystemen.

# Over deze fork

Deze fork voegt een werkend bouwsysteem en CI-pipeline toe voor de MS-DOS 4.0-broncode. Het bouwt de originele 8086 assembly- en C-bronnen tot een volledig, opstartbaar besturingssysteem -- zowel de OEM **MS-DOS** als **IBM PC-DOS** varianten.

De build produceert kant-en-klare schijfkopieën (64MB harde schijf en historisch correcte diskettes van 360KB tot 1,44MB) die opstarten in QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, of op echte vintage hardware. Vooraf gebouwde images zijn beschikbaar op de [Releases](https://github.com/tgies/MS-DOS/releases)-pagina.

Dit werk profiteert enorm van eerder werk dat door anderen is gedaan om de MS-DOS 4.0-broncode te kunnen bouwen door enkele kleine problemen in de vrijgegeven broncodeboom op te lossen (verkeerde bestandspaden en verminkte tekencoderingen), waaronder, maar niet beperkt tot, [ecm](https://hg.pushbx.org/ecm/msdos4) en [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Probeer het

Download `msdos4.img` van de [laatste release](https://github.com/tgies/MS-DOS/releases) en start het op:

```bash
qemu-system-i386 -hda msdos4.img
```

Of met DOSBox, start DOSBox zoals gewoonlijk en start vervolgens de image (laat `-l C` weg als u een diskette-image gebruikt):

```bash
BOOT msdos4.img -l C
```

Of met dosemu (download `msdos4-dosemu.img`, die een speciale header heeft voor dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licentie

Alle bestanden in deze repo worden vrijgegeven onder de [MIT-licentie](https://en.wikipedia.org/wiki/MIT_License) volgens het [LICENSE-bestand](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) dat is opgeslagen in de root van deze repo.

# Voor historische referentie

> **OPMERKING:** Deze sectie is behouden uit de originele README.md van Microsoft die bij de vrijgave van de broncode zat. De bouwscripts en tools in deze repository worden apart van de historische broncode onderhouden. Pull requests voor verbeteringen aan het bouwsysteem zijn welkom.

De bronbestanden in deze repo zijn voor historische referentie en blijven statisch, dus stuur alstublieft **geen** Pull Requests die wijzigingen in de bronbestanden voorstellen, maar voel u vrij om deze repo te forken en te experimenteren 😊.

Dit project heeft de [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/) aangenomen. Zie voor meer informatie de [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) of neem contact op met [opencode@microsoft.com](mailto:opencode@microsoft.com) voor eventuele aanvullende vragen of opmerkingen.

# MS-DOS 4.0 bouwen

Vooraf gebouwde schijfkopieën zijn beschikbaar op de [Releases](https://github.com/tgies/MS-DOS/releases)-pagina. Om vanaf de broncode te bouwen:

## Vereisten

- dosemu2
- mtools
- mkfatimage16 (van dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 of nieuwer is vereist.** comcom64 is de vervanging voor command.com die door dosemu2 wordt gebruikt. Sommige eerdere versies hebben een [bug in het `COPY`-commando](https://github.com/dosemu2/comcom64/pull/117) die het samenvoegen van bestanden (`copy /b a+b dest`) verbreekt wanneer dit via `COMMAND /C` wordt aangeroepen, wat nmake gebruikt om makefile-commando's uit te voeren. Dit zorgt ervoor dat de IO.SYS-build stilzwijgend mislukt.
>
> Controleer uw versie met `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) of controleer uw pakketbeheerder. Als u een oudere versie heeft:
> - **Aanbevolen:** Update comcom64 naar 0.4-0~202602051302 of nieuwer
> - **Oplossing:** Bouw comcom64 vanaf de broncode: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (zorg ervoor dat `make install` over uw bestaande `command.efi` installeert)

## Snelstart

```bash
cd v4.0
./mak.sh              # Bouw DOS 4
./mkhdimg.sh          # Maak 64MB harde schijf-image
./mkhdimg.sh --floppy # Maak 1,44MB opstartdiskette
```

## Bouwvarianten

De broncode ondersteunt meerdere bouwconfiguraties. Gebruik de `--flavor` vlag:

```bash
./mak.sh                    # Bouw MS-DOS (standaard)
./mak.sh --flavor=pcdos     # Bouw IBM PC-DOS
```

| Variant | Systeembestanden | Beschrijving |
|---------|------------------|--------------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS voor IBM-compatibele PC's (standaard, aanbevolen) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (voor historische nauwkeurigheid) |

Beide varianten bevatten IBM PC hardware-specifieke code (INT 10H video BIOS, 8259 PIC, PCjr ROM cartridge ondersteuning).

**Belangrijk:** De **msdos** variant bevat meer bugfixes dan **pcdos**. Vermoedelijk kon Microsoft fixes sneller naar OEM MS-DOS pushen dan het goedkeuringsproces van IBM voor PC-DOS toestond. Het is bekend dat IBM de DOS-ontwikkeling tijdelijk grotendeels overnam rond DOS 3.3 tot DOS 4.0, dus een mogelijke theorie is dat PC-DOS in wezen als bevroren werd beschouwd toen de code terug werd gegeven aan Microsoft, die een aantal bugs vond en deze in OEM MS-DOS repareerde zonder PC-DOS aan te raken.

Opmerkelijke verschillen:
- DOS kernel INT 24 (kritieke fout) afhandelingsfix
- FDISK integer overflow-beveiliging voor grote schijven
- Grotere EMS-buffers in FASTOPEN
- Betere invoervalidatie in EXE2BIN

De standaard **msdos** variant is wat OEM's zoals Compaq, Dell en HP leverden als "MS-DOS" op hun IBM-compatibele PC's. Deze broncode-release lijkt eigenlijk afkomstig te zijn van de OAK (OEM Adaptation Kit) -- de code die Microsoft aan OEM's verstrekte om hen in staat te stellen MS-DOS aan te passen aan hun hardware.

## Schijfkopie-opties

```bash
# Harde schijf-images (produceert msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # 64MB FAT16 image
./mkhdimg.sh --size 32          # 32MB image

# Diskette-images (alle formaten)
./mkhdimg.sh --floppy           # 1,44MB minimaal (alleen systeembestanden)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB met hulpprogramma's
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB met hulpprogramma's
./mkhdimg.sh --floppy=1200 --floppy-full  # 1,2MB met hulpprogramma's
./mkhdimg.sh --floppy=1440 --floppy-full  # 1,44MB met hulpprogramma's
```

Harde schijf-images worden in twee formaten geproduceerd: `msdos4.img` is een raw disk image die werkt met QEMU, VirtualBox, bochs en de meeste emulators. `msdos4-dosemu.img` is het dosemu hdimage-formaat (128-byte header). Diskette-images zijn raw en werken overal.

## Bekende beperkingen

- **DOS Shell niet inbegrepen**: De broncode van DOS Shell (DOSSHELL) is niet open-source gemaakt. SELECT.EXE (het installatieprogramma) deelt code met DOSSHELL en kan niet worden gebouwd.
- **PC-DOS branding onvolledig**: De `--flavor=pcdos` build gebruikt IBM systeembestandsnamen (IBMBIO.COM, IBMDOS.COM) en sommige PC-DOS-specifieke codepaden, maar toont nog steeds "MS-DOS" in VER en de opstartbanner. Dit komt omdat het berichtbestand van IBM (`usa-ibm.msg` of vergelijkbaar) niet open-source is gemaakt—alleen de Microsoft-gemerkte `usa-ms.msg` is vrijgegeven.
- **Niet-IBM-compatibele build**: Een derde configuratie (`IBMVER=FALSE`) bestaat in de broncode voor niet-IBM-compatibele hardware, maar deze bouwt niet succesvol. Het lijkt erop dat deze configuratie bedoeld is voor enkele van de kortstondige niet-IBM-compatibele x86 PC's uit het begin van de jaren 80 -- het vermijdt specifiek bepaalde IBM-compatibel-specifieke codepaden die te maken hebben met hardware zoals de BIOS, PIC, PIT, enzovoort. Verder onderzoek is nodig, maar het is waarschijnlijk dat deze broncodeboom onvolledig is en de hardware-specifieke code (IO.SYS-zaken) mist die nodig zou zijn om DOS-services op dergelijke hardware te implementeren.

# Handelsmerken

Dit project kan handelsmerken of logo's bevatten voor projecten, producten of diensten. Geautoriseerd gebruik van handelsmerken of logo's van Microsoft is onderworpen aan en moet voldoen aan de [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Het gebruik van handelsmerken of logo's van Microsoft in gewijzigde versies van dit project mag geen verwarring veroorzaken of sponsoring door Microsoft impliceren.
Elk gebruik van handelsmerken of logo's van derden is onderworpen aan het beleid van die derden.
