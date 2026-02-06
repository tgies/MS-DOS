<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Codice Sorgente di MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Questo repository contiene il codice sorgente originale e i binari compilati per MS-DOS v1.25 e MS-DOS v2.0, oltre al codice sorgente per MS-DOS v4.00 sviluppato congiuntamente da IBM e Microsoft.

I file di MS-DOS v1.25 e v2.0 [furono originariamente condivisi al Computer History Museum il 25 marzo 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) e sono stati (ri)pubblicati in questo repository per renderli più facili da trovare, usarli come riferimento in documenti e lavori esterni e consentirne la consultazione e la sperimentazione per coloro che sono interessati ai primi sistemi operativi per PC.

# Informazioni su questo fork

Questo fork aggiunge un sistema di build funzionante e una pipeline CI per il codice sorgente di MS-DOS 4.0. Compila i sorgenti originali in assembly 8086 e C in un sistema operativo completo e avviabile -- sia nella versione OEM **MS-DOS** che **IBM PC-DOS**.

La build produce immagini disco pronte all'uso (hard disk da 64MB e floppy disk d'epoca da 360KB a 1.44MB) che si avviano in QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, o su hardware vintage reale. Le immagini pre-compilate sono disponibili nella pagina [Releases](https://github.com/tgies/MS-DOS/releases).

Questo lavoro beneficia enormemente del lavoro precedente svolto da altri per compilare il codice sorgente di MS-DOS 4.0, risolvendo alcuni problemi minori nell'albero dei sorgenti rilasciato (percorsi file errati e codifiche dei caratteri danneggiate), inclusi, ma non limitati a, [ecm](https://hg.pushbx.org/ecm/msdos4) e [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Provalo

Scarica `msdos4.img` dall'[ultima release](https://github.com/tgies/MS-DOS/releases) e avvialo:

```bash
qemu-system-i386 -hda msdos4.img
```

Oppure con DOSBox, avvia DOSBox normalmente e poi avvia l'immagine (ometti `-l C` se usi un'immagine floppy):

```bash
BOOT msdos4.img -l C
```

Oppure con dosemu (scarica `msdos4-dosemu.img`, che ha un header speciale per dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licenza

Tutti i file all'interno di questo repository sono rilasciati sotto la [Licenza MIT](https://en.wikipedia.org/wiki/MIT_License) come indicato nel [file LICENSE](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) salvato alla radice di questo repository.

# Per riferimento storico

> **NOTA:** Questa sezione è preservata dal README.md originale di Microsoft che accompagna il rilascio del codice sorgente. Gli script di build e gli strumenti in questo repository sono mantenuti separatamente dal codice sorgente storico. Le Pull Request per miglioramenti al sistema di build sono benvenute.

I file sorgente in questo repository sono per riferimento storico e saranno mantenuti statici, quindi per favore **non inviare** Pull Request suggerendo modifiche ai file sorgente, ma sentiti libero di fare un fork di questo repository e sperimentare 😊.

Questo progetto ha adottato il [Codice di Condotta Open Source di Microsoft](https://opensource.microsoft.com/codeofconduct/). Per ulteriori informazioni, consultare le [Domande frequenti sul codice di condotta](https://opensource.microsoft.com/codeofconduct/faq/) o contattare [opencode@microsoft.com](mailto:opencode@microsoft.com) per eventuali ulteriori domande o commenti.

# Compilare MS-DOS 4.0

Le immagini disco pre-compilate sono disponibili nella pagina [Releases](https://github.com/tgies/MS-DOS/releases). Per compilare dal sorgente:

## Requisiti

- dosemu2
- mtools
- mkfatimage16 (da dosemu2)

> [!IMPORTANT]
> **È richiesto comcom64 0.4-0~202602051302 o successivo.** comcom64 è la sostituzione di command.com utilizzata da dosemu2. Alcune versioni precedenti hanno un [bug nel comando `COPY`](https://github.com/dosemu2/comcom64/pull/117) che interrompe la concatenazione dei file (`copy /b a+b dest`) quando invocato tramite `COMMAND /C`, che nmake usa per eseguire i comandi del makefile. Questo causa il fallimento silenzioso della build di IO.SYS.
>
> Controlla la tua versione con `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) o verifica tramite il tuo package manager. Se hai una versione più vecchia:
> - **Consigliato:** Aggiorna comcom64 alla versione 0.4-0~202602051302 o successiva
> - **Soluzione alternativa:** Compila comcom64 dal sorgente: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (assicurati che `make install` installi sopra il tuo `command.efi` esistente)

## Avvio Rapido

```bash
cd v4.0
./mak.sh              # Compila DOS 4
./mkhdimg.sh          # Crea immagine hard disk da 64MB
./mkhdimg.sh --floppy # Crea floppy boot da 1.44MB
```

## Varianti di Build

Il codice sorgente supporta multiple configurazioni di build. Usa il flag `--flavor`:

```bash
./mak.sh                    # Compila MS-DOS (default)
./mak.sh --flavor=pcdos     # Compila IBM PC-DOS
```

| Variante | File di Sistema | Descrizione |
|--------|-----------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | MS-DOS OEM per PC compatibili IBM (default, consigliato) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (per accuratezza storica) |

Entrambe le varianti includono codice specifico per hardware IBM PC (BIOS video INT 10H, PIC 8259, supporto cartucce ROM PCjr).

**Importante:** La variante **msdos** contiene più correzioni di bug rispetto a **pcdos**. Presumibilmente, Microsoft poteva distribuire correzioni a MS-DOS OEM più velocemente di quanto il processo di approvazione di IBM permettesse per PC-DOS. È noto che IBM prese essenzialmente il controllo dello sviluppo di DOS temporaneamente circa da DOS 3.3 fino a DOS 4.0, quindi una possibile teoria è che PC-DOS fosse considerato essenzialmente congelato quando il codice fu restituito a Microsoft, che scoprì diversi bug che corresse in MS-DOS OEM senza toccare PC-DOS.

Differenze notevoli:
- Correzione nella gestione INT 24 (errore critico) del kernel DOS
- Protezione contro overflow di interi in FDISK per dischi di grandi dimensioni
- Buffer EMS più grandi in FASTOPEN
- Migliore validazione dell'input in EXE2BIN

La variante **msdos** di default è quella che gli OEM come Compaq, Dell e HP distribuivano come "MS-DOS" sui loro PC compatibili IBM. Questo rilascio del sorgente sembra effettivamente derivare dall'OAK (OEM Adaptation Kit) -- il codice che Microsoft forniva agli OEM per permettere loro di personalizzare MS-DOS per il loro hardware.

## Opzioni Immagini Disco

```bash
# Immagini hard disk (produce msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Immagine FAT16 da 64MB
./mkhdimg.sh --size 32          # Immagine da 32MB

# Immagini floppy (tutte le dimensioni)
./mkhdimg.sh --floppy           # 1.44MB minimale (solo file di sistema)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB con utility
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB con utility
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB con utility
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB con utility
```

Le immagini hard disk sono prodotte in due formati: `msdos4.img` è un'immagine disco raw che funziona con QEMU, VirtualBox, bochs e la maggior parte degli emulatori. `msdos4-dosemu.img` è il formato hdimage di dosemu (header da 128 byte). Le immagini floppy sono raw e funzionano ovunque.

## Limitazioni Note

- **DOS Shell non incluso**: Il codice sorgente di DOS Shell (DOSSHELL) non è stato reso open source. SELECT.EXE (l'installer) condivide del codice con DOSSHELL e non può essere compilato.
- **Branding PC-DOS incompleto**: La build `--flavor=pcdos` utilizza i nomi dei file di sistema IBM (IBMBIO.COM, IBMDOS.COM) e alcuni percorsi di codice specifici di PC-DOS, ma visualizza ancora "MS-DOS" in VER e nel banner di avvio. Questo perché il file dei messaggi di IBM (`usa-ibm.msg` o simile) non è stato reso open source—solo il file con il branding Microsoft `usa-ms.msg` è stato rilasciato.
- **Build non compatibile IBM**: Esiste una terza configurazione (`IBMVER=FALSE`) nel sorgente per hardware non compatibile IBM, ma non si compila con successo. Sembra che questa configurazione sia per alcuni dei PC x86 non compatibili IBM di breve durata dei primi anni '80 -- evita specificamente alcuni percorsi di codice specifici per compatibilità IBM che trattano hardware come BIOS, PIC, PIT, e così via. È necessaria un'ulteriore indagine, ma è probabile che questo albero dei sorgenti sia incompleto e manchi il codice specifico dell'hardware (roba di IO.SYS) che dovrebbe essere fornito per implementare i servizi DOS su tale hardware.

# Marchi Commerciali

Questo progetto può contenere marchi commerciali o loghi per progetti, prodotti o servizi. L'uso autorizzato di marchi commerciali o loghi Microsoft è soggetto e deve seguire le
[Linee Guida sui Marchi Commerciali e sul Brand di Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
L'uso di marchi commerciali o loghi Microsoft in versioni modificate di questo progetto non deve causare confusione o implicare sponsorizzazione da parte di Microsoft.
Qualsiasi uso di marchi commerciali o loghi di terze parti è soggetto alle politiche di tali terze parti.
