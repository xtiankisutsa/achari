#!/bin/bash

function logo(){
cat << "EOF"
  ___       _                _ 
 / _ \     | |              (_)
/ /_\ \ ___| |__   __ _ _ __ _ 
|  _  |/ __| '_ \ / _` | '__| |
| | | | (__| | | | (_| | |  | |
\_| |_/\___|_| |_|\__,_|_|  |_|   
                                                                                              
EOF
	echo "Version: 0.1.0 beta"
	echo "Developed by: Christian Kisutsa"
	echo ""
}



#+++++++
#ACHARI
#+++++++
#Check if option and codes file has been provided
if ! [ "$1" ] || [ "$1" == '-h' ]  || [ "$1" == '--help' ] || ! [ "$2" ]; then 
logo
echo "Usage:"
echo "[options] <path/to/keep_note/folder>"
echo ""
echo "Options:
-p, --pdf   - convert notes to PDF
-i, --png   - convert note to PNG file
-h, --help  - print this help"
echo " "
echo "Example:
Convert to PDF e.g $0 --pdf </full/path/to/keep_note/folder>
Convert to PNG e.g $0 --png </full/path/to/keep_note/file>"

exit -1
fi

#++++++++++++++++++++
#Convert HTML to PDF
#+++++++++=++++++++++
if [ $1 == '-p' ] || [ $1 == '--pdf' ] ; then


logo
	
echo "==================="
echo " Converting to PDF "
echo "==================="
echo "[-]Enter PDF title:"
read pdf_title
echo ""
echo "[-]Enter PDF file name: (without whitespace and .pdf)"
read pdf_name
echo ""

echo "[-]Setting up environment..."
mkdir -p buffer/
touch buffer/pages.txt
touch buffer/images.txt
echo ""

#Find the necessary html files
echo "[-]Listing files to convert..."
find $2 -name "page*" -type f -exec ls {} \; | sort -V | tee buffer/pages.txt
echo ""

echo "[-]Listing images to convert..."
find $2 -name "*png" -type f -exec ls {} \; | sort -V | tee buffer/images.txt
find $2 -name "*jpg" -type f -exec ls {} \; | sort -V | tee -a buffer/images.txt
echo ""

files_no=`wc -l buffer/pages.txt | cut -d " " -f 1`
echo "[-]Processing $files_no files...."

count=1

	while read html_file;
	
	do	
		cp "$html_file" buffer/$count.html		
		count=`expr $count + 1`
	
	done <"buffer/pages.txt"

	while read image_file;
	
	do	
		
		cp "$image_file" buffer/		
		count=`expr $count + 1`
	
	done <"buffer/images.txt"
echo " "


cd tools/

#Get the necessary HTML files
page_files=`ls ../buffer/*.html | sort -V`

#Generate the PDFs
echo "[-]Generating shrinked PDF"
./wkhtmltopdf --page-size "A4" --title "$pdf_title" --footer-left "[doctitle]" --footer-right "[page]/[toPage]" --footer-line \
        --header-center "[title]" --header-line $page_files "$pdf_name"_small.pdf
echo " "
echo "[-]Generating regular PDF"
./wkhtmltopdf --page-size "A4" --title "$pdf_title" --footer-left "[doctitle]" --footer-right "[page]/[toPage]" --footer-line \
        --header-center "[title]" --header-line $page_files --disable-smart-shrinking "$pdf_name"_large.pdf
echo ""
cd ../

#Tidy up
echo "[-]Cleaning up.."
mv tools/"$pdf_name"_small.pdf tools/"$pdf_name"_large.pdf .
rm -r buffer/

fi

#++++++++++++++++++++
#Convert HTML to PNG
#+++++++++=++++++++++
if [ $1 == '-i' ] || [ $1 == '--png' ] ; then

#Call the necessary functions
logo
echo "==================="
echo " Converting to PNG "
echo "==================="
echo "[-]Enter PNG file name: (without whitespace and .png)"
read png_name
echo ""

echo "[-]Generating PNG"
./wkhtmltoimage "$2" "$png_name".png

fi


