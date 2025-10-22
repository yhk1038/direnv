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

# 출력 유틸리티 함수
log() { printf "\033[1;32m[✔]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[✘]\033[0m %s\n" "$1" >&2; }
step() { printf "\n\033[1;34m▶ %s\033[0m\n" "$1"; }

# 설치 버전과 URL 설정
# VERSION 환경변수가 설정되어 있지 않으면 최신 버전을 가져옴
if [ -z "$VERSION" ]; then
  VERSION="$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/src/VERSION)"
fi
TAR_URL="https://github.com/yhk1038/direnv/releases/download/$VERSION/direnv-$VERSION.tar.gz"
INSTALL_DIR="$HOME/.direnv"
TMP_TAR_FILE="/tmp/direnv.tar.gz"

# 1단계: 다운로드 (언어 파일 없이 하드코딩 메시지 사용)
step "Downloading direnv $VERSION..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$TAR_URL" -o "$TMP_TAR_FILE" || {
    error "Failed to download using curl"; exit 1;
  }
elif command -v wget >/dev/null 2>&1; then
  wget -q "$TAR_URL" -O "$TMP_TAR_FILE" || {
    error "Failed to download using wget"; exit 1;
  }
else
  error "curl or wget is required"; exit 1;
fi
log "Download complete"

# 2단계: 압축 해제
step "Extracting files..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_TAR_FILE" -C "$INSTALL_DIR" --strip-components=1 || {
  error "Failed to extract files"; exit 1;
}
rm -f "$TMP_TAR_FILE"

# 2-1단계: 언어 파일 로드 (추출 후)
LANG_FILE="$INSTALL_DIR/src/lang/${LANG_CODE}.lang"
if [ -f "$LANG_FILE" ]; then
  . "$LANG_FILE"
elif [ -f "$INSTALL_DIR/src/lang/en.lang" ]; then
  . "$INSTALL_DIR/src/lang/en.lang"
else
  echo "[direnv] ⚠️  Language file not found, using fallback messages"
fi

log "$(printf "$MSG_DONE_INSTALL_DIR" "$INSTALL_DIR")"

# 2-1단계: uninstall.sh 다운로드
UNINSTALL_URL="https://raw.githubusercontent.com/yhk1038/direnv/main/uninstall.sh"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$UNINSTALL_URL" -o "$INSTALL_DIR/uninstall.sh" 2>/dev/null
elif command -v wget >/dev/null 2>&1; then
  wget -q "$UNINSTALL_URL" -O "$INSTALL_DIR/uninstall.sh" 2>/dev/null
fi
chmod +x "$INSTALL_DIR/uninstall.sh" 2>/dev/null

# 3단계: 사용자 shell 설정 파일 감지
step "${MSG_STEP_SHELL:-Detecting shell configuration file...}"
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
log "$(printf "${MSG_DONE_RCFILE:-Shell configuration file: %s}" "$RC_FILE")"

# 4단계: 자동 초기화 설정
step "${MSG_STEP_INIT:-Setting up auto-initialization...}"
if ! grep '.direnv/src/init.sh' "$RC_FILE" >/dev/null 2>&1; then
  printf '\n# Direnv auto-initialization\n[ -f ~/.direnv/src/init.sh ] && source ~/.direnv/src/init.sh\n' >> "$RC_FILE"
  log "${MSG_DONE_INIT_ADDED:-Auto-initialization added}"
else
  log "${MSG_DONE_INIT_EXISTS:-Auto-initialization already exists}"
fi

# 완료 메시지
log "${MSG_DONE_COMPLETE:-Installation complete!}"
printf "\n%s\n\n" "${MSG_OR_RUN_NOW:-Restart your terminal or run:}"
printf "      source %s\n" "$RC_FILE"
echo ""
echo ""
exit 0
