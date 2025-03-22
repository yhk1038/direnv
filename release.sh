#!/bin/sh

# 사용법: ./release.sh v1.0.0
#
# 💡 이 스크립트를 프로젝트 루트에 두고 실행 전에 chmod +x release.sh로 실행 권한 주세요.

set -e

VERSION="$1"
echo "🔖 Git 태그 생성 및 푸시"
echo "$VERSION" > ./VERSION
git add .
git commit -m "Update version: $VERSION"
git tag "$VERSION"
git push origin "$VERSION"
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
