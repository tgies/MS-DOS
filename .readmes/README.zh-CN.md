<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 源代码

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

本仓库包含 MS-DOS v1.25 和 MS-DOS v2.0 的原始源代码和编译后的二进制文件，以及由 IBM 和 Microsoft 共同开发的 MS-DOS v4.00 源代码。

MS-DOS v1.25 和 v2.0 的文件[最初于 2014 年 3 月 25 日在计算机历史博物馆分享](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/)，并在本仓库中（重新）发布，以便于查找、在外部文章和作品中引用，并允许对早期 PC 操作系统感兴趣的人进行探索和实验。

# 关于此分支 (Fork)

此分支为 MS-DOS 4.0 源代码添加了可用的构建系统和 CI 流水线。它将原始的 8086 汇编和 C 源代码构建为一个完整的、可启动的操作系统 —— 包括 OEM **MS-DOS** 和 **IBM PC-DOS** 两个变体。

构建过程会生成开箱即用的磁盘映像（64MB 硬盘和符合时代特征的 360KB 到 1.44MB 软盘），这些映像可以在 QEMU、VirtualBox、bochs、dosemu、86Box、PCem 或真实的复古硬件上启动。预构建的映像可在 [Releases](https://github.com/tgies/MS-DOS/releases) 页面下载。

这项工作在很大程度上受益于其他人之前为使 MS-DOS 4.0 源代码可构建而所做的工作，他们清理了已发布源代码树中的一些小问题（错误的文件路径和损坏的字符编码），包括但不限于 [ecm](https://hg.pushbx.org/ecm/msdos4) 和 [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477)。

# 试一试

从 [最新发布](https://github.com/tgies/MS-DOS/releases) 下载 `msdos4.img` 并启动它：

```bash
qemu-system-i386 -hda msdos4.img
```

或者使用 DOSBox，正常启动 DOSBox，然后启动映像（如果使用软盘映像，请省略 `-l C`）：

```bash
BOOT msdos4.img -l C
```

或者使用 dosemu（下载 `msdos4-dosemu.img`，它具有 dosemu2 的特殊头文件）：

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# 许可证

本仓库中的所有文件均根据本仓库根目录中存储的 [LICENSE 文件](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) 以 [MIT 许可证](https://en.wikipedia.org/wiki/MIT_License) 发布。

# 历史参考

> **注意：** 本节保留自源代码发布时附带的 Microsoft 原始 README.md。本仓库中的构建脚本和工具与历史源代码分开维护。欢迎提交关于改进构建系统的 Pull Request。

本仓库中的源文件仅供历史参考，并将保持静态，因此请**不要发送**建议修改源文件的 Pull Request，但欢迎 Fork 本仓库并进行实验 😊。

本项目采用了 [Microsoft 开源行为准则](https://opensource.microsoft.com/codeofconduct/)。有关更多信息，请参阅[行为准则常见问题解答](https://opensource.microsoft.com/codeofconduct/faq/)，或如有任何其他问题或评论，请联系 [opencode@microsoft.com](mailto:opencode@microsoft.com)。

# 构建 MS-DOS 4.0

预构建的磁盘映像可在 [Releases](https://github.com/tgies/MS-DOS/releases) 页面上找到。要从源代码构建：

## 要求

- dosemu2
- mtools
- mkfatimage16 (来自 dosemu2)

> [!IMPORTANT]
> **需要 comcom64 0.4-0~202602051302 或更高版本。** comcom64 是 dosemu2 使用的 command.com 替代品。一些早期版本在 [`COPY` 命令中存在 Bug](https://github.com/dosemu2/comcom64/pull/117)，当通过 `COMMAND /C`（nmake 使用它来执行 makefile 命令）调用时，会破坏文件连接 (`copy /b a+b dest`)。这会导致 IO.SYS 构建静默失败。
>
> 使用 `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) 检查您的版本，或检查您的包管理器。如果您使用的是旧版本：
> - **推荐：** 将 comcom64 更新到 0.4-0~202602051302 或更高版本
> - **解决方法：** 从源代码构建 comcom64：`git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install`（确保 `make install` 安装在现有的 `command.efi` 之上）

## 快速开始

```bash
cd v4.0
./mak.sh              # 构建 DOS 4
./mkhdimg.sh          # 创建 64MB 硬盘映像
./mkhdimg.sh --floppy # 创建 1.44MB 启动软盘
```

## 构建变体 (Flavors)

源代码支持多种构建配置。使用 `--flavor` 标志：

```bash
./mak.sh                    # 构建 MS-DOS (默认)
./mak.sh --flavor=pcdos     # 构建 IBM PC-DOS
```

| 变体 | 系统文件 | 描述 |
|--------|--------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | 用于 IBM 兼容 PC 的 OEM MS-DOS (默认，推荐) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (为了历史准确性) |

这两种变体都包含 IBM PC 硬件特定的代码（INT 10H 视频 BIOS、8259 PIC、PCjr ROM 卡带支持）。

**重要：** **msdos** 变体包含比 **pcdos** 更多的错误修复。据推测，Microsoft 能够比 IBM 允许的 PC-DOS 审批流程更快地将修复推送到 OEM MS-DOS。众所周知，IBM 在 DOS 3.3 到 DOS 4.0 期间基本上暂时接管了 DOS 开发，因此一种可能的理论是，当代码交还给 Microsoft 时，PC-DOS 基本上被认为是冻结的，Microsoft 发现了许多错误，并在 OEM MS-DOS 中修复了这些错误，而没有触及 PC-DOS。

显著差异：
- DOS 内核 INT 24（严重错误）处理修复
- 针对大磁盘的 FDISK 整数溢出保护
- FASTOPEN 中更大的 EMS 缓冲区
- EXE2BIN 中更好的输入验证

默认的 **msdos** 变体是 Compaq、Dell 和 HP 等 OEM 在其 IBM 兼容 PC 上作为 "MS-DOS" 发布的版本。此源代码发布实际上似乎源自 OAK (OEM Adaptation Kit) —— Microsoft 提供给 OEM 以允许他们为其硬件定制 MS-DOS 的代码。

## 磁盘映像选项

```bash
# 硬盘映像 (生成 msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # 64MB FAT16 映像
./mkhdimg.sh --size 32          # 32MB 映像

# 软盘映像 (所有尺寸)
./mkhdimg.sh --floppy           # 1.44MB 最小化 (仅系统文件)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB 带实用程序
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB 带实用程序
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB 带实用程序
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB 带实用程序
```

硬盘映像以两种格式生成：`msdos4.img` 是原始磁盘映像，适用于 QEMU、VirtualBox、bochs 和大多数模拟器。`msdos4-dosemu.img` 是 dosemu hdimage 格式（128 字节头文件）。软盘映像是原始格式，随处可用。

## 已知限制

- **未包含 DOS Shell**：DOS Shell (DOSSHELL) 源代码未开源。SELECT.EXE（安装程序）与 DOSSHELL 共享一些代码，无法构建。
- **PC-DOS 品牌不完整**：`--flavor=pcdos` 构建使用 IBM 系统文件名 (IBMBIO.COM, IBMDOS.COM) 和一些 PC-DOS 特定的代码路径，但在 VER 和启动横幅中仍显示 "MS-DOS"。这是因为 IBM 的消息文件（`usa-ibm.msg` 或类似文件）未开源——仅发布了带有 Microsoft 品牌的 `usa-ms.msg`。
- **非 IBM 兼容构建**：源代码中存在针对非 IBM 兼容硬件的第三种配置 (`IBMVER=FALSE`)，但无法成功构建。这种配置似乎是针对 1980 年代早期一些短命的非 IBM 兼容 x86 PC 的 —— 它专门避开了处理 BIOS、PIC、PIT 等硬件的某些 IBM 兼容特定代码路径。需要进一步调查，但很可能此源代码树不完整，缺少在该类硬件上实现 DOS 服务所需提供的硬件特定代码（IO.SYS 相关内容）。

# 商标

本项目可能包含项目、产品或服务的商标或徽标。Microsoft 商标或徽标的授权使用受 [Microsoft 商标和品牌指南](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general) 的约束，并必须遵守该指南。
在本项目修改版本中使用 Microsoft 商标或徽标不得引起混淆或暗示 Microsoft 赞助。
任何第三方商标或徽标的使用均受该第三方的政策约束。
