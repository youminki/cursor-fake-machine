#!/bin/bash

# 📍 환경 변수
STORAGE_PATH="$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json"
BACKUP_PATH="$STORAGE_PATH.bak.$(date +%Y%m%d_%H%M%S)"
NEW_MACHINE_ID=$(uuidgen)

# ✅ 1. 백업 및 machineId 교체
if [ ! -f "$STORAGE_PATH" ]; then
  echo "❌ storage.json 파일을 찾을 수 없습니다: $STORAGE_PATH"
  exit 1
fi

cp "$STORAGE_PATH" "$BACKUP_PATH"
echo "✅ storage.json 백업 완료: $BACKUP_PATH"

# 변경
/usr/bin/python3 - <<EOF
import json
path = "$STORAGE_PATH"
with open(path) as f:
    data = json.load(f)
data["telemetry.macMachineId"] = "$NEW_MACHINE_ID"
with open(path, "w") as f:
    json.dump(data, f, indent=2)
EOF

echo "✅ machineId 변경 완료: $NEW_MACHINE_ID"

# ✅ 2. Cursor 종료
pkill -9 Cursor && echo "🛑 Cursor 종료됨"

# ✅ 3. (선택) 이메일 생성 및 로그인 - 선택 기능으로 아래는 기본 출력만
echo "📨 이메일 자동 생성 기능은 아직 연동되지 않음 (필요 시 추가 개발)"

# ✅ 4. 완료 안내
echo "🎉 작업 완료! 이제 Cursor를 수동으로 실행하면 Pro 체험이 초기화됩니다."
