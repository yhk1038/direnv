# Git Commit Guidelines

이 문서는 direnv 프로젝트의 커밋 규칙을 정의합니다.

---

## 커밋 메시지 형식

이 프로젝트는 **Conventional Commits 기반의 영어 커밋 메시지**를 사용하되, 일부 예외를 허용합니다.

### 기본 형식

```
<type>: <description>

또는

<description> (타입 없이, 간단한 업데이트의 경우)
```

---

## 커밋 타입 (Type)

### 필수 타입 (중요한 변경사항)

다음 타입은 **반드시 사용**해야 합니다:

| 타입 | 사용 시점 | 예시 |
|------|----------|------|
| `feat:` | 새로운 기능 추가 | `feat: add 'df' alias to clean up tmp directory files` |
| `fix:` | 버그 수정 | `fix: prevent env loading when in home directory` |
| `test:` | 테스트 추가 또는 수정 | `test: Add first test` |
| `ci:` | CI/CD 설정 변경 | `ci: add GitHub Actions workflow for testing` |
| `chore:` | 기타 변경 (빌드, 설정 등) | `chore: suppress error output when restoring env vars from backup` |

### 선택적 타입

다음은 필요 시 사용 가능:

| 타입 | 사용 시점 | 예시 |
|------|----------|------|
| `docs:` | 문서 변경 | `docs: update README with new installation steps` |
| `refactor:` | 코드 리팩토링 (기능 변경 없음) | `refactor: simplify alias backup logic` |
| `perf:` | 성능 개선 | `perf: optimize environment variable loading` |

---

## 커밋 메시지 작성 규칙

### 1. 설명 (Description)

- **영어로 작성**
- **소문자로 시작** (첫 글자를 대문자로 하지 않음)
- **명령형 동사 사용** (add, fix, update 등)
- **마침표(.)를 붙이지 않음**
- **간결하고 명확하게** (50자 이내 권장)

**좋은 예시**:
```
feat: add 'df' alias to clean up tmp directory files
fix: restrict env loading to home directory subtree
chore: suppress error output when restoring env vars from backup
```

**나쁜 예시**:
```
Feat: Add new feature.  ❌ (대문자 시작, 마침표 있음)
added df alias  ❌ (타입 없음 - feat:을 사용해야 함)
Fix bug  ❌ (설명이 너무 불명확)
```

### 2. 타입 생략 가능한 경우

**간단한 업데이트**나 **자명한 변경**은 타입 없이 작성 가능:

```
Update ko.lang
Update detect-language.sh
Set default readme to eng
Remove code archiving comments
```

**주의**: 타입을 생략할 때는 다음을 확인:
- 변경사항이 단순한가? (예: 파일명 업데이트, 주석 제거 등)
- 설명만으로도 무엇을 했는지 명확한가?
- 기능 추가나 버그 수정처럼 중요한 변경이 **아닌가**?

### 3. 범위 (Scope) 명시

파일이나 모듈을 명시하고 싶을 때 `타입: 범위 / 설명` 형식 사용:

```
fix: install.sh / LANG_CODE should not contain double quote
fix: locale / add single quotation to fix loading error
```

또는 단순히 설명에 포함:

```
load script / Ignore backup alias in week case
unload script / Use while loop Instead of for loop (meaningful IFS)
```

---

## 특수 커밋: 버전 업데이트

버전 업데이트는 **별도의 커밋**으로 생성:

```
Update version: v0.1.1
Update version: v0.1.0
```

**규칙**:
- 타입 없음 (단순히 `Update version:`)
- 버전은 `vX.Y.Z` 형식
- 다른 변경사항과 함께 커밋하지 않음 (버전 업데이트는 항상 별도 커밋)

---

## 커밋 작성 프로세스

### 1. 변경사항 분류

커밋하기 전에 변경사항을 다음 기준으로 분류:

| 변경 유형 | 커밋 타입 |
|----------|----------|
| 새 기능 추가 | `feat:` |
| 버그 수정 | `fix:` |
| 테스트 추가/수정 | `test:` |
| CI/CD 변경 | `ci:` |
| 문서 업데이트 | `docs:` 또는 `Update [파일명]` |
| 에러 억제, 로깅 개선 등 | `chore:` |
| 리팩토링 | `refactor:` |
| 간단한 파일 업데이트 | 타입 없이 `Update [파일명]` |

### 2. 여러 변경사항이 있는 경우

**의미 단위로 분리하여 커밋**:

```bash
# ❌ 나쁜 예 (여러 변경을 한 커밋에)
git commit -m "feat: add df alias and fix install.sh bug"

# ✅ 좋은 예 (분리된 커밋)
git commit -m "feat: add 'df' alias to clean up tmp directory files"
git commit -m "fix: install.sh / LANG_CODE should not contain double quote"
```

### 3. 커밋 전 체크리스트

```markdown
[ ] 테스트 실행 (`make test`) - 모든 테스트 통과 확인
[ ] POSIX 호환성 준수 확인
[ ] 커밋 메시지가 영어로 작성되었는지 확인
[ ] 커밋 타입이 적절한지 확인 (중요한 변경은 타입 필수)
[ ] 설명이 명확하고 간결한지 확인 (50자 이내)
[ ] 소문자로 시작하고 마침표가 없는지 확인
```

---

## 커밋 예시 모음

### 기능 추가 (feat:)

```
feat: add 'df' alias to clean up tmp directory files
feat: support Japanese language in install script
feat: add automatic backup restoration on error
```

### 버그 수정 (fix:)

```
fix: prevent env loading when in home directory
fix: restrict env loading to home directory subtree
fix: install.sh / LANG_CODE should not contain double quote
fix: triple single quote in alias parsing
```

### 테스트 (test:)

```
test: Add first test
test: add test case for alias backup mechanism
test: verify env loading blocked outside home directory
```

### CI/CD (ci:)

```
ci: add GitHub Actions workflow for testing
ci: update release workflow to include zip files
ci: add automatic version tagging on release
```

### 기타 작업 (chore:)

```
chore: suppress error output when restoring env vars from backup
chore: clean up deprecated comments in release script
chore: update .gitignore for tmp files
```

### 간단한 업데이트 (타입 없음)

```
Update ko.lang
Update detect-language.sh
Create en.lang
Set default readme to eng
Remove code archiving comments
```

### 범위가 명시된 경우

```
load script / Ignore backup alias in weak case
unload script / Use while loop Instead of for loop (meaningful IFS)
```

---

## 안티패턴 (피해야 할 것)

❌ **절대 하지 말아야 할 것**:

```
# 1. 한글 커밋 메시지
기능/ df 별칭 추가  ❌

# 2. 대문자로 시작 + 마침표
Fix: Bug in install script.  ❌

# 3. 불명확한 설명
fix: bug  ❌
update: changes  ❌
chore: stuff  ❌

# 4. 여러 변경사항을 하나로
feat: add df alias, fix install.sh, update lang files  ❌

# 5. 버전 업데이트를 다른 변경과 함께
feat: add new feature
Update version: v0.1.0  ❌
```

---

## 릴리즈 워크플로우

릴리즈 시 다음 순서를 따름:

```bash
# 1. 기능 개발 및 커밋
git commit -m "feat: add new feature"
git commit -m "fix: fix bug in feature"

# 2. 버전 업데이트 (별도 커밋)
echo "v0.1.2" > VERSION
git add VERSION
git commit -m "Update version: v0.1.2"

# 3. 태그 및 푸시 (release.sh가 자동으로 처리)
./release.sh v0.1.2
```

---

## 참고: Conventional Commits

이 프로젝트는 [Conventional Commits](https://www.conventionalcommits.org/) 스펙을 기반으로 하되, 다음과 같은 차이점이 있습니다:

| 항목 | Conventional Commits | 이 프로젝트 |
|------|---------------------|-----------|
| 언어 | 영어 | 영어 |
| 타입 필수 여부 | 필수 | 중요한 변경사항만 필수 |
| 첫 글자 | 소문자 | 소문자 |
| 범위 (scope) | `type(scope):` | `type: scope /` 또는 생략 |
| 간단한 업데이트 | 타입 필수 | 타입 생략 가능 |

---

## 변경 이력

- **2025-10-22**: 초안 작성 - 기존 커밋 히스토리 분석 및 규칙 문서화
