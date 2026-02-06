<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Code source de MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Ce dépôt contient le code source original et les binaires compilés de MS-DOS v1.25 et MS-DOS v2.0, ainsi que le code source de MS-DOS v4.00 développé conjointement par IBM et Microsoft.

Les fichiers de MS-DOS v1.25 et v2.0 [ont été initialement partagés au Computer History Museum le 25 mars 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) et sont (re)publiés dans ce dépôt pour les rendre plus faciles à trouver, à référencer dans des écrits et travaux externes, et pour permettre l'exploration et l'expérimentation pour ceux qui s'intéressent aux premiers systèmes d'exploitation pour PC.

# À propos de ce fork

Ce fork ajoute un système de compilation fonctionnel et un pipeline CI pour le code source de MS-DOS 4.0. Il compile les sources originales en assembleur 8086 et en C pour produire un système d'exploitation complet et amorçable -- à la fois les versions OEM **MS-DOS** et **IBM PC-DOS**.

La compilation produit des images disque prêtes à l'emploi (disque dur de 64 Mo et disquettes d'époque de 360 Ko à 1,44 Mo) qui démarrent dans QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, ou sur du véritable matériel vintage. Des images pré-compilées sont disponibles sur la page [Releases](https://github.com/tgies/MS-DOS/releases).

Ce travail bénéficie grandement des travaux antérieurs effectués par d'autres pour compiler le code source de MS-DOS 4.0 en nettoyant quelques problèmes mineurs dans l'arborescence source publiée (chemins de fichiers incorrects et encodages de caractères corrompus), notamment, mais sans s'y limiter, [ecm](https://hg.pushbx.org/ecm/msdos4) et [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Essayez-le

Téléchargez `msdos4.img` depuis la [dernière version](https://github.com/tgies/MS-DOS/releases) et démarrez-le :

```bash
qemu-system-i386 -hda msdos4.img
```

Ou avec DOSBox, démarrez DOSBox normalement puis amorcez l'image (omettez `-l C` si vous utilisez une image disquette) :

```bash
BOOT msdos4.img -l C
```

Ou avec dosemu (téléchargez `msdos4-dosemu.img`, qui a un en-tête spécial pour dosemu2) :

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licence

Tous les fichiers de ce dépôt sont publiés sous la [Licence MIT](https://fr.wikipedia.org/wiki/Licence_MIT) conformément au [fichier LICENSE](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) stocké à la racine de ce dépôt.

# Pour référence historique

> **REMARQUE :** Cette section est conservée du README.md original de Microsoft accompagnant la publication du code source. Les scripts de compilation et les outils de ce dépôt sont maintenus séparément du code source historique. Les Pull Requests pour améliorer le système de compilation sont les bienvenues.

Les fichiers sources de ce dépôt sont fournis pour référence historique et resteront statiques, donc s'il vous plaît **n'envoyez pas** de Pull Requests suggérant des modifications aux fichiers sources, mais n'hésitez pas à forker ce dépôt et à expérimenter 😊.

Ce projet a adopté le [Code de Conduite Open Source de Microsoft](https://opensource.microsoft.com/codeofconduct/). Pour plus d'informations, consultez la [FAQ du Code de Conduite](https://opensource.microsoft.com/codeofconduct/faq/) ou contactez [opencode@microsoft.com](mailto:opencode@microsoft.com) pour toute question ou commentaire supplémentaire.

# Compiler MS-DOS 4.0

Des images disque pré-compilées sont disponibles sur la page [Releases](https://github.com/tgies/MS-DOS/releases). Pour compiler à partir des sources :

## Prérequis

- dosemu2
- mtools
- mkfatimage16 (de dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 ou ultérieur est requis.** comcom64 est le remplacement de command.com utilisé par dosemu2. Certaines versions antérieures ont un [bug dans la commande `COPY`](https://github.com/dosemu2/comcom64/pull/117) qui empêche la concaténation de fichiers (`copy /b a+b dest`) lorsqu'elle est invoquée via `COMMAND /C`, que nmake utilise pour exécuter les commandes makefile. Cela provoque l'échec silencieux de la compilation d'IO.SYS.
>
> Vérifiez votre version avec `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) ou consultez votre gestionnaire de paquets. Si vous avez une version plus ancienne :
> - **Recommandé :** Mettez à jour comcom64 vers 0.4-0~202602051302 ou ultérieur
> - **Solution de contournement :** Compilez comcom64 depuis les sources : `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (assurez-vous que `make install` installe par-dessus votre `command.efi` existant)

## Démarrage rapide

```bash
cd v4.0
./mak.sh              # Compiler DOS 4
./mkhdimg.sh          # Créer une image disque dur de 64 Mo
./mkhdimg.sh --floppy # Créer une disquette d'amorçage de 1,44 Mo
```

## Variantes de compilation

Le code source prend en charge plusieurs configurations de compilation. Utilisez le drapeau `--flavor` :

```bash
./mak.sh                    # Compiler MS-DOS (par défaut)
./mak.sh --flavor=pcdos     # Compiler IBM PC-DOS
```

| Variante | Fichiers système | Description |
|----------|------------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | MS-DOS OEM pour PC compatibles IBM (par défaut, recommandé) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (pour l'exactitude historique) |

Les deux variantes incluent du code spécifique au matériel IBM PC (BIOS vidéo INT 10H, PIC 8259, support cartouche ROM PCjr).

**Important :** La variante **msdos** contient plus de corrections de bugs que **pcdos**. Vraisemblablement, Microsoft pouvait déployer des corrections dans l'OEM MS-DOS plus rapidement que le processus d'approbation d'IBM ne le permettait pour PC-DOS. Il est connu qu'IBM a essentiellement repris le développement de DOS temporairement vers DOS 3.3 jusqu'à DOS 4.0, donc une théorie possible est que PC-DOS était essentiellement considéré comme gelé lorsque le code a été rendu à Microsoft, qui a trouvé un certain nombre de bugs qu'ils ont corrigés dans l'OEM MS-DOS sans toucher PC-DOS.

Différences notables :
- Correction de la gestion INT 24 (erreur critique) du noyau DOS
- Protection contre le dépassement d'entier dans FDISK pour les grands disques
- Tampons EMS plus grands dans FASTOPEN
- Meilleure validation des entrées dans EXE2BIN

La variante **msdos** par défaut est ce que les OEM comme Compaq, Dell et HP livraient sous le nom de « MS-DOS » sur leurs PC compatibles IBM. Cette version source semble en fait dériver de l'OAK (OEM Adaptation Kit) -- le code que Microsoft fournissait aux OEM pour leur permettre de personnaliser MS-DOS pour leur matériel.

## Options d'image disque

```bash
# Images disque dur (produit msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Image FAT16 de 64 Mo
./mkhdimg.sh --size 32          # Image de 32 Mo

# Images disquette (toutes tailles)
./mkhdimg.sh --floppy           # 1,44 Mo minimal (fichiers système uniquement)
./mkhdimg.sh --floppy=360 --floppy-full   # 360 Ko avec utilitaires
./mkhdimg.sh --floppy=720 --floppy-full   # 720 Ko avec utilitaires
./mkhdimg.sh --floppy=1200 --floppy-full  # 1,2 Mo avec utilitaires
./mkhdimg.sh --floppy=1440 --floppy-full  # 1,44 Mo avec utilitaires
```

Les images disque dur sont produites en deux formats : `msdos4.img` est une image disque brute qui fonctionne avec QEMU, VirtualBox, bochs et la plupart des émulateurs. `msdos4-dosemu.img` est au format hdimage de dosemu (en-tête de 128 octets). Les images disquette sont brutes et fonctionnent partout.

## Limitations connues

- **DOS Shell non inclus** : Le code source du DOS Shell (DOSSHELL) n'a pas été publié en open source. SELECT.EXE (l'installateur) partage du code avec DOSSHELL et ne peut pas être compilé.
- **Image de marque PC-DOS incomplète** : La compilation `--flavor=pcdos` utilise les noms de fichiers système IBM (IBMBIO.COM, IBMDOS.COM) et certains chemins de code spécifiques à PC-DOS, mais affiche toujours « MS-DOS » dans VER et la bannière de démarrage. Cela s'explique par le fait que le fichier de messages d'IBM (`usa-ibm.msg` ou similaire) n'a pas été publié en open source -- seul le fichier avec la marque Microsoft `usa-ms.msg` a été publié.
- **Compilation non compatible IBM** : Une troisième configuration (`IBMVER=FALSE`) existe dans les sources pour le matériel non compatible IBM, mais elle ne compile pas correctement. Il semble que cette configuration soit destinée à certains des PC x86 non compatibles IBM de courte durée du début des années 1980 -- elle évite spécifiquement certains chemins de code spécifiques aux compatibles IBM concernant le matériel comme le BIOS, PIC, PIT, etc. Une enquête plus approfondie est nécessaire, mais il est probable que cette arborescence source soit incomplète et manque le code spécifique au matériel (code IO.SYS) qui devrait être fourni pour implémenter les services DOS sur un tel matériel.

# Marques déposées

Ce projet peut contenir des marques déposées ou des logos pour des projets, produits ou services. L'utilisation autorisée des marques déposées ou logos de Microsoft est soumise et doit suivre les [Directives de marque et de marque déposée de Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
L'utilisation de marques déposées ou de logos Microsoft dans des versions modifiées de ce projet ne doit pas créer de confusion ou impliquer le parrainage de Microsoft.
Toute utilisation de marques déposées ou de logos tiers est soumise aux politiques de ces tiers.
