#!/bin/bash

ROOT="${1:-P:/2/r18/output}"
OUT_LIST="fail_1.txt"
TIMEOUT_SEC=120

# 既存ファイル削除
rm -f "$OUT_LIST"
echo "Output file: $OUT_LIST"
echo "Scanning: $ROOT"

# ファイルカウント
total=$(find "$ROOT" -type f 2>/dev/null | wc -l)
echo "Total files: $total"

count=0
fail_count=0

# 全ファイルをスキャン
find "$ROOT" -type f 2>/dev/null | while IFS= read -r file; do
  count=$((count + 1))
  
  if [ $((count % 1000)) -eq 0 ]; then
    echo "Processed: $count / $total, Failed: $fail_count"
  fi
  
  # ImageMagick で画像検証
  timeout "${TIMEOUT_SEC}s" magick "$file" -strip -write NUL: +delete >/dev/null 2>&1
  exit_code=$?
  
  # エラーまたはタイムアウト（exit 124）の場合
  if [ $exit_code -ne 0 ]; then
    echo "$file" >> "$OUT_LIST"
    fail_count=$((fail_count + 1))
  fi
done

echo "DONE. Failed list: $OUT_LIST"
wc -l "$OUT_LIST" 2>/dev/null || echo "No failed files"
