<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logosu" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 Kaynak Kodu

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

Bu depo, MS-DOS v1.25 ve MS-DOS v2.0'ın orijinal kaynak kodunu ve derlenmiş çalıştırılabilir dosyalarını, ayrıca IBM ve Microsoft tarafından ortaklaşa geliştirilen MS-DOS v4.00'ın kaynak kodunu içerir.

MS-DOS v1.25 ve v2.0 dosyaları [ilk olarak 25 Mart 2014 tarihinde Bilgisayar Tarihi Müzesinde yayınlanmıştır](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) ve bu depoda, daha kolay bulunabilmesi, dış yazılar ve çalışmalarda atıflanabilmesi ve öncül Kişisel Bilgisayar İşletim Sistemlerine ilgi duyanların keşif ve denemeler yapabilmesi için (yeniden) yayınlanmaktadır.

# Bu fork hakkında

Bu fork, MS-DOS 4.0 kaynak kodu için çalışan bir derleme sistemi ve CI hattı ekler. Orijinal 8086 assembly ve C kaynaklarını tam ve başlatılabilir bir işletim sistemine -- hem OEM **MS-DOS** hem de **IBM PC-DOS** sürümlerine -- derler.

Derleme, QEMU, VirtualBox, bochs, dosemu, 86Box, PCem veya gerçek eski donanımda başlatılabilen kullanıma hazır disk imajları (64MB sabit disk ve 360KB'den 1.44MB'ye kadar döneme uygun disketler) üretir. Önceden derlenmiş imajlar [Releases](https://github.com/tgies/MS-DOS/releases) sayfasında mevcuttur.

Bu çalışma, yayınlanan kaynak ağacındaki bazı küçük sorunları (yanlış dosya yolları ve bozuk karakter kodlamaları) temizleyerek MS-DOS 4.0 kaynak kodunun derlenmesini sağlamak için başkaları tarafından yapılan önceki çalışmalardan büyük fayda sağlamıştır; bunlar arasında [ecm](https://hg.pushbx.org/ecm/msdos4) ve [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477) yer almaktadır ancak bunlarla sınırlı değildir.

# Deneyin

[Son sürümden](https://github.com/tgies/MS-DOS/releases) `msdos4.img` dosyasını indirin ve başlatın:

```bash
qemu-system-i386 -hda msdos4.img
```

Ya da DOSBox ile, DOSBox'ı normal şekilde başlatın ve ardından imajı başlatın (disket imajı kullanıyorsanız `-l C` parametresini çıkarın):

```bash
BOOT msdos4.img -l C
```

Ya da dosemu ile (`msdos4-dosemu.img` dosyasını indirin, bu dosyanın dosemu2 için özel bir başlığı vardır):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# Lisans

Bu depodaki tüm dosyalar, deponun kök klasöründeki [LICENSE dosyasında](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE) belirtildiği gibi [MIT Lisansıyla](https://en.wikipedia.org/wiki/MIT_License) yayınlanmıştır.

# Tarihsel referans için

> **NOT:** Bu bölüm, Microsoft'un kaynak kod sürümü ile birlikte gelen orijinal README.md dosyasından korunmuştur. Bu depodaki derleme betikleri ve araçları, tarihsel kaynak kodundan ayrı olarak sürdürülmektedir. Derleme sistemine yönelik iyileştirme önerileri içeren Pull Request'ler memnuniyetle karşılanır.

Bu depodaki kaynak dosyalar tarihsel referans içindir ve statik olarak saklanacaktır, bu yüzden lütfen kaynak dosyalara herhangi bir değişiklik öneren Pull Request **göndermeyin**, ancak bu depoyu fork'lamaktan ve denemeler yapmaktan çekinmeyin 😊.

Bu proje [Microsoft Açık Kaynak Davranış Kurallarını](https://opensource.microsoft.com/codeofconduct/) benimsemiştir. Daha fazla bilgi için [Davranış Kuralları SSS](https://opensource.microsoft.com/codeofconduct/faq/) sayfasını inceleyin ya da başka sorular veya yorumlar için [opencode@microsoft.com](mailto:opencode@microsoft.com) ile iletişime geçin.

# MS-DOS 4.0'ı Derlemek

Önceden derlenmiş disk imajları [Releases](https://github.com/tgies/MS-DOS/releases) sayfasında mevcuttur. Kaynaktan derlemek için:

## Gereksinimler

- dosemu2
- mtools
- mkfatimage16 (dosemu2'dan)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 veya daha yenisi gereklidir.** comcom64, dosemu2 tarafından kullanılan command.com yerine geçen programdır. Bazı eski sürümlerde, nmake'in makefile komutlarını çalıştırmak için kullandığı `COMMAND /C` ile çağrıldığında dosya birleştirmeyi (`copy /b a+b dest`) bozan `COPY` komutunda bir [hata](https://github.com/dosemu2/comcom64/pull/117) vardır. Bu durum IO.SYS derlemesinin sessizce başarısız olmasına neden olur.
>
> Sürümünüzü `dpkg -s comcom64 | grep Version` (Debian/Ubuntu) ile kontrol edin veya paket yöneticinizi kontrol edin. Eski bir sürümdeyseniz:
> - **Önerilen:** comcom64'ü 0.4-0~202602051302 veya daha yeni bir sürüme güncelleyin
> - **Geçici çözüm:** comcom64'ü kaynaktan derleyin: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (`make install`'ın mevcut `command.efi` dosyanızın üzerine kurulum yaptığından emin olun)

## Hızlı Başlangıç

```bash
cd v4.0
./mak.sh              # DOS 4'ü derle
./mkhdimg.sh          # 64MB sabit disk imajı oluştur
./mkhdimg.sh --floppy # 1.44MB başlatılabilir disket oluştur
```

## Derleme Çeşitleri

Kaynak kod birden fazla derleme yapılandırmasını destekler. `--flavor` bayrağını kullanın:

```bash
./mak.sh                    # MS-DOS'u derle (varsayılan)
./mak.sh --flavor=pcdos     # IBM PC-DOS'u derle
```

| Çeşit | Sistem Dosyaları | Açıklama |
|-------|------------------|----------|
| **msdos** | IO.SYS, MSDOS.SYS | IBM-uyumlu PC'ler için OEM MS-DOS (varsayılan, önerilir) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (tarihsel doğruluk için) |

Her iki çeşit de IBM PC donanımına özgü kod içerir (INT 10H video BIOS, 8259 PIC, PCjr ROM kartuş desteği).

**Önemli:** **msdos** çeşidi, **pcdos**'tan daha fazla hata düzeltmesi içerir. Muhtemelen Microsoft, OEM MS-DOS için düzeltmeleri IBM'in PC-DOS için onay sürecinin izin verdiğinden daha hızlı yayınlayabiliyordu. IBM'in DOS 3.3 ile DOS 4.0 arasında geçici olarak DOS geliştirmeyi üstlendiği biliniyor, bu nedenle olası bir teori, kod Microsoft'a geri verildiğinde PC-DOS'un esasen dondurulmuş olarak kabul edildiği, Microsoft'un OEM MS-DOS'ta PC-DOS'a dokunmadan düzelttiği bir dizi hata bulduğu yönündedir.

Önemli farklar:
- DOS çekirdeği INT 24 (kritik hata) işleme düzeltmesi
- Büyük diskler için FDISK tamsayı taşması koruması
- FASTOPEN'da daha büyük EMS arabellekleri
- EXE2BIN'de daha iyi girdi doğrulaması

Varsayılan **msdos** çeşidi, Compaq, Dell ve HP gibi OEM'lerin IBM-uyumlu PC'lerinde "MS-DOS" olarak sevk ettikleri sürümdür. Bu kaynak sürümü aslında OAK'den (OEM Adaptation Kit) -- Microsoft'un OEM'lere MS-DOS'u donanımları için özelleştirmelerine izin vermek üzere sağladığı koddan -- türemiş gibi görünmektedir.

## Disk İmajı Seçenekleri

```bash
# Sabit disk imajları (msdos4.img + msdos4-dosemu.img üretir)
./mkhdimg.sh                    # 64MB FAT16 imajı
./mkhdimg.sh --size 32          # 32MB imaj

# Disket imajları (tüm boyutlar)
./mkhdimg.sh --floppy           # 1.44MB minimal (sadece sistem dosyaları)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB yardımcı programlarla
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB yardımcı programlarla
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB yardımcı programlarla
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB yardımcı programlarla
```

Sabit disk imajları iki formatta üretilir: `msdos4.img`, QEMU, VirtualBox, bochs ve çoğu emülatörle çalışan ham bir disk imajıdır. `msdos4-dosemu.img`, dosemu hdimage formatıdır (128 baytlık başlık). Disket imajları hamdır ve her yerde çalışır.

## Bilinen Sınırlamalar

- **DOS Shell dahil değil**: DOS Shell (DOSSHELL) kaynak kodu açık kaynak yapılmamıştır. SELECT.EXE (yükleyici) DOSSHELL ile bazı kodları paylaşır ve derlenemez.
- **PC-DOS markalama tamamlanmamış**: `--flavor=pcdos` derlemesi IBM sistem dosya adlarını (IBMBIO.COM, IBMDOS.COM) ve bazı PC-DOS'a özgü kod yollarını kullanır, ancak VER komutunda ve başlangıç başlığında yine de "MS-DOS" görüntüler. Bunun nedeni, IBM'in mesaj dosyasının (`usa-ibm.msg` veya benzeri) açık kaynak yapılmamış olmasıdır -- yalnızca Microsoft markalı `usa-ms.msg` yayınlanmıştır.
- **IBM-uyumlu olmayan derleme**: Kaynak kodda IBM-uyumlu olmayan donanım için üçüncü bir yapılandırma (`IBMVER=FALSE`) mevcuttur, ancak başarıyla derlenmez. Bu yapılandırmanın 1980'lerin başındaki kısa ömürlü IBM-uyumlu olmayan x86 PC'lerden bazıları için olduğu görülmektedir -- özellikle BIOS, PIC, PIT gibi donanımlarla ilgili IBM-uyumlu-özgü kod yollarından kaçınır. Daha fazla araştırma gereklidir, ancak muhtemelen bu kaynak ağacı tamamlanmamıştır ve bu tür donanımlarda DOS hizmetlerini uygulamak için sağlanması gereken donanıma özgü kodu (IO.SYS içerikleri) eksiktir.

# Ticari Markalar

Bu proje, projeler, ürünler veya hizmetler için ticari markalar veya logolar içerebilir. Microsoft ticari markalarının veya logolarının yetkili kullanımı, [Microsoft'un Ticari Marka ve Marka Yönergelerine](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general) tabidir ve bunlara uymalıdır.
Bu projenin değiştirilmiş sürümlerinde Microsoft ticari markalarının veya logolarının kullanımı kafa karışıklığına neden olmamalı veya Microsoft sponsorluğunu ima etmemelidir.
Üçüncü taraf ticari markalarının veya logolarının herhangi bir kullanımı, bu üçüncü tarafların politikalarına tabidir.
