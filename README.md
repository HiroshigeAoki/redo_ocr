# redo_ocr

Google Cloud Vision API を使ってPDFのOCRを書き換えるスクリプトです。

## 使用方法

1. Google Cloud Platform でプロジェクトを作成し、APIを有効にする
2. Google Cloud Vision API service account key fileをダウンロード
3. cat example.env > .envで環境変数ファイルを作成し必要な情報を記入。
   1. ダウンロードしたkey fileのパスをGOOGLE_APPLICATION_CREDENTIALSに設定。
   2. 元のPDFファイルのパスをINPUT_FILEに設定
   3. OCRを書き換えたPDFファイルを保存するパスをOUTPUT_FILEに設定
4. pythonの仮想環境を作成し、必要なライブラリをインストール
   1. python -m venv venv
   2. source ./venv/bin/activate
   3. pip install -r requirements.txt
5. 実行
   1. bash redo_ocr.sh
