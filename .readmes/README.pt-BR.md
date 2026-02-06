<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Código Fonte do MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Este repositório contém o código-fonte original e os binários compilados do MS-DOS v1.25 e MS-DOS v2.0, além do código-fonte do MS-DOS v4.00 desenvolvido em conjunto pela IBM e Microsoft.

Os arquivos do MS-DOS v1.25 e v2.0 [foram originalmente compartilhados no Computer History Museum em 25 de março de 2014]( http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) e estão sendo (re)publicados neste repositório para facilitar a localização, referência em trabalhos e escritos externos, e para permitir exploração e experimentação para aqueles interessados em Sistemas Operacionais de PC antigos.

# Sobre este fork

Este fork adiciona um sistema de build funcional e pipeline de CI para o código-fonte do MS-DOS 4.0. Ele compila as fontes originais em assembly 8086 e C em um sistema operacional completo e bootável -- tanto na versão OEM **MS-DOS** quanto na **IBM PC-DOS**.

O build produz imagens de disco prontas para uso (disco rígido de 64MB e disquetes de época corretos de 360KB a 1.44MB) que inicializam no QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, ou em hardware vintage real. Imagens pré-compiladas estão disponíveis na página de [Releases](https://github.com/tgies/MS-DOS/releases).

Este trabalho se beneficia muito do trabalho anterior feito por outros para fazer o código-fonte do MS-DOS 4.0 compilar, limpando alguns problemas menores na árvore de código-fonte liberada (caminhos de arquivo errados e codificações de caracteres corrompidas), incluindo, mas não limitado a, [ecm](https://hg.pushbx.org/ecm/msdos4) e [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Experimente

Baixe `msdos4.img` da [versão mais recente](https://github.com/tgies/MS-DOS/releases) e inicialize:

```bash
qemu-system-i386 -hda msdos4.img
```

Ou com DOSBox, inicie o DOSBox normalmente e então inicialize a imagem (omita `-l C` se estiver usando uma imagem de disquete):

```bash
BOOT msdos4.img -l C
```

Ou com dosemu (baixe `msdos4-dosemu.img`, que possui um cabeçalho especial para dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licença

Todos os arquivos dentro deste repositório são liberados sob a [Licença MIT]( https://en.wikipedia.org/wiki/MIT_License) conforme o [arquivo LICENSE](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) armazenado na raiz deste repositório.

# Para referência histórica

> **NOTA:** Esta seção é preservada do README.md original da Microsoft que acompanha a liberação do código-fonte. Os scripts de build e ferramentas neste repositório são mantidos separadamente do código-fonte histórico. Pull requests para melhorias no sistema de build são bem-vindos.

Os arquivos fonte neste repositório são para referência histórica e serão mantidos estáticos, então por favor **não envie** Pull Requests sugerindo quaisquer modificações aos arquivos fonte, mas sinta-se livre para fazer fork deste repositório e experimentar 😊.

Este projeto adotou o [Código de Conduta de Código Aberto da Microsoft](https://opensource.microsoft.com/codeofconduct/). Para mais informações, consulte o [FAQ do Código de Conduta](https://opensource.microsoft.com/codeofconduct/faq/) ou contate [opencode@microsoft.com](mailto:opencode@microsoft.com) com quaisquer perguntas ou comentários adicionais.

# Compilando o MS-DOS 4.0

Imagens de disco pré-compiladas estão disponíveis na página de [Releases](https://github.com/tgies/MS-DOS/releases). Para compilar a partir do código-fonte:

## Requisitos

- dosemu2
- mtools
- mkfatimage16 (do dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 ou posterior é necessário.** comcom64 é o substituto do command.com usado pelo dosemu2. Algumas versões anteriores têm um [bug no comando `COPY`](https://github.com/dosemu2/comcom64/pull/117) que quebra a concatenação de arquivos (`copy /b a+b dest`) quando invocado via `COMMAND /C`, que o nmake usa para executar comandos de makefile. Isso faz com que o build do IO.SYS falhe silenciosamente.
>
> Verifique sua versão com `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) ou consulte seu gerenciador de pacotes. Se você estiver em uma versão mais antiga:
> - **Recomendado:** Atualize o comcom64 para 0.4-0~202602051302 ou posterior
> - **Solução alternativa:** Compile o comcom64 a partir do código-fonte: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (certifique-se de que `make install` instale por cima do seu `command.efi` existente)

## Início Rápido

```bash
cd v4.0
./mak.sh              # Compila DOS 4
./mkhdimg.sh          # Cria imagem de disco rígido de 64MB
./mkhdimg.sh --floppy # Cria disquete de boot de 1.44MB
```

## Versões de Build

O código-fonte suporta múltiplas configurações de build. Use a flag `--flavor`:

```bash
./mak.sh                    # Compila MS-DOS (padrão)
./mak.sh --flavor=pcdos     # Compila IBM PC-DOS
```

| Variante | Arquivos do Sistema | Descrição |
|--------|---------------------|-----------|
| **msdos** | IO.SYS, MSDOS.SYS | MS-DOS OEM para PCs compatíveis com IBM (padrão, recomendado) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (para precisão histórica) |

Ambas as versões incluem código específico de hardware do IBM PC (BIOS de vídeo INT 10H, PIC 8259, suporte a cartucho ROM PCjr).

**Importante:** A versão **msdos** contém mais correções de bugs do que **pcdos**. Presumivelmente, a Microsoft podia enviar correções para o MS-DOS OEM mais rapidamente do que o processo de aprovação da IBM permitia para o PC-DOS. Sabe-se que a IBM essencialmente assumiu o desenvolvimento do DOS temporariamente em torno do DOS 3.3 até o DOS 4.0, então uma teoria possível é que o PC-DOS foi essencialmente considerado congelado quando o código foi devolvido à Microsoft, que encontrou uma série de bugs que corrigiu no MS-DOS OEM sem tocar no PC-DOS.

Diferenças notáveis:
- Correção no tratamento de INT 24 (erro crítico) no kernel do DOS
- Proteção contra overflow de inteiros no FDISK para discos grandes
- Buffers EMS maiores no FASTOPEN
- Melhor validação de entrada no EXE2BIN

A versão padrão **msdos** é o que OEMs como Compaq, Dell e HP forneciam como "MS-DOS" em seus PCs compatíveis com IBM. Esta liberação de código-fonte na verdade parece derivar do OAK (OEM Adaptation Kit) -- o código que a Microsoft fornecia aos OEMs para permitir que personalizassem o MS-DOS para seu hardware.

## Opções de Imagem de Disco

```bash
# Imagens de disco rígido (produz msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Imagem FAT16 de 64MB
./mkhdimg.sh --size 32          # Imagem de 32MB

# Imagens de disquete (todos os tamanhos)
./mkhdimg.sh --floppy           # 1.44MB mínimo (apenas arquivos do sistema)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB com utilitários
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB com utilitários
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB com utilitários
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB com utilitários
```

Imagens de disco rígido são produzidas em dois formatos: `msdos4.img` é uma imagem de disco raw que funciona com QEMU, VirtualBox, bochs e a maioria dos emuladores. `msdos4-dosemu.img` é o formato hdimage do dosemu (cabeçalho de 128 bytes). Imagens de disquete são raw e funcionam em todos os lugares.

## Limitações Conhecidas

- **DOS Shell não incluído**: O código-fonte do DOS Shell (DOSSHELL) não foi disponibilizado como código aberto. SELECT.EXE (o instalador) compartilha algum código com o DOSSHELL e não pode ser compilado.
- **Marca PC-DOS incompleta**: O build `--flavor=pcdos` usa nomes de arquivos do sistema IBM (IBMBIO.COM, IBMDOS.COM) e alguns caminhos de código específicos do PC-DOS, mas ainda exibe "MS-DOS" no VER e no banner de inicialização. Isso ocorre porque o arquivo de mensagens da IBM (`usa-ibm.msg` ou similar) não foi disponibilizado como código aberto—apenas o `usa-ms.msg` com marca Microsoft foi liberado.
- **Build não compatível com IBM**: Uma terceira configuração (`IBMVER=FALSE`) existe no código-fonte para hardware não compatível com IBM, mas não compila com sucesso. Parece que esta configuração é para alguns dos PCs x86 não compatíveis com IBM de vida curta do início dos anos 1980 -- ela especificamente evita certos caminhos de código específicos de compatíveis com IBM lidando com hardware como BIOS, PIC, PIT, etc. É necessária mais investigação, mas é provável que esta árvore de código-fonte esteja incompleta e faltando o código específico de hardware (coisas do IO.SYS) que precisaria ser fornecido para implementar serviços do DOS em tal hardware.

# Marcas Registradas

Este projeto pode conter marcas registradas ou logotipos de projetos, produtos ou serviços. O uso autorizado de marcas registradas ou logotipos da Microsoft está sujeito e deve seguir as
[Diretrizes de Marcas Registradas e Marcas da Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
O uso de marcas registradas ou logotipos da Microsoft em versões modificadas deste projeto não deve causar confusão ou implicar patrocínio da Microsoft.
Qualquer uso de marcas registradas ou logotipos de terceiros está sujeito às políticas desses terceiros.
