####################################
# Options availables:
#   compress: compress all pdf files
#   ocr: search for pdf files and then apply a ocr layer to them
#   search: search pdf files
#   searchcom: search compress pdf files
#   searchnocom: search for non compress pdf files and then compress them
#   enhance: search for non compress pdf files and then enhance them
#   ocr_enh: search for compress pdf files and then apply a ocr layer to them
####################################
selection="searchnocom"
####################################

dir=$1
real_dir=`echo $(realpath -s $dir)`
folder_option=$selection
new_dir="${real_dir}_${folder_option}"
clear

compress ()
{
	echo "in $PWD path"
	for f in *.pdf; do
		originalname="${f%}"
		if [[ "$f" =~ .*"pdf".* ]]
		then
			newname="compress_${f%}"
			echo "making new compress pdf file: $newname"
			gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.6 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${newname}" "${originalname}"
			echo "Deleting old pdf file: $originalname"
	        rm -rf $originalname
		fi
	done
}

ocr ()
{
	echo "in $PWD path"
	for f in *.pdf; do
		originalname="${f%}"
		if [[ "$f" =~ .*"pdf".* ]]
		then
			newname="ocr_${f%}"
			echo "making new pdf file with ocr layer: $newname"
			ocrmypdf -q -l spa --rotate-pages --force-ocr "${originalname}" "${newname}"
			echo "Deleting old pdf file: $originalname"
	        #rm -rf $originalname
		fi
	done
}

search ()
{
	cd $real_dir
	echo "in $PWD path"
	for f in *.pdf; do
		originalname="${f%}"
		echo "found pdf file: $f"
	done
}

searchcom ()
{
	cd $dir
	for f in *.pdf; do
		originalname="${f%}"
		if [[ "$f" =~ .*"compress".* ]]; then
			echo "found compress pdf file: $f"
		fi
	done
}

searchnocom ()
{
	echo "in $PWD path"
	for f in *.pdf; do
		if [[ ! "$f" =~ .*"compress".* ]]; then
			originalname="${f%}"
		    newname="compress_${originalname%}"
			echo "found no compress file: $originalname"
			echo "making new compress file: $newname"
			gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.6 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${newname}" "${originalname}"
			echo "Deleting old pdf file: $originalname"
	        rm -rf $originalname
		fi
	done
}

ocr_enh ()
{
	echo "in $PWD path"
	for f in *.pdf; do
		if [[ "$f" =~ .*"enhanced".* ]]; then
			originalname="${f%}"
		    newname="ocr_${originalname%}"
			echo "found compress file: $originalname"
			echo "making new pdf file with ocr: $newname"
			ocrmypdf -q -l spa --rotate-pages --deskew --force-ocr "${originalname}" "${newname}"
			echo "Deleting old pdf file: $originalname"
	        #rm -rf $originalname
		fi
	done
}

enhance ()
{
	echo "in $PWD path"
	for f in *.pdf; do
		if [[ ! "$f" =~ .*"compress".* ]]; then
			originalname="${f%}"
		    newname="enhanced_${originalname%}"
			echo "found no compressed file: $originalname"
			echo "making new enhanced pdf file: $newname"
			convert -density 300 "${originalname}" -strip -quality 100 -black-threshold 47% -contrast -despeckle -enhance -auto-level -antialias  -enhance -enhance -fuzz 40% -fill white -despeckle -enhance -compress Zip "${newname}"
			#convert -density 300 "${originalname}" -threshold 67% -contrast -despeckle -enhance -auto-level -antialias -strip -compress Zip "${newname}"
			echo "Deleting old pdf file: $originalname"
	        #rm -rf $originalname
		fi
	done
}

if [[ $selection == "compress" ]]; then
	echo "running job: 'compress pdfs'"
	mkdir -p "${new_dir}" && cp -r $dir/* $new_dir
	cd $new_dir
	compress
fi

if [[ $selection == "search" ]]; then
	echo "running job: 'search pdfs'"
	search
fi

if [[ $selection == "searchcom" ]]; then
	echo "running job: 'search compress pdfs'"
	searchcom
fi

if [[ $selection == "searchnocom" ]]; then
	echo "running job: 'compress no compressed pdfs'"
	mkdir -p "${new_dir}" && cp -r $dir/* $new_dir
	cd $new_dir
	searchnocom
fi

if [[ $selection == "enhance" ]]; then
	echo "running job: 'enhance pdfs'"
	mkdir -p "${new_dir}" && cp -r $dir/* $new_dir
	cd $new_dir
	enhance
fi

if [[ $selection == "ocr_enh" ]]; then
	echo "running job: 'ocr to enhanced pdfs'"
	mkdir -p "${new_dir}" && cp -r $dir/* $new_dir
	cd $new_dir
	ocr_enh
fi

if [[ $selection == "ocr" ]]; then
	echo "running job: 'ocr'"
	mkdir -p "${new_dir}" && cp -r $dir/* $new_dir
	cd $new_dir
	ocr
fi

if [[ $selection == "resoluciones" ]]; then
	echo "running jobs with: 'resoluciones'"
	mkdir -p "${dir}_enhance" && cp -r $dir/* "${dir}_enhance"
	cd "${dir}_enhance"
	enhance
	cd ..
	mkdir -p "${dir}_enhance_ocr_enh" && cp -r ${dir}_enhance/* "${dir}_enhance_ocr_enh"
	cd "${dir}_enhance_ocr_enh"
	ocr_enh
	cd ..
	mkdir -p "${dir}_terminado" && cp -r ${dir}_enhance_ocr_enh/* "${dir}_terminado"
	cd "${dir}_terminado"
	searchnocom
	cd ..
	mkdir "${dir}_join"
	pdftk ${dir}_terminado/* output ${dir}_join/join.pdf
	echo "### running spliter ###"
	mkdir "${dir}_separados"
	ruby '/home/jonathan/Documentos/programas en Ruby/separador_pdfs.rb' "${dir}_join" "${dir}_separados"
fi

if [[ $selection == "fichas" ]]; then
	echo "running jobs with: 'fichas'"
	mkdir -p "${new_dir}" && cp -r $dir/* $new_dir
	cd $new_dir
	searchnocom
	cd ..
fi

#rm -rf "${dir}_enhance" "${dir}_enhance_ocr_enh" "${dir}_terminado" "${dir}_join"

echo ""
echo "###########################"
echo "Terminada las tareas..."
echo "###########################"
echo ""
