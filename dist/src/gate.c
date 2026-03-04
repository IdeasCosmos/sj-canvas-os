#include "../include/canvasos_engine.h"

void gate_open(CanvasEngine *eng, uint16_t id)  { if(id<TILEGATE_COUNT) eng->gates[id]=GATE_OPEN; }
void gate_close(CanvasEngine *eng, uint16_t id) { if(id<TILEGATE_COUNT) eng->gates[id]=GATE_CLOSE; }
int  gate_is_open(const CanvasEngine *eng, uint16_t id) { return id<TILEGATE_COUNT && eng->gates[id]==GATE_OPEN; }
