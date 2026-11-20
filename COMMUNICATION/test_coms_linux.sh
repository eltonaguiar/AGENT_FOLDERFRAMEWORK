#!/usr/bin/env bash
# test_coms_linux.sh -- acceptance suite for COMMUNICATION/coms.
#
# Safe to run on a laptop: HOME is a throwaway directory and every retained topic
# this suite writes is cleared at the end. It needs a reachable broker
# (COMS_BROKER, default 127.0.0.1) -- CI starts a local mosquitto, so nothing
# here depends on the production bus.
#
# Covers the five defects fixed on 2026-11-20 plus the large-payload path:
#   B1 unquoted heredoc      B5 '*' is not an MQTT wildcard
#   B3 no retain guard       B4 append-only roster
#   B4b dedupe_roster.py     plus 500 KB via --file (argv cannot carry it)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMS="$ROOT/coms"
BROKER="${COMS_BROKER:-127.0.0.1}"
PORT="${COMS_PORT:-1883}"
export COMS_BROKER="$BROKER" COMS_PORT="$PORT" COMS_AGENT="ci-agent"

WORK="$(mktemp -d)"
export HOME="$WORK/home"
mkdir -p "$HOME"
WROTE=()

PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); printf '[PASS] %s -- %s\n' "$1" "${2:-}"; }
fail() { FAIL=$((FAIL + 1)); printf '[FAIL] %s -- %s\n' "$1" "${2:-}"; }
skip() { SKIP=$((SKIP + 1)); printf '[SKIP] %s -- %s\n' "$1" "${2:-}"; }

expect_eq() { # name want got [detail]
  if [[ "$2" == "$3" ]]; then pass "$1" "${4:-}$3"; else fail "$1" "${4:-}want=$2 got=$3"; fi
}
expect_exit() { # name want got
  if [[ "$2" -eq "$3" ]]; then pass "$1" "exit=$3"; else fail "$1" "want exit=$2 got exit=$3"; fi
}

sub() { mosquitto_sub -h "$BROKER" -p "$PORT" "$@" 2>/dev/null; }
pub() { mosquitto_pub -h "$BROKER" -p "$PORT" "$@" 2>/dev/null; }

cleanup() {
  local t
  for t in "${WROTE[@]:-}"; do
    [[ -n "$t" ]] && pub -r -t "$t" -m ''
  done
  # Registry rows this suite published, matched by their ci-agent suffix only.
  sub -t 'registry/#' --retained-only -v -W 2 | awk '$1 ~ /\/ci-agent$/ {print $1}' | while read -r t; do
    [[ -n "$t" ]] && pub -r -t "$t" -m ''
  done
  rm -rf "$WORK"
}
trap cleanup EXIT

# --------------------------------------------------------------- 0. broker
printf '=== 0. broker %s:%s ===\n' "$BROKER" "$PORT"
up=0
for _ in $(seq 1 40); do
  if (exec 3<>"/dev/tcp/$BROKER/$PORT") 2>/dev/null; then up=1; break; fi
  sleep 0.5
done
if [[ $up -eq 1 ]]; then
  pass 'broker reachable' "$BROKER:$PORT"
else
  fail 'broker reachable' "$BROKER:$PORT never opened"
  printf '\n=== summary ===\nPASS: %d / FAIL: %d / SKIP: %d\n' "$PASS" "$FAIL" "$SKIP"
  exit 1
fi

# ------------------------------------------------- 1. B1 heredoc executes
printf '\n=== 1. B1 unknown command ===\n'
out="$(bash "$COMS" notacommand 2>&1)"
expect_exit 'unknown command exits 2' 2 $?
expect_eq 'backticks in help stop executing' 0 "$(printf '%s' "$out" | grep -c 'command not found')"
if printf '%s' "$out" | grep -q 'live wake bus'; then
  pass 'help text still printed' 'learn text present'
else
  fail 'help text still printed' 'no learn text in output'
fi

# ------------------------------------------------ 2. B5 wildcard rejection
printf '\n=== 2. B5 wildcard guard ===\n'
err="$(bash "$COMS" topics 'notes/*' 2>&1)"
expect_exit "'*' pattern rejected" 2 $?
if printf '%s' "$err" | grep -q 'is not an MQTT wildcard'; then
  pass 'hint names the real wildcards' "'+' and '#' mentioned"
else
  fail 'hint names the real wildcards' "$(printf '%s' "$err" | head -1)"
fi

NOTE="notes/ci-probe-$RANDOM"
WROTE+=("$NOTE")
bash "$COMS" send --retain "$NOTE" 'ci probe payload' >/dev/null 2>&1
listing="$(bash "$COMS" topics 'notes/+' --wait 3 2>&1)"
case "$listing" in
  *"$NOTE"*) pass "correct wildcard still finds notes" "$NOTE listed" ;;
  *) fail "correct wildcard still finds notes" "$NOTE missing from notes/+" ;;
esac

# ----------------------------------------------------- 3. B3 retain guard
printf '\n=== 3. B3 retain guard ===\n'
FOREIGN='inbox/ci-probe-host/ci-probe-wt/ci-probe-agent'
guard_out="$(bash "$COMS" send --retain "$FOREIGN" 'guard probe' 2>&1)"
expect_exit 'foreign-seat --retain refused' 2 $?
landed="$(sub -t "$FOREIGN" --retained-only -W 2 | wc -c | tr -d ' ')"
expect_eq 'refused message was not published' 0 "$landed"
BCAST='inbox/ci-probe-host/ci-probe-wt/all'
WROTE+=("$BCAST")
bash "$COMS" send --retain "$BCAST" 'broadcast is not a seat' >/dev/null 2>&1
expect_exit 'worktree broadcast still allowed' 0 $?

# ------------------------------------------- 4. large payload (500 KB file)
printf '\n=== 4. 500 KB payload via --file ===\n'
BIGFILE="$WORK/big.txt"
python3 -c "import sys; sys.stdout.write('B' * 500000)" > "$BIGFILE"
BIGT="status/ci-big-$RANDOM"
WROTE+=("$BIGT")
bash "$COMS" send --retain --file "$BIGFILE" "$BIGT" >/dev/null 2>&1
expect_exit '500 KB send exits 0' 0 $?
got_bytes="$(sub -t "$BIGT" --retained-only -W 3 -F '%l' | head -1 | tr -d '\r\n ')"
expect_eq '500 KB arrives whole' 500000 "$got_bytes" 'bytes='
# argv cannot carry it: prove the limit is why --file exists.
arg_err="$(bash "$COMS" send --retain "status/ci-argv-$RANDOM" "$(cat "$BIGFILE")" 2>&1)"
arg_code=$?
case "$arg_err" in
  *'Argument list too long'*) pass 'argv path is genuinely impossible' "kernel refused, exit=$arg_code" ;;
  *)
    if [[ $arg_code -ne 0 ]]; then
      pass 'argv path is genuinely impossible' "refused, exit=$arg_code"
    else
      skip 'argv path is genuinely impossible' 'kernel accepted 500 KB in one arg here'
    fi
    ;;
esac

# ----------------------------------------------------- 5. B4 roster upsert
printf '\n=== 5. B4 roster upsert ===\n'
bash "$COMS" register --agent ci-agent --goal first >/dev/null 2>&1
bash "$COMS" register --agent ci-agent --goal second >/dev/null 2>&1
rows="$(wc -l < "$HOME/.coms/agents.jsonl" | tr -d ' ')"
expect_eq 'double register keeps one row' 1 "$rows"
if grep -q '"goal":"second"' "$HOME/.coms/agents.jsonl"; then
  pass 'goal updated in place' 'second'
else
  fail 'goal updated in place' "$(head -1 "$HOME/.coms/agents.jsonl")"
fi

# --------------------------------------------- 6. check exit-code contract
printf '\n=== 6. check ===\n'
bash "$COMS" check --agent ci-agent --wait 2 --no-notes >/dev/null 2>&1
expect_exit 'check exits 0' 0 $?
# Unset COMS_AGENT for this one: with it exported, check legitimately resolves
# an agent and exits 0, so the no-argument contract is only visible without it.
env -u COMS_AGENT bash "$COMS" check >/dev/null 2>&1
expect_exit 'check without --agent exits 2' 2 $?
bash "$COMS" check --agent ci-agent --wait abc >/dev/null 2>&1
expect_exit 'check --wait abc rejected' 2 $?

# ------------------------------------------------ 7. dedupe_roster.py
printf '\n=== 7. dedupe_roster.py ===\n'
DUP="$WORK/dup.jsonl"
printf '%s\n' \
  '{"agent":"a","swarmbus_id":"h__w__a","goal":"one","registered_at":"2026-01-01T00:00:00Z"}' \
  '{"agent":"a","swarmbus_id":"h__w__a","goal":"two","registered_at":"2026-01-02T00:00:00Z"}' \
  '{"agent":"a","swarmbus_id":"h__w__a","goal":"","registered_at":"2026-01-03T00:00:00Z"}' \
  '{"agent":"b","swarmbus_id":"h__w__b","goal":"other","registered_at":"2026-01-01T00:00:00Z"}' > "$DUP"
before="$(wc -l < "$DUP" | tr -d ' ')"
python3 "$ROOT/dedupe_roster.py" "$DUP" >/dev/null 2>&1
after_dry="$(wc -l < "$DUP" | tr -d ' ')"
expect_eq 'dry run leaves the file alone' "$before" "$after_dry"
python3 "$ROOT/dedupe_roster.py" "$DUP" --apply >/dev/null 2>&1
expect_exit 'apply exits 0' 0 $?
expect_eq 'apply collapses to distinct seats' 2 "$(wc -l < "$DUP" | tr -d ' ')"
if compgen -G "$DUP.bak-*" >/dev/null; then
  pass 'backup kept' "$(basename "$(compgen -G "$DUP.bak-*" | head -1)")"
else
  fail 'backup kept' 'no .bak-* file'
fi
if grep -q '"goal":"two"' "$DUP"; then
  pass 'newest non-empty field wins' 'goal=two'
else
  fail 'newest non-empty field wins' "$(tr '\n' ' ' < "$DUP")"
fi

# -------------------------------------------------- 8. secret refusal
printf '\n=== 8. secret guard ===\n'
bash "$COMS" register --agent ci-agent --goal 'AKIAIOSFODNN7EXAMPLE' >/dev/null 2>&1
expect_exit 'aws-key shaped goal refused' 2 $?

# ------------------------------------------------------------- summary
printf '\n=== summary ===\n'
printf 'PASS: %d / FAIL: %d / SKIP: %d\n' "$PASS" "$FAIL" "$SKIP"
if [[ $FAIL -gt 0 ]]; then
  printf '%d failing check(s).\n' "$FAIL"
  exit 1
fi
printf 'No failures.\n'
exit 0
