#!/bin/sh

# 사용법: ./release.sh [patch|minor|major]
#
# 💡 Semantic versioning을 사용하여 자동으로 버전을 증가시킵니다.
# - patch: v0.1.1 -> v0.1.2 (버그 수정)
# - minor: v0.1.1 -> v0.2.0 (새 기능 추가, 하위 호환)
# - major: v0.1.1 -> v1.0.0 (하위 호환성 깨지는 변경)

set -e

BUMP_TYPE="$1"

# 현재 버전 읽기
if [ ! -f "./src/VERSION" ]; then
  echo "❌ VERSION 파일을 찾을 수 없습니다."
  exit 1
fi

CURRENT_VERSION=$(cat ./src/VERSION)
echo "📌 현재 버전: $CURRENT_VERSION"

# v 접두사 제거
VERSION_NUMBER="${CURRENT_VERSION#v}"

# 버전 파싱 (major.minor.patch)
MAJOR=$(echo "$VERSION_NUMBER" | cut -d. -f1)
MINOR=$(echo "$VERSION_NUMBER" | cut -d. -f2)
PATCH=$(echo "$VERSION_NUMBER" | cut -d. -f3)

# 버전 증가
case "$BUMP_TYPE" in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    echo "❌ 사용법: ./release.sh [patch|minor|major]"
    echo ""
    echo "예시:"
    echo "  ./release.sh patch  # $CURRENT_VERSION -> v$MAJOR.$MINOR.$((PATCH + 1))"
    echo "  ./release.sh minor  # $CURRENT_VERSION -> v$MAJOR.$((MINOR + 1)).0"
    echo "  ./release.sh major  # $CURRENT_VERSION -> v$((MAJOR + 1)).0.0"
    exit 1
    ;;
esac

NEW_VERSION="v$MAJOR.$MINOR.$PATCH"
echo "🚀 새 버전: $NEW_VERSION"

# 사용자 확인
printf "계속하시겠습니까? (y/N): "
read -r CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "❌ 취소되었습니다."
  exit 1
fi

echo "🔖 Git 태그 생성 및 푸시"
printf "%s" "$NEW_VERSION" > ./src/VERSION
git add .
git commit -m "Update version: $NEW_VERSION"
git tag "$NEW_VERSION"
git push
git push origin "$NEW_VERSION"

echo "✅ 릴리즈 완료: $NEW_VERSION"

#PROJECT_NAME="direnv"
#ARCHIVE_NAME="${PROJECT_NAME}-${VERSION}.tar.gz"
#
#if [ -z "$VERSION" ]; then
#  echo "🔺 버전 태그를 입력하세요. 예: ./release.sh v1.0.0"
#  exit 1
#fi
#
#echo "📦 압축 파일 생성 중: $ARCHIVE_NAME"
#tar -czf ./dist/"$ARCHIVE_NAME" ./src
#
#echo "🔖 Git 태그 생성 및 푸시"
#git add "./VERSION"
#git commit -m "Update version: $VERSION"
#git tag "$VERSION"
#git push origin "$VERSION"
#
#echo "🚀 GitHub 릴리즈 등록 중"
#gh release create "$VERSION" "$ARCHIVE_NAME" \
#  --title "$VERSION Release" \
#  --notes "버전 $VERSION 릴리즈입니다."
#
#echo "✅ 완료! GitHub 릴리즈에 파일이 업로드되었습니다."
