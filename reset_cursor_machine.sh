#!/bin/bash

# macOS 기준 경로
STORAGE_PATH="$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json"

# 백업 경로
BACKUP_PATH="$STORAGE_PATH.bak.$(date +%Y%m%d_%H%M%S)"

# UUID 생성 함수
generate_uuid() {
  uuidgen
}

# 파일 존재 여부 확인
if [ ! -f "$STORAGE_PATH" ]; then
  echo "❌ storage.json 파일이 존재하지 않습니다."
  echo "⛳ 경로: $STORAGE_PATH"
  exit 1
fi

# 백업
cp "$STORAGE_PATH" "$BACKUP_PATH"
echo "✅ 기존 machineId 백업 완료: $BACKUP_PATH"

# 새로운 machineId 생성
NEW_ID=$(generate_uuid)

# 기존 JSON 수정 (telemetry.macMachineId 덮어쓰기)
if jq --arg newid "$NEW_ID" '.["telemetry.macMachineId"] = $newid' "$STORAGE_PATH" > "${STORAGE_PATH}.tmp"; then
  mv "${STORAGE_PATH}.tmp" "$STORAGE_PATH"
  echo "✅ 새로운 machineId 적용 완료: $NEW_ID"
else
  echo "❌ JSON 수정 중 오류 발생"
  exit 1
fi

# 사용자에게 Cursor 재시작 여부 묻기
read -p "🔄 Cursor 프로세스를 종료하시겠습니까? (y/n): " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  pkill -9 Cursor && echo "🛑 Cursor 프로세스 종료 완료"
else
  echo "🔕 Cursor 프로세스는 유지됩니다."
fi

echo "🎉 작업이 완료되었습니다."
