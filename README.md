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
<img width="623" height="189" alt="image" src="https://github.com/user-attachments/assets/cf25f638-860a-44d7-8b8e-f9ebdaaf74c3" />

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
<img width="618" height="170" alt="image" src="https://github.com/user-attachments/assets/c25bc7b3-febb-44fc-b20e-8ba6d473ed6c" />

---

#### 2차: CocoaPods 캐싱

CocoaPods 의존성과 스펙 저장소를 캐싱하여 `pod install` 시간을 단축합니다.

```yaml
- name: Cache CocoaPods
  uses: actions/cache@v4
  with:
    path: |
      build/iOS/${{ inputs.build_name }}/Pods
      ~/.cocoapods/repos
    key: pods-${{ hashFiles(format('build/iOS/{0}/Podfile.lock', inputs.build_name)) }}
```

<!-- 2차 최적화 적용 결과 스크린샷 -->

---

#### 3차: Xcode 병렬 빌드

Fastlane에서 Xcode 빌드 시 병렬 컴파일을 활성화합니다.

```ruby
build_app(
  xcargs: "-jobs 8 -parallelizeTargets",
  ...
)
```

<!-- 3차 최적화 적용 결과 스크린샷 -->

---

### 최적화 결과 요약

| 차수 | 최적화 내용 | 적용 전 | 적용 후 | 비고 |
|:---:|------------|--------|--------|------|
| 1차 | Unity Library/IL2CPP 캐싱 | 40~50분 | 40분 초반 | ⚠️ 에러로 인해 비활성화 |
| 2차 | CocoaPods 캐싱 | - | - | ✅ 활성화 |
| 3차 | Xcode 병렬 빌드 | - | - | ✅ 활성화 |

> **참고:** 1차 캐싱 최적화는 PPtr cast failed 에러로 인해 현재 비활성화되어 있습니다. 자세한 내용은 [캐시 정책](#캐시-정책)을 참고하세요.

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

<img width="1152" height="178" alt="image" src="https://github.com/user-attachments/assets/23075f9f-84bc-47f4-a4a2-9758c1fbef39" />


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

## Self-hosted Runner (선택)

### Self-hosted Runner란?

GitHub Actions는 기본적으로 GitHub에서 제공하는 클라우드 서버(GitHub-hosted runner)에서 실행됩니다. **Self-hosted runner**는 자신의 맥북이나 서버에서 빌드를 실행하는 방식입니다.

### 왜 Self-hosted를 사용하나요?

| 항목 | GitHub-hosted | Self-hosted |
|------|---------------|-------------|
| **비용** | 유료 (분당 과금) | 무료 |
| **무료 한도** | Private repo: 2,000분/월 | 무제한 |
| **빌드 속도** | 보통 | 빠름 (로컬 캐시) |
| **Unity 라이선스** | 매번 활성화 필요 | 한 번만 활성화 |
| **설정 복잡도** | 간단 | 초기 설정 필요 |
| **가용성** | 24/7 | 맥북이 켜져 있어야 함 |

**추천 상황:**
- Private 저장소에서 빌드 비용을 줄이고 싶을 때
- 빌드를 자주 실행해서 무료 한도를 초과할 때
- 더 빠른 빌드 속도가 필요할 때

---

### Self-hosted 사전 요구사항

Self-hosted runner를 사용하려면 맥북에 다음이 설치되어 있어야 합니다:

| 소프트웨어 | 용도 | 확인 방법 |
|-----------|------|----------|
| Unity | Unity 빌드 | Unity Hub 실행 |
| Xcode | iOS 빌드 | `xcode-select -p` |
| Fastlane | 배포 자동화 | `fastlane --version` |
| CocoaPods | iOS 의존성 | `pod --version` |
| 인증서 | 코드 서명 | Keychain Access 앱 |
| 프로비저닝 프로파일 | 앱 배포 | `~/Library/MobileDevice/Provisioning Profiles/` |

> **참고:** 이미 맥북에서 Unity iOS 빌드를 수동으로 성공한 적이 있다면, 위 항목들은 모두 설치되어 있습니다.

---

### Self-hosted Runner 설정 방법

#### Step 1: GitHub에서 Runner 등록

1. GitHub Repository로 이동
2. **Settings** → **Actions** → **Runners** 클릭
3. **New self-hosted runner** 버튼 클릭
4. **macOS** 선택
5. 표시되는 토큰을 복사해둡니다

#### Step 2: 맥북에서 Runner 설치

터미널을 열고 다음 명령어를 실행합니다:

```bash
# 1. 작업 폴더 생성
mkdir -p ~/actions-runner && cd ~/actions-runner

# 2. Runner 다운로드 (GitHub 페이지에서 최신 버전 확인)
# Apple Silicon (M1/M2/M3)
curl -o actions-runner-osx-arm64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-osx-arm64-2.321.0.tar.gz

# Intel Mac
curl -o actions-runner-osx-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-osx-x64-2.321.0.tar.gz

# 3. 압축 해제
tar xzf ./actions-runner-osx-*.tar.gz

# 4. Runner 설정 (GitHub에서 복사한 토큰 사용)
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN

# 5. Runner 실행
./run.sh
```

#### Step 3: Runner를 백그라운드 서비스로 등록 (선택)

맥북을 재시작해도 자동으로 Runner가 실행되도록 설정합니다:

```bash
# 서비스 설치
sudo ./svc.sh install

# 서비스 시작
sudo ./svc.sh start

# 서비스 상태 확인
sudo ./svc.sh status

# 서비스 중지 (필요시)
sudo ./svc.sh stop

# 서비스 제거 (필요시)
sudo ./svc.sh uninstall
```

#### Step 4: Runner 상태 확인

GitHub Repository → **Settings** → **Actions** → **Runners**에서 Runner가 **Idle** 상태로 표시되면 성공입니다.

---

### Self-hosted 워크플로우 사용

Self-hosted runner용 워크플로우는 `ios-testflight-self.yml`입니다.

#### 필요한 Secrets (4개만)

| Secret | 설명 |
|--------|------|
| `APPSTORE_ISSUER_ID` | App Store Connect API Issuer ID |
| `APPSTORE_KEY_ID` | App Store Connect API Key ID |
| `APPSTORE_PRIVATE_KEY` | App Store Connect API 키 (.p8 내용) |
| `APPLE_TEAM_ID` | Apple Developer Team ID |

> **참고:** Unity 라이선스, 인증서 관련 Secrets는 **불필요**합니다. 맥북에 이미 설정되어 있기 때문입니다.

#### 워크플로우 호출 예시

```yaml
name: iOS Build (Self-hosted)

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      version:
        description: 'Version (e.g., 1.0.0)'
        required: false

jobs:
  ios:
    uses: leehyoenjong/Unity-Git-Actions-CI/.github/workflows/ios-testflight-self.yml@main
    with:
      unity_path: '/Applications/Unity/Hub/Editor/6000.3.2f1/Unity.app/Contents/MacOS/Unity'
      bundle_id: 'com.company.app'
      profile_name: 'MyApp_AppStore_Profile'
      build_name: 'MyApp'
      version: ${{ github.event.inputs.version }}
    secrets:
      APPSTORE_ISSUER_ID: ${{ secrets.APPSTORE_ISSUER_ID }}
      APPSTORE_KEY_ID: ${{ secrets.APPSTORE_KEY_ID }}
      APPSTORE_PRIVATE_KEY: ${{ secrets.APPSTORE_PRIVATE_KEY }}
      APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
```

#### Unity 경로 확인 방법

```bash
# Unity Hub에서 설치된 Unity 경로 확인
ls /Applications/Unity/Hub/Editor/

# 출력 예시: 6000.3.2f1

# 전체 경로
/Applications/Unity/Hub/Editor/6000.3.2f1/Unity.app/Contents/MacOS/Unity
```

---

### GitHub-hosted vs Self-hosted 선택 가이드

| 상황 | 추천 |
|------|------|
| 처음 시작하는 경우 | GitHub-hosted |
| 빌드 비용을 줄이고 싶은 경우 | Self-hosted |
| 맥북을 항상 켜둘 수 있는 경우 | Self-hosted |
| 안정성이 중요한 경우 | GitHub-hosted |
| 둘 다 유연하게 사용하고 싶은 경우 | **둘 다 설정** |

> **팁:** 두 워크플로우를 모두 설정해두면, 맥북이 꺼져 있을 때는 GitHub-hosted로, 켜져 있을 때는 Self-hosted로 빌드할 수 있습니다.

---

## 라이선스

MIT License
