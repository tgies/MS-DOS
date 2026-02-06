<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="Logotipo do MS-DOS" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Código Fonte do MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Este repositório contém o código fonte e os binários compilados originais do MS-DOS v1.25 e MS-DOS v2.0, mais o código fonte do MS-DOS v4.00 desenvolvido conjuntamente pela IBM e pela Microsoft.

Os ficheiros do MS-DOS v1.25 e v2.0 [foram partilhados originalmente no Museu da História da Computação (Computer History Museum) no dia 25 de Março de 2014](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) e estão a ser (re)publicados neste repositório de forma a serem mais fáceis de encontrar, referenciar em trabalhos e artigos externos, e permitir a exploração e experimentação para aqueles interessados em Sistemas Operativos antigos para PCs.

# Acerca deste fork

Este fork adiciona um sistema de compilação funcional e um pipeline de CI para o código fonte do MS-DOS 4.0. Compila o código assembly 8086 original e as fontes em C num sistema operativo completo e arrancável -- tanto nas versões OEM **MS-DOS** como **IBM PC-DOS**.

A compilação produz imagens de disco prontas a usar (disco rígido de 64MB e disquetes fiéis ao período, de 360KB a 1.44MB) que arrancam em QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, ou em hardware antigo real. Imagens pré-compiladas estão disponíveis na página de [Releases](https://github.com/tgies/MS-DOS/releases).

Este trabalho beneficia muito do trabalho prévio feito por outros para conseguir compilar o código fonte do MS-DOS 4.0, corrigindo alguns problemas menores na árvore de código publicada (caminhos de ficheiros incorretos e codificações de caracteres corrompidas), incluindo, mas não limitado a, [ecm](https://hg.pushbx.org/ecm/msdos4) e [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Experimente

Descarregue `msdos4.img` a partir da [última release](https://github.com/tgies/MS-DOS/releases) e arranque-a:

```bash
qemu-system-i386 -hda msdos4.img
```

Ou com DOSBox, inicie o DOSBox normalmente e depois arranque a imagem (omita `-l C` se usar uma imagem de disquete):

```bash
BOOT msdos4.img -l C
```

Ou com dosemu (descarregue `msdos4-dosemu.img`, que tem um cabeçalho especial para dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Licença

Todos os ficheiros deste repositório estão lançados sob a [Licença MIT](https://pt.wikipedia.org/wiki/Licen%C3%A7a_MIT) como descrito no [ficheiro LICENSE](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) presente na raiz deste repositório.

# Para referência histórica

> **NOTA:** Esta secção está preservada do README.md original da Microsoft que acompanha a publicação do código fonte. Os scripts de compilação e ferramentas neste repositório são mantidos separadamente do código fonte histórico. Pull requests para melhorias ao sistema de compilação são bem-vindos.

Os ficheiros de código fonte deste repositório são para referência histórica e serão mantidos estáticos, portanto pedimos que **não envie** Pull Requests a sugerir modificações aos ficheiros de código fonte, mas sinta-se à vontade para dar fork a este repositório e experimentar 😊.

Este projeto adota o [Código de Conduta Open Source da Microsoft](https://opensource.microsoft.com/codeofconduct/). Para mais informações veja as [Perguntas Frequentes sobre o Código de Conduta](https://opensource.microsoft.com/codeofconduct/faq/) ou contacte [opencode@microsoft.com](mailto:opencode@microsoft.com) com quaisquer questões ou comentários adicionais.

# Compilar o MS-DOS 4.0

Imagens de disco pré-compiladas estão disponíveis na página de [Releases](https://github.com/tgies/MS-DOS/releases). Para compilar a partir do código fonte:

## Requisitos

- dosemu2
- mtools
- mkfatimage16 (do dosemu2)

> [!IMPORTANT]
> **É necessário comcom64 0.4-0~202602051302 ou posterior.** comcom64 é o substituto do command.com usado pelo dosemu2. Algumas versões anteriores têm um [bug no comando `COPY`](https://github.com/dosemu2/comcom64/pull/117) que quebra a concatenação de ficheiros (`copy /b a+b dest`) quando invocado via `COMMAND /C`, que o nmake usa para executar comandos do makefile. Isto causa a falha silenciosa da compilação do IO.SYS.
>
> Verifique a sua versão com `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) ou consulte o seu gestor de pacotes. Se estiver numa versão anterior:
> - **Recomendado:** Atualize o comcom64 para 0.4-0~202602051302 ou posterior
> - **Solução alternativa:** Compile o comcom64 a partir do código fonte: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (certifique-se que o `make install` instala por cima do seu `command.efi` existente)

## Início Rápido

```bash
cd v4.0
./mak.sh              # Compilar DOS 4
./mkhdimg.sh          # Criar imagem de disco rígido de 64MB
./mkhdimg.sh --floppy # Criar disquete de arranque de 1.44MB
```

## Versões de Compilação

O código fonte suporta múltiplas configurações de compilação. Use a flag `--flavor`:

```bash
./mak.sh                    # Compilar MS-DOS (predefinido)
./mak.sh --flavor=pcdos     # Compilar IBM PC-DOS
```

| Versão | Ficheiros de Sistema | Descrição |
|--------|---------------------|-----------|
| **msdos** | IO.SYS, MSDOS.SYS | MS-DOS OEM para PCs compatíveis com IBM (predefinido, recomendado) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (para exatidão histórica) |

Ambas as versões incluem código específico de hardware IBM PC (BIOS de vídeo INT 10H, PIC 8259, suporte a cartuchos ROM PCjr).

**Importante:** A versão **msdos** contém mais correções de bugs do que **pcdos**. Presumivelmente, a Microsoft conseguia enviar correções para o MS-DOS OEM mais rapidamente do que o processo de aprovação da IBM permitia para o PC-DOS. É sabido que a IBM essencialmente assumiu temporariamente o desenvolvimento do DOS desde cerca do DOS 3.3 até ao DOS 4.0, pelo que uma teoria possível é que o PC-DOS foi essencialmente considerado congelado quando o código foi devolvido à Microsoft, que encontrou vários bugs que corrigiram no MS-DOS OEM sem tocar no PC-DOS.

Diferenças notáveis:
- Correção no tratamento de INT 24 (erro crítico) do kernel DOS
- Proteção contra overflow de inteiros no FDISK para discos grandes
- Buffers EMS maiores no FASTOPEN
- Melhor validação de entrada no EXE2BIN

A versão predefinida **msdos** é o que OEMs como Compaq, Dell e HP distribuíam como "MS-DOS" nos seus PCs compatíveis com IBM. Esta publicação do código fonte parece de facto derivar do OAK (OEM Adaptation Kit) -- o código que a Microsoft fornecia aos OEMs para lhes permitir personalizar o MS-DOS para o seu hardware.

## Opções de Imagem de Disco

```bash
# Imagens de disco rígido (produz msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Imagem FAT16 de 64MB
./mkhdimg.sh --size 32          # Imagem de 32MB

# Imagens de disquete (todos os tamanhos)
./mkhdimg.sh --floppy           # 1.44MB mínima (apenas ficheiros de sistema)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB com utilitários
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB com utilitários
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB com utilitários
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB com utilitários
```

As imagens de disco rígido são produzidas em dois formatos: `msdos4.img` é uma imagem de disco bruta que funciona com QEMU, VirtualBox, bochs e a maioria dos emuladores. `msdos4-dosemu.img` está no formato hdimage do dosemu (cabeçalho de 128 bytes). As imagens de disquete são brutas e funcionam em todo o lado.

## Limitações Conhecidas

- **DOS Shell não incluído**: O código fonte do DOS Shell (DOSSHELL) não foi tornado open-source. SELECT.EXE (o instalador) partilha algum código com o DOSSHELL e não pode ser compilado.
- **Marca PC-DOS incompleta**: A compilação `--flavor=pcdos` usa nomes de ficheiros de sistema IBM (IBMBIO.COM, IBMDOS.COM) e alguns caminhos de código específicos do PC-DOS, mas ainda exibe "MS-DOS" no VER e na mensagem de arranque. Isto deve-se ao facto de o ficheiro de mensagens da IBM (`usa-ibm.msg` ou similar) não ter sido tornado open-source—apenas o `usa-ms.msg` com a marca Microsoft foi publicado.
- **Compilação não-compatível-IBM**: Existe uma terceira configuração (`IBMVER=FALSE`) no código fonte para hardware não-compatível-IBM, mas não compila com sucesso. Parece que esta configuração é para alguns dos PCs x86 não-compatíveis-IBM de curta duração do início dos anos 1980 -- especificamente evita certos caminhos de código específicos de compatíveis-IBM que lidam com hardware como a BIOS, PIC, PIT, e assim por diante. É necessária mais investigação, mas é provável que esta árvore de código esteja incompleta e falte o código específico de hardware (partes do IO.SYS) que teria de ser fornecido para implementar serviços DOS em tal hardware.

# Marcas Registadas

Este projeto pode conter marcas registadas ou logotipos de projetos, produtos ou serviços. O uso autorizado de marcas registadas ou logotipos da Microsoft está sujeito e deve seguir as
[Diretrizes de Marcas Registadas e Marca da Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
O uso de marcas registadas ou logotipos da Microsoft em versões modificadas deste projeto não pode causar confusão ou implicar patrocínio da Microsoft.
Qualquer uso de marcas registadas ou logotipos de terceiros está sujeito às políticas desses terceiros.
