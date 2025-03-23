#!/bin/sh

# 현재 사용자의 HOME 디렉토리
REAL_HOME="$HOME"
FAILED=0

# 테스트 대상 함수
should_load_env() {
  local test_dir="$1"
  local expected="$2"
  export PWD="$test_dir"

  if [ "$PWD" = "$REAL_HOME" ]; then
    if [ "$expected" = "block" ]; then
      echo "✅ (PASS) Blocked as expected: $PWD"
    else
      echo "❌ (FAIL) Unexpectedly blocked: $PWD"
      FAILED=1
    fi
    return
  fi

  case "$PWD" in
    "$REAL_HOME"/*)
      if [ "$expected" = "allow" ]; then
        echo "✅ (PASS) Allowed as expected: $PWD"
      else
        echo "❌ (FAIL) Unexpectedly allowed: $PWD"
        FAILED=1
      fi
      ;;
    *)
      if [ "$expected" = "block" ]; then
        echo "✅ (PASS) Blocked as expected: $PWD"
      else
        echo "❌ (FAIL) Unexpectedly blocked: $PWD"
        FAILED=1
      fi
      ;;
  esac
}

# 테스트 케이스 목록 (빈 줄 방지)
TEST_CASES=$(cat <<EOF
/Users/Shared/Relocated Items|block
$REAL_HOME|block
$REAL_HOME/tmp|allow
$REAL_HOME/Projects|allow
$REAL_HOME/Projects/Atoz/payplo/api|allow
EOF
)

echo "🧪 Running environment loading tests for HOME=$REAL_HOME..."
echo

# 루프 실행 (서브셸이 아닌 리디렉션 방식 + 빈 줄 제거)
while IFS='|' read path expectation; do
  should_load_env "$path" "$expectation"
done <<EOF
$(echo "$TEST_CASES" | awk NF)
EOF

echo
if [ "$FAILED" -eq 0 ]; then
  echo "✅ All tests passed!"
else
  echo "❌ Some tests failed."
fi

# 조건부 종료 코드 (CI에서만 실패 시 1)
if [ "$CI" = "true" ]; then
  exit "$FAILED"
else
  exit 0
fi
