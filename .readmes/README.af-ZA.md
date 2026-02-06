<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 Bronkode

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Hierdie repo bevat die oorspronklike bronkode en saamgestelde binaries vir MS-DOS v1.25 en MS-DOS v2.0, plus die bronkode vir MS-DOS v4.00 wat gesamentlik deur IBM en Microsoft ontwikkel is.

Die MS-DOS v1.25 en v2.0 lêers [is oorspronklik op 25 Maart 2014 by die Computer History Museum gedeel]( http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) en word in hierdie repo (her)gepubliseer om dit makliker te maak om te vind, na te verwys in eksterne skryfwerk en werke, en om eksplorasie en eksperimente toe te laat vir diegene wat belangstel in vroeë PC-bedryfstelsels.

# Oor hierdie fork

Hierdie fork voeg 'n werkende boustelsel en CI-pyplyn vir die MS-DOS 4.0 bronkode by. Dit bou die oorspronklike 8086-assembly-kode en C-bronne in 'n volledige, opstartbare bedryfstelsel -- beide die OEM **MS-DOS** en **IBM PC-DOS** variante.

Die bou produseer gebruiksklaar skyfbeelde (64MB hardeskyf en tydperk-korrekte floppies van 360KB tot 1.44MB) wat opstart in QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, of op regte antieke hardeware. Vooraf-geboude beelde is beskikbaar op die [Releases](https://github.com/tgies/MS-DOS/releases) bladsy.

Hierdie werk baat grootliks by vorige werk wat deur ander gedoen is om die MS-DOS 4.0 bronkode te laat bou deur 'n paar klein probleme in die vrygestelde bronboom op te los (verkeerde lêerpaaie en verwronge karakterkoderings), insluitend, maar nie beperk tot nie, [ecm](https://hg.pushbx.org/ecm/msdos4) en [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Probeer dit

Laai `msdos4.img` af van die [nuutste vrystelling](https://github.com/tgies/MS-DOS/releases) en start dit op:

```bash
qemu-system-i386 -hda msdos4.img
```

Of met DOSBox, begin DOSBox normaal en start dan die beeld op (laat `-l C` weg as jy 'n floppy-beeld gebruik):

```bash
BOOT msdos4.img -l C
```

Of met dosemu (laai `msdos4-dosemu.img` af, wat 'n spesiale kop vir dosemu2 het):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Lisensie

Alle lêers in hierdie repo word vrygestel onder die [MIT Lisensie]( https://en.wikipedia.org/wiki/MIT_License) soos per die [LICENSE lêer](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) gestoor in die wortel van hierdie repo.

# Vir historiese verwysing

> **LET WEL:** Hierdie afdeling is behou van Microsoft se oorspronklike README.md wat die bronkode-vrystelling vergesel. Die bouskrifte en gereedskap in hierdie repository word afsonderlik van die historiese bronkode onderhou. Pull requests vir verbeterings aan die boustelsel is welkom.

Die bronlêers in hierdie repo is vir historiese verwysing en sal staties gehou word, so stuur asseblief **nie** Pull Requests wat enige wysigings aan die bronlêers voorstel nie, maar voel vry om hierdie repo te fork en te eksperimenteer 😊.

Hierdie projek het die [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/) aangeneem. Vir meer inligting, sien die [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) of kontak [opencode@microsoft.com](mailto:opencode@microsoft.com) met enige addisionele vrae of kommentaar.

# Bou van MS-DOS 4.0

Vooraf-geboude skyfbeelde is beskikbaar op die [Releases](https://github.com/tgies/MS-DOS/releases) bladsy. Om van bron te bou:

## Vereistes

- dosemu2
- mtools
- mkfatimage16 (van dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 of later word benodig.** comcom64 is die command.com vervanging wat deur dosemu2 gebruik word. Sommige vroeër weergawes het 'n [fout in die `COPY` opdrag](https://github.com/dosemu2/comcom64/pull/117) wat lêer-aaneenskakeling (`copy /b a+b dest`) breek wanneer dit via `COMMAND /C` aangeroep word, wat nmake gebruik om makefile-opdragte uit te voer. Dit veroorsaak dat die IO.SYS bou stilweg misluk.
>
> Kontroleer jou weergawe met `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) of kontroleer jou pakketbestuurder. As jy op 'n ouer weergawe is:
> - **Aanbeveel:** Dateer comcom64 op na 0.4-0~202602051302 of later
> - **Tydelike oplossing:** Bou comcom64 van bron: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (maak seker `make install` installeer oor jou bestaande `command.efi`)

## Vinnige Begin

```bash
cd v4.0
./mak.sh              # Bou DOS 4
./mkhdimg.sh          # Skep 64MB hardeskyf beeld
./mkhdimg.sh --floppy # Skep 1.44MB opstart floppy
```

## Bou Variante

Die bronkode ondersteun verskeie bou-konfigurasies. Gebruik die `--flavor` vlag:

```bash
./mak.sh                    # Bou MS-DOS (verstek)
./mak.sh --flavor=pcdos     # Bou IBM PC-DOS
```

| Variant | Stelsel Lêers | Beskrywing |
|--------|--------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS vir IBM-versoenbare PC's (verstek, aanbeveel) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (vir historiese akkuraatheid) |

Beide variante sluit IBM PC hardeware-spesifieke kode in (INT 10H video BIOS, 8259 PIC, PCjr ROM-kassie ondersteuning).

**Belangrik:** Die **msdos** variant bevat meer foutoplossings as **pcdos**. Vermoedelik kon Microsoft oplossings vinniger na OEM MS-DOS stoot as wat IBM se goedkeuringsproses vir PC-DOS toegelaat het. Dit is bekend dat IBM feitlik tydelik DOS-ontwikkeling oorgeneem het circa DOS 3.3 deur DOS 4.0, so een moontlike teorie is dat PC-DOS feitlik as gevries beskou is toe die kode aan Microsoft teruggegee is, wat 'n aantal foute gevind het wat hulle in OEM MS-DOS reggemaak het sonder om aan PC-DOS te raak.

Noemenswaardige verskille:
- DOS kernel INT 24 (kritieke fout) hantering regstelling
- FDISK heelgetal-oorloop beskerming vir groot skywe
- Groter EMS buffers in FASTOPEN
- Beter invoer-validering in EXE2BIN

Die verstek **msdos** variant is wat OEM's soos Compaq, Dell, en HP as "MS-DOS" op hul IBM-versoenbare PC's verskip het. Hierdie bronkode-vrystelling blyk eintlik van die OAK (OEM Adaptation Kit) af te kom -- die kode wat Microsoft aan OEM's verskaf het om hulle toe te laat om MS-DOS vir hul hardeware aan te pas.

## Skyfbeeld Opsies

```bash
# Hardeskyf beelde (produseer msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # 64MB FAT16 beeld
./mkhdimg.sh --size 32          # 32MB beeld

# Floppy beelde (alle groottes)
./mkhdimg.sh --floppy           # 1.44MB minimaal (slegs stelsel lêers)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB met nutsmiddele
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB met nutsmiddele
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB met nutsmiddele
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB met nutsmiddele
```

Hardeskyf beelde word in twee formate geproduseer: `msdos4.img` is 'n rou skyfbeeld wat werk met QEMU, VirtualBox, bochs, en meeste emulators. `msdos4-dosemu.img` is die dosemu hdimage formaat (128-greep kop). Floppy beelde is rou en werk oral.

## Bekende Beperkings

- **DOS Shell nie ingesluit nie**: Die DOS Shell (DOSSHELL) bronkode is nie oopbron gemaak nie. SELECT.EXE (die installeerder) deel sommige kode met DOSSHELL en kan nie gebou word nie.
- **PC-DOS handelsmerk onvolledig**: Die `--flavor=pcdos` bou gebruik IBM stelsel lêername (IBMBIO.COM, IBMDOS.COM) en sommige PC-DOS-spesifieke kode paaie, maar vertoon steeds "MS-DOS" in VER en die opstart banner. Dit is omdat IBM se boodskap lêer (`usa-ibm.msg` of soortgelyk) nie oopbron gemaak is nie—slegs die Microsoft-handelsmerk `usa-ms.msg` is vrygestel.
- **Nie-IBM-versoenbare bou**: 'n Derde konfigurasie (`IBMVER=FALSE`) bestaan in die bron vir nie-IBM-versoenbare hardeware, maar dit bou nie suksesvol nie. Dit blyk dat hierdie konfigurasie vir sommige van die kort-lewende nie-IBM-versoenbare x86 PC's van die vroeë 1980's is -- dit vermy spesifiek sekere IBM-versoenbare-spesifieke kode paaie wat handel met hardeware soos die BIOS, PIC, PIT, ensovoorts. Verdere ondersoek is nodig, maar dit is waarskynlik dat hierdie bronboom onvolledig is en die hardeware-spesifieke kode (IO.SYS goed) mis wat verskaf moet word om DOS-dienste op sulke hardeware te implementeer.

# Handelsmerke

Hierdie projek mag dalk handelsmerke of logo's vir projekte, produkte, of dienste bevat. Gemagtigde gebruik van Microsoft handelsmerke of logo's is onderworpe aan en moet volg aan [Microsoft se Handelsmerk & Handelsmerk Riglyne](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Gebruik van Microsoft handelsmerke of logo's in gewysigde weergawes van hierdie projek mag nie verwarring veroorsaak of Microsoft borgtog impliseer nie. Enige gebruik van derde-party handelsmerke of logo's is onderworpe aan daardie derde-party se beleide.
