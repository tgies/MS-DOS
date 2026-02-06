<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Codi font de MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Aquest repositori conté el codi font i binaris compilats originals per a MS-DOS v1.25 i per a MS-DOS v2.0, a més del codi font de MS-DOS v4.00 desenvolupat conjuntament per IBM i Microsoft.

Els fitxers de MS-DOS v1.25 i v2.0 [van ser originalment compartits al Museu Històric dels Computadors el 25 de març del 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) i estan sent (re)publicats en aquest repositori per fer-los més fàcils de trobar, de referenciar en escrits i treballs externs, i permetre l'exploració i experimentació per a aquells interessats en Sistemes Operatius de PC primerencs.

# Sobre aquesta bifurcació

Aquesta bifurcació afegeix un sistema de compilació funcional i un pipeline de CI per al codi font de MS-DOS 4.0. Compila les fonts originals en assemblador 8086 i C en un sistema operatiu complet i arrencable -- tant la versió OEM **MS-DOS** com la versió **IBM PC-DOS**.

La compilació produeix imatges de disc llestes per utilitzar (disc dur de 64MB i disquets d'època correcta des de 360KB fins a 1.44MB) que arrenquen en QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, o en maquinari antic real. Les imatges precompilades estan disponibles a la pàgina de [Llançaments](https://github.com/tgies/MS-DOS/releases).

Aquest treball es beneficia enormement del treball previ fet per altres per aconseguir que el codi font de MS-DOS 4.0 compilés, netejant alguns problemes menors en l'arbre de fonts alliberat (camins de fitxers incorrectes i codificacions de caràcters malmeses), incloent, però no limitat a, [ecm](https://hg.pushbx.org/ecm/msdos4) i [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Prova-ho

Descarrega `msdos4.img` del [darrer llançament](https://github.com/tgies/MS-DOS/releases) i arrenca'l:

```bash
qemu-system-i386 -hda msdos4.img
```

O amb DOSBox, inicia DOSBox com és habitual i després arrenca la imatge (omet `-l C` si utilitzes una imatge de disquet):

```bash
BOOT msdos4.img -l C
```

O amb dosemu (descarrega `msdos4-dosemu.img`, que té una capçalera especial per a dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Llicència

Tots els fitxers dintre d'aquest repositori estan alliberats sota la [Llicència MIT](https://en.wikipedia.org/wiki/MIT_License) segons el [fitxer de LLICÈNCIA](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) emmagatzemat en l'arrel d'aquest repositori.

# Per a referència històrica

> **NOTA:** Aquesta secció es preserva del README.md original de Microsoft que acompanya l'alliberament del codi font. Els scripts de compilació i les eines en aquest repositori es mantenen separadament del codi font històric. Les Pull Requests per a millores al sistema de compilació són benvingudes.

Els fitxers font en aquest repositori són per a referència històrica i es mantindran estàtics, així que si us plau **no envieu** Pull Requests suggerint qualsevol modificació als fitxers font, però sentiu-vos lliures de bifurcar aquest repositori i experimentar 😊.

Aquest projecte ha adoptat el [Codi de Conducta de Codi Obert de Microsoft](https://opensource.microsoft.com/codeofconduct/). Per a més informació consulteu les [Preguntes Freqüents del Codi de Conducta](https://opensource.microsoft.com/codeofconduct/faq/) o contacteu amb [opencode@microsoft.com](mailto:opencode@microsoft.com) amb qualsevol pregunta o comentari addicional.

# Compilant MS-DOS 4.0

Les imatges de disc precompilades estan disponibles a la pàgina de [Llançaments](https://github.com/tgies/MS-DOS/releases). Per compilar des del codi font:

## Requisits

- dosemu2
- mtools
- mkfatimage16 (de dosemu2)

> [!IMPORTANT]
> **Es requereix comcom64 0.4-0~202602051302 o posterior.** comcom64 és el reemplaçament de command.com utilitzat per dosemu2. Algunes versions anteriors tenen un [error en la comanda `COPY`](https://github.com/dosemu2/comcom64/pull/117) que trenca la concatenació de fitxers (`copy /b a+b dest`) quan s'invoca mitjançant `COMMAND /C`, cosa que nmake utilitza per executar comandes de makefile. Això fa que la compilació de IO.SYS falli silenciosament.
>
> Comproveu la vostra versió amb `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) o consulteu el vostre gestor de paquets. Si teniu una versió anterior:
> - **Recomanat:** Actualitzeu comcom64 a 0.4-0~202602051302 o posterior
> - **Solució alternativa:** Compileu comcom64 des del codi font: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (assegureu-vos que `make install` instal·la sobre el vostre `command.efi` existent)

## Inici Ràpid

```bash
cd v4.0
./mak.sh              # Compila DOS 4
./mkhdimg.sh          # Crea imatge de disc dur de 64MB
./mkhdimg.sh --floppy # Crea disquet d'arrencada de 1.44MB
```

## Versions de Compilació

El codi font admet múltiples configuracions de compilació. Utilitzeu la bandera `--flavor`:

```bash
./mak.sh                    # Compila MS-DOS (per defecte)
./mak.sh --flavor=pcdos     # Compila IBM PC-DOS
```

| Versió | Fitxers del Sistema | Descripció |
|--------|---------------------|------------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS per a PCs compatibles amb IBM (per defecte, recomanat) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (per a precisió històrica) |

Ambdues versions inclouen codi específic de maquinari IBM PC (BIOS de vídeo INT 10H, PIC 8259, suport de cartutx ROM PCjr).

**Important:** La versió **msdos** conté més correccions d'errors que **pcdos**. Presumiblement, Microsoft podia impulsar correccions a OEM MS-DOS més ràpidament del que el procés d'aprovació d'IBM permetia per a PC-DOS. Es coneix que IBM essencialment va prendre el control del desenvolupament de DOS temporalment cap a DOS 3.3 fins a DOS 4.0, així que una teoria possible és que PC-DOS essencialment es va considerar congelat quan el codi va ser retornat a Microsoft, qui va trobar diversos errors que van corregir en OEM MS-DOS sense tocar PC-DOS.

Diferències notables:
- Correcció de la gestió de INT 24 (error crític) del nucli de DOS
- Protecció contra desbordament d'enters a FDISK per a discs grans
- Memòries intermèdies EMS més grans a FASTOPEN
- Millor validació d'entrada a EXE2BIN

La versió **msdos** per defecte és el que OEMs com Compaq, Dell i HP van distribuir com a "MS-DOS" en els seus PCs compatibles amb IBM. Aquest alliberament de codi font sembla derivar realment de l'OAK (OEM Adaptation Kit) -- el codi que Microsoft proporcionava als OEMs per permetre'ls personalitzar MS-DOS per al seu maquinari.

## Opcions d'Imatge de Disc

```bash
# Imatges de disc dur (produeix msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Imatge FAT16 de 64MB
./mkhdimg.sh --size 32          # Imatge de 32MB

# Imatges de disquet (totes les mides)
./mkhdimg.sh --floppy           # 1.44MB mínim (només fitxers del sistema)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB amb utilitats
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB amb utilitats
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB amb utilitats
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB amb utilitats
```

Les imatges de disc dur es produeixen en dos formats: `msdos4.img` és una imatge de disc crua que funciona amb QEMU, VirtualBox, bochs i la majoria d'emuladors. `msdos4-dosemu.img` és el format d'imatge de disc dur de dosemu (capçalera de 128 bytes). Les imatges de disquet són crues i funcionen arreu.

## Limitacions Conegudes

- **DOS Shell no inclòs**: El codi font de DOS Shell (DOSSHELL) no va ser alliberat com a codi obert. SELECT.EXE (l'instal·lador) comparteix codi amb DOSSHELL i no pot ser compilat.
- **Marca PC-DOS incompleta**: La compilació `--flavor=pcdos` utilitza noms de fitxers del sistema IBM (IBMBIO.COM, IBMDOS.COM) i alguns camins de codi específics de PC-DOS, però encara mostra "MS-DOS" a VER i el missatge d'inici. Això és perquè el fitxer de missatges d'IBM (`usa-ibm.msg` o similar) no va ser alliberat com a codi obert—només el `usa-ms.msg` amb marca de Microsoft va ser alliberat.
- **Compilació no compatible amb IBM**: Existeix una tercera configuració (`IBMVER=FALSE`) al codi font per a maquinari no compatible amb IBM, però no compila amb èxit. Sembla que aquesta configuració és per a alguns dels PCs x86 no compatibles amb IBM de vida curta dels primers anys 80 -- específicament evita certs camins de codi específics de compatibles amb IBM que tracten amb maquinari com la BIOS, PIC, PIT, i similars. És necessària una investigació addicional, però és probable que aquest arbre de codi font estigui incomplet i li manqui el codi específic de maquinari (coses de IO.SYS) que s'hauria de proporcionar per implementar serveis de DOS en tal maquinari.

# Marques Registrades

Aquest projecte pot contenir marques comercials o logos per a projectes, productes o serveis. L'ús autoritzat de marques comercials o logos de Microsoft està subjecte i ha de seguir les [Directrius de Marques i Marques Comercials de Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
L'ús de marques comercials o logos de Microsoft en versions modificades d'aquest projecte no ha de causar confusió o implicar patrocini de Microsoft.
Qualsevol ús de marques comercials o logos de tercers està subjecte a les polítiques d'aquests tercers.
