<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logga" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 källkod

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Det här repot innehåller originalkällkoden och kompilerade binärfiler för MS-DOS v1.25 och MS-DOS v2.0, samt källkoden för MS-DOS v4.00 som utvecklades gemensamt av IBM och Microsoft.

Filerna för MS-DOS v1.25 och v2.0 [delades ursprungligen på Computer History Museum den 25 mars 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) och publiceras (åter) i detta repo för att göra dem lättare att hitta, referera till i externa artiklar och verk, samt för att möjliggöra utforskning och experiment för dem som är intresserade av tidiga PC-operativsystem.

# Om denna fork

Denna fork lägger till ett fungerande byggsystem och CI-pipeline för MS-DOS 4.0 källkoden. Den bygger de ursprungliga 8086 assembly- och C-källorna till ett komplett, startbart operativsystem -- både OEM **MS-DOS** och **IBM PC-DOS** varianterna.

Bygget producerar färdiga diskavbilder (64MB hårddisk och periodriktiga disketter från 360KB till 1.44MB) som startar i QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, eller på riktig vintage-hårdvara. Färdigbyggda avbilder finns tillgängliga på [Releases](https://github.com/tgies/MS-DOS/releases)-sidan.

Detta arbete drar stor nytta av tidigare arbete av andra för att få MS-DOS 4.0 källkoden att bygga genom att rensa upp några mindre problem i det släppta källkodsträdet (felaktiga filsökvägar och skadade teckenkodningar), inklusive, men inte begränsat till, [ecm](https://hg.pushbx.org/ecm/msdos4) och [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Prova det

Ladda ner `msdos4.img` från den [senaste releasen](https://github.com/tgies/MS-DOS/releases) och starta den:

```bash
qemu-system-i386 -hda msdos4.img
```

Eller med DOSBox, starta DOSBox som vanligt och starta sedan avbilden (utelämna `-l C` om du använder en diskettavbild):

```bash
BOOT msdos4.img -l C
```

Eller med dosemu (ladda ner `msdos4-dosemu.img`, som har en speciell header för dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licens

Alla filer i detta repo är släppta under [MIT-licensen](https://en.wikipedia.org/wiki/MIT_License) enligt [LICENSE-filen](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) som finns i roten av detta repo.

# För historisk referens

> **OBS:** Detta avsnitt är bevarat från Microsofts ursprungliga README.md som medföljde källkodsreleasen. Byggskripten och verktygen i detta repositorium underhålls separat från den historiska källkoden. Pull requests för förbättringar av byggsystemet är välkomna.

Källkodsfilerna i detta repo är för historisk referens och kommer att hållas statiska, så var vänlig att **inte skicka** Pull Requests med förslag på ändringar i källkodsfilerna, men forka gärna repot och experimentera 😊.

Detta projekt har antagit [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). För mer information se [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) eller kontakta [opencode@microsoft.com](mailto:opencode@microsoft.com) med eventuella frågor eller kommentarer.

# Bygga MS-DOS 4.0

Färdigbyggda diskavbilder finns tillgängliga på [Releases](https://github.com/tgies/MS-DOS/releases)-sidan. För att bygga från källkod:

## Krav

- dosemu2
- mtools
- mkfatimage16 (från dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 eller senare krävs.** comcom64 är command.com-ersättningen som används av dosemu2. Några tidigare versioner har en [bugg i `COPY`-kommandot](https://github.com/dosemu2/comcom64/pull/117) som bryter filkonkatenering (`copy /b a+b dest`) när det anropas via `COMMAND /C`, vilket nmake använder för att exekvera makefile-kommandon. Detta orsakar att IO.SYS-bygget misslyckas tyst.
>
> Kontrollera din version med `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) eller kolla din pakethanterare. Om du har en äldre version:
> - **Rekommenderat:** Uppdatera comcom64 till 0.4-0~202602051302 eller senare
> - **Workaround:** Bygg comcom64 från källkod: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (säkerställ att `make install` installerar över din befintliga `command.efi`)

## Snabbstart

```bash
cd v4.0
./mak.sh              # Bygg DOS 4
./mkhdimg.sh          # Skapa 64MB hårddiskavbild
./mkhdimg.sh --floppy # Skapa 1.44MB startdiskett
```

## Byggvarianter

Källkoden stödjer flera byggkonfigurationer. Använd `--flavor`-flaggan:

```bash
./mak.sh                    # Bygg MS-DOS (standard)
./mak.sh --flavor=pcdos     # Bygg IBM PC-DOS
```

| Variant | Systemfiler | Beskrivning |
|---------|-------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS för IBM-kompatibla PCer (standard, rekommenderad) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (för historisk korrekthet) |

Båda varianterna inkluderar IBM PC-hårdvaruspecifik kod (INT 10H video BIOS, 8259 PIC, PCjr ROM-kassett-stöd).

**Viktigt:** **msdos**-varianten innehåller fler buggfixar än **pcdos**. Förmodligen kunde Microsoft pusha fixar till OEM MS-DOS snabbare än IBMs godkännandeprocess tillät för PC-DOS. Det är känt att IBM i princip tog över DOS-utvecklingen tillfälligt cirka DOS 3.3 till och med DOS 4.0, så en möjlig teori är att PC-DOS i princip ansågs frusen när koden lämnades tillbaka till Microsoft, som hittade ett antal buggar som de fixade i OEM MS-DOS utan att röra PC-DOS.

Noterbara skillnader:
- DOS-kernel INT 24 (kritiskt fel) hanteringsfix
- FDISK integer overflow-skydd för stora diskar
- Större EMS-buffertar i FASTOPEN
- Bättre indata-validering i EXE2BIN

Standard **msdos**-varianten är vad OEM-tillverkare som Compaq, Dell och HP skeppade som "MS-DOS" på sina IBM-kompatibla PCer. Denna källkodsrelease verkar faktiskt härstamma från OAK (OEM Adaptation Kit) -- koden Microsoft tillhandahöll till OEM-tillverkare för att låta dem anpassa MS-DOS till sin hårdvara.

## Diskavbildsalternativ

```bash
# Hårddiskavbilder (producerar msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # 64MB FAT16-avbild
./mkhdimg.sh --size 32          # 32MB-avbild

# Diskettavbilder (alla storlekar)
./mkhdimg.sh --floppy           # 1.44MB minimal (endast systemfiler)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB med verktyg
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB med verktyg
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB med verktyg
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB med verktyg
```

Hårddiskavbilder produceras i två format: `msdos4.img` är en rå diskavbild som fungerar med QEMU, VirtualBox, bochs och de flesta emulatorer. `msdos4-dosemu.img` är dosemu hdimage-formatet (128-byte header). Diskettavbilder är råa och fungerar överallt.

## Kända begränsningar

- **DOS Shell inte inkluderad**: DOS Shell (DOSSHELL) källkoden var inte öppen källkod. SELECT.EXE (installeraren) delar viss kod med DOSSHELL och kan inte byggas.
- **PC-DOS-varumärkesprofilering ofullständig**: `--flavor=pcdos`-bygget använder IBMs systemfilnamn (IBMBIO.COM, IBMDOS.COM) och vissa PC-DOS-specifika kodsökvägar, men visar fortfarande "MS-DOS" i VER och startbanern. Detta beror på att IBMs meddelandefil (`usa-ibm.msg` eller liknande) inte var öppen källkod—endast den Microsoft-varumärkta `usa-ms.msg` släpptes.
- **Icke-IBM-kompatibelt bygge**: En tredje konfiguration (`IBMVER=FALSE`) existerar i källkoden för icke-IBM-kompatibel hårdvara, men den bygger inte framgångsrikt. Det verkar som att denna konfiguration är för några av de kortvariga icke-IBM-kompatibla x86-PCerna från tidiga 1980-talet -- den undviker specifikt vissa IBM-kompatibel-specifika kodsökvägar som hanterar hårdvara som BIOS, PIC, PIT, och så vidare. Ytterligare undersökning är nödvändig, men det är troligt att detta källkodsträd är ofullständigt och saknar den hårdvaruspecifika koden (IO.SYS-grejer) som skulle behöva tillhandahållas för att implementera DOS-tjänster på sådan hårdvara.

# Varumärken

Detta projekt kan innehålla varumärken eller logotyper för projekt, produkter eller tjänster. Auktoriserad användning av Microsofts varumärken eller logotyper är föremål för och måste följa [Microsofts riktlinjer för varumärken och varumärkesprofilering](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Användning av Microsofts varumärken eller logotyper i modifierade versioner av detta projekt får inte orsaka förvirring eller antyda Microsoft-sponsring. All användning av tredjepartsvarumärken eller logotyper är föremål för dessa tredjeparters policyer.
