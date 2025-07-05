#!/bin/bash

echo ""
echo "📦 go-cursor-help 자동 설치 스크립트 시작합니다..."
echo ""

# Go 설치 여부 확인
if ! command -v go &> /dev/null
then
    echo "❌ Go가 설치되어 있지 않습니다. 먼저 설치해주세요 (예: brew install go)"
    exit 1
fi

# 임시 디렉토리 생성
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit 1

# 저장소 클론
echo "🔄 go-cursor-help 저장소를 클론 중..."
git clone https://github.com/yuaotian/go-cursor-help.git
cd go-cursor-help || exit 1

# 빌드
echo "🔨 빌드 중..."
go build -o go-cursor-help

if [ ! -f "./go-cursor-help" ]; then
    echo "❌ 빌드 실패: 실행 파일이 생성되지 않았습니다."
    exit 1
fi

# 바이너리 이동
echo "🚚 /usr/local/bin으로 실행 파일 이동 (sudo 필요)"
sudo mv go-cursor-help /usr/local/bin/

# 확인
if command -v go-cursor-help &> /dev/null; then
    echo ""
    echo "✅ 설치 완료! 다음 명령어로 실행해보세요:"
    echo ""
    echo "   go-cursor-help"
    echo ""
else
    echo "⚠️ 설치 실패: go-cursor-help 명령어를 찾을 수 없습니다."
fi

# 정리
cd ~
rm -rf "$TEMP_DIR"
