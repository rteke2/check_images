# check_images - 画像破損検証ツール

## 目的
クラウドマウント上の大量画像を ImageMagick 全デコードで破損判定し、
通信断等の一過性エラーを除外するため、失敗ファイルだけをリトライして確定する。

## 背景
- ファイルの拡張子だけでは信用できない（全デコードが必須）
- クラウドマウントは通信が途中で切れることがあるため、1回の失敗=破損とは限らない
- 175,000件以上のファイルを効率的にチェックする必要がある

## 実行環境

### 必要なツール
- **ImageMagick 7.x** (画像検証用)
- **Bash** (Windows: Git Bash推奨)

### ImageMagick のインストール

**このリポジトリにはImageMagickインストーラーが含まれています。**

#### 最も簡単な方法（リポジトリ内インストーラー使用）:
```bash
# リポジトリをクローン
git clone https://github.com/rteke2/check_images.git
cd check_images

# Windowsでインストーラーを実行
./ImageMagick-7.1.2-11-Q16-HDRI-x64-dll.exe
```

インストール時の注意:
- **「Add application directory to your system path」にチェック**
- デフォルトインストール先: `C:\Program Files\ImageMagick`

#### Windows の場合（その他の方法）:
1. 公式サイトからダウンロード: https://imagemagick.org/script/download.php
2. `ImageMagick-*-Q16-HDRI-x64-dll.exe` をダウンロード
3. インストール実行（PATHに追加する）

確認コマンド:
```bash
magick --version
```

#### または winget でインストール:
```powershell
winget install ImageMagick
```

## 使用方法

### 1. 初回スキャン（全ファイルチェック）

```bash
cd check_images
bash scan_all_to_fail1.sh 'P:/2/r18/output'
```

または PowerShell版:
```powershell
powershell -ExecutionPolicy Bypass -File scan_all_to_fail1_v3.ps1 -Root 'P:\2\r18\output'
```

結果: `fail_1.txt` に失敗ファイルのリストが生成される

### 2. リトライ（一過性エラー除外）

```powershell
powershell -ExecutionPolicy Bypass -File retry_list.ps1 -InList fail_1.txt -OutList fail_2.txt
```

繰り返し:
```powershell
powershell -File retry_list.ps1 -InList fail_2.txt -OutList fail_3.txt
powershell -File retry_list.ps1 -InList fail_3.txt -OutList fail_4.txt
```

### 3. 最終判定
最後まで残った `fail_N.txt` のファイルを破損/恒常エラーとして扱う。

## スクリプト一覧

| ファイル | 説明 |
|---------|------|
| `scan_all_to_fail1.sh` | Bash版：全ファイルスキャン |
| `scan_all_to_fail1_v3.ps1` | PowerShell版：全ファイルスキャン（進捗表示付き） |
| `retry_list.ps1` | 失敗ファイルを再チェック |

## 開発経緯

### 問題1: PowerShell でのパス処理
- 日本語パスの処理で文字化けが発生
- リダイレクトエラー（`RedirectStandardOutput` と `RedirectStandardError` が同じ）
- 対策: リダイレクトを削除、Bash版を作成

### 問題2: ファイル列挙の失敗
- PowerShell の `Get-ChildItem` が日本語パスで動作しない場合がある
- 対策: Bash の `find` コマンドを使用

### 問題3: 実行時間
- 175,523ファイルの処理に約30分〜1時間
- タイムアウト設定: 120秒/ファイル

## トラブルシューティング

### magick コマンドが見つからない
```bash
# PATHを確認
echo $PATH | grep -i imagemagick

# または直接パス指定
/c/Program\ Files/ImageMagick/magick.exe --version
```

### ほぼ全ファイルがエラーになる
- ImageMagick が正しくインストールされているか確認
- `magick` コマンドが単体で動作するかテスト:
  ```bash
  magick "P:/2/r18/output/books/paywall/sample/1.jpg" -strip -write NUL: +delete
  ```

### クラウドマウントが切断される
- ネットワーク接続を確認
- リトライスクリプトで再実行

## ライセンス
MIT License
