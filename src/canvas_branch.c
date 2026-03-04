/*
 * canvas_branch.c — Phase 5: Branch 구현 스켈레톤
 */
#include "../include/canvas_branch.h"
#include "../include/engine_time.h"
#include <string.h>
#include <stdio.h>

void branch_table_init(BranchTable *bt) {
    memset(bt, 0, sizeof(*bt));
    bt->active_branch = BRANCH_ROOT;
}

uint32_t branch_create(BranchTable *bt, uint32_t parent_id,
                       uint8_t plane_mask,
                       uint16_t x_min, uint16_t x_max,
                       uint16_t y_min, uint16_t y_max,
                       uint8_t lane_id) {
    if (bt->count >= BRANCH_MAX) return BRANCH_NONE;

    uint32_t new_id = bt->count + 1u;
    BranchDesc *b = &bt->branches[bt->count++];
    *b = (BranchDesc){
        .branch_id    = new_id,
        .parent_id    = parent_id,
        .x_min        = x_min,  .x_max = x_max,
        .y_min        = y_min,  .y_max = y_max,
        .quadrant_mask= 0x0F,
        .plane_mask   = plane_mask,
        .gate_policy  = 0,
        .lane_id      = lane_id,
        .flags        = LANE_F_ACTIVE,
    };
    return new_id;
}

int branch_switch(EngineContext *ctx, BranchTable *bt, uint32_t branch_id) {
    /* PageSelector를 branch의 설정으로 교체 (O(1)) */
    for (uint32_t i = 0; i < bt->count; i++) {
        if (bt->branches[i].branch_id == branch_id) {
            bt->active_branch = branch_id;
            /* Phase 5 TODO: ctx의 CR2 PageSelector 업데이트 */
            (void)ctx;
            return 0;
        }
    }
    return -1;
}

int branch_destroy(BranchTable *bt, uint32_t branch_id) {
    for (uint32_t i = 0; i < bt->count; i++) {
        if (bt->branches[i].branch_id == branch_id) {
            /* 마지막 항목으로 swap */
            bt->branches[i] = bt->branches[--bt->count];
            return 0;
        }
    }
    return -1;
}

int branch_commit_delta(EngineContext *ctx, const DeltaCommit *d) {
    /* Phase 5 TODO: WH 레코드에 DELTA 타입으로 기록
     *   WH opcode = WH_OP_DELTA (0x20 예약)
     *   C0.A = branch_id, C0.B = WH_OP_DELTA, C0.G = flags
     *   C1.A = pack16(x,y), C1.B = 0, C1.R = after.R
     *   실제 before/after Cell은 CanvasFS slot에 저장 후 참조
     */
    (void)ctx; (void)d;
    return 0;
}

int branch_merge(EngineContext *ctx, BranchTable *bt,
                 uint32_t branch_id, MergePolicy policy) {
    /* Phase 5 TODO:
     *   1. WH에서 branch_id 태그된 레코드 순서대로 읽기
     *   2. policy에 따라 parent에 적용
     *   3. 적용된 레코드에 MERGED 플래그 설정
     */
    (void)ctx; (void)bt; (void)branch_id; (void)policy;
    return 0;
}

int branch_scan_y_range(EngineContext *ctx, const BranchDesc *b) {
    /* Phase 5 TODO:
     *   Y축을 시간축으로 사용하는 스캔.
     *   b->y_min ~ b->y_max 행만 순서대로 실행.
     *   각 행은 1 tick 또는 y_tick_stride tick에 해당.
     */
    (void)ctx; (void)b;
    return 0;
}

int branch_parallel_tick(EngineContext *ctx, BranchTable *bt,
                         uint32_t branch_a, uint32_t branch_b) {
    /* 순차 실행 (Phase 5): a 실행 후 b 실행
     * Phase 6에서 pthread_create 또는 OpenCL dispatch로 교체
     */
    branch_switch(ctx, bt, branch_a);
    branch_scan_y_range(ctx, &bt->branches[branch_a]);
    branch_switch(ctx, bt, branch_b);
    branch_scan_y_range(ctx, &bt->branches[branch_b]);
    return 0;
}

int branch_table_flush(EngineContext *ctx, BranchTable *bt) {
    /* Phase 5 TODO: bt를 CR1 타일에 직렬화 (BranchCommit 구조체 배열) */
    (void)ctx; (void)bt;
    return 0;
}

int branch_table_load(EngineContext *ctx, BranchTable *bt) {
    (void)ctx; (void)bt;
    return 0;
}
