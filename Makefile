.PHONY: release release-patch release-minor release-major test

# 🔄 테스트 실행
# 사용법: make test
test:
	@echo "🔍 Running direnv environment loading tests..."
	@sh test/test_load_current_dir_env.sh

# 📦 릴리즈 - Semantic Versioning
# 사용법:
#   make release-patch  # 버그 수정 (v0.1.1 -> v0.1.2)
#   make release-minor  # 새 기능 (v0.1.1 -> v0.2.0)
#   make release-major  # 하위 호환 깨지는 변경 (v0.1.1 -> v1.0.0)

release-patch:
	@./release.sh patch

release-minor:
	@./release.sh minor

release-major:
	@./release.sh major

# 📦 레거시 릴리즈 (deprecated)
# 사용법: make release VERSION=v0.0.11
# ⚠️  대신 release-patch/minor/major를 사용하세요
release:
	@echo "⚠️  경고: 이 명령어는 deprecated 되었습니다."
	@echo "대신 다음을 사용하세요:"
	@echo "  make release-patch  # 버그 수정"
	@echo "  make release-minor  # 새 기능"
	@echo "  make release-major  # Breaking change"
	@echo ""
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ VERSION을 지정해주세요. 예: make release VERSION=v0.1.2"; \
		exit 1; \
	fi
	@./release.sh $(VERSION)
