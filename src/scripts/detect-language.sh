#!/bin/sh

# 언어 감지 (기본: 영어)
LANG_CODE=$(locale 2>/dev/null | grep -E '^LANG=' | cut -d= -f2 | cut -d_ -f1 | sed 's/\"//g')
LANG_CODE=${LANG_CODE:-en}

# 지원 언어 확인 (지원되지 않으면 en 으로 fallback)
case "$LANG_CODE" in
  en|ko|ja) ;;  # 지원하는 언어 목록
  *) LANG_CODE="en" ;;
esac

LANG_FILE="$HOME/.direnv/src/lang/${LANG_CODE}.lang"
[ -f "$LANG_FILE" ] && . "$LANG_FILE" || {
  echo "[direnv] ⚠️  No language file found for '$LANG_CODE', falling back to English."
  LANG_FILE="$HOME/.direnv/src/lang/en.lang"
  [ -f "$LANG_FILE" ] && . "$LANG_FILE"
}
