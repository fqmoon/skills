#!/usr/bin/env bash
# memo pre-commit 守卫：拦住凭据与密钥形态。命中即中止提交。
# 装在 ~/memo/.git/hooks/pre-commit（符号链接到本文件）。
set -uo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

PATTERNS='sk-[A-Za-z0-9_-]{16,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.|(password|passwd|token|secret|api[_-]?key|access[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]]{8,}'

hits=$(git diff --cached -z --name-only --diff-filter=ACM \
  | xargs -0 -r grep -nEI -- "$PATTERNS" 2>/dev/null)

if [ -n "$hits" ]; then
  echo "✗ memo pre-commit 拦截：疑似凭据，未提交。" >&2
  echo "$hits" | head -20 >&2
  echo "确认无害后可用：git commit --no-verify" >&2
  exit 1
fi
exit 0
