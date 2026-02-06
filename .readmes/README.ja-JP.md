<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 ソースコード

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

このリポジトリは、MS-DOS v1.25とMS-DOS v2.0のオリジナルソースコードとコンパイル済みバイナリ、そしてIBMとMicrosoftが共同開発したMS-DOS v4.00のソースコードを含んでいます。

MS-DOS v1.25とv2.0のファイルは、[元々2014年3月25日にComputer History Museumで公開されたもの](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/)であり、見つけやすく、外部の文書や作品から参照しやすく、初期のPCオペレーティングシステムに興味を持つ人々が探索や実験を行えるようにするため、このリポジトリで（再）公開されています。

# このフォークについて

このフォークは、MS-DOS 4.0のソースコードに対する動作するビルドシステムとCIパイプラインを追加しています。オリジナルの8086アセンブリとCソースを、OEM **MS-DOS**とIBM **PC-DOS**の両方のフレーバーで、完全な起動可能なオペレーティングシステムにビルドします。

ビルドにより、QEMU、VirtualBox、bochs、dosemu、86Box、PCem、または実際のヴィンテージハードウェアで起動できる、すぐに使えるディスクイメージ（64MBハードディスクと360KBから1.44MBまでの当時の仕様に準拠したフロッピー）が生成されます。ビルド済みイメージは[Releases](https://github.com/tgies/MS-DOS/releases)ページで入手できます。

この作業は、リリースされたソースツリーの軽微な問題（間違ったファイルパスや文字エンコーディングの破損）をクリーンアップすることで、MS-DOS 4.0のソースコードをビルド可能にする以前の取り組みから大きな恩恵を受けています。これには、[ecm](https://hg.pushbx.org/ecm/msdos4)や[hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477)などの貢献が含まれますが、これに限定されません。

# 試してみる

[最新リリース](https://github.com/tgies/MS-DOS/releases)から`msdos4.img`をダウンロードして起動します：

```bash
qemu-system-i386 -hda msdos4.img
```

または、DOSBoxで通常通りDOSBoxを起動してからイメージを起動します（フロッピーイメージを使用する場合は`-l C`を省略してください）：

```bash
BOOT msdos4.img -l C
```

または、dosemu（`msdos4-dosemu.img`をダウンロードしてください。dosemu2用の特別なヘッダーを持っています）：

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# ライセンス

このリポジトリ内のすべてのファイルは、このリポジトリのルートに保存されている[LICENSEファイル](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE)に従い、[MIT License](https://en.wikipedia.org/wiki/MIT_License)の下でリリースされています。

# 歴史的参考資料について

> **注意：** このセクションは、ソースコードリリースに付属していたMicrosoftのオリジナルREADME.mdから保存されています。このリポジトリのビルドスクリプトとツールは、歴史的なソースコードとは別に保守されています。ビルドシステムの改善に関するプルリクエストは歓迎します。

このリポジトリのソースファイルは歴史的参考資料であり、静的に保持されますので、ソースファイルへの変更を提案するプルリクエストは**送らないで**ください。ただし、このリポジトリをフォークして実験することは歓迎します😊

このプロジェクトは[Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/)を採用しています。詳細については、[Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)をご覧いただくか、[opencode@microsoft.com](mailto:opencode@microsoft.com)までご質問やコメントをお送りください。

# MS-DOS 4.0のビルド

ビルド済みディスクイメージは[Releases](https://github.com/tgies/MS-DOS/releases)ページで入手できます。ソースからビルドするには：

## 必要要件

- dosemu2
- mtools
- mkfatimage16（dosemu2から）

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302以降が必要です。** comcom64は、dosemu2が使用するcommand.comの代替品です。一部の古いバージョンには、`COMMAND /C`経由で呼び出されたときにファイルの連結（`copy /b a+b dest`）を壊す[`COPY`コマンドのバグ](https://github.com/dosemu2/comcom64/pull/117)があり、これがnmakeがmakefileコマンドを実行するために使用されるため、IO.SYSのビルドが静かに失敗します。
>
> `dpkg -s comcom64 | grep Version`（Debian/Ubuntu）でバージョンを確認するか、パッケージマネージャーで確認してください。古いバージョンの場合：
> - **推奨：** comcom64を0.4-0~202602051302以降にアップデート
> - **回避策：** ソースからcomcom64をビルド：`git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install`（`make install`が既存の`command.efi`の上にインストールされることを確認してください）

## クイックスタート

```bash
cd v4.0
./mak.sh              # DOS 4をビルド
./mkhdimg.sh          # 64MBハードディスクイメージを作成
./mkhdimg.sh --floppy # 1.44MBブートフロッピーを作成
```

## ビルドフレーバー

ソースコードは複数のビルド構成をサポートしています。`--flavor`フラグを使用します：

```bash
./mak.sh                    # MS-DOSをビルド（デフォルト）
./mak.sh --flavor=pcdos     # IBM PC-DOSをビルド
```

| フレーバー | システムファイル | 説明 |
|--------|--------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | IBM互換PC用のOEM MS-DOS（デフォルト、推奨） |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS（歴史的正確性のため） |

両方のフレーバーには、IBM PCハードウェア固有のコード（INT 10Hビデオ BIOS、8259 PIC、PCjr ROMカートリッジサポート）が含まれています。

**重要：** **msdos**フレーバーは**pcdos**よりも多くのバグ修正を含んでいます。おそらく、MicrosoftはIBMの承認プロセスがPC-DOSで許可したよりも速く、OEM MS-DOSに修正をプッシュできたためです。IBMがDOS 3.3からDOS 4.0頃にDOS開発を一時的に引き継いだことが知られているため、一つの可能性として、コードがMicrosoftに戻されたときにPC-DOSは本質的に凍結されたと考えられ、Microsoftは多数のバグを発見し、PC-DOSには触れずにOEM MS-DOSで修正したという説があります。

注目すべき違い：
- DOSカーネルINT 24（重大エラー）処理の修正
- 大容量ディスク用のFDISK整数オーバーフロー保護
- FASTOPENでのより大きなEMSバッファ
- EXE2BINでのより良い入力検証

デフォルトの**msdos**フレーバーは、Compaq、Dell、HPなどのOEMがIBM互換PC上で「MS-DOS」として出荷したものです。このソースリリースは実際には、OAK（OEM Adaptation Kit）— MicrosoftがOEMに提供して、MS-DOSをハードウェア用にカスタマイズできるようにしたコード — から派生しているようです。

## ディスクイメージオプション

```bash
# ハードディスクイメージ（msdos4.img + msdos4-dosemu.imgを生成）
./mkhdimg.sh                    # 64MB FAT16イメージ
./mkhdimg.sh --size 32          # 32MBイメージ

# フロッピーイメージ（すべてのサイズ）
./mkhdimg.sh --floppy           # 1.44MB最小構成（システムファイルのみ）
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB ユーティリティ付き
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB ユーティリティ付き
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB ユーティリティ付き
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB ユーティリティ付き
```

ハードディスクイメージは2つの形式で生成されます：`msdos4.img`は、QEMU、VirtualBox、bochs、およびほとんどのエミュレータで動作する生のディスクイメージです。`msdos4-dosemu.img`は、dosemuのhdimage形式（128バイトヘッダー）です。フロッピーイメージは生形式で、どこでも動作します。

## 既知の制限事項

- **DOS Shellは含まれていません**：DOS Shell（DOSSHELL）のソースコードはオープンソース化されませんでした。SELECT.EXE（インストーラー）はDOSSHELLと一部のコードを共有しているため、ビルドできません。
- **PC-DOSブランディングは不完全です**：`--flavor=pcdos`ビルドは、IBMシステムファイル名（IBMBIO.COM、IBMDOS.COM）といくつかのPC-DOS固有のコードパスを使用しますが、VERと起動バナーには依然として「MS-DOS」と表示されます。これは、IBMのメッセージファイル（`usa-ibm.msg`または類似のもの）がオープンソース化されず、Microsoftブランドの`usa-ms.msg`のみがリリースされたためです。
- **非IBM互換ビルド**：非IBM互換ハードウェア用の3つ目の構成（`IBMVER=FALSE`）がソースに存在しますが、正常にビルドできません。この構成は、1980年代初期の短命だった非IBM互換x86 PCの一部を対象としているようです — 具体的には、BIOS、PIC、PITなどのハードウェアを扱うIBM互換固有のコードパスを回避します。さらなる調査が必要ですが、このソースツリーは不完全で、そのようなハードウェア上でDOSサービスを実装するために提供される必要があるハードウェア固有のコード（IO.SYS関連）が欠けている可能性があります。

# 商標

このプロジェクトには、プロジェクト、製品、またはサービスの商標またはロゴが含まれている場合があります。Microsoftの商標またはロゴの承認された使用は、[Microsoftの商標とブランドガイドライン](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general)に従う必要があります。このプロジェクトの修正版でMicrosoftの商標またはロゴを使用する場合、混乱を引き起こしたり、Microsoftのスポンサーシップを暗示したりしてはなりません。第三者の商標またはロゴの使用は、それらの第三者のポリシーに従います。
