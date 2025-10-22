#!/bin/sh

# -----------------------------
# Direnv 설치 스크립트
# - ~/.direnv 디렉토리에 설치
# - shell rc 파일에 alias 추가
# -----------------------------

# 언어 코드 감지
LANG_CODE=$(locale 2>/dev/null | grep -E '^LANG=' | cut -d= -f2 | cut -d_ -f1 | sed 's/\"//g')
LANG_CODE=${LANG_CODE:-en}

# 지원 언어 확인 (지원되지 않으면 en 으로 fallback)
case "$LANG_CODE" in
  en|ko|ja) ;;  # 지원하는 언어 목록
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

# 설치 버전과 URL 설정
VERSION="$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/VERSION)"
TAR_URL="https://github.com/yhk1038/direnv/releases/download/$VERSION/direnv-$VERSION.tar.gz"
INSTALL_DIR="$HOME/.direnv"
TMP_TAR_FILE="/tmp/direnv.tar.gz"

# 1단계: 다운로드
step "$(printf "$MSG_STEP_DOWNLOAD" "$VERSION")"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$TAR_URL" -o "$TMP_TAR_FILE" || {
    error "$MSG_ERR_CURL"; exit 1;
  }
elif command -v wget >/dev/null 2>&1; then
  wget -q "$TAR_URL" -O "$TMP_TAR_FILE" || {
    error "$MSG_ERR_WGET"; exit 1;
  }
else
  error "$MSG_ERR_TOOL_REQUIRED"; exit 1;
fi
log "$MSG_DONE_DOWNLOAD"

# 2단계: 압축 해제
step "$MSG_STEP_EXTRACT"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_TAR_FILE" -C "$INSTALL_DIR" --strip-components=1 || {
  error "$MSG_ERR_EXTRACT"; exit 1;
}
rm -f "$TMP_TAR_FILE"
log "$(printf "$MSG_DONE_INSTALL_DIR" "$INSTALL_DIR")"

# 3단계: 사용자 shell 설정 파일 감지
step "$MSG_STEP_SHELL"
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
log "$(printf "$MSG_DONE_RCFILE" "$RC_FILE")"

# 4단계: 자동 초기화 및 alias 추가
step "$MSG_STEP_INIT"
if ! grep '.direnv/src/init.sh' "$RC_FILE" >/dev/null 2>&1; then
  printf '\n# Direnv auto-initialization\n[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh\nalias de=". \$HOME/.direnv/src/init.sh"\n' >> "$RC_FILE"
  log "$MSG_DONE_INIT_ADDED"
else
  log "$MSG_DONE_INIT_EXISTS"
fi

# 완료 메시지
log "$MSG_DONE_COMPLETE"
exit 0
