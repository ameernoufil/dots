#!/usr/bin/env zsh

set -euo pipefail

test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

state_dir="$test_root/state"
mkdir -p "$state_dir"

function git() {
if [[ $1 == rev-parse ]]; then
    print -r -- "$TEST_CURRENT_REPO_ROOT"
    return 0
fi

if [[ $3 == worktree && $4 == list ]]; then
    print -r -- "worktree $TEST_MAIN_REPO_ROOT"
    print -r -- "HEAD 0123456789abcdef"
    print -r -- "branch refs/heads/main"
    return 0
fi

if [[ $3 == fetch && $4 == origin && $5 == --prune ]]; then
    if (( ${TEST_FETCH_EXIT:-0} == 0 )); then
        print 1 >"$TEST_STATE_DIR/fetch-complete"
    fi
    return ${TEST_FETCH_EXIT:-0}
fi

if [[ $3 == for-each-ref ]]; then
    print -r -- origin/main
    return 0
fi

if [[ $3 == show-ref ]]; then
    if (( ${TEST_BRANCH_EXISTS_AFTER_FETCH:-0} == 1 )) &&
        [[ -f $TEST_STATE_DIR/fetch-complete ]]; then
        return 0
    fi
    return $(( ! ${TEST_BRANCH_EXISTS:-0} ))
fi

print -u2 "Unexpected git arguments: $*"
return 2
}

function fzf() {
call_count_file="$TEST_STATE_DIR/fzf-call-count"
call_count=0
[[ -f $call_count_file ]] && call_count=$(<$call_count_file)
(( call_count += 1 ))
print -r -- "$call_count" >"$call_count_file"

if (( call_count == 1 )); then
    print -r -- "${TEST_TARGET_QUERY:->new-feature}"
    [[ -n ${TEST_TARGET_SELECTION:-} ]] &&
        print -r -- "$TEST_TARGET_SELECTION"
    return ${TEST_TARGET_FZF_STATUS:-1}
fi

print -r -- origin/main
return 0
}

function herdr() {
print -rl -- "$@" >"$TEST_STATE_DIR/herdr-args"
return ${TEST_HERDR_EXIT:-0}
}

export TEST_STATE_DIR="$state_dir"
export TEST_CURRENT_REPO_ROOT=/fixture/repo
export TEST_MAIN_REPO_ROOT=/fixture/repo
export TEST_BRANCH_EXISTS=0
export TEST_TARGET_QUERY='>new-feature'
export TEST_TARGET_SELECTION=''
export TEST_TARGET_FZF_STATUS=1
export TEST_FETCH_EXIT=0
export TEST_BRANCH_EXISTS_AFTER_FETCH=0
script_path="${0:A:h}/../bin/herdr-worktree-create"
function run_script() {
    set +e
    set +o pipefail
    source "$script_path"
}

(run_script) <<<y

expected_args=(
    worktree
    create
    --cwd
    /fixture/repo
    --branch
    new-feature
    --base
    origin/main
    --focus
)
actual_args=("${(@f)$(<"$state_dir/herdr-args")}")

if [[ ${(j:\n:)actual_args} != ${(j:\n:)expected_args} ]]; then
    print -u2 "Expected herdr arguments:"
    print -u2 -rl -- "$expected_args[@]"
    print -u2 "Actual herdr arguments:"
    print -u2 -rl -- "$actual_args[@]"
    exit 1
fi

print "PASS: a missing remote branch can be created from the selected source"

print 0 >"$state_dir/fzf-call-count"
export TEST_CURRENT_REPO_ROOT=/fixture/repo-worktrees/existing-feature
(run_script) <<<y

linked_actual_args=("${(@f)$(<"$state_dir/herdr-args")}")
if [[ ${linked_actual_args[4]} != /fixture/repo ]]; then
    print -u2 \
        "Expected a linked-worktree launch to use the main checkout, got '${linked_actual_args[4]}'"
    exit 1
fi

print "PASS: a linked-worktree launch uses the main checkout as Herdr's source"

print 0 >"$state_dir/fzf-call-count"
rm -f "$state_dir/fetch-complete"
export TEST_CURRENT_REPO_ROOT=/fixture/repo
export TEST_BRANCH_EXISTS=0
export TEST_BRANCH_EXISTS_AFTER_FETCH=1
export TEST_TARGET_QUERY=feature/roo
export TEST_TARGET_SELECTION=origin/feature/room
export TEST_TARGET_FZF_STATUS=0
(run_script)

existing_expected_args=(
    worktree
    create
    --cwd
    /fixture/repo
    --branch
    feature/room
    --base
    origin/feature/room
    --focus
)
existing_actual_args=("${(@f)$(<"$state_dir/herdr-args")}")
existing_fzf_calls=$(<"$state_dir/fzf-call-count")

if [[ ${(j:\n:)existing_actual_args} != ${(j:\n:)existing_expected_args} ]]; then
    print -u2 "Expected an existing branch to use itself as the base"
    exit 1
fi

if (( existing_fzf_calls != 1 )); then
    print -u2 "Expected an existing branch to need one prompt, got $existing_fzf_calls"
    exit 1
fi

print "PASS: fetching makes a new remote branch available before the picker"

print 0 >"$state_dir/fzf-call-count"
export TEST_BRANCH_EXISTS=0
export TEST_BRANCH_EXISTS_AFTER_FETCH=0
export TEST_TARGET_QUERY='>new-feature'
export TEST_TARGET_SELECTION=''
export TEST_TARGET_FZF_STATUS=1
export TEST_HERDR_EXIT=42
set +e
failure_output=$( (run_script) <<< $'y\n' 2>&1 )
failure_status=$?
set -e

if (( failure_status != 42 )); then
    print -u2 "Expected helper to preserve herdr exit code 42, got $failure_status"
    exit 1
fi

if [[ $failure_output != *"Failed to create worktree for branch 'new-feature' (herdr exited 42)."* ]]; then
    print -u2 "Expected a visible worktree failure message, got:"
    print -u2 -r -- "$failure_output"
    exit 1
fi

print "PASS: a herdr failure remains visible and preserves its exit code"
