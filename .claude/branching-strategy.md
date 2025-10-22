# 브랜치 전략
# Branching Strategy

**최종 업데이트**: 2025-10-22

---

## 개요

이 문서는 에이전트 중심 협업을 위한 **자동화된 브랜치 전략**을 정의합니다.

**핵심 원칙**:
- 모든 브랜치는 `feat/` 접두사로 시작
- 부모-자식 작업 구조 지원 (Task - Subtask 재귀 구조)
- 모든 브랜치는 PR을 통해 부모 브랜치로 병합
- 부모 브랜치 병합 시 사용자 승인 필수

---

## 브랜치 네이밍 컨벤션

### 최상위 작업 브랜치

```
feat/[task-name]

예시:
- feat/japanese-lang-support
- feat/performance-optimization
- feat/env-backup-improvement
```

### 서브태스크 브랜치

```
feat/[parent-task]/[subtask-name]

예시:
- feat/japanese-lang-support/install-script
- feat/japanese-lang-support/lang-file
- feat/performance-optimization/load-script
- feat/performance-optimization/alias-caching
```

### 브랜치 네이밍 규칙

- **소문자만 사용**
- **단어 구분은 하이픈(`-`)** 사용
- **간결하고 명확하게** (2-4단어 권장)
- **동사-명사 조합** 권장 (예: `add-korean-lang`, `fix-backup-bug`)

**좋은 예**:
```
feat/add-korean-lang
feat/fix-alias-backup
feat/improve-loading-speed
feat/japanese-support/install-updates
```

**나쁜 예**:
```
feat/KoreanLanguage          (대문자 사용)
feat/add_korean_language     (언더스코어 사용)
feat/temporary-fix-123       (의미 불명확)
feat/feature                 (너무 모호함)
```

---

## 작업 유형별 브랜치 전략

### 1. 최상위 작업 (부모가 없는 작업)

최상위 작업은 `main` 브랜치에서 직접 분기합니다.

#### 작업 플로우

```bash
# 1. main 브랜치로 이동
git checkout main
git pull origin main

# 2. 플래닝 진행 (에이전트가 자동으로 수행)
# - .claude/tasks/ 에 작업 문서 작성
# - 목표, 범위, 기술적 접근 방법 등 문서화

# 3. 플래닝 문서 커밋 및 푸시 (main에 직접)
git add .claude/tasks/XX-task-name.md
git commit -m "docs: add task document for [작업명]"
git push origin main

# 4. 피쳐 브랜치 생성 및 체크아웃
git checkout -b feat/task-name

# 5. 작업 진행
# - 코드 작성
# - 의미 단위로 커밋
# - 문서 업데이트 (별도 커밋)

# 6. 피쳐 브랜치 푸시
git push -u origin feat/task-name
```

#### 왜 플래닝 문서를 main에 먼저 푸시하나요?

**이유**:
1. **빠른 공유**: 다른 개발자가 즉시 작업 계획을 확인 가능
2. **중복 방지**: 다른 팀원이 동일한 작업을 시작하는 것을 방지
3. **명확한 기록**: 프로젝트 히스토리에 계획이 먼저 기록됨
4. **협업 촉진**: 팀원이 피드백을 빠르게 제공 가능

#### 플래닝 단계에서 하는 일

- 작업 목표 및 범위 정의
- 기술적 접근 방법 설계
- 관련 파일 및 스크립트 식별
- 예상 이슈 및 해결 방안
- 하위 태스크 분해 (필요시)

---

### 2. 서브태스크 (부모 작업이 있는 작업)

서브태스크는 기본적으로 **부모 브랜치 내에서** 작업합니다.

#### 언제 서브 브랜치를 생성하나요?

서브 브랜치 생성은 **선택사항**입니다. 다음 경우에만 생성을 고려하세요:

**서브 브랜치 생성이 필요한 경우**:
- ✅ 작업이 **복잡**하고 여러 커밋이 필요
- ✅ 변경 범위가 **크고 위험**해서 격리가 필요
- ✅ 다른 팀원과 **병렬로 작업**해야 함
- ✅ **실험적 구현**이 필요하여 안전하게 테스트하고 싶음

**서브 브랜치가 불필요한 경우**:
- ❌ 간단한 버그 수정 또는 문서 변경
- ❌ 단일 파일 또는 단일 스크립트 수정
- ❌ 즉시 완료 가능한 작은 작업

#### 서브 브랜치 없이 작업 (기본)

```bash
# 1. 부모 브랜치에서 작업
git checkout feat/parent-task

# 2. 작업 진행
# - 코드 작성
# - 커밋

# 3. 부모 브랜치에 푸시
git push origin feat/parent-task
```

#### 서브 브랜치 생성하여 작업

```bash
# 1. 부모 브랜치 확인
git checkout feat/parent-task
git pull origin feat/parent-task

# 2. 서브 브랜치 생성
git checkout -b feat/parent-task/subtask-name

# 3. 작업 진행
# - 코드 작성
# - 의미 단위로 커밋

# 4. 서브 브랜치 푸시
git push -u origin feat/parent-task/subtask-name

# 5. PR 생성 (부모 브랜치로)
gh pr create --base feat/parent-task --head feat/parent-task/subtask-name \
  --title "Subtask: [서브태스크명]" \
  --body "부모 작업: feat/parent-task"

# 6. 사용자 승인 후 병합
# (에이전트가 사용자에게 승인 요청)

# 7. 병합 완료 후 서브 브랜치 삭제
git branch -d feat/parent-task/subtask-name
git push origin --delete feat/parent-task/subtask-name
```

---

## PR 생성 및 병합 규칙

### 기본 원칙

- **모든 브랜치는 PR을 통해 병합** (직접 merge 금지)
- **서브태스크 → 부모 브랜치로 PR**
- **최상위 작업 → main 브랜치로 PR**
- **부모 브랜치 병합 시 사용자 승인 필수**

### PR 생성

#### 서브태스크 → 부모 브랜치 PR

```bash
gh pr create \
  --base feat/parent-task \
  --head feat/parent-task/subtask-name \
  --title "Subtask: [서브태스크 설명]" \
  --body "$(cat <<'EOF'
## 서브태스크 개요
[서브태스크가 하는 일 설명]

## 변경 사항
- [변경사항 1]
- [변경사항 2]

## 테스트
- [테스트 내용]

## 부모 작업
feat/parent-task

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

#### 최상위 작업 → main PR

```bash
gh pr create \
  --base main \
  --head feat/task-name \
  --title "[작업명]" \
  --body "$(cat <<'EOF'
## Summary
- [주요 변경사항 1]
- [주요 변경사항 2]

## 관련 작업 문서
[.claude/tasks/XX-task-name.md](.claude/tasks/XX-task-name.md)

## Test plan
- [ ] make test 통과
- [ ] 로컬 환경에서 정상 동작 확인
- [ ] [추가 테스트 항목]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### 사용자 승인 확인

**중요**: 부모 브랜치로 병합할 때는 **반드시 사용자에게 승인을 요청**합니다.

#### 에이전트의 승인 요청 프로세스

```
1. PR 생성 완료 안내:
   "PR을 생성했습니다: [PR URL]"

2. 승인 여부 확인:
   "이 PR을 [부모 브랜치명]에 병합하시겠습니까?

   변경 사항:
   - [주요 변경사항 요약]

   병합하려면 '예' 또는 '병합'이라고 답변해주세요.
   검토가 더 필요하면 '나중에'라고 답변해주세요."

3. 사용자 응답에 따라:
   - "예" / "병합" → PR 병합 진행
   - "나중에" / "보류" → 병합 중단, PR은 열린 상태로 유지
   - 명확하지 않은 응답 → 다시 확인
```

#### 자동 병합 가능한 경우 (예외)

다음 경우에는 자동으로 병합해도 됩니다:

- ✅ **문서만 변경**하는 PR (코드 변경 없음)
- ✅ **명백한 오타 수정** (typo fix)
- ✅ **주석 추가/수정**

이 경우에도 사용자에게 **안내는 필수**:
```
"문서만 변경하는 PR이므로 자동으로 병합하겠습니다: [PR URL]"
```

### PR 병합 절차

```bash
# 1. PR이 병합 가능한지 확인
gh pr checks [PR번호]

# 2. 사용자 승인 후 병합
gh pr merge [PR번호] --squash --delete-branch

# 3. 병합 완료 안내
echo "PR이 [부모 브랜치명]에 병합되었습니다."
echo "로컬 브랜치 [브랜치명]이 삭제되었습니다."
```

### 병합 완료 후 브랜치 삭제

PR 병합이 완료되면, **반드시** 사용자에게 브랜치 삭제 여부를 확인합니다.

#### 에이전트의 브랜치 삭제 확인 프로세스

```
1. 병합 완료 안내:
   "PR이 성공적으로 병합되었습니다: [PR URL]
    브랜치 [브랜치명]이 로컬에서 삭제되었습니다."

2. 원격 브랜치 삭제 확인:
   "원격 저장소(origin)의 브랜치도 삭제하시겠습니까?

    브랜치명: [브랜치명]

    삭제하려면 '예' 또는 '삭제'라고 답변해주세요.
    남겨두려면 '아니오' 또는 '유지'라고 답변해주세요."

3. 사용자 응답에 따라:
   - "예" / "삭제" → 원격 브랜치 삭제 실행
   - "아니오" / "유지" → 원격 브랜치 유지
   - 명확하지 않은 응답 → 다시 확인
```

#### 원격 브랜치 삭제 실행

```bash
# 사용자가 삭제에 동의한 경우
git push origin --delete [브랜치명]

# 삭제 완료 안내
echo "원격 브랜치 origin/[브랜치명]이 삭제되었습니다."
```

#### 브랜치 삭제 체크리스트

```markdown
[ ] PR 병합 완료
[ ] 로컬 브랜치 삭제 완료 (gh pr merge --delete-branch)
[ ] 사용자에게 원격 브랜치 삭제 여부 확인
[ ] (승인 시) 원격 브랜치 삭제 완료
[ ] 삭제 완료 안내
```

#### 브랜치 삭제 예외

다음 경우에는 **브랜치를 삭제하지 않습니다**:

- ❌ `main` 브랜치
- ❌ 사용자가 명시적으로 유지를 요청한 경우
- ❌ 장기 운영되는 feature 브랜치 (사용자 확인 필요)

---

## 문서 커밋 규칙

### 문서는 독립적으로 커밋

문서 변경사항은 **코드와 별도로 커밋**합니다.

**이유**:
- 문서와 코드는 다른 목적을 가짐
- 문서는 자주 업데이트되며, 커밋 히스토리를 깔끔하게 유지
- 문서만 빠르게 수정하고 푸시 가능

**좋은 예**:
```bash
# 커밋 1: 문서 작성
git add .claude/tasks/01-japanese-lang-support.md
git commit -m "docs: add task document for Japanese language support"

# 커밋 2: 기능 구현
git add src/lang/ja.lang
git commit -m "feat: add Japanese language file"

# 커밋 3: 문서 업데이트
git add .claude/tasks/01-japanese-lang-support.md
git commit -m "docs: update progress log for Japanese language support"
```

**나쁜 예**:
```bash
# 문서와 코드를 함께 커밋
git add .claude/tasks/01-japanese-lang-support.md src/lang/ja.lang
git commit -m "feat: add Japanese language support with documentation"
```

### 작업 중 문서 업데이트

작업을 진행하면서 문서를 수시로 업데이트하고 커밋합니다:

```bash
# 작업 진행 중간에 발견한 이슈를 문서에 기록
git add .claude/tasks/01-japanese-lang-support.md
git commit -m "docs: record issues found during Japanese language implementation"

# 기술적 결정사항을 문서에 추가
git add .claude/tasks/01-japanese-lang-support.md
git commit -m "docs: document technical decisions for language detection"
```

---

## 브랜치 병합 플로우 다이어그램

```
main
 │
 ├─ (문서 커밋) feat/task-A 플래닝 문서
 │
 └─ feat/task-A (최상위 작업)
     │
     ├─ (직접 작업) 간단한 변경사항들
     │
     ├─ feat/task-A/subtask-1 (복잡한 서브태스크)
     │   └─ PR → feat/task-A 병합
     │
     ├─ feat/task-A/subtask-2 (또 다른 서브태스크)
     │   └─ PR → feat/task-A 병합
     │
     └─ PR → main 병합
```

---

## 실전 예시

### 예시 1: 최상위 작업 - 일본어 언어 지원 추가

```bash
# 1. main에서 플래닝
git checkout main
git pull origin main

# 2. 작업 문서 작성
# .claude/tasks/01-japanese-lang-support.md 생성

# 3. 문서 커밋 및 푸시
git add .claude/tasks/01-japanese-lang-support.md
git commit -m "docs: add task document for Japanese language support"
git push origin main

# 4. 피쳐 브랜치 생성
git checkout -b feat/japanese-lang-support

# 5. 작업 진행
# - 언어 파일 추가
git add src/lang/ja.lang
git commit -m "feat: add Japanese language file"

# - install.sh 업데이트
git add install.sh
git commit -m "feat: add Japanese to supported languages in install script"

# - README 업데이트
git add README.md
git commit -m "docs: update README with Japanese language support"

# 6. 푸시
git push -u origin feat/japanese-lang-support

# 7. PR 생성
gh pr create --base main --head feat/japanese-lang-support \
  --title "feat: add Japanese language support" \
  --body "..."

# 8. 사용자 승인 확인
# "이 PR을 main에 병합하시겠습니까?"

# 9. 승인 후 병합 (로컬 브랜치 자동 삭제)
gh pr merge --squash --delete-branch

# 10. 원격 브랜치 삭제 확인
# "원격 저장소(origin)의 브랜치도 삭제하시겠습니까?"

# 11. 사용자가 "예"라고 답하면 원격 브랜치 삭제
git push origin --delete feat/japanese-lang-support
```

### 예시 2: 서브태스크가 있는 복잡한 작업

```bash
# 1. main에서 플래닝 (동일)
git checkout main
# ... 문서 작성 및 커밋 ...
git push origin main

# 2. 피쳐 브랜치 생성
git checkout -b feat/performance-optimization

# 3. 간단한 작업은 직접 진행
git add src/scripts/load_current_dir_env.sh
git commit -m "perf: optimize alias backup logic"
git push origin feat/performance-optimization

# 4. 복잡한 서브태스크는 별도 브랜치
git checkout -b feat/performance-optimization/caching-mechanism

# 서브태스크 작업...
git add src/scripts/cache_manager.sh
git commit -m "feat: implement alias caching mechanism"
git push -u origin feat/performance-optimization/caching-mechanism

# 5. 서브태스크 PR 생성
gh pr create \
  --base feat/performance-optimization \
  --head feat/performance-optimization/caching-mechanism \
  --title "Subtask: implement alias caching mechanism"

# 6. 사용자 승인 후 부모 브랜치로 병합
# "이 PR을 feat/performance-optimization에 병합하시겠습니까?"
gh pr merge --squash --delete-branch

# 7. 원격 서브 브랜치 삭제 확인 및 실행
# "원격 저장소의 브랜치도 삭제하시겠습니까?"
git push origin --delete feat/performance-optimization/caching-mechanism

# 8. 부모 브랜치로 돌아가서 계속 작업
git checkout feat/performance-optimization
git pull origin feat/performance-optimization

# 9. 모든 작업 완료 후 main으로 PR
gh pr create --base main --head feat/performance-optimization \
  --title "perf: optimize environment loading performance"

# 10. 사용자 승인 후 main에 병합
gh pr merge --squash --delete-branch

# 11. 원격 브랜치 삭제 확인 및 실행
git push origin --delete feat/performance-optimization
```

---

## 체크리스트

### 최상위 작업 시작 시

```markdown
[ ] main 브랜치로 체크아웃 완료
[ ] main 브랜치 최신 상태로 업데이트 완료
[ ] 작업 문서 작성 완료
[ ] 작업 문서를 main에 커밋 및 푸시 완료
[ ] 피쳐 브랜치 생성 및 체크아웃 완료
[ ] 브랜치 네이밍 규칙 준수 확인
```

### 서브태스크 시작 시

```markdown
[ ] 부모 브랜치 확인 완료
[ ] 서브 브랜치 생성 필요 여부 판단 완료
[ ] (서브 브랜치 생성 시) 브랜치 네이밍 규칙 준수 확인
```

### PR 생성 시

```markdown
[ ] PR 제목 및 본문 작성 완료
[ ] PR이 올바른 base 브랜치를 가리키는지 확인
[ ] 변경 사항 요약 포함
[ ] 테스트 체크리스트 포함
```

### PR 병합 시

```markdown
[ ] (부모 브랜치로 병합 시) 사용자 승인 확인 완료
[ ] PR 체크(CI/테스트) 통과 확인
[ ] 병합 완료
[ ] 로컬 브랜치 삭제 완료
[ ] 사용자에게 병합 완료 안내
[ ] **버전 범프 추정 및 실행**
[ ] 원격 브랜치 삭제 여부 사용자에게 확인
[ ] (승인 시) 원격 브랜치 삭제 완료
[ ] 삭제 완료 안내
```

---

## 버전 범프 규칙

### 기능 브랜치 병합 완료 시 자동 버전 범프

**핵심 원칙**: 모든 기능 브랜치가 main에 병합될 때, 에이전트는 **자동으로 적절한 버전 범프를 추정하고 실행**합니다.

### 버전 범프 추정 기준

에이전트는 다음 기준으로 버전 타입을 추정합니다:

#### 1. **Major (v0.1.1 -> v1.0.0)** - 하위 호환성이 깨지는 변경
- 기존 API/인터페이스 제거
- 기존 동작 방식의 근본적 변경
- 설정 파일 형식 변경 (migration 필요)
- 필수 의존성 major 버전 업그레이드
- 스크립트 사용법이 완전히 바뀌는 경우

**키워드**: `breaking`, `remove`, `deprecated API removal`, `incompatible`

**예시**:
```
feat: remove support for old .envrc format
feat: change environment variable naming convention
feat!: redesign alias system (breaking change)
```

#### 2. **Minor (v0.1.1 -> v0.2.0)** - 새로운 기능 추가 (하위 호환)
- 새로운 기능 추가
- 새로운 명령어/옵션 추가
- 새로운 언어 지원 추가
- 성능 개선 (visible improvement)
- 새로운 설정 옵션 추가 (기존 동작 유지)

**키워드**: `feat`, `add`, `implement`, `support`, `enhance`, `improve`

**예시**:
```
feat: add Japanese language support
feat: implement caching mechanism
feat: add interactive configuration wizard
perf: improve loading performance by 50%
```

#### 3. **Patch (v0.1.1 -> v0.1.2)** - 버그 수정 및 마이너 개선
- 버그 수정
- 문서 개선
- 테스트 추가
- 코드 리팩토링 (동작 변경 없음)
- 오타 수정
- 로깅 개선
- 내부 구조 개선

**키워드**: `fix`, `docs`, `chore`, `refactor`, `test`, `style`

**예시**:
```
fix: prevent duplicate alias backup
docs: update README with installation guide
chore: update dependencies
refactor: simplify load script logic
```

### 버전 범프 실행 프로세스

#### 1단계: 커밋 메시지 분석

```bash
# 병합된 브랜치의 모든 커밋 메시지 수집
git log main..feat/branch-name --oneline

# 커밋 메시지에서 타입 추출
# - feat, feat! -> minor or major
# - fix, docs, chore, refactor -> patch
# - BREAKING CHANGE in body -> major
```

#### 2단계: 버전 타입 추정

에이전트는 다음 로직으로 버전 타입을 추정합니다:

```
1. BREAKING CHANGE 또는 feat! 있음 → **major**
2. feat 있음 → **minor**
3. fix, docs, chore만 있음 → **patch**
4. 불명확함 → 사용자에게 확인
```

#### 3단계: 사용자에게 버전 범프 제안

```
"이 기능 브랜치가 main에 병합되었습니다.

커밋 분석 결과:
- feat: 2개 (새 기능 추가)
- fix: 1개 (버그 수정)
- docs: 3개 (문서 업데이트)

추천 버전 범프: **minor** (v0.1.1 -> v0.2.0)

이유:
- 새로운 기능이 추가되었습니다 (일본어 언어 지원)
- 하위 호환성이 유지됩니다
- 버그 수정도 포함되어 있습니다

버전 범프를 실행하시겠습니까?
- 'yes' 또는 'minor': 추천대로 minor 버전 범프
- 'patch': patch 버전만 증가 (v0.1.1 -> v0.1.2)
- 'major': major 버전 증가 (v0.1.1 -> v1.0.0)
- 'skip': 버전 범프 건너뛰기
"
```

#### 4단계: 버전 범프 실행

사용자 응답에 따라:

```bash
# minor 선택 시
make release-minor

# patch 선택 시
make release-patch

# major 선택 시
make release-major

# skip 선택 시
# 버전 범프 건너뛰고 계속 진행
```

### 버전 범프 예외 사항

다음 경우에는 버전 범프를 **제안하지 않습니다**:

- ❌ 서브태스크 브랜치가 부모 브랜치로 병합되는 경우 (main이 아님)
- ❌ 문서만 변경된 경우 (`docs:` 커밋만 있음)
- ❌ 테스트나 CI 설정만 변경된 경우
- ❌ `.claude/` 디렉토리만 변경된 경우 (워크플로우 문서 등)

이런 경우 에이전트는 다음과 같이 안내합니다:

```
"이 브랜치는 문서/내부 설정만 변경했으므로 버전 범프를 건너뜁니다."
```

### 버전 범프 판단이 어려운 경우

에이전트가 버전 타입을 확신할 수 없는 경우:

```
"이 브랜치의 변경사항을 분석했지만, 적절한 버전 타입을 확신할 수 없습니다.

커밋 내역:
- refactor: 전체 로딩 시스템 재구현
- perf: 성능 50% 개선
- fix: 여러 버그 수정

이 변경사항은 어떤 버전 범프가 적절할까요?
- 'minor': 새로운 기능 추가 또는 visible improvement (v0.1.1 -> v0.2.0)
- 'patch': 버그 수정 또는 내부 개선 (v0.1.1 -> v0.1.2)
- 'major': 하위 호환성 깨짐 (v0.1.1 -> v1.0.0)
- 'skip': 버전 범프 건너뛰기
"
```

### 커밋 메시지 분석 예시

#### 예시 1: Minor 버전 범프

```
커밋 내역:
- feat: add Japanese language support
- feat: add language detection in install script
- docs: update README with Japanese instructions
- test: add tests for Japanese language

추정: **minor** (새 기능 추가, 하위 호환)
```

#### 예시 2: Patch 버전 범프

```
커밋 내역:
- fix: prevent duplicate alias entries
- fix: handle empty environment variables correctly
- test: add edge case tests
- docs: update troubleshooting guide

추정: **patch** (버그 수정만 포함)
```

#### 예시 3: Major 버전 범프

```
커밋 내역:
- feat!: redesign configuration file format
- docs: add migration guide from v0.x to v1.x
- feat: remove deprecated --legacy flag

추정: **major** (breaking changes 포함)
```

#### 예시 4: 버전 범프 불필요

```
커밋 내역:
- docs: fix typo in README
- docs: update installation instructions
- chore: update .gitignore

추정: **skip** (문서/설정만 변경)
```

### 버전 범프 체크리스트

```markdown
[ ] main 브랜치로 기능 브랜치 병합 완료
[ ] 병합된 브랜치의 커밋 메시지 분석 완료
[ ] 버전 타입 추정 완료 (major/minor/patch/skip)
[ ] 사용자에게 버전 범프 제안 및 설명
[ ] 사용자 선택에 따라 적절한 make 명령 실행
[ ] 버전 범프 완료 또는 스킵 안내
```

---

## 자주 묻는 질문 (FAQ)

### Q1: 서브태스크를 언제 별도 브랜치로 만들어야 하나요?

**A**: 다음 기준을 참고하세요:

- **브랜치 생성 권장**: 3개 이상의 커밋이 필요하거나, 변경 범위가 큰 경우
- **브랜치 불필요**: 1-2개 커밋으로 완료되는 간단한 작업

의심스러우면 사용자에게 물어보세요:
```
"이 서브태스크는 [변경 범위]를 포함합니다.
별도 브랜치를 생성하시겠습니까, 아니면 부모 브랜치에서 직접 작업하시겠습니까?"
```

### Q2: 문서 커밋을 main에 직접 푸시해도 괜찮나요?

**A**: 예, **플래닝 문서만** main에 직접 푸시합니다.

- ✅ 최상위 작업의 플래닝 문서 (처음 작성 시)
- ❌ 작업 진행 중 문서 업데이트 (피쳐 브랜치에서 커밋)

### Q3: 사용자가 승인 없이 바로 병합하라고 하면?

**A**: 최소한 안내는 해야 합니다:

```
"알겠습니다. PR을 바로 병합하겠습니다.
변경 사항: [요약]
PR URL: [링크]"
```

### Q4: 병합 완료 후 항상 원격 브랜치를 삭제해야 하나요?

**A**: 필수는 아니지만 **권장**합니다.

- ✅ **삭제 권장**: 단기 feature 브랜치, 서브태스크 브랜치
- ❌ **삭제 불가**: main 등 주요 브랜치
- ⚠️ **사용자 판단**: 장기 운영 브랜치, 재사용 예정 브랜치

사용자에게 항상 확인 후 진행합니다:
```
"원격 저장소(origin)의 브랜치도 삭제하시겠습니까?"
```

### Q5: gh pr merge --delete-branch가 원격 브랜치도 삭제하나요?

**A**: 아니요, `--delete-branch` 플래그는 **로컬 브랜치만** 삭제합니다.

원격 브랜치 삭제는 별도로 수행해야 합니다:
```bash
git push origin --delete [브랜치명]
```

### Q6: 기능 브랜치 병합 시 항상 버전 범프를 해야 하나요?

**A**: 아니요, 다음 경우에는 **버전 범프를 건너뜁니다**:

- 문서만 변경 (`docs:` 커밋만)
- 워크플로우 설정만 변경 (`.claude/` 디렉토리)
- 테스트/CI 설정만 변경
- 서브태스크 브랜치가 부모 브랜치로 병합 (main이 아님)

에이전트가 자동으로 판단하지만, 불확실한 경우 사용자에게 물어봅니다.

### Q7: 버전 범프 추정이 잘못되면 어떻게 하나요?

**A**: 에이전트가 제안한 버전 타입을 사용자가 바꿀 수 있습니다:

```
에이전트: "추천 버전 범프: minor"
사용자: "patch로 해줘"
에이전트: "알겠습니다. patch 버전 범프를 실행합니다."
```

사용자의 선택이 최종 결정입니다.

### Q8: 여러 기능을 한 번에 병합했을 때 버전은?

**A**: 에이전트가 **가장 높은 우선순위**의 버전 타입을 제안합니다:

```
커밋 내역:
- feat: 새 기능 A (minor)
- feat!: Breaking change B (major)
- fix: 버그 수정 (patch)

→ 추천: **major** (가장 높은 영향도)
```

우선순위: `major` > `minor` > `patch`

---

## 관련 문서

- [에이전트 워크플로우](agent-workflow.md) - 전체 작업 프로세스
- [작업 문서 구조](tasks/README.md) - 작업 문서 관리
- [커밋 가이드라인](commit-guidelines.md) - Git 커밋 규칙
- [CLAUDE.md](../CLAUDE.md) - 프로젝트 전체 가이드

---

## 변경 이력

- **2025-10-22**:
  - direnv 프로젝트에 맞게 조정 및 적용
  - 버전 범프 규칙 추가 (기능 브랜치 병합 시 자동 버전 추정 및 실행)
- **2025-10-20**: onoffhub-frontend에서 초안 작성

---

**이 브랜치 전략은 프로젝트 관리 효율성을 위해 모든 에이전트가 반드시 준수해야 합니다.**
