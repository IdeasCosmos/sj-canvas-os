# CanvasOS (SJCANVOS)

## Always-ON Execution Philosophy
CanvasOS는 기본적으로 “항상 ON(전기 연결)” 상태이며,
실행은 ON 신호가 아니라 **차단(CLOSE)을 기본값으로 두고, 통과(OPEN)만 흐르게 하는 방식**으로 제어합니다.
즉, 제어는 “켜기”가 아니라 **차단을 신호로 처리**합니다.

> C 기반 결정론적 타일 실행 시스템

## 핵심 철학: Always-ON, 차단이 신호다

- **캔버스(기판)는 항상 전기가 흐르는 상태(Always-ON)**로 가정한다.
- 우리는 전원을 켜는 방식이 아니라, **차단(CLOSE) 신호로 흐름을 제어**한다.
- 실행은 “켜기”가 아니라 **열림(OPEN)만 통과**시키는 구조다.

## 프로젝트 헌법 (5대 원칙)

1. 실행 스캔은 반드시 (512,512)에서 시작한다.
2. 스캔 좌표 열거는 Ring(MH)로 완전 결정론이다.
3. 기본 상태는 CLOSE(차단)이며, OPEN(통과)만 실행 효과가 있다.
4. A_word는 분기/Opcode/Arg의 단일 진실(Single Source of Truth)이다.
5. ABGR I/O는 A_word->B->G->R 순서로 fetch/write 최적화한다.

## 디렉토리 구조

    SJCANVOS/
    docs/
      SPEC_CanvasOS_QuadBoot_v1.md
      SCAN_RingMH.md
      SPEC_CanvasFS_v1_1.md
    include/
      canvasos_types.h
      canvasos_engine.h
      canvasfs.h
      canvasfs_bpage.h
    src/
      engine.c
      scan_ringmh.c
      gate.c
      bpage.c
      cvp_io.c
      active_set.c
      control_region.c
      scheduler.c
      canvasfs.c
      canvasfs_bpage.c
    tools/
      mkhello.c
    tests/
      test_scan.c
      test_gate.c
      test_canvasfs.c
    Makefile
    README.md

## 빌드

    make          # 전체 빌드
    make test     # 테스트 실행
    make hello    # hello.cvp 생성
    make clean    # 클린

## 명세 - 구현 매핑

SPEC_CanvasOS_QuadBoot_v1.md   ->  src/engine.c
SCAN_RingMH.md                 ->  src/scan_ringmh.c
SPEC TileGate                  ->  src/gate.c
SPEC B-page                    ->  src/bpage.c
SPEC CVP I/O                   ->  src/cvp_io.c
SPEC ActiveSet                 ->  src/active_set.c
SPEC Control Region / Scheduler->  src/control_region.c / src/scheduler.c
SPEC_CanvasFS_v1_1.md          ->  src/canvasfs.c

---

# CanvasFS v1.2 (Phase 2 구현 완료)

CanvasFS는 **데이터를 이동하지 않고(복사 금지)**, 구조적 참조로 파일을 정의한다.

## 저장 모델

- **VolumeTile (VOL1)**: “볼륨/마운트 포인트”
  - 타일 내부 셀을 슬롯 테이블로 사용한다.
  - 현재 구현은 **row0(헤더)을 예약**하므로 슬롯은 **240개(15×16)**.
    - (원하면 헤더를 (0,0..1) 등 최소 셀로 줄이고 나머지를 슬롯으로 풀어서 256까지 확장 가능)

- **Slot(슬롯 셀) 레이아웃**
  - `A` : TINY 데이터(≤4B) 또는 (dat_gate | meta_gate<<16)
  - `B` : SlotClass (FREE/TINY/SMALL/LARGE)
  - `G` : 길이(≤224) 또는 LARGE=0xFF
  - `R` : flags (has_dat / chain / has_meta / bpage_override 등)
  - `pad` : per-slot bpage override (0xFF = inherit)

- **DataTile (DAT1)**: 실제 데이터 저장
  - payload 224B (rows 2..15, R 채널)
  - LARGE는 DataTile 체인으로 확장

- **MetaTile (MET1)**: LARGE의 `real_len(u32)` 저장 (확장 메타용)

## 자동 클래스 선택

- `TINY (≤4B)` : A_word inline 저장
- `SMALL (≤224B)` : DataTile 1개
- `LARGE (>224B)` : DataTile 체인 + MetaTile(real_len)

## FreeMap (FRE1)

- DataTile 할당을 위한 비트맵 타일
- `fs_freemap_init / alloc / free` 제공

## Gate 연동

- `CanvasFS`는 `ActiveSet*`를 받을 수 있다.
- Gate가 CLOSED이면 read/write가 `FS_ERR_GATE`로 차단된다.

---

# B-page Adapter (포맷2포맷)

**데이터 이동 없이** encode/decode 규칙만 바꿔서 동일 데이터를 다른 포맷처럼 해석한다.

## 1) Volume bpage

- VolumeTile(0,1)에 bpage id/chain 정보를 가진다.
- `fs_set_bpage(vol, id)` 또는 `fs_set_bpage_chain(vol, chain)`

## 2) per-slot bpage override

- 슬롯 셀 `pad`에 8-bit bpage override
- `fs_slot_set_bpage(key, id)`

## 3) Adapter Chain

- 최대 8단 체인 지원 (`BpageChain`)
- encode는 순방향, decode는 역방향 적용

기본 bpage:
- 0 IDENTITY
- 1 XOR8
- 2 NIBBLE
- 3 ROTL1

---

# DirectoryBlock v2 (DIR1)

- `name_hash → FsKey(volume,slot)` 매핑
- 최소 구현(테스트용)으로 4글자 이름을 기록한다.
- API: `fs_mkdir / fs_dir_create / fs_dir_open / fs_dir_unlink / fs_dir_ls`

---

## 라이선스
CanvasOS Project -- SJCanvas

---

## 아키텍처 레이어 (Phase 로드맵)

    Phase 0  Engine 골격    Ring(MH) 스캔 + Gate OPEN/CLOSE + OP_PRINT/HALT
    Phase 1  Active Engine  Adaptive Scan(Ring/Hybrid/Spiral) + Energy Decay
    Phase 2  CanvasFS v1.2  VOLH/VOLT 256슬롯 + FreeMap + DirectoryBlock + BpageChain
    Phase 3  Scheduler      Process Energy Budget + Gate-space 격리 (스켈레톤)
    Phase 4  CVP I/O        Canvas 이미지 로드/세이브 + B-page 섹션
    Phase 5  Mount          Canvas간 통신 + Adapter BpageChain

## 타일 레이아웃 (v1.2)

    VOLH  볼륨 헤더  (0,0)=magic (0,1)=VOLT ptr (0,2)=bpage/chain
    VOLT  슬롯 타일  16×16 = 256슬롯 전부 (헤더 없음)
    DAT1  데이터     payload 224B + next 체인 포인터
    MET1  메타       real_len(u32) + 확장 메타
    DIR1  디렉터리   FNV-1a32 hash + linear probe, 56 entries/tile
    FRE1  FreeMap    4096-bit bitmap, O(1) alloc/free

## Reserved Gate 영역

    Control Region: gate_id 2080..2275 (tile_x 32..35, tile_y 32..35)
    FreeMap init 시 자동 예약됨