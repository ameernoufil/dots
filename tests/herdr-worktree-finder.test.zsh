#!/usr/bin/env zsh

set -euo pipefail

test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
export TEST_RESULT="$test_root/result"
export TEST_FINDER_INPUT="$test_root/finder-input"

function git() {
    if [[ $1 == rev-parse ]]; then
        print -r -- /fixture/repo-worktrees/current
        return 0
    fi

    if [[ $3 == worktree && $4 == list ]]; then
        print -r -- "worktree /fixture/repo"
        print -r -- "HEAD 0123456789abcdef"
        print -r -- "branch refs/heads/main"
        return 0
    fi

    return 2
}

function herdr() {
    if [[ $1 == worktree && $2 == list ]]; then
        print -r -- '{"result":{"worktrees":[{"path":"/fixture/repo","branch":"main","open_workspace_id":"w1"},{"path":"/fixture/repo-worktrees/feature-room","branch":"feature/room","open_workspace_id":"w2"}]}}'
        return 0
    fi

    if [[ $1 == workspace && $2 == focus ]]; then
        print -r -- "$3" >"$TEST_RESULT"
        return 0
    fi

    return 2
}

function fzf() {
    if [[ ${(j: :)@} != *"one:accept"* ]]; then
        print -u2 "Expected the worktree finder to auto-accept one match"
        return 2
    fi

    finder_input=$(<&0)
    print -r -- "$finder_input" >"$TEST_FINDER_INPUT"
    selected=$(print -r -- "$finder_input" | tail -n 1)
    print -r -- "$selected"
}

source "${0:A:h}/../bin/herdr-worktree-finder"

if [[ $(<"$TEST_RESULT") != w2 ]]; then
    print -u2 "Expected the selected worktree workspace ID w2"
    exit 1
fi

print "PASS: the worktree finder focuses a selected worktree from the current repository"

if ! awk -F '\t' '
    NF != 3 { exit 1 }
    NR == 1 { first = index($3, "repo") }
    NR == 2 { second = index($3, "feature-room") }
    END { exit !(first > 0 && first == second) }
' "$TEST_FINDER_INPUT"; then
    print -u2 "Expected every worktree directory to start in the same display column"
    exit 1
fi

print "PASS: worktree branch and directory columns are aligned"
