#!/bin/bash

# 다운로드할 파일 목록 파일
URL_FILE="download_urls.txt"

# 베이스 URL (제거할 부분)
BASE_URL="http://172.10.50.146:8081/repository/okestro-repo/"

# URL 파일이 존재하는지 확인
if [ ! -f "$URL_FILE" ]; then
    echo "$URL_FILE 파일을 찾을 수 없습니다."
    exit 1
fi

# URL 파일을 한 줄씩 읽기
while IFS= read -r url; do
    # BASE_URL 부분을 제거한 나머지 경로 추출
    relative_path="${url#$BASE_URL}"
    
    # 파일 저장 경로 설정
    file_dir=$(dirname "$relative_path")
    file_name=$(basename "$relative_path")
    
    # 디렉토리가 존재하지 않으면 생성
    mkdir -p "$file_dir"
    
    # 파일 다운로드
    curl -o "$file_dir/$file_name" "$url"
done < "$URL_FILE"

