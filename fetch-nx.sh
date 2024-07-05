#!/bin/bash

# 넥서스 인증 정보
USERNAME="admin"
PASSWORD="cloud1234"

# 넥서스 URL 및 레포지토리 이름
BASE_URL="http://172.10.50.146:8081"
REPOSITORY_NAME="okestro-repo"

# 넥서스 v1 API 기본 엔드포인트
API_URL="${BASE_URL}/service/rest/v1/search/assets?sort=group&direction=asc&repository=${REPOSITORY_NAME}"

# 결과를 저장할 임시 파일 및 로그 파일
TEMP_FILE=$(mktemp)
LOG_FILE="nexus_api.log"
OUTPUT_FILE="download_urls.txt"

# 페이지네이션 처리 변수
CONTINUE=true
TOKEN=""

# 기존의 출력 파일을 비웁니다
> "$OUTPUT_FILE"

# API 호출 및 페이지네이션 처리
while $CONTINUE; do
  if [ -n "$TOKEN" ]; then
    RESPONSE=$(curl -s -u "${USERNAME}:${PASSWORD}" "${API_URL}&continuationToken=${TOKEN}")
  else
    RESPONSE=$(curl -s -u "${USERNAME}:${PASSWORD}" "${API_URL}")
  fi

  # 로그 파일에 응답 기록
  echo "Response:" >> "$LOG_FILE"
  echo "$RESPONSE" >> "$LOG_FILE"

  # downloadUrl 추출
  echo "$RESPONSE" | jq -r '.items[] | .downloadUrl' >> "$TEMP_FILE"

  # 다음 페이지 토큰 추출
  TOKEN=$(echo "$RESPONSE" | jq -r '.continuationToken')
  echo "Token: $TOKEN" >> "$LOG_FILE"

  if [ "$TOKEN" == "null" ]; then
    CONTINUE=false
  fi
done

# 중복 제거 및 정렬 후 파일에 저장
sort "$TEMP_FILE" | uniq > "$OUTPUT_FILE"

# 임시 파일 삭제
rm "$TEMP_FILE"

echo "Download URLs have been saved to $OUTPUT_FILE"

