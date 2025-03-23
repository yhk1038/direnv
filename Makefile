.PHONY: release test

# 🔄 테스트 실행
# 사용법: make test
test:
	@echo "🔍 Running direnv environment loading tests..."
	@sh test/test_load_current_dir_env.sh

# 📦 릴리즈용 zip 압축 생성
# 사용법: make release VERSION=v0.0.11
release:
	./release.sh $(VERSION)
