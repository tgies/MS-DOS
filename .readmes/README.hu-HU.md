<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 Forráskód

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Ez a tároló tartalmazza az eredeti forráskódot és a futtatható bináris állományokat az MS-DOS v1.25-höz és az MS-DOS v2.0-hoz, valamint az MS-DOS v4.00 forráskódját, amelyet az IBM és a Microsoft közösen fejlesztett.

Az MS-DOS v1.25 és v2.0 fájlok már korábban [megosztásra kerültek a Computer History Museum oldalán 2014. március 25-én](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/), és most ebben a tárolóban is elérhetőek, hogy könnyebben megtalálhatóak és hivatkozhatóak legyenek külső írásokban és művekben, valamint hogy lehetővé tegyék a felfedezést és kísérletezést azok számára, akik érdeklődnek a korai PC operációs rendszerek iránt.

# Erről a forkról

Ez a fork működő build rendszert és CI pipeline-t ad az MS-DOS 4.0 forráskódjához. Az eredeti 8086 assembly és C forráskódokat teljes, bootolható operációs rendszerré fordítja -- mind az OEM **MS-DOS**, mind az **IBM PC-DOS** változatokban.

A build elkészíti a használatra kész lemezképeket (64MB merevlemez és korabeli hajlékonylemezek 360KB-tól 1.44MB-ig), amelyek bootolnak QEMU-ban, VirtualBox-ban, bochs-ban, dosemu-ban, 86Box-ban, PCem-ben, vagy valódi régi hardveren. Előre összeállított lemezképek elérhetőek a [Releases](https://github.com/tgies/MS-DOS/releases) oldalon.

Ez a munka sokat profitál mások korábbi munkájából, akik az MS-DOS 4.0 forráskód fordíthatóvá tételén dolgoztak a kiadott forrásfa néhány kisebb problémájának (hibás fájl elérési utak és tönkrement karakterkódolások) javításával, beleértve, de nem kizárólagosan: [ecm](https://hg.pushbx.org/ecm/msdos4) és [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Próbáld ki

Töltsd le az `msdos4.img` fájlt a [legfrissebb kiadásból](https://github.com/tgies/MS-DOS/releases) és bootold:

```bash
qemu-system-i386 -hda msdos4.img
```

Vagy DOSBox-szal, indítsd el a DOSBox-ot szokás szerint, majd bootold a lemezképet (hagyd el a `-l C` kapcsolót, ha hajlékonylemezt használsz):

```bash
BOOT msdos4.img -l C
```

Vagy dosemu-val (töltsd le az `msdos4-dosemu.img` fájlt, amely speciális fejlécet tartalmaz a dosemu2 számára):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licensz

Az összes fájl ebben a tárolóban [MIT Licensz](https://en.wikipedia.org/wiki/MIT_License) alatt került kiadásra, a tároló gyökérkönyvtárában található [LICENSE fájl](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) szerint.

# Történelmi hivatkozásként

> **MEGJEGYZÉS:** Ezt a részt megőriztük a Microsoft eredeti README.md fájljából, amely a forráskód kiadását kísérte. A tárolóban található build scriptek és eszközök a történelmi forráskódtól függetlenül kerülnek karbantartásra. A build rendszer fejlesztéséhez küldött pull request-eket szívesen fogadjuk.

A forrásfájlok ebben a tárolóban történelmi hivatkozás céljából vannak elhelyezve, és statikusak maradnak, úgyhogy kérjük **ne küldj** Pull Request-et a forrásfájlok módosítására vonatkozóan, de nyugodtan forkold ezt a tárolót és kísérletezz 😊.

Ez a projekt elfogadta a [Microsoft Open Source Magatartási Kódexét](https://opensource.microsoft.com/codeofconduct/). További információkért látogasd meg a [Magatartási Kódex GYIK](https://opensource.microsoft.com/codeofconduct/faq/) oldalt, vagy vedd fel a kapcsolatot az [opencode@microsoft.com](mailto:opencode@microsoft.com) címen bármilyen további kérdéssel vagy megjegyzéssel.

# Az MS-DOS 4.0 fordítása

Előre összeállított lemezképek elérhetőek a [Releases](https://github.com/tgies/MS-DOS/releases) oldalon. Forráskódból történő fordításhoz:

## Követelmények

- dosemu2
- mtools
- mkfatimage16 (a dosemu2-ból)

> [!IMPORTANT]
> **A comcom64 0.4-0~202602051302 vagy újabb verzió szükséges.** A comcom64 a command.com helyettesítő, amelyet a dosemu2 használ. Néhány korábbi verzió [hibát tartalmaz a `COPY` parancsban](https://github.com/dosemu2/comcom64/pull/117), amely megtöri a fájlösszefűzést (`copy /b a+b dest`) amikor `COMMAND /C` paranccson keresztül kerül meghívásra, amit az nmake használ a makefile parancsok végrehajtására. Ez az IO.SYS build csendes hibáját okozza.
>
> Ellenőrizd a verziót a `dpkg -s comcom64 | grep Version` paranccsal (Debian/Ubuntu) vagy nézd meg a csomagkezelőben. Ha régebbi verziód van:
> - **Ajánlott:** Frissítsd a comcom64-et 0.4-0~202602051302 vagy újabb verzióra
> - **Megoldás:** Fordítsd a comcom64-et forrásból: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (győződj meg róla, hogy a `make install` a meglévő `command.efi` fájl helyére telepít)

## Gyors kezdés

```bash
cd v4.0
./mak.sh              # DOS 4 fordítása
./mkhdimg.sh          # 64MB merevlemez kép létrehozása
./mkhdimg.sh --floppy # 1.44MB boot hajlékonylemez létrehozása
```

## Build változatok

A forráskód több build konfigurációt támogat. Használd a `--flavor` kapcsolót:

```bash
./mak.sh                    # MS-DOS fordítása (alapértelmezett)
./mak.sh --flavor=pcdos     # IBM PC-DOS fordítása
```

| Változat | Rendszerfájlok | Leírás |
|----------|----------------|--------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS IBM-kompatibilis PC-khez (alapértelmezett, ajánlott) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (történelmi pontossághoz) |

Mindkét változat tartalmazza az IBM PC hardver-specifikus kódját (INT 10H videó BIOS, 8259 PIC, PCjr ROM cartridge támogatás).

**Fontos:** Az **msdos** változat több hibajavítást tartalmaz, mint a **pcdos**. Feltehetően a Microsoft gyorsabban tudta az OEM MS-DOS-ba tolni a javításokat, mint amennyire az IBM jóváhagyási folyamata engedte volna a PC-DOS esetében. Ismert, hogy az IBM lényegében ideiglenesen átvette a DOS fejlesztést körülbelül a DOS 3.3-tól a DOS 4.0-ig, így az egyik lehetséges elmélet szerint a PC-DOS lényegében befagyasztottnak számított, amikor a kódot visszaadták a Microsoftnak, aki számos hibát talált, amelyeket az OEM MS-DOS-ban javítottak anélkül, hogy a PC-DOS-hoz hozzányúltak volna.

Figyelemre méltó különbségek:
- DOS kernel INT 24 (kritikus hiba) kezelési javítás
- FDISK egész szám túlcsordulás védelem nagy lemezekhez
- Nagyobb EMS pufferek a FASTOPEN-ben
- Jobb bemenet validáció az EXE2BIN-ben

Az alapértelmezett **msdos** változat az, amit az OEM-ek, mint a Compaq, Dell és HP "MS-DOS"-ként szállítottak az IBM-kompatibilis PC-jeiken. Ez a forráskiadás valójában az OAK-ból (OEM Adaptation Kit) származik -- a kódból, amelyet a Microsoft az OEM-eknek biztosított, hogy lehetővé tegye számukra az MS-DOS testreszabását a hardverükhöz.

## Lemezkép opciók

```bash
# Merevlemez képek (létrehozza az msdos4.img + msdos4-dosemu.img fájlokat)
./mkhdimg.sh                    # 64MB FAT16 kép
./mkhdimg.sh --size 32          # 32MB kép

# Hajlékonylemez képek (minden méret)
./mkhdimg.sh --floppy           # 1.44MB minimális (csak rendszerfájlok)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB segédprogramokkal
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB segédprogramokkal
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB segédprogramokkal
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB segédprogramokkal
```

A merevlemez képek két formátumban készülnek: az `msdos4.img` egy nyers lemez kép, amely működik QEMU-val, VirtualBox-szal, bochs-szal és a legtöbb emulátorral. Az `msdos4-dosemu.img` a dosemu hdimage formátum (128 bájtos fejléc). A hajlékonylemez képek nyers formátumúak és mindenhol működnek.

## Ismert korlátozások

- **A DOS Shell nincs benne**: A DOS Shell (DOSSHELL) forráskódja nem került nyílt forráskódúvá. A SELECT.EXE (a telepítő) kódot oszt meg a DOSSHELL-lel, és nem fordítható.
- **A PC-DOS branding hiányos**: A `--flavor=pcdos` build az IBM rendszerfájl neveket használja (IBMBIO.COM, IBMDOS.COM) és néhány PC-DOS-specifikus kód útvonalat, de még mindig "MS-DOS"-t jelenít meg a VER-ben és az indítási bannerben. Ennek oka, hogy az IBM üzenetfájlja (`usa-ibm.msg` vagy hasonló) nem került nyílt forráskódúvá -- csak a Microsoft márkájú `usa-ms.msg` került kiadásra.
- **Nem IBM-kompatibilis build**: Egy harmadik konfiguráció (`IBMVER=FALSE`) létezik a forráskódban a nem IBM-kompatibilis hardverekhez, de nem fordítható sikeresen. Úgy tűnik, hogy ez a konfiguráció néhány rövid életű, nem IBM-kompatibilis x86 PC-hez készült a korai 1980-as évekből -- kifejezetten kerüli az IBM-kompatibilis-specifikus kód útvonalakat, amelyek olyan hardverekkel foglalkoznak, mint a BIOS, PIC, PIT stb. További vizsgálat szükséges, de valószínű, hogy ez a forrásfa hiányos és hiányzik belőle a hardver-specifikus kód (IO.SYS dolgok), amelyet biztosítani kellene a DOS szolgáltatások ilyen hardveren történő megvalósításához.

# Védjegyek

Ez a projekt tartalmazhat védjegyeket vagy logókat projektekhez, termékekhez vagy szolgáltatásokhoz. A Microsoft védjegyek vagy logók engedélyezett használata a [Microsoft Védjegy és Márka Irányelvek](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general) hatálya alá tartozik és azokat kell követnie. A Microsoft védjegyek vagy logók használata a projekt módosított verzióiban nem okozhat zavart és nem jelenthet Microsoft támogatást. Bármilyen harmadik fél védjegyeinek vagy logóinak használatára az adott harmadik fél szabályzatai vonatkoznak.
