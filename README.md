# Unity Git Actions CI

Unity 빌드 및 스토어 배포를 위한 재사용 가능한 GitHub Actions 워크플로우입니다.

## 지원 플랫폼

- [x] iOS (TestFlight)
- [ ] Android (APK)
- [ ] Android (Google Play Console)

---

## iOS TestFlight 배포

### 개요

이 워크플로우는 Unity 프로젝트를 iOS로 빌드하고 TestFlight에 자동 배포합니다.

```
[Unity 프로젝트] → [Xcode 프로젝트 생성] → [IPA 빌드] → [TestFlight 업로드]
```

---

## 설정 방법 (Step by Step)

### Step 1: 프로젝트에 워크플로우 파일 생성

프로젝트 루트에 `.github/workflows/ios-testflight.yml` 파일을 생성합니다.

```
your-unity-project/
├── .github/
│   └── workflows/
│       └── ios-testflight.yml   ← 이 파일 생성
├── Assets/
├── Packages/
├── ProjectSettings/
└── ...
```

**파일 내용:**

```yaml
name: iOS Build & TestFlight

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      version:
        description: 'Build version (e.g., 1.0.0)'
        required: false
        default: ''

jobs:
  ios:
    uses: leehyoenjong/Unity-Git-Actions-CI/.github/workflows/ios-testflight.yml@main
    with:
      unity_version: "6000.3.2f1"
      bundle_id: "com.yourcompany.yourapp"
      profile_name: "YourApp_AppStore_Profile"
      build_name: "YourApp"
      xcode_version: "15.4"
      version: ${{ github.event.inputs.version }}
    secrets: inherit
```

---

### Step 2: 입력 파라미터 값 설정

`with:` 블록의 각 값을 프로젝트에 맞게 수정합니다.

| 파라미터 | 필수 | 기본값 | 설명 | 값 확인 방법 |
|---------|:----:|--------|------|-------------|
| `unity_version` | O | - | Unity 버전 | Unity Hub → 프로젝트 버전 확인 |
| `bundle_id` | O | - | iOS 번들 ID | Unity → Project Settings → Player → iOS → Other Settings → Bundle Identifier |
| `profile_name` | O | - | 프로비저닝 프로파일 이름 | Apple Developer → Certificates, Identifiers & Profiles → Profiles |
| `build_name` | X | `App` | 빌드 출력 이름 | 원하는 앱 이름 |
| `xcode_version` | X | `15.4` | Xcode 버전 | [GitHub Actions Runner Images](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md) 참고 |
| `version` | X | `0.0.1` | 앱 버전 | 수동 실행 시 입력 또는 태그에서 추출 |

**예시 (NOC 프로젝트):**

```yaml
with:
  unity_version: "6000.3.2f1"           # Unity 6000.3.2f1 사용
  bundle_id: "com.STUCKPIXEL.NOC"       # 번들 ID
  profile_name: "NOC_AppStore_Profile"  # 프로비저닝 프로파일 이름
  build_name: "NOC"                     # 출력될 IPA 이름
  xcode_version: "15.4"                 # Xcode 15.4 사용
  version: ${{ github.event.inputs.version }}
```

---

### Step 3: Fastlane 파일 복사

이 리포지토리의 `fastlane/` 폴더와 `Gemfile`을 프로젝트 루트에 복사합니다.

```
your-unity-project/
├── .github/workflows/ios-testflight.yml
├── fastlane/                    ← 복사
│   └── Fastfile
├── Gemfile                      ← 복사
├── Assets/
└── ...
```

**복사할 파일:**
- `fastlane/Fastfile`
- `Gemfile`

---

### Step 4: GitHub Secrets 설정

GitHub 리포지토리에서 Secrets를 설정합니다.

**경로:** Repository → Settings → Secrets and variables → Actions → New repository secret

#### 4.1 Unity 라이선스 관련

| Secret 이름 | 값 | 얻는 방법 |
|------------|-----|----------|
| `UNITY_EMAIL` | Unity 계정 이메일 | Unity 로그인 이메일 |
| `UNITY_PASSWORD` | Unity 계정 비밀번호 | Unity 로그인 비밀번호 |
| `UNITY_LICENSE` | Unity 라이선스 내용 | 아래 "Unity 라이선스 얻기" 참고 |

**Unity 라이선스 얻기:**
```bash
# 로컬에서 Unity 라이선스 파일 위치
# macOS: /Library/Application Support/Unity/Unity_lic.ulf
# Windows: C:\ProgramData\Unity\Unity_lic.ulf

# 파일 내용을 복사하여 UNITY_LICENSE에 붙여넣기
cat "/Library/Application Support/Unity/Unity_lic.ulf"
```

#### 4.2 iOS 인증서 관련

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
# 클립보드에 복사됨 → IOS_CERTIFICATE_BASE64에 붙여넣기

# 프로비저닝 프로파일 변환
base64 -i YourApp.mobileprovision | pbcopy
# 클립보드에 복사됨 → IOS_PROVISION_PROFILE_BASE64에 붙여넣기
```

#### 4.3 App Store Connect API 관련

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
# (-----BEGIN PRIVATE KEY----- 부터 -----END PRIVATE KEY----- 까지)
```

---

### Step 5: 빌드 실행

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
- Professional 라이선스가 필요한 경우 game-ci 문서 참고

### 코드 사이닝 오류
- `profile_name`이 실제 프로비저닝 프로파일 이름과 일치하는지 확인
- 인증서가 만료되지 않았는지 확인
- Bundle ID가 프로비저닝 프로파일과 일치하는지 확인

### Xcode 버전 오류
- [GitHub Actions Runner Images](https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md)에서 사용 가능한 Xcode 버전 확인

---

## 라이선스

MIT License
