CC     = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2 -Iinclude
LDFLAGS = -lpthread

ENGINE_SRC = src/canvasos_cli.c \
             src/engine.c src/scan_ringmh.c src/active_set.c src/canvasfs.c \
             src/canvasfs_bpage.c src/scheduler.c src/control_region.c src/engine_time.c \
             src/gate_ops.c src/canvasos_opcodes.c src/cvp_io.c src/engine_ctx.c \
             src/lane_exec.c src/bpage_table.c src/inject.c src/wh_io.c \
             src/canvas_lane.c src/canvas_merge.c src/canvas_multiverse.c src/canvas_branch.c \
             src/canvas_bh_compress.c src/workers.c src/canvas_gpu_stub.c src/sjptl_parser.c

CORE_SRC   = src/engine.c \
             src/scan_ringmh.c src/active_set.c src/canvasfs.c src/canvasfs_bpage.c \
             src/scheduler.c src/control_region.c src/engine_time.c src/gate_ops.c \
             src/canvasos_opcodes.c src/cvp_io.c src/engine_ctx.c src/lane_exec.c \
             src/bpage_table.c src/inject.c src/wh_io.c src/canvas_lane.c \
             src/canvas_merge.c src/canvas_multiverse.c src/canvas_branch.c src/canvas_bh_compress.c \
             src/workers.c src/canvas_gpu_stub.c src/sjptl_parser.c

ENGINE_BIN = canvasos

TEST_SCAN     = tests/test_scan
TEST_GATE     = tests/test_gate
TEST_CANVASFS = tests/test_canvasfs
TEST_SCHED    = tests/test_scheduler
TEST_CVP      = tests/test_cvp

.PHONY: all run test clean

all: $(ENGINE_BIN)

$(ENGINE_BIN): $(ENGINE_SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

run: $(ENGINE_BIN)
	./$(ENGINE_BIN)

test: $(TEST_SCAN) $(TEST_GATE) $(TEST_CANVASFS) $(TEST_SCHED) $(TEST_CVP)
	./$(TEST_SCAN)
	./$(TEST_GATE)
	./$(TEST_CANVASFS)
	./$(TEST_SCHED)
	./$(TEST_CVP)

$(TEST_SCAN): tests/test_scan.c src/scan_ringmh.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(TEST_GATE): tests/test_gate.c src/active_set.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(TEST_CANVASFS): tests/test_canvasfs.c src/canvasfs.c src/canvasfs_bpage.c src/active_set.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(TEST_SCHED): tests/test_scheduler.c src/scheduler.c src/active_set.c src/canvasfs.c src/canvasfs_bpage.c src/engine_time.c src/gate_ops.c src/canvasos_opcodes.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(TEST_CVP): tests/test_cvp.c src/cvp_io.c src/engine_ctx.c src/lane_exec.c src/bpage_table.c src/inject.c src/wh_io.c src/canvas_lane.c src/canvas_merge.c src/canvas_multiverse.c src/canvas_branch.c src/canvas_bh_compress.c src/workers.c src/canvas_gpu_stub.c src/sjptl_parser.c src/scheduler.c src/engine_time.c src/gate_ops.c src/canvasos_opcodes.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(ENGINE_BIN) $(TEST_SCAN) $(TEST_GATE) $(TEST_CANVASFS) $(TEST_SCHED) $(TEST_CVP) *.cvp

CLI_SRC = src/canvasos_cli.c src/scan_ringmh.c src/active_set.c \
          src/canvasfs.c src/canvasfs_bpage.c \
          src/scheduler.c src/control_region.c src/engine_time.c \
          src/gate_ops.c src/canvasos_opcodes.c \
          src/cvp_io.c src/engine_ctx.c src/lane_exec.c src/bpage_table.c src/inject.c src/wh_io.c src/canvas_lane.c src/canvas_merge.c src/canvas_multiverse.c src/canvas_branch.c src/canvas_bh_compress.c src/workers.c src/canvas_gpu_stub.c src/sjptl_parser.c 
CLI_BIN = canvasos_cli

cli: $(CLI_BIN)

$(CLI_BIN): $(CLI_SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)


SJTERM_SRC = src/sjterm.c
SJTERM_BIN = sjterm


$(SJTERM_BIN): $(SJTERM_SRC) $(ENGINE_SRC)
	$(CC) $(CFLAGS) -o $(SJTERM_BIN) $(SJTERM_SRC) $(ENGINE_SRC) $(LDFLAGS)


tests/test_phase6: tests/test_phase6.c $(CORE_SRC)
	$(CC) $(CFLAGS) -o tests/test_phase6 tests/test_phase6.c $(CORE_SRC) $(LDFLAGS)

TEST_PHASE6    = tests/test_phase6
