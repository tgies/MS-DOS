<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25、v2.0、v4.0 原始碼

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

這個 repo 包括了 MS-DOS v1.25 和 MS-DOS v2.0 的原始碼以及編譯好的執行檔，以及由 IBM 和 Microsoft 共同開發的 MS-DOS v4.00 原始碼。

我們在 [2014 年的 3 月 25 日於計算機歷史博物館 (Computer History Museum)](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) 首次分享了 MS-DOS v1.25 和 v2.0 的檔案，現在把這些檔案放在這個 repo 中，讓大家可以更方便地搜尋、在其他文章或專案中參考，也讓對於早期 PC 作業系統有興趣的人可以進行探索與實驗。

# 關於這個 fork

這個 fork 為 MS-DOS 4.0 原始碼加入了可運作的建置系統和 CI 流程。它能將原始的 8086 組合語言和 C 語言原始碼建置成完整、可開機的作業系統，包括 OEM **MS-DOS** 和 **IBM PC-DOS** 兩種版本。

建置過程會產生可直接使用的磁碟映像檔（64MB 硬碟和符合時代規格的軟碟，從 360KB 到 1.44MB），可在 QEMU、VirtualBox、bochs、dosemu、86Box、PCem 中開機，或在真實的老式硬體上執行。預先建置好的映像檔可在 [Releases](https://github.com/tgies/MS-DOS/releases) 頁面下載。

這項工作受益於其他人先前為了讓 MS-DOS 4.0 原始碼能夠建置所做的努力，包括清理釋出的原始碼樹中的一些小問題（錯誤的檔案路徑和損壞的字元編碼），包括但不限於 [ecm](https://hg.pushbx.org/ecm/msdos4) 和 [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477) 的貢獻。

# 試試看

從 [最新的 release](https://github.com/tgies/MS-DOS/releases) 下載 `msdos4.img` 並開機：

```bash
qemu-system-i386 -hda msdos4.img
```

或使用 DOSBox，正常啟動 DOSBox 然後開機映像檔（如果使用軟碟映像檔，請省略 `-l C`）：

```bash
BOOT msdos4.img -l C
```

或使用 dosemu（下載 `msdos4-dosemu.img`，這是有 dosemu2 專用標頭的版本）：

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# 授權條款

所有在這個 repo 的檔案皆使用 [MIT 授權](https://en.wikipedia.org/wiki/MIT_License)，詳細資訊請參考這個 repo 根目錄放的[授權檔](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE)。

# 歷史參考

> **注意：**本節保留自 Microsoft 原始 README.md 隨同原始碼釋出的內容。這個 repository 中的建置腳本和工具與歷史原始碼分開維護。歡迎針對建置系統改進的 Pull Requests。

這份原始碼放在這個 repo 的目的是要留一個歷史紀錄，所以會保持不動。因此請**不要**送任何修改原始碼的 Pull Requests 來，但自行 fork 這個 repo 並做自己的實驗是沒問題的 😊。

這個專案採用了 [Microsoft 開放原始碼管理辦法](https://opensource.microsoft.com/codeofconduct/)。如果需要更多資訊，請參考[管理辦法常見問題](https://opensource.microsoft.com/codeofconduct/faq/)或是聯絡 [opencode@microsoft.com](mailto:opencode@microsoft.com) 來進行進一步的詢問。

# 建置 MS-DOS 4.0

預先建置好的磁碟映像檔可在 [Releases](https://github.com/tgies/MS-DOS/releases) 頁面取得。若要從原始碼建置：

## 需求

- dosemu2
- mtools
- mkfatimage16（來自 dosemu2）

> [!IMPORTANT]
> **需要 comcom64 0.4-0~202602051302 或更新版本。** comcom64 是 dosemu2 使用的 command.com 替代品。某些較早的版本在透過 `COMMAND /C` 呼叫時，`COPY` 指令有一個會破壞檔案串接（`copy /b a+b dest`）的[臭蟲](https://github.com/dosemu2/comcom64/pull/117)，而 nmake 使用該方式執行 makefile 指令。這會導致 IO.SYS 建置默默失敗。
>
> 使用 `dpkg -s comcom64 | grep Version`（Debian/Ubuntu）檢查您的版本，或查看您的套件管理員。如果您使用較舊版本：
> - **建議：**更新 comcom64 到 0.4-0~202602051302 或更新版本
> - **替代方案：**從原始碼建置 comcom64：`git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install`（確保 `make install` 覆蓋安裝在您現有的 `command.efi` 之上）

## 快速開始

```bash
cd v4.0
./mak.sh              # 建置 DOS 4
./mkhdimg.sh          # 建立 64MB 硬碟映像檔
./mkhdimg.sh --floppy # 建立 1.44MB 開機軟碟
```

## 建置版本

原始碼支援多種建置配置。使用 `--flavor` 旗標：

```bash
./mak.sh                    # 建置 MS-DOS（預設）
./mak.sh --flavor=pcdos     # 建置 IBM PC-DOS
```

| 版本 | 系統檔案 | 說明 |
|--------|--------------|-------------|
| **msdos** | IO.SYS, MSDOS.SYS | 用於 IBM 相容 PC 的 OEM MS-DOS（預設，建議使用） |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS（用於歷史準確性） |

兩種版本都包含 IBM PC 硬體專屬程式碼（INT 10H 影像 BIOS、8259 PIC、PCjr ROM 卡匣支援）。

**重要：****msdos** 版本包含比 **pcdos** 更多的錯誤修復。據推測，Microsoft 能夠比 IBM 的審批流程允許的 PC-DOS 更快地推送修復到 OEM MS-DOS。已知 IBM 在 DOS 3.3 到 DOS 4.0 期間基本上暫時接管了 DOS 開發，因此一種可能的理論是，當程式碼交還給 Microsoft 時，PC-DOS 基本上被視為凍結，而 Microsoft 發現了許多錯誤並在 OEM MS-DOS 中修復，而沒有觸碰 PC-DOS。

值得注意的差異：
- DOS 核心 INT 24（關鍵錯誤）處理修復
- FDISK 對大型磁碟的整數溢位保護
- FASTOPEN 中更大的 EMS 緩衝區
- EXE2BIN 中更好的輸入驗證

預設的 **msdos** 版本就是 OEM 廠商如 Compaq、Dell 和 HP 在其 IBM 相容 PC 上作為「MS-DOS」出貨的版本。這個原始碼釋出實際上似乎源自 OAK（OEM Adaptation Kit）——Microsoft 提供給 OEM 廠商的程式碼，允許他們為自己的硬體客製化 MS-DOS。

## 磁碟映像檔選項

```bash
# 硬碟映像檔（產生 msdos4.img + msdos4-dosemu.img）
./mkhdimg.sh                    # 64MB FAT16 映像檔
./mkhdimg.sh --size 32          # 32MB 映像檔

# 軟碟映像檔（所有大小）
./mkhdimg.sh --floppy           # 1.44MB 最小版（僅系統檔案）
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB 含工具程式
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB 含工具程式
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB 含工具程式
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB 含工具程式
```

硬碟映像檔以兩種格式產生：`msdos4.img` 是原始磁碟映像檔，可與 QEMU、VirtualBox、bochs 和大多數模擬器搭配使用。`msdos4-dosemu.img` 是 dosemu hdimage 格式（128 位元組標頭）。軟碟映像檔是原始格式，可在任何地方使用。

## 已知限制

- **未包含 DOS Shell**：DOS Shell（DOSSHELL）原始碼未開放原始碼。SELECT.EXE（安裝程式）與 DOSSHELL 共享部分程式碼，因此無法建置。
- **PC-DOS 品牌不完整**：`--flavor=pcdos` 建置使用 IBM 系統檔案名稱（IBMBIO.COM、IBMDOS.COM）和一些 PC-DOS 專屬程式碼路徑，但在 VER 和啟動橫幅中仍顯示「MS-DOS」。這是因為 IBM 的訊息檔案（`usa-ibm.msg` 或類似檔案）未開放原始碼——僅釋出了 Microsoft 品牌的 `usa-ms.msg`。
- **非 IBM 相容建置**：原始碼中存在針對非 IBM 相容硬體的第三種配置（`IBMVER=FALSE`），但無法成功建置。看起來這個配置是為一些 1980 年代早期短命的非 IBM 相容 x86 PC 準備的——它特別迴避了處理 BIOS、PIC、PIT 等硬體的某些 IBM 相容專屬程式碼路徑。需要進一步調查，但很可能這個原始碼樹是不完整的，缺少需要提供以在此類硬體上實作 DOS 服務的硬體專屬程式碼（IO.SYS 相關內容）。

# 商標

這個專案可能包含專案、產品或服務的商標或標誌。Microsoft 商標或標誌的授權使用必須遵守
[Microsoft 商標與品牌指南](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general)。
在這個專案的修改版本中使用 Microsoft 商標或標誌不得造成混淆或暗示 Microsoft 贊助。
任何第三方商標或標誌的使用均受這些第三方政策的約束。
