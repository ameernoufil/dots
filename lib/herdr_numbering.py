"""Shared helpers for herdr sidebar numbering.

Herdr renders position numbers only in the collapsed sidebar. These helpers
reproduce the two orders the expanded sidebar uses, so numbers stamped as an
$idx metadata token match the positions the keybindings actually jump to.
"""

from __future__ import annotations

import json
import os
import subprocess

HERDR = os.environ.get("HERDR_BIN", os.path.expanduser("~/.local/bin/herdr"))
CONFIG_PATH = os.environ.get(
    "HERDR_CONFIG_PATH", os.path.expanduser("~/.config/herdr/config.toml")
)

# Mirrors tab_attention_priority() in src/app/api_helpers.rs.
ATTENTION_PRIORITY = {"blocked": 4, "done": 3, "working": 2, "idle": 1, "unknown": 0}


def run(args: list[str]) -> str:
    result = subprocess.run(
        [HERDR, *args], capture_output=True, text=True, timeout=20, check=False
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"herdr {' '.join(args)} failed: {result.stderr.strip() or result.stdout.strip()}"
        )
    return result.stdout


def snapshot() -> dict:
    return json.loads(run(["api", "snapshot"]))["result"]["snapshot"]


def agent_panel_sort() -> str:
    """Read ui.agent_panel_sort; agent numbering must match the rendered order."""
    try:
        import tomllib

        with open(CONFIG_PATH, "rb") as handle:
            config = tomllib.load(handle)
    except (OSError, ValueError, ImportError):
        return "spaces"
    return "priority" if config.get("ui", {}).get("agent_panel_sort") == "priority" else "spaces"


def visible_workspace_order(workspaces: list[dict]) -> list[int]:
    """Sidebar row order: worktree spaces group under their main checkout.

    Mirrors workspace_list_entries_inner() in src/ui/sidebar.rs, which is what
    switch_workspace and the navigate-mode digits index into. Groups are assumed
    expanded; collapsing one in the UI shifts positions until the next sync.
    """
    members: dict[str, list[int]] = {}
    for index, workspace in enumerate(workspaces):
        worktree = workspace.get("worktree")
        if worktree:
            members.setdefault(worktree["repo_key"], []).append(index)

    grouped = {
        key
        for key, group in members.items()
        if len(group) >= 2
        and any(not workspaces[i]["worktree"]["is_linked_worktree"] for i in group)
    }

    emitted: set[str] = set()
    order: list[int] = []
    for index, workspace in enumerate(workspaces):
        worktree = workspace.get("worktree")
        key = worktree["repo_key"] if worktree else None
        if key is None or key not in grouped:
            order.append(index)
            continue
        if key in emitted:
            continue
        emitted.add(key)
        group = members[key]
        parent = next(
            (i for i in group if not workspaces[i]["worktree"]["is_linked_worktree"]), None
        )
        if parent is None:
            order.append(index)
            continue
        order.append(parent)
        order.extend(i for i in group if i != parent)
    return order


def agent_order(agents: list[dict], sort: str | None = None) -> list[dict]:
    """Agent panel order. focus_agent indexes into this list."""
    if (sort or agent_panel_sort()) != "priority":
        return list(agents)
    return sorted(
        agents,
        key=lambda agent: (
            -ATTENTION_PRIORITY.get(agent.get("agent_status", "unknown"), 0),
            -agent.get("state_change_seq", 0),
        ),
    )
