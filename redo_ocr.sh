#!/bin/bash
# https://github.com/mah-jp/pdf4search/blob/master/pdf4search_wrapper.sh

set -a; source .env; set +a # load .env

# user's variables
COMMAND_CONVERT="./lib/redo_ocr/gcv2pdf.sh"

for PDF_FILE_PATH in $( find $PDF_DIR -type f -name '*.pdf' | sort ); do
	PDF_FILE_LOCK="${PDF_FILE_PATH}.lock"
	if [ ! -e "${PDF_FILE_LOCK}" ]; then
		echo "Start: ${PDF_FILE_PATH}"
		touch "${PDF_FILE_LOCK}"
		${COMMAND_CONVERT} "${PDF_FILE_PATH}"
		PDF_FILE_PATH_WITHOUT_EXT="${PDF_FILE_PATH%.pdf}"
		mv "${PDF_FILE_PATH_WITHOUT_EXT}.pdf" "${PDF_FILE_PATH_WITHOUT_EXT}.pdf.bak" # ocr書き換え済みのpdfをバックアップ
		mv "${PDF_FILE_PATH_WITHOUT_EXT}-ocr.pdf" "${PDF_FILE_PATH_WITHOUT_EXT}.pdf"
		mv "${PDF_FILE_PATH_WITHOUT_EXT}.pdf" "${DIR_OUTPUT}"
		rm "${PDF_FILE_LOCK}"
		echo "Done: ${PDF_FILE_PATH}"
	fi
done