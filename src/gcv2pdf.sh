#!/bin/bash
# https://github.com/mah-jp/pdf4search/blob/master/pdf4search.sh

set -a; source .env; set +a # load .env

GCV2OCR_CMD="./src/redo_ocr/gcvocr.sh"
GCV2HOCR_CMD="./venv/bin/python ./src/redo_ocr/gcv2hocr.py"
HOCR2PDF_CMD="./venv/bin/python ./src/redo_ocr/hocr2pdf.py"

PDF_PATH="$1"
PDF_FILENAME=$(basename "$PDF_PATH")
PDF_DIR=$(dirname "$PDF_PATH")
TMP_DIR="/tmp/${PDF_FILENAME%.*}"
TMP_DPI=300
OUTPUT_FILENAME="${PDF_FILENAME%.*}-ocr.pdf"
ERROR_LOG_FILE_PATH="${PDF_DIR}/${PDF_FILENAME}_ERROR.log"

# pdf -> jpeg
mkdir -p "${TMP_DIR}"
echo "Converting pdf -> jpeg"
pdftoppm -r ${TMP_DPI} -jpeg "${PDF_PATH}" "${TMP_DIR}/page"

# TODO: 例外処理の追加(たまに、jpegの中身が空になることがあり、その時、GCV2OCR_CMDがエラーになる。)
# jpeg -> Google Cloud Vision -> hocr
for JPG_FILE_PATH in $(find ${TMP_DIR} -type f -name '*.jpg' | sort); do
	JPG_FILENAME=$(basename "$JPG_FILE_PATH") # page-01.jpg
	PAGE=${JPG_FILENAME%.*} # page-01
	HOCR_FILE_PATH=${TMP_DIR}/${PAGE}.hocr # $TMP_DIR/page-01.hocr
	JSON_FILE_PATH=${TMP_DIR}/${JPG_FILENAME}.json # $TMP_DIR/page-01.jpg.json
	echo "gcvocr.sh: ${JPG_FILE_PATH} > ${JSON_FILE_PATH}"
	${GCV2OCR_CMD} "${JPG_FILE_PATH}"
	echo "gcv2hocr: ${JSON_FILE_PATH} ${HOCR_FILE_PATH}"
	${GCV2HOCR_CMD} --savefile "${HOCR_FILE_PATH}" "${JSON_FILE_PATH}" >> "${ERROR_LOG_FILE_PATH}"
done

# hocr+jpg -> pdf
# TODO: metaデータを引き継ぐ(pdfInfo➔.pdfmarkfileを作成する。https://unix.stackexchange.com/questions/489230/where-is-metadata-for-pdf-files-can-i-insert-metadata-into-any-pdf-file)
echo "Generating: ${OUTPUT_FILENAME}"
${HOCR2PDF_CMD} --savefile "${TMP_DIR}/${PDF_FILENAME}" "${TMP_DIR}/"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/default -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${PDF_DIR}/${OUTPUT_FILENAME}" "${TMP_DIR}/${PDF_FILENAME}"

#rm -r "${TMP_DIR}"