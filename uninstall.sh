#!/bin/sh

# -----------------------------
# Direnv 제거 스크립트
# - ~/.direnv 디렉토리 삭제
# - shell rc 파일에서 direnv 관련 라인 제거
# -----------------------------

# 언어 코드 감지
LANG_CODE=$(locale 2>/dev/null | grep -E '^LANG=' | cut -d= -f2 | cut -d_ -f1 | sed 's/\"//g')
LANG_CODE=${LANG_CODE:-en}

# 지원 언어 확인 (지원되지 않으면 en 으로 fallback)
case "$LANG_CODE" in
  en|ko) ;;  # 지원하는 언어 목록
  *) LANG_CODE="en" ;;
esac

# 언어 URL
LANG_URL="https://raw.githubusercontent.com/yhk1038/direnv/main/src/lang/${LANG_CODE}.lang"

# curl로 읽어서 eval로 실행
LANG_CONTENT=$(curl -fsSL "$LANG_URL")
if [ -n "$LANG_CONTENT" ]; then
  eval "$LANG_CONTENT"
else
  echo "[direnv] ⚠️  Failed to load language file: $LANG_CODE"
fi

# 출력 유틸리티 함수
log() { printf "\033[1;32m[✔]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[✘]\033[0m %s\n" "$1" >&2; }
step() { printf "\n\033[1;34m▶ %s\033[0m\n" "$1"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }

# 사용자 확인 프롬프트
step "$MSG_UNINSTALL_CONFIRM"
printf "$(printf "$MSG_UNINSTALL_PROMPT"): "
read -r CONFIRM

case "$CONFIRM" in
  y|Y|yes|Yes|YES)
    log "$MSG_UNINSTALL_PROCEEDING"
    ;;
  *)
    warn "$MSG_UNINSTALL_CANCELLED"
    exit 0
    ;;
esac

# 1단계: Shell 설정 파일 감지
step "$MSG_UNINSTALL_STEP_DETECT_SHELL"
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

case "$SHELL_NAME" in
  bash)
    RC_FILE="$HOME/.bashrc"
    [ ! -f "$RC_FILE" ] && RC_FILE="$HOME/.bash_profile"
    ;;
  zsh) RC_FILE="$HOME/.zshrc" ;;
  ksh) RC_FILE="$HOME/.kshrc" ;;
  *)   RC_FILE="$HOME/.profile" ;;
esac

if [ -f "$RC_FILE" ]; then
  log "$(printf "$MSG_UNINSTALL_DETECTED_RC" "$RC_FILE")"
else
  warn "$(printf "$MSG_UNINSTALL_RC_NOT_FOUND" "$RC_FILE")"
fi

# 2단계: Shell 설정 파일 백업 및 정리
if [ -f "$RC_FILE" ]; then
  step "$MSG_UNINSTALL_STEP_CLEAN_RC"

  # 백업 생성
  BACKUP_FILE="${RC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$RC_FILE" "$BACKUP_FILE" 2>/dev/null

  if [ -f "$BACKUP_FILE" ]; then
    log "$(printf "$MSG_UNINSTALL_BACKUP_CREATED" "$BACKUP_FILE")"
  else
    error "$MSG_UNINSTALL_BACKUP_FAILED"
  fi

  # direnv 관련 라인 제거
  # 임시 파일 사용하여 제거
  TMP_FILE="${RC_FILE}.tmp"
  grep -v '.direnv/src/init.sh' "$RC_FILE" > "$TMP_FILE" 2>/dev/null

  if [ -f "$TMP_FILE" ]; then
    mv "$TMP_FILE" "$RC_FILE"
    log "$(printf "$MSG_UNINSTALL_RC_CLEANED" "$RC_FILE")"
  else
    error "$MSG_UNINSTALL_RC_CLEAN_FAILED"
  fi
fi

# 3단계: ~/.direnv 디렉토리 삭제
step "$MSG_UNINSTALL_STEP_REMOVE_DIR"
INSTALL_DIR="$HOME/.direnv"

if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR" 2>/dev/null

  if [ ! -d "$INSTALL_DIR" ]; then
    log "$(printf "$MSG_UNINSTALL_DIR_REMOVED" "$INSTALL_DIR")"
  else
    error "$(printf "$MSG_UNINSTALL_DIR_REMOVE_FAILED" "$INSTALL_DIR")"
    exit 1
  fi
else
  warn "$(printf "$MSG_UNINSTALL_DIR_NOT_FOUND" "$INSTALL_DIR")"
fi

# 완료 메시지
log "$MSG_UNINSTALL_COMPLETE"
exit 0
