#include "../include/canvasos_engine.h"

void bpage_apply(CanvasEngine *eng, Cell *cell) {
    for (int i=0; i<256; i++) {
        const BPageRule *rule = &eng->bpage[i];
        if ((cell->a_word & rule->cond_mask) == rule->cond_val)
            cell->a_word = rule->exec_aword;
    }
}
