#!/usr/bin/env bash
# Validate work-manager plugin structure, references, and content
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
PASS=0

pass() { ((PASS++)); echo "  ✓ $1"; }
fail() { ((ERRORS++)); echo "  ✗ $1"; }

echo "=== work-manager plugin validation ==="
echo ""

# --- Structure ---
echo "[Structure]"

[ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ] && pass "plugin.json exists" || fail "plugin.json missing"
[ -d "$PLUGIN_ROOT/agents" ] && pass "agents/ exists" || fail "agents/ missing"
[ -d "$PLUGIN_ROOT/skills" ] && pass "skills/ exists" || fail "skills/ missing"
[ -d "$PLUGIN_ROOT/hooks" ] && pass "hooks/ exists" || fail "hooks/ missing"

echo ""

# --- plugin.json ---
echo "[plugin.json]"

if command -v jq &>/dev/null; then
  jq empty "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null && pass "valid JSON" || fail "invalid JSON"

  name=$(jq -r '.name' "$PLUGIN_ROOT/.claude-plugin/plugin.json")
  [ "$name" = "work-manager" ] && pass "name = work-manager" || fail "name = '$name', expected 'work-manager'"

  for comp in agents skills hooks; do
    val=$(jq -r ".components.$comp // empty" "$PLUGIN_ROOT/.claude-plugin/plugin.json")
    [ -n "$val" ] && pass "components.$comp declared" || fail "components.$comp missing"
  done
else
  echo "  ⚠ jq not found, skipping JSON validation"
fi

echo ""

# --- Agent ---
echo "[Agent: work-manager]"

agent="$PLUGIN_ROOT/agents/work-manager.md"
[ -f "$agent" ] && pass "agent file exists" || fail "agent file missing"

if [ -f "$agent" ]; then
  grep -q "^name:" "$agent" && pass "has name field" || fail "missing name field"
  grep -q "^allowed-tools:" "$agent" && pass "has allowed-tools (not 'tools:')" || fail "uses 'tools:' instead of 'allowed-tools:'"
  grep -q "^model:" "$agent" && pass "has model field" || fail "missing model field"
  grep -q "^color:" "$agent" && pass "has color field" || fail "missing color field"
  grep -q 'CLAUDE_PLUGIN_ROOT' "$agent" && pass "uses \${CLAUDE_PLUGIN_ROOT}" || fail "missing \${CLAUDE_PLUGIN_ROOT} reference"

  # No hardcoded paths
  if grep -qE '~/\.claude/|/Users/' "$agent"; then
    fail "contains hardcoded paths"
  else
    pass "no hardcoded paths"
  fi
fi

echo ""

# --- Skills ---
echo "[Skills]"

expected_skills="work-start work-done work-status work-pr work-recall work-update"
for skill in $expected_skills; do
  skill_file="$PLUGIN_ROOT/skills/$skill/SKILL.md"
  if [ -f "$skill_file" ]; then
    pass "$skill/SKILL.md exists"

    # Check frontmatter
    if head -1 "$skill_file" | grep -q "^---"; then
      pass "$skill has frontmatter"
    else
      fail "$skill missing frontmatter"
    fi

    # Check name in frontmatter
    if grep -q "^name: $skill" "$skill_file"; then
      pass "$skill name matches directory"
    else
      fail "$skill name doesn't match directory name"
    fi

    # Check description exists and uses third person
    if grep -q "^description:" "$skill_file"; then
      if grep -A2 "^description:" "$skill_file" | grep -qi "this skill should be used"; then
        pass "$skill description uses third person"
      else
        fail "$skill description not in third person"
      fi
    else
      fail "$skill missing description"
    fi

    # No hardcoded paths
    if grep -qE '~/\.claude/|/Users/' "$skill_file"; then
      fail "$skill contains hardcoded paths"
    else
      pass "$skill no hardcoded paths"
    fi
  else
    fail "$skill/SKILL.md missing"
  fi
done

echo ""

# --- Hooks ---
echo "[Hooks]"

hooks_file="$PLUGIN_ROOT/hooks/hooks.json"
[ -f "$hooks_file" ] && pass "hooks.json exists" || fail "hooks.json missing"

if [ -f "$hooks_file" ] && command -v jq &>/dev/null; then
  jq empty "$hooks_file" 2>/dev/null && pass "valid JSON" || fail "invalid JSON"

  # Check expected hook events
  for event in Stop UserPromptSubmit; do
    count=$(jq -r ".hooks.$event | length" "$hooks_file" 2>/dev/null)
    if [ "$count" -gt 0 ] 2>/dev/null; then
      pass "$event hook registered ($count)"
    else
      fail "$event hook missing"
    fi
  done

  # All hooks should be type: agent
  bad_types=$(jq -r '[.hooks[][] | select(.type != "agent")] | length' "$hooks_file" 2>/dev/null)
  if [ "$bad_types" = "0" ]; then
    pass "all hooks are type: agent"
  else
    fail "$bad_types hook(s) not type: agent"
  fi

  # Hooks should reference _summary.md
  if grep -q "_summary.md" "$hooks_file"; then
    pass "hooks reference _summary.md"
  else
    fail "hooks don't reference _summary.md"
  fi

  # No hardcoded paths in hooks
  if grep -qE '~/\.claude/|/Users/' "$hooks_file"; then
    fail "hooks contain hardcoded paths"
  else
    pass "hooks no hardcoded paths"
  fi
fi

echo ""

# --- Agent routing completeness ---
echo "[Routing]"

if [ -f "$agent" ]; then
  for skill in $expected_skills; do
    if grep -q "$skill" "$agent"; then
      pass "agent routes to $skill"
    else
      fail "agent missing route for $skill"
    fi
  done
fi

echo ""

# --- Summary ---
echo "=== Results: $PASS passed, $ERRORS failed ==="
[ "$ERRORS" -eq 0 ] && exit 0 || exit 1
