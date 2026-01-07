# Unity iOS CI - Reusable Workflow

Unity iOS 빌드 및 TestFlight 배포를 위한 재사용 가능한 GitHub Actions 워크플로우입니다.

## 사용 방법

### 1. 프로젝트에 워크플로우 파일 추가

프로젝트의 `.github/workflows/deploy.yml` 파일을 생성합니다:

```yaml
name: iOS Deploy

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
    uses: YOUR_USERNAME/unity-ios-ci/.github/workflows/ios-testflight.yml@main
    with:
      unity_version: "6000.3.2f1"
      bundle_id: "com.yourcompany.yourapp"
      profile_name: "YourApp_AppStore_Profile"
      build_name: "YourApp"
      xcode_version: "15.4"
      version: ${{ github.event.inputs.version }}
    secrets: inherit
```

### 2. 프로젝트에 Fastlane 파일 복사

이 리포지토리의 `fastlane/` 폴더와 `Gemfile`을 프로젝트 루트에 복사합니다.

```
your-project/
├── .github/workflows/deploy.yml
├── fastlane/
│   └── Fastfile
├── Gemfile
├── Assets/
└── ...
```

### 3. GitHub Secrets 설정

프로젝트 리포지토리의 Settings > Secrets and variables > Actions에서 다음 시크릿을 설정합니다:

| Secret | 설명 |
|--------|------|
| `UNITY_LICENSE` | Unity 라이선스 (base64) |
| `UNITY_EMAIL` | Unity 계정 이메일 |
| `UNITY_PASSWORD` | Unity 계정 비밀번호 |
| `IOS_CERTIFICATE_BASE64` | iOS 배포 인증서 (.p12, base64) |
| `IOS_CERTIFICATE_PASSWORD` | 인증서 비밀번호 |
| `IOS_PROVISION_PROFILE_BASE64` | 프로비저닝 프로파일 (base64) |
| `APPSTORE_ISSUER_ID` | App Store Connect API Issuer ID |
| `APPSTORE_KEY_ID` | App Store Connect API Key ID |
| `APPSTORE_PRIVATE_KEY` | App Store Connect API Private Key |
| `APPLE_TEAM_ID` | Apple Developer Team ID |

## 입력 파라미터

| 파라미터 | 필수 | 기본값 | 설명 |
|---------|------|--------|------|
| `unity_version` | O | - | Unity 버전 (예: 6000.3.2f1) |
| `bundle_id` | O | - | iOS 번들 ID |
| `profile_name` | O | - | 프로비저닝 프로파일 이름 |
| `build_name` | X | App | 빌드 출력 이름 |
| `xcode_version` | X | 15.4 | Xcode 버전 |
| `version` | X | 0.0.1 | 앱 버전 |

## 빌드 트리거

- **태그 푸시**: `v*` 패턴의 태그 푸시 시 자동 실행 (예: v1.0.0)
- **수동 실행**: GitHub Actions 탭에서 수동으로 실행

## 라이선스

MIT License
