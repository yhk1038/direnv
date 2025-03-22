#!/bin/sh

# -----------------------------
# Direnv 설치 스크립트
# - ~/.direnv 디렉토리에 설치
# - shell rc 파일에 alias 추가
# -----------------------------

VERSION="$(curl -fsSL https://raw.githubusercontent.com/yhk1038/direnv/main/VERSION)"
TAR_URL="https://github.com/yhk1038/direnv/releases/download/$VERSION/direnv-$VERSION.tar.gz"
INSTALL_DIR="$HOME/.direnv"
TMP_TAR_FILE="/tmp/direnv.tar.gz"

# 출력 유틸
log() { printf "\033[1;32m[✔]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[✘]\033[0m %s\n" "$1" >&2; }
step() { printf "\n\033[1;34m▶ %s\033[0m\n" "$1"; }

step "1. 소스코드 다운로드 중... ($VERSION)"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$TAR_URL" -o "$TMP_TAR_FILE" || {
    error "다운로드 실패 (curl)"; exit 1;
  }
elif command -v wget >/dev/null 2>&1; then
  wget -q "$TAR_URL" -O "$TMP_TAR_FILE" || {
    error "다운로드 실패 (wget)"; exit 1;
  }
else
  error "curl 또는 wget이 필요합니다. 설치 후 다시 시도해주세요."
  exit 1
fi
log "다운로드 완료"

step "2. 압축 해제 중..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_TAR_FILE" -C "$INSTALL_DIR" --strip-components=1 || {
  error "압축 해제 실패"; exit 1;
}
rm -f "$TMP_TAR_FILE"
log "설치 디렉토리: $INSTALL_DIR"

step "3. 사용자 shell 환경 감지 중..."
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

case "$SHELL_NAME" in
  bash)
    RC_FILE="$HOME/.bashrc"
    [ ! -f "$RC_FILE" ] && RC_FILE="$HOME/.bash_profile"
    ;;
  zsh)
    RC_FILE="$HOME/.zshrc"
    ;;
  ksh)
    RC_FILE="$HOME/.kshrc"
    ;;
  *)
    RC_FILE="$HOME/.profile"
    ;;
esac
log "감지된 shell rc 파일: $RC_FILE"

step "4. alias 추가 중..."
if ! grep 'alias de=' "$RC_FILE" >/dev/null 2>&1; then
  printf '\n# Direnv alias\nalias de=". \$HOME/.direnv/src/init.sh"\n' >> "$RC_FILE"
  log "alias 'de' 추가 완료"
else
  log "이미 alias 'de'가 등록되어 있습니다."
fi

log "🎉 설치가 완료되었습니다! 새로운 터미널에서 'de'를 실행해보세요."
exit 0
