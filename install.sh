#!/bin/bash

# Unity Git Actions CI 설치 스크립트
# 사용법: curl -s https://raw.githubusercontent.com/leehyoenjong/Unity-Git-Actions-CI/main/install.sh | bash

set -e

REPO_URL="https://raw.githubusercontent.com/leehyoenjong/Unity-Git-Actions-CI/main"

echo "========================================"
echo "  Unity Git Actions CI 설치 스크립트"
echo "========================================"
echo ""

# 1. Gemfile 다운로드
echo "[1/3] Gemfile 다운로드 중..."
curl -sO "${REPO_URL}/Gemfile"
echo "      완료!"

# 2. fastlane/Fastfile 다운로드
echo "[2/3] fastlane/Fastfile 다운로드 중..."
mkdir -p fastlane
curl -so fastlane/Fastfile "${REPO_URL}/fastlane/Fastfile"
echo "      완료!"

# 3. 워크플로우 템플릿 생성
echo "[3/3] .github/workflows/ios-testflight.yml 생성 중..."
mkdir -p .github/workflows
cat > .github/workflows/ios-testflight.yml << 'EOF'
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
      unity_version: "6000.3.2f1"        # TODO: Unity 버전 수정
      bundle_id: "com.company.app"       # TODO: 번들 ID 수정
      profile_name: "App_AppStore"       # TODO: 프로비저닝 프로파일 이름 수정
      build_name: "App"                  # TODO: 빌드 이름 수정
      xcode_version: "15.4"
      version: ${{ github.event.inputs.version }}
    secrets: inherit
EOF
echo "      완료!"

echo ""
echo "========================================"
echo "  설치 완료!"
echo "========================================"
echo ""
echo "생성된 파일:"
echo "  - Gemfile"
echo "  - fastlane/Fastfile"
echo "  - .github/workflows/ios-testflight.yml"
echo ""
echo "다음 단계:"
echo "  1. .github/workflows/ios-testflight.yml 파일 열기"
echo "  2. TODO 표시된 값들을 프로젝트에 맞게 수정:"
echo "     - unity_version: Unity 버전"
echo "     - bundle_id: iOS 번들 ID"
echo "     - profile_name: 프로비저닝 프로파일 이름"
echo "     - build_name: 앱 이름"
echo "  3. GitHub Secrets 설정 (README.md 참고)"
echo ""
echo "자세한 설정 방법:"
echo "  https://github.com/leehyoenjong/Unity-Git-Actions-CI#readme"
echo ""
