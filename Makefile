.PHONY: release release-patch release-minor release-major test

# 🔄 테스트 실행
# 사용법: make test
test:
	@echo "=========================================="
	@echo "🔍 Running direnv test suite"
	@echo "=========================================="
	@echo ""
	@echo "Running: test_load_current_dir_env.sh"
	@sh test/test_load_current_dir_env.sh
	@echo ""
	@echo "Running: test_cd_error_fix.sh"
	@sh test/test_cd_error_fix.sh
	@echo ""
	@echo "Running: test_backup_restore_mechanism.sh"
	@sh test/test_backup_restore_mechanism.sh
	@echo ""
	@echo "Running: test_unload_current_dir_env.sh"
	@sh test/test_unload_current_dir_env.sh
	@echo ""
	@echo "Running: test_directory_changed_hook.sh"
	@sh test/test_directory_changed_hook.sh
	@echo ""
	@echo "Running: test_secure_install.sh"
	@sh test/test_secure_install.sh
	@echo ""
	@echo "Running: test_disable_enable.sh"
	@bash test/test_disable_enable.sh
	@echo ""
	@echo "Running: test_unload_path_safety.sh"
	@sh test/test_unload_path_safety.sh
	@echo ""
	@echo "Running: test_e2e_workflow.sh"
	@bash test/test_e2e_workflow.sh
	@echo ""
	@echo "=========================================="
	@echo "✅ All tests completed!"
	@echo "=========================================="

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
