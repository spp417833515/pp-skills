#!/usr/bin/env bash
# pp-skills 安装器 — 把 5 阶段 ppwiki 流水线技能装进 Claude Code 和/或 Codex
# 用法: bash install.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/skills"
# 单一信源 = MYAI data/skills(金源)。安装顺序: 金源先行 → 再推 adapters,
# 保证 GUI 展示(读金源)与 Claude/Codex 执行(读 adapters)永远同一份。
MYAI_ROOT="${MYAI_ROOT:-$HOME/桌面/MYAI}"
SKILLS=(pp-clarify-v2 pp-plan-v2 pp-execute-v2 pp-review-v2 pp-archive-v2 pp-pipeline)
OLD_V1=(clarify-v2 plan-v2 archive-v2)   # 旧·无前缀版 → 清理(单一信源)
RETIRED=(pp-sync-v2)                      # 已退役·并入 pp-archive-v2 → 清理残留

install_to() {
  local tool="$1" base="$2" dest="$2/skills"
  if [ ! -d "$base" ]; then
    echo "  ⊘ $tool 未检测到($base 不存在)· 跳过"
    return
  fi
  mkdir -p "$dest"
  for s in "${SKILLS[@]}"; do
    rm -rf "$dest/$s"
    cp -r "$SRC/$s" "$dest/$s"
    echo "  ✓ $s"
  done
  for o in "${OLD_V1[@]}"; do
    if [ -d "$dest/$o" ]; then rm -rf "$dest/$o"; echo "  ✗ 清理旧 v1: $o"; fi
  done
  for r in "${RETIRED[@]}"; do
    if [ -d "$dest/$r" ]; then rm -rf "$dest/$r"; echo "  ✗ 清理退役技能: $r(并入 pp-archive-v2)"; fi
  done
  echo "  → $tool: ${#SKILLS[@]} 技能就位 @ $dest"
}

echo "════ pp-skills 安装 ════"
install_to "MYAI 金源"   "$MYAI_ROOT/data"
install_to "Claude Code" "$HOME/.claude"
install_to "Codex"       "$HOME/.codex"

echo
echo "──── 依赖:ppwiki MCP ────"
ok=0
grep -rqsiE "pp_?wiki" "$HOME/.claude.json" "$HOME"/.claude/*.json 2>/dev/null && { echo "  ✓ Claude 侧疑似已配 ppwiki"; ok=1; }
grep -qsiE "pp_?wiki" "$HOME/.codex/config.toml" 2>/dev/null && { echo "  ✓ Codex 侧已配 ppwiki(config.toml)"; ok=1; }
[ "$ok" = 0 ] && echo "  ⚠ 未检测到 ppwiki MCP · 这套技能依赖它 · 见 ppwiki-setup.md"

echo
echo "完成。新技能通常热加载;若 / 菜单没出现,重启 Claude/Codex 一次。"
echo "调用:/pp-clarify-v2 <一句话需求>  → 一路 A 到 /pp-archive-v2"
