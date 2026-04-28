#!/usr/bin/env bash
# subagent-catalog helper for Gemini CLI
# ported from VoltAgent/awesome-claude-code-subagents

set -euo pipefail

# --- CONFIG ---
readonly TTL_SECONDS=$((12 * 60 * 60))   # 12 hours
readonly CACHE_FILE="$HOME/.gemini/cache/subagent-catalog.md"
readonly REPO_URL="https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main"

# --- HELPERS ---

get_mtime() {
  date -r "$1" +%s
}

format_age() {
  local seconds=$1
  if [ $seconds -lt 60 ]; then
    echo "${seconds}s"
  elif [ $seconds -lt 3600 ]; then
    echo "$(( seconds / 60 ))m"
  else
    echo "$(( seconds / 3600 ))h"
  fi
}

fetch_to_cache() {
  mkdir -p "$(dirname "$CACHE_FILE")"
  if curl -sf --connect-timeout 5 --max-time 30 "$REPO_URL/README.md" -o "$CACHE_FILE.tmp" 2>/dev/null; then
    mv "$CACHE_FILE.tmp" "$CACHE_FILE"
    return 0
  else
    rm -f "$CACHE_FILE.tmp"
    return 1
  fi
}

ensure_cache() {
  local cache_age=0
  if [ -f "$CACHE_FILE" ]; then
    cache_age=$(( $(date +%s) - $(get_mtime "$CACHE_FILE") ))
    if [ $cache_age -lt $TTL_SECONDS ]; then
      return 0
    fi
  fi

  if fetch_to_cache; then
    return 0
  elif [ -f "$CACHE_FILE" ]; then
    echo "WARNING: fetch failed, using stale cache ($(format_age $cache_age) old)" >&2
    return 0
  else
    echo "ERROR: fetch failed and no cache. check network" >&2
    return 1
  fi
}

# --- COMMANDS ---

list_agents() {
  ensure_cache
  cat "$CACHE_FILE"
}

search_agents() {
  local query="$1"
  ensure_cache
  # Search for the query in the cache file and return matching lines
  grep -i "$query" "$CACHE_FILE" || echo "No agents found matching '$query'"
}

fetch_agent() {
  local agent_name="$1"
  # Find the agent in the README to get its path
  # Format in README: - [**agent-name**](categories/XX-category/agent-name.md)
  local agent_path=$(grep -o "categories/.*$agent_name\.md" "$CACHE_FILE" | head -n 1)
  
  if [ -z "$agent_path" ]; then
    echo "ERROR: Agent '$agent_name' not found in catalog." >&2
    return 1
  fi
  
  curl -sf "$REPO_URL/$agent_path"
}

invalidate_cache() {
  rm -f "$CACHE_FILE"
  echo "Cache invalidated."
  if [[ "${1:-}" == "--fetch" ]]; then
    fetch_to_cache && echo "Cache refreshed."
  fi
}

# Dispatcher
case "${1:-}" in
  list)
    list_agents
    ;;
  search)
    search_agents "${2:-}"
    ;;
  fetch)
    fetch_agent "${2:-}"
    ;;
  invalidate)
    invalidate_cache "${2:-}"
    ;;
  *)
    echo "Usage: $0 {list|search <query>|fetch <name>|invalidate [--fetch]}"
    exit 1
    ;;
esac
