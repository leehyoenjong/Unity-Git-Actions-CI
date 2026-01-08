# Unity Git Actions CI

Unity 빌드 및 스토어 배포를 위한 재사용 가능한 GitHub Actions 워크플로우입니다.

## 지원 플랫폼

- [x] iOS (TestFlight)
- [ ] Android (APK)
- [ ] Android (Google Play Console)

---

## 빠른 설치 (권장)

**터미널(Terminal)에서 실행하세요!**

1. 터미널을 엽니다
2. Unity 프로젝트 폴더로 이동합니다:
   ```bash
   cd /your/unity/project/path
   ```
3. 아래 명령어를 실행합니다:
   ```bash
   curl -s https://raw.githubusercontent.com/leehyoenjong/Unity-Git-Actions-CI/main/install.sh | bash
   ```

**설치 후:**
1. `.github/workflows/ios-testflight.yml` 파일 열기
2. `TODO` 표시된 값들을 프로젝트에 맞게 수정
3. GitHub Secrets 설정 (아래 Step 4 참고)

---

## iOS TestFlight 배포

### 개요

이 워크플로우는 Unity 프로젝트를 iOS로 빌드하고 TestFlight에 자동 배포합니다.

```
[Unity 프로젝트] → [Xcode 프로젝트 생성] → [CocoaPods 설치] → [IPA 빌드] → [TestFlight 업로드]
```

### 주요 특징
- CocoaPods 자동 설치 지원
- UnityFramework 자동 서명 처리
- 디버그 로그 출력

---

## 설정 방법 (Step by Step)

### Step 1: 빠른 설치 실행

터미널에서 Unity 프로젝트 폴더로 이동 후:

```bash
curl -s https://raw.githubusercontent.com/leehyoenjong/Unity-Git-Actions-CI/main/install.sh | bash
```

이 명령어는 다음 파일들을 자동으로 생성합니다:
- `.github/workflows/ios-testflight.yml`
- `fastlane/Fastfile`
- `Gemfile`

---

### Step 2: 입력 파라미터 값 설정

`.github/workflows/ios-testflight.yml` 파일을 열고 `TODO` 표시된 값들을 수정합니다.

| 파라미터 | 필수 | 기본값 | 설명 | 값 확인 방법 |
|---------|:----:|--------|------|-------------|
| `unity_version` | O | - | Unity 버전 | Unity Hub → 프로젝트 버전 확인 |
| `bundle_id` | O | - | iOS 번들 ID | Unity → Project Settings → Player → iOS → Bundle Identifier |
| `profile_name` | O | - | 프로비저닝 프로파일 이름 | Apple Developer → Profiles |
| `build_name` | O | `App` | 빌드 출력 이름 | 원하는 앱 이름 |
| `xcode_version` | X | `16.4` | Xcode 버전 | [GitHub Runner Images](https://github.com/actions/runner-images) 참고 |
| `version` | X | `0.0.1` | 앱 버전 | 수동 실행 시 입력 또는 태그에서 추출 |

**예시:**

```yaml
with:
  unity_version: "6000.3.2f1"
  bundle_id: "com.STUCKPIXEL.NOC"
  profile_name: "NOC_AppStore_Profile"
  build_name: "NOC"
  xcode_version: "16.4"
  version: ${{ github.event.inputs.version }}
```

---

### Step 3: GitHub Secrets 설정

GitHub 리포지토리에서 Secrets를 설정합니다.

**경로:** Repository → Settings → Secrets and variables → Actions → New repository secret

#### 3.1 Unity 라이선스 관련

| Secret 이름 | 값 | 얻는 방법 |
|------------|-----|----------|
| `UNITY_EMAIL` | Unity 계정 이메일 | Unity 로그인 이메일 |
| `UNITY_PASSWORD` | Unity 계정 비밀번호 | Unity 로그인 비밀번호 |
| `UNITY_LICENSE` | Unity 라이선스 내용 | 아래 참고 |

**Unity 라이선스 얻기:**
```bash
# macOS
cat "/Library/Application Support/Unity/Unity_lic.ulf"

# Windows
type "C:\ProgramData\Unity\Unity_lic.ulf"
```

#### 3.2 iOS 인증서 관련

| Secret 이름 | 값 | 얻는 방법 |
|------------|-----|----------|
| `IOS_CERTIFICATE_BASE64` | .p12 인증서 (Base64) | 아래 참고 |
| `IOS_CERTIFICATE_PASSWORD` | 인증서 비밀번호 | .p12 내보낼 때 설정한 비밀번호 |
| `IOS_PROVISION_PROFILE_BASE64` | 프로비저닝 프로파일 (Base64) | 아래 참고 |
| `APPLE_TEAM_ID` | Apple 팀 ID | Apple Developer → Membership → Team ID |

**인증서를 Base64로 변환:**
```bash
# .p12 인증서 변환
base64 -i Certificates.p12 | pbcopy

# 프로비저닝 프로파일 변환
base64 -i YourApp.mobileprovision | pbcopy
```

#### 3.3 App Store Connect API 관련

| Secret 이름 | 값 | 얻는 방법 |
|------------|-----|----------|
| `APPSTORE_ISSUER_ID` | Issuer ID | App Store Connect → Users and Access → Integrations → Keys |
| `APPSTORE_KEY_ID` | Key ID | 위와 동일 |
| `APPSTORE_PRIVATE_KEY` | API 키 내용 (.p8) | 키 생성 시 다운로드한 .p8 파일 내용 |

**App Store Connect API 키 생성:**
1. [App Store Connect](https://appstoreconnect.apple.com) 로그인
2. Users and Access → Integrations → App Store Connect API
3. Keys 탭 → "+" 버튼으로 새 키 생성
4. 역할: Admin 또는 App Manager
5. 생성 후:
   - Issuer ID: 페이지 상단에 표시
   - Key ID: 생성된 키 옆에 표시
   - .p8 파일: 다운로드 (한 번만 가능!)

```bash
# .p8 파일 내용 확인
cat AuthKey_XXXXXXXXXX.p8
# 출력된 내용 전체를 APPSTORE_PRIVATE_KEY에 붙여넣기
```

---

### Step 4: 빌드 실행

#### 방법 1: 태그 푸시 (자동 실행)
```bash
git tag v1.0.0
git push origin v1.0.0
```

#### 방법 2: 수동 실행
1. GitHub → Repository → Actions 탭
2. "iOS Build & TestFlight" 워크플로우 선택
3. "Run workflow" 버튼 클릭
4. (선택) 버전 입력
5. "Run workflow" 클릭

---

## 전체 Secrets 체크리스트

| Secret | 필수 | 설정 완료 |
|--------|:----:|:--------:|
| `UNITY_EMAIL` | O | [ ] |
| `UNITY_PASSWORD` | O | [ ] |
| `UNITY_LICENSE` | O | [ ] |
| `IOS_CERTIFICATE_BASE64` | O | [ ] |
| `IOS_CERTIFICATE_PASSWORD` | O | [ ] |
| `IOS_PROVISION_PROFILE_BASE64` | O | [ ] |
| `APPLE_TEAM_ID` | O | [ ] |
| `APPSTORE_ISSUER_ID` | O | [ ] |
| `APPSTORE_KEY_ID` | O | [ ] |
| `APPSTORE_PRIVATE_KEY` | O | [ ] |

---

## 문제 해결

### Unity 라이선스 오류
- `UNITY_LICENSE` 값이 올바른지 확인
- Professional 라이선스가 필요한 경우 [game-ci 문서](https://game.ci/docs/github/activation) 참고

### 코드 사이닝 오류
- `profile_name`이 실제 프로비저닝 프로파일 이름과 일치하는지 확인
- 인증서가 만료되지 않았는지 확인
- Bundle ID가 프로비저닝 프로파일과 일치하는지 확인

### Xcode 버전 오류
- [GitHub Actions Runner Images](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)에서 사용 가능한 Xcode 버전 확인

### CocoaPods 오류
- `Podfile`이 Unity 빌드 출력에 포함되어 있는지 확인
- 빌드 경로가 `build/iOS/{build_name}/` 형식인지 확인

---

## 빌드 시간 최적화

### 최적화를 하는 이유

- **빠른 빌드**: 개발 이터레이션 속도 향상
- **비용 절감**: GitHub Actions Private 저장소는 **무료 기준 월 2,000분**으로 제한됨

### 최적화 전 (40~50분)

최적화 적용 전 빌드 시간입니다.
<img width="1278" height="152" alt="image" src="https://github.com/user-attachments/assets/91bfa359-dc2c-482d-9bf2-2be152eae98f" />

---

### 적용된 최적화

#### 1차: 워크플로우 캐싱 최적화

Unity 빌드 캐싱과 Artifact 전송을 최적화합니다.

**IL2CPP 빌드 캐싱**
```yaml
- name: Cache IL2CPP
  uses: actions/cache@v4
  with:
    path: Library/Il2cppBuildCache
    key: il2cpp-iOS-${{ hashFiles('Assets/**/*.cs', 'Packages/**/*.cs') }}
```

**Library 캐시 키 최적화**
```yaml
# Before
key: Library-iOS-${{ hashFiles('Assets/**', 'Packages/**', 'ProjectSettings/**') }}

# After
key: Library-iOS-${{ hashFiles('Packages/manifest.json', 'ProjectSettings/ProjectVersion.txt') }}
```

**Artifact 압축 최적화**
```yaml
- name: Upload Xcode project
  uses: actions/upload-artifact@v4
  with:
    compression-level: 6
```

<!-- 1차 최적화 적용 결과 스크린샷 -->

---

#### 2차: Xcode 병렬 빌드

Fastlane에서 Xcode 빌드 시 병렬 컴파일을 활성화합니다.

```ruby
build_app(
  xcargs: "-jobs 8 -parallelizeTargets",
  ...
)
```

<!-- 2차 최적화 적용 결과 스크린샷 -->

---

### 최적화 결과 요약

| 차수 | 최적화 내용 | 적용 전 | 적용 후 | 단축 시간 |
|:---:|------------|--------|--------|----------|
| 1차 | 워크플로우 캐싱 최적화 | 40~50분 | - | - |
| 2차 | Xcode 병렬 빌드 | - | - | - |
| | **총합** | **40~50분** | **-** | **-** |

<!-- 최종 결과 비교 스크린샷 -->

---

### 캐시 정책

#### 비활성화된 캐시

다음 캐시들은 **빌드 안정성을 위해 비활성화**되어 있습니다:

| 캐시 | 비활성화 이유 |
|------|-------------|
| Unity Library | 에셋 참조 손상 가능 (PPtr cast failed 에러) |
| IL2CPP Build Cache | Unity 빌드와 연관된 캐시 손상 위험 |

**발생할 수 있는 오류:**

<!-- TODO: PPtr 에러 스크린샷 추가 -->

```
PPtr cast failed when dereferencing! Casting from Mesh to MonoScript at FileID -2597519522473998463!
```

이 에러는 캐시된 Library 폴더와 현재 프로젝트 에셋 간의 불일치로 발생합니다. CI 환경에서는 에셋 변경 시 캐시가 자동으로 갱신되지 않아 참조가 깨질 수 있습니다.

#### 활성화된 캐시

다음 캐시들은 **안전하게 사용** 가능합니다:

| 캐시 | 설명 |
|------|------|
| CocoaPods (Pods) | iOS 의존성 라이브러리 |
| CocoaPods repos | CocoaPods 스펙 저장소 |
| Ruby Bundler | Fastlane 등 Ruby 의존성 |

---

### 캐시 문제 해결

캐시 관련 빌드 문제 발생 시:

1. GitHub 저장소 → **Actions** 탭
2. 왼쪽 메뉴 **Caches** 클릭
3. 문제가 되는 캐시 삭제

다음 빌드에서 새로운 캐시가 생성됩니다.

---

## 라이선스

MIT License
