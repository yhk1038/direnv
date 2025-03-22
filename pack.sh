#!/bin/sh

VERSION="$1"
PROJECT_NAME="direnv"
ARCHIVE_NAME="${PROJECT_NAME}-${VERSION}.tar.gz"

echo "📦 압축 파일 생성 중: $ARCHIVE_NAME"
tar -czf ./dist/"$ARCHIVE_NAME" ./src
