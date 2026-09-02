#!/usr/bin/env bash
#
# Agent 应用开发团队（Eval 驱动）—— 一键安装脚本
#
# 自动检测你是否已经装过其他 Claude 团队（标准团队 / 小程序团队等）：
#   - 没装过 → 安装全部 8 个 agent（本团队自包含，开箱即用）
#   - 已装过 → 只补 7 个 agent 专属角色，共用 agent 不覆盖（保留你可能改过的版本）
#
# 用法：
#   bash install.sh            # 智能安装（推荐）
#   bash install.sh --force    # 强制覆盖所有同名 agent
#   bash install.sh --uninstall
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DST="$HOME/.claude/agents"
SKILL_DST="$HOME/.claude/skills/agent-dev-team"

# Agent 应用开发专属 agent（永远安装）
OWN_AGENTS=(
  agentapp-architect
  agentapp-eval-lead
  agentapp-builder
  agentapp-runtime
  agentapp-safety
  agentapp-reality-checker
  agentapp-frontend
)

# 与其他团队共用的 agent（已存在则默认跳过，不覆盖）
SHARED_AGENTS=(
  technical-writer
)

c_green() { printf '\033[32m%s\033[0m\n' "$1"; }
c_yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
c_blue() { printf '\033[36m%s\033[0m\n' "$1"; }

# ---------- 卸载 ----------
if [[ "${1:-}" == "--uninstall" ]]; then
  c_yellow "卸载 Agent 应用开发团队..."
  for a in "${OWN_AGENTS[@]}"; do
    rm -f "$AGENTS_DST/$a.md" && echo "  删除 $a.md"
  done
  rm -rf "$SKILL_DST" && echo "  删除 skill"
  c_yellow "注意：共用 agent（technical-writer）未删除，可能仍被其他团队使用。"
  c_green "卸载完成。"
  exit 0
fi

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

mkdir -p "$AGENTS_DST" "$SKILL_DST"

# ---------- 检测是否已有其他团队 ----------
HAS_OTHER_TEAM=false
if [[ -f "$AGENTS_DST/technical-writer.md" ]]; then
  HAS_OTHER_TEAM=true
fi

echo ""
c_blue "=== Agent 应用开发团队（Eval 驱动）安装程序 ==="
if $HAS_OTHER_TEAM; then
  c_yellow "检测到你已安装其他 Claude 团队的共用 agent。"
  echo "→ 只安装 7 个 agent 专属角色，共用 agent 保持你现有版本不动。"
else
  echo "→ 未检测到其他团队，安装完整套件（8 个 agent，开箱即用）。"
fi
echo ""

installed=0; skipped=0; overwritten=0

install_one() {
  local name="$1" src="$SCRIPT_DIR/agents/$1.md" dst="$AGENTS_DST/$1.md"
  if [[ -f "$dst" && "$FORCE" == false ]]; then
    echo "  跳过（已存在）：$name"; ((skipped+=1)); return
  fi
  if [[ -f "$dst" ]]; then ((overwritten+=1)); else ((installed+=1)); fi
  cp "$src" "$dst"
  echo "  安装：$name"
}

echo "[ Agent 应用专属角色 ]"
for a in "${OWN_AGENTS[@]}"; do install_one "$a"; done

echo ""
echo "[ 共用 agent ]"
for a in "${SHARED_AGENTS[@]}"; do install_one "$a"; done

echo ""
echo "[ 总指挥剧本 skill ]"
cp "$SCRIPT_DIR/skills/agent-dev-team/SKILL.md" "$SKILL_DST/SKILL.md"
echo "  安装：agent-dev-team/SKILL.md"

echo ""
c_green "=== 安装完成 ==="
echo "  新增 $installed 个 / 跳过 $skipped 个 / 覆盖 $overwritten 个 agent + 1 个 skill"
echo ""
echo "验证："
echo "  ls $AGENTS_DST/ | grep agentapp"
echo "  ls $SKILL_DST/SKILL.md"
echo ""
echo "重启 Claude Code 后，新开对话输入「用 agent 团队开发一个 XXX」即可触发。"
