#!/usr/bin/env bash
set -euo pipefail

command -v godot >/dev/null 2>&1 || {
	echo "godot is not on PATH. Run: bash scripts/install-godot.sh" >&2
	exit 1
}

mkdir -p build/validation

# Godot may report a script error but still exit zero. Check both status and log.
run_checked() {
	local name="$1"
	shift
	"$@" 2>&1 | tee "build/validation/${name}.log"
	if grep -Eq '(^|[[:space:]])(SCRIPT ERROR|ERROR):' "build/validation/${name}.log"; then
		echo "Godot reported errors during ${name}." >&2
		exit 1
	fi
}

run_checked import godot --headless --path . --editor --quit
run_checked smoke godot --headless --path . res://scenes/smoke_test.tscn --quit-after 3
grep -q 'SMOKE_TEST_READY' build/validation/smoke.log
run_checked gate1 godot --headless --path . res://scenes/gate1.tscn --quit-after 3
grep -q 'GATE1_READY' build/validation/gate1.log
run_checked movement timeout 90s godot --headless --path . --fixed-fps 60 --script tests/gate1_test.gd
grep -q 'GATE1_TESTS_PASSED' build/validation/movement.log

run_checked gate2 godot --headless --path . res://scenes/gate2.tscn --quit-after 3
grep -q 'GATE2_READY' build/validation/gate2.log
run_checked combat timeout 90s godot --headless --path . --fixed-fps 60 --script tests/combat_test.gd
grep -q 'COMBAT_TESTS_PASSED' build/validation/combat.log

run_checked gate3 godot --headless --path . res://scenes/gate3.tscn --quit-after 3
grep -q 'GATE3_READY' build/validation/gate3.log
run_checked interaction timeout 90s godot --headless --path . --fixed-fps 60 --script tests/interaction_test.gd
grep -q 'INTERACTION_TESTS_PASSED' build/validation/interaction.log

run_checked gate4 godot --headless --path . res://scenes/gate4.tscn --quit-after 3
grep -q GATE4_READY build/validation/gate4.log
run_checked slice timeout 90s godot --headless --path . --fixed-fps 60 --script tests/slice_test.gd
grep -q SLICE_TESTS_PASSED build/validation/slice.log

run_checked gate5 godot --headless --path . --quit-after 3
grep -q GATE5_READY build/validation/gate5.log
run_checked presentation timeout 90s godot --headless --path . --fixed-fps 60 --script tests/presentation_test.gd
grep -q PRESENTATION_TESTS_PASSED build/validation/presentation.log

run_checked qa timeout 90s godot --headless --path . --fixed-fps 60 --script tests/qa_test.gd
grep -q QA_TESTS_PASSED build/validation/qa.log

echo "Project validation passed."
