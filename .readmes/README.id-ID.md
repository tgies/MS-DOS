<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# Kode Sumber MS-DOS v1.25, v2.0, v4.0

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Repo ini berisi kode sumber asli dan biner terkompilasi untuk MS-DOS v1.25 dan MS-DOS v2.0, ditambah kode sumber untuk MS-DOS v4.00 yang dikembangkan bersama oleh IBM dan Microsoft.

Berkas MS-DOS v1.25 dan v2.0 [awalnya dibagikan di Museum Sejarah Komputer pada 25 Maret 2014]( http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) dan sedang diterbitkan (ulang) di repo ini agar lebih mudah ditemukan, sebagai referensi dalam tulisan dan karya eksternal, dan untuk memungkinkan eksplorasi dan eksperimen bagi mereka yang tertarik pada Sistem Operasi PC awal.

# Tentang fork ini

Fork ini menambahkan sistem build yang berfungsi dan pipeline CI untuk kode sumber MS-DOS 4.0. Sistem ini membangun kode sumber assembly 8086 dan C asli menjadi sistem operasi yang lengkap dan dapat di-boot -- baik untuk varian OEM **MS-DOS** maupun **IBM PC-DOS**.

Build ini menghasilkan image disk siap pakai (hard disk 64MB dan floppy dari masa yang sesuai mulai dari 360KB hingga 1.44MB) yang dapat di-boot di QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, atau pada hardware vintage asli. Image yang sudah di-build tersedia di halaman [Releases](https://github.com/tgies/MS-DOS/releases).

Pekerjaan ini sangat diuntungkan oleh pekerjaan terdahulu yang dilakukan oleh orang lain untuk membuat kode sumber MS-DOS 4.0 dapat di-build dengan membersihkan beberapa masalah minor dalam pohon sumber yang dirilis (path berkas yang salah dan encoding karakter yang rusak), termasuk namun tidak terbatas pada, [ecm](https://hg.pushbx.org/ecm/msdos4) dan [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477).

# Coba sekarang

Unduh `msdos4.img` dari [release terbaru](https://github.com/tgies/MS-DOS/releases) dan boot:

```bash
qemu-system-i386 -hda msdos4.img
```

Atau dengan DOSBox, jalankan DOSBox seperti biasa kemudian boot image (hilangkan `-l C` jika menggunakan image floppy):

```bash
BOOT msdos4.img -l C
```

Atau dengan dosemu (unduh `msdos4-dosemu.img`, yang memiliki header khusus untuk dosemu2):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Lisensi

Semua berkas dalam repo ini dirilis di bawah [Lisensi MIT]( https://en.wikipedia.org/wiki/MIT_License) sesuai [berkas LICENSE](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) yang disimpan di akar repo ini.

# Untuk referensi historis

> **CATATAN:** Bagian ini dipertahankan dari README.md asli Microsoft yang menyertai rilis kode sumber. Skrip build dan tooling di repositori ini dipelihara secara terpisah dari kode sumber historis. Pull request untuk peningkatan sistem build dipersilakan.

Berkas sumber di repo ini adalah untuk referensi historis dan akan tetap statis, jadi mohon **jangan mengirimkan** Pull Request yang menyarankan modifikasi apa pun ke berkas sumber, tetapi jangan ragu untuk melakukan fork repo ini dan bereksperimen 😊.

Proyek ini telah mengadopsi [Kode Perilaku Microsoft Open Source](https://opensource.microsoft.com/codeofconduct/). Untuk informasi lebih lanjut, lihat [Pedoman Perilaku FAQ](https://opensource.microsoft.com/codeofconduct/faq/) atau hubungi [opencode@microsoft.com](mailto:opencode@microsoft.com) dengan pertanyaan atau komentar tambahan.

# Membangun MS-DOS 4.0

Image disk yang sudah di-build tersedia di halaman [Releases](https://github.com/tgies/MS-DOS/releases). Untuk membangun dari sumber:

## Persyaratan

- dosemu2
- mtools
- mkfatimage16 (dari dosemu2)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 atau lebih baru diperlukan.** comcom64 adalah pengganti command.com yang digunakan oleh dosemu2. Beberapa versi sebelumnya memiliki [bug di perintah `COPY`](https://github.com/dosemu2/comcom64/pull/117) yang merusak penggabungan berkas (`copy /b a+b dest`) ketika dipanggil melalui `COMMAND /C`, yang digunakan nmake untuk mengeksekusi perintah makefile. Ini menyebabkan build IO.SYS gagal secara diam-diam.
>
> Periksa versi Anda dengan `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) atau periksa package manager Anda. Jika Anda menggunakan versi yang lebih lama:
> - **Direkomendasikan:** Perbarui comcom64 ke 0.4-0~202602051302 atau lebih baru
> - **Workaround:** Build comcom64 dari sumber: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (pastikan `make install` menginstal di atas `command.efi` yang sudah ada)

## Mulai Cepat

```bash
cd v4.0
./mak.sh              # Build DOS 4
./mkhdimg.sh          # Buat image hard disk 64MB
./mkhdimg.sh --floppy # Buat boot floppy 1.44MB
```

## Build Flavor

Kode sumber mendukung beberapa konfigurasi build. Gunakan flag `--flavor`:

```bash
./mak.sh                    # Build MS-DOS (default)
./mak.sh --flavor=pcdos     # Build IBM PC-DOS
```

| Flavor | Berkas Sistem | Deskripsi |
|--------|--------------|-----------|
| **msdos** | IO.SYS, MSDOS.SYS | OEM MS-DOS untuk PC yang kompatibel dengan IBM (default, direkomendasikan) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (untuk akurasi historis) |

Kedua flavor termasuk kode spesifik hardware IBM PC (INT 10H video BIOS, 8259 PIC, dukungan ROM cartridge PCjr).

**Penting:** Flavor **msdos** berisi lebih banyak perbaikan bug daripada **pcdos**. Kemungkinan besar, Microsoft dapat mengirimkan perbaikan ke OEM MS-DOS lebih cepat daripada proses persetujuan IBM yang diizinkan untuk PC-DOS. Diketahui bahwa IBM pada dasarnya mengambil alih pengembangan DOS untuk sementara sekitar DOS 3.3 hingga DOS 4.0, jadi satu teori yang mungkin adalah bahwa PC-DOS pada dasarnya dianggap beku ketika kode diserahkan kembali ke Microsoft, yang menemukan sejumlah bug yang mereka perbaiki di OEM MS-DOS tanpa menyentuh PC-DOS.

Perbedaan yang menonjol:
- Perbaikan penanganan INT 24 (critical error) kernel DOS
- Perlindungan integer overflow FDISK untuk disk besar
- Buffer EMS yang lebih besar di FASTOPEN
- Validasi input yang lebih baik di EXE2BIN

Flavor **msdos** default adalah apa yang dikirimkan oleh OEM seperti Compaq, Dell, dan HP sebagai "MS-DOS" pada PC yang kompatibel dengan IBM mereka. Rilis sumber ini sebenarnya tampaknya berasal dari OAK (OEM Adaptation Kit) -- kode yang disediakan Microsoft kepada OEM untuk memungkinkan mereka menyesuaikan MS-DOS untuk hardware mereka.

## Opsi Image Disk

```bash
# Image hard disk (menghasilkan msdos4.img + msdos4-dosemu.img)
./mkhdimg.sh                    # Image FAT16 64MB
./mkhdimg.sh --size 32          # Image 32MB

# Image floppy (semua ukuran)
./mkhdimg.sh --floppy           # 1.44MB minimal (hanya berkas sistem)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB dengan utilitas
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB dengan utilitas
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB dengan utilitas
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB dengan utilitas
```

Image hard disk diproduksi dalam dua format: `msdos4.img` adalah image disk mentah yang berfungsi dengan QEMU, VirtualBox, bochs, dan sebagian besar emulator. `msdos4-dosemu.img` adalah format hdimage dosemu (header 128-byte). Image floppy adalah mentah dan berfungsi di mana saja.

## Keterbatasan yang Diketahui

- **DOS Shell tidak termasuk**: Kode sumber DOS Shell (DOSSHELL) tidak di-open-source. SELECT.EXE (installer) berbagi beberapa kode dengan DOSSHELL dan tidak dapat di-build.
- **Branding PC-DOS tidak lengkap**: Build `--flavor=pcdos` menggunakan nama berkas sistem IBM (IBMBIO.COM, IBMDOS.COM) dan beberapa path kode spesifik PC-DOS, tetapi masih menampilkan "MS-DOS" di VER dan banner startup. Ini karena berkas pesan IBM (`usa-ibm.msg` atau serupa) tidak di-open-source—hanya `usa-ms.msg` bermerek Microsoft yang dirilis.
- **Build non-IBM-compatible**: Konfigurasi ketiga (`IBMVER=FALSE`) ada dalam sumber untuk hardware non-IBM-compatible, tetapi tidak berhasil di-build. Tampaknya konfigurasi ini untuk beberapa PC x86 non-IBM-compatible yang berumur pendek dari awal 1980-an -- secara khusus menghindari path kode spesifik IBM-compatible tertentu yang berkaitan dengan hardware seperti BIOS, PIC, PIT, dan sebagainya. Investigasi lebih lanjut diperlukan, tetapi kemungkinan pohon sumber ini tidak lengkap dan kehilangan kode spesifik hardware (IO.SYS stuff) yang perlu disediakan untuk mengimplementasikan layanan DOS pada hardware tersebut.

# Merek Dagang

Proyek ini mungkin berisi merek dagang atau logo untuk proyek, produk, atau layanan. Penggunaan yang diizinkan dari
merek dagang atau logo Microsoft tunduk dan harus mengikuti
[Pedoman Merek Dagang & Merek Microsoft](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Penggunaan merek dagang atau logo Microsoft dalam versi modifikasi proyek ini tidak boleh menyebabkan kebingungan atau menyiratkan sponsor Microsoft.
Penggunaan merek dagang atau logo pihak ketiga tunduk pada kebijakan pihak ketiga tersebut.
