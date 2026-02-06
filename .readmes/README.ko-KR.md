<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="MS-DOS logo" src="https://github.com/Microsoft/MS-DOS/blob/main/.readmes/msdos-logo.png">

# MS-DOS v1.25, v2.0, v4.0 소스 코드

[![Build MS-DOS 4](https://github.com/tgies/MS-DOS/actions/workflows/build.yml/badge.svg)](https://github.com/tgies/MS-DOS/actions/workflows/build.yml)

이 레포지토리는 MS-DOS v1.25와 v2.0의 원본 소스코드 및 컴파일된 바이너리와 IBM과 Microsoft가 공동 개발한 MS-DOS v4.00의 소스코드를 포함하고 있습니다.

MS-DOS v1.25와 v2.0 파일들은 [원래 2014년 3월 25일 컴퓨터 역사 박물관에서 공유되었고](http://www.computerhistory.org/atchm/microsoft-ms-dos-early-source-code/) 사람들이 찾기 쉽게 하고, 외부 문헌 및 저작물에 인용할 수 있도록 하며, 초기 PC 운영체제에 관심이 있는 사람들의 분석과 실험을 위해 이 레포지토리에 (재)배포되었습니다.

# 이 포크에 대하여

이 포크는 MS-DOS 4.0 소스코드를 위한 작동하는 빌드 시스템과 CI 파이프라인을 추가합니다. 원본 8086 어셈블리와 C 소스를 완전하고 부팅 가능한 운영체제로 빌드합니다 -- OEM **MS-DOS**와 **IBM PC-DOS** 두 가지 flavor를 모두 지원합니다.

빌드는 바로 사용 가능한 디스크 이미지(64MB 하드 디스크 및 360KB부터 1.44MB까지의 당시 표준 플로피)를 생성하며, QEMU, VirtualBox, bochs, dosemu, 86Box, PCem, 또는 실제 빈티지 하드웨어에서 부팅할 수 있습니다. 미리 빌드된 이미지는 [Releases](https://github.com/tgies/MS-DOS/releases) 페이지에서 다운로드할 수 있습니다.

이 작업은 MS-DOS 4.0 소스코드를 빌드 가능하게 만들기 위해 공개된 소스 트리의 경미한 문제들(잘못된 파일 경로 및 손상된 문자 인코딩)을 정리한 다른 분들의 선행 작업으로부터 큰 도움을 받았습니다. 여기에는 [ecm](https://hg.pushbx.org/ecm/msdos4)과 [hharte](https://github.com/hharte/MS-DOS/commit/1f506100a818cb9b6c2b29aeda8d4d24d094c477)가 포함되지만 이에 국한되지 않습니다.

# 사용해 보기

[최신 릴리스](https://github.com/tgies/MS-DOS/releases)에서 `msdos4.img`를 다운로드하여 부팅하세요:

```bash
qemu-system-i386 -hda msdos4.img
```

또는 DOSBox를 사용하는 경우, 평소처럼 DOSBox를 시작한 다음 이미지를 부팅하세요 (플로피 이미지를 사용하는 경우 `-l C` 생략):

```bash
BOOT msdos4.img -l C
```

또는 dosemu로 (`msdos4-dosemu.img`를 다운로드하세요. 이 파일은 dosemu2를 위한 특별한 헤더가 있습니다):

```bash
dosemu -f <(echo '$_hdimage = "msdos4-dosemu.img"')
```

# 라이선스

이 레포지토리의 모든 파일들은 레포지토리 루트에 있는 [LICENSE 파일](https://github.com/Microsoft/MS-DOS/blob/main/LICENSE)에 명시된 대로 [MIT 라이선스](https://en.wikipedia.org/wiki/MIT_License)로 배포됩니다.

# 역사적 참고 사항

> **참고:** 이 섹션은 소스코드 공개와 함께 Microsoft의 원본 README.md에서 보존된 것입니다. 이 레포지토리의 빌드 스크립트와 도구는 역사적 소스코드와 별도로 유지 관리됩니다. 빌드 시스템 개선을 위한 Pull Request는 환영합니다.

이 레포지토리의 소스 파일들은 역사적 참고 자료이며 정적으로 유지될 것이므로, 소스 파일 수정을 제안하는 Pull Request를 **보내지 마시기 바랍니다**. 하지만 자유롭게 포크하여 실험하세요 😊.

이 프로젝트는 [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/)를 따릅니다. 더 많은 정보를 원하시면 [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)를 참고하거나 추가 질문이나 의견이 있으시면 [opencode@microsoft.com](mailto:opencode@microsoft.com)으로 연락해 주시기 바랍니다.

# MS-DOS 4.0 빌드하기

미리 빌드된 디스크 이미지는 [Releases](https://github.com/tgies/MS-DOS/releases) 페이지에서 다운로드할 수 있습니다. 소스에서 빌드하려면:

## 요구 사항

- dosemu2
- mtools
- mkfatimage16 (dosemu2에서 제공)

> [!IMPORTANT]
> **comcom64 0.4-0~202602051302 이상이 필요합니다.** comcom64는 dosemu2에서 사용하는 command.com 대체 프로그램입니다. 일부 이전 버전에는 nmake가 makefile 명령을 실행하기 위해 사용하는 `COMMAND /C`를 통해 호출될 때 파일 연결(`copy /b a+b dest`)을 중단시키는 [`COPY` 명령의 버그](https://github.com/dosemu2/comcom64/pull/117)가 있습니다. 이로 인해 IO.SYS 빌드가 자동으로 실패합니다.
>
> `dpkg -s comcom64 | grep Version` (Debian/Ubuntu)로 버전을 확인하거나 패키지 매니저를 확인하세요. 이전 버전을 사용 중이라면:
> - **권장:** comcom64를 0.4-0~202602051302 이상으로 업데이트
> - **임시 해결책:** 소스에서 comcom64를 빌드: `git clone https://github.com/dosemu2/comcom64 && cd comcom64 && make && sudo make install` (`make install`이 기존 `command.efi` 위에 설치되는지 확인)

## 빠른 시작

```bash
cd v4.0
./mak.sh              # DOS 4 빌드
./mkhdimg.sh          # 64MB 하드 디스크 이미지 생성
./mkhdimg.sh --floppy # 1.44MB 부팅 플로피 생성
```

## 빌드 Flavor

소스코드는 여러 빌드 구성을 지원합니다. `--flavor` 플래그를 사용하세요:

```bash
./mak.sh                    # MS-DOS 빌드 (기본값)
./mak.sh --flavor=pcdos     # IBM PC-DOS 빌드
```

| Flavor | 시스템 파일 | 설명 |
|--------|------------|------|
| **msdos** | IO.SYS, MSDOS.SYS | IBM 호환 PC용 OEM MS-DOS (기본값, 권장) |
| **pcdos** | IBMBIO.COM, IBMDOS.COM | IBM PC-DOS (역사적 정확성을 위해) |

두 flavor 모두 IBM PC 하드웨어 특정 코드(INT 10H 비디오 BIOS, 8259 PIC, PCjr ROM 카트리지 지원)를 포함합니다.

**중요:** **msdos** flavor가 **pcdos**보다 더 많은 버그 수정을 포함합니다. 아마도 Microsoft는 IBM의 승인 프로세스가 PC-DOS에 허용한 것보다 OEM MS-DOS에 수정 사항을 더 빠르게 적용할 수 있었던 것으로 보입니다. DOS 3.3에서 DOS 4.0까지 IBM이 일시적으로 DOS 개발을 주도한 것으로 알려져 있으므로, 한 가지 가능한 이론은 코드가 Microsoft에 다시 넘어갔을 때 PC-DOS가 본질적으로 동결된 것으로 간주되었고, Microsoft는 PC-DOS를 건드리지 않고 OEM MS-DOS에서 수정한 여러 버그를 발견했다는 것입니다.

주목할 만한 차이점:
- DOS 커널 INT 24(치명적 오류) 처리 수정
- 대용량 디스크를 위한 FDISK 정수 오버플로 보호
- FASTOPEN의 더 큰 EMS 버퍼
- EXE2BIN의 더 나은 입력 검증

기본 **msdos** flavor는 Compaq, Dell, HP와 같은 OEM이 IBM 호환 PC에서 "MS-DOS"로 출시한 것입니다. 이 소스 릴리스는 실제로 OAK(OEM Adaptation Kit)에서 파생된 것으로 보이며, 이는 Microsoft가 OEM에게 제공하여 하드웨어에 맞게 MS-DOS를 맞춤화할 수 있도록 한 코드입니다.

## 디스크 이미지 옵션

```bash
# 하드 디스크 이미지 (msdos4.img + msdos4-dosemu.img 생성)
./mkhdimg.sh                    # 64MB FAT16 이미지
./mkhdimg.sh --size 32          # 32MB 이미지

# 플로피 이미지 (모든 크기)
./mkhdimg.sh --floppy           # 1.44MB 최소 (시스템 파일만)
./mkhdimg.sh --floppy=360 --floppy-full   # 360KB 유틸리티 포함
./mkhdimg.sh --floppy=720 --floppy-full   # 720KB 유틸리티 포함
./mkhdimg.sh --floppy=1200 --floppy-full  # 1.2MB 유틸리티 포함
./mkhdimg.sh --floppy=1440 --floppy-full  # 1.44MB 유틸리티 포함
```

하드 디스크 이미지는 두 가지 형식으로 생성됩니다: `msdos4.img`는 QEMU, VirtualBox, bochs 및 대부분의 에뮬레이터에서 작동하는 raw 디스크 이미지입니다. `msdos4-dosemu.img`는 dosemu hdimage 형식(128바이트 헤더)입니다. 플로피 이미지는 raw 형식이며 모든 곳에서 작동합니다.

## 알려진 제한 사항

- **DOS Shell 미포함**: DOS Shell(DOSSHELL) 소스코드는 오픈소스화되지 않았습니다. SELECT.EXE(설치 프로그램)는 DOSSHELL과 일부 코드를 공유하며 빌드할 수 없습니다.
- **PC-DOS 브랜딩 불완전**: `--flavor=pcdos` 빌드는 IBM 시스템 파일 이름(IBMBIO.COM, IBMDOS.COM)과 일부 PC-DOS 특정 코드 경로를 사용하지만, VER 및 시작 배너에는 여전히 "MS-DOS"가 표시됩니다. 이는 IBM의 메시지 파일(`usa-ibm.msg` 또는 유사)이 오픈소스화되지 않았기 때문입니다—Microsoft 브랜드의 `usa-ms.msg`만 공개되었습니다.
- **IBM 비호환 빌드**: IBM 비호환 하드웨어를 위한 세 번째 구성(`IBMVER=FALSE`)이 소스에 존재하지만 성공적으로 빌드되지 않습니다. 이 구성은 1980년대 초반의 일부 단명한 IBM 비호환 x86 PC를 위한 것으로 보입니다 -- 특히 BIOS, PIC, PIT 등과 같은 하드웨어를 다루는 IBM 호환 특정 코드 경로를 피합니다. 추가 조사가 필요하지만, 이 소스 트리가 불완전하고 그러한 하드웨어에서 DOS 서비스를 구현하기 위해 제공되어야 하는 하드웨어 특정 코드(IO.SYS 관련)가 누락되어 있을 가능성이 있습니다.

# 상표

이 프로젝트에는 프로젝트, 제품 또는 서비스에 대한 상표 또는 로고가 포함될 수 있습니다. Microsoft 상표 또는 로고의 승인된 사용은 [Microsoft의 상표 및 브랜드 가이드라인](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general)을 따라야 합니다.
이 프로젝트의 수정된 버전에서 Microsoft 상표 또는 로고를 사용하는 경우 혼란을 야기하거나 Microsoft의 후원을 암시해서는 안 됩니다.
제3자 상표 또는 로고의 사용은 해당 제3자의 정책을 따릅니다.
