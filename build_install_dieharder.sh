#!/bin/sh

INPUT_STRING=$(uname -s)
  case $INPUT_STRING in
	"Darwin")
		break
		;;
	*)
		echo "This build script is intended for macOS."
        read -n 1 key
        exit
		;;
  esac

echo "Dieharder 3.31.1.4 for macOS, the NON-developer edition"
mkdir logs

echo "Downloading GSL"
echo "CURL" > logs/curl.std.txt
echo "CURL" > logs/curl.err.txt
curl -L -o gsl.zip https://mirror.ibcp.fr/pub/gnu/gsl/gsl-latest.tar.gz >> logs/curl.std.txt 2>> logs/curl.err.txt
tar -xf gsl.zip >> logs/curl.std.txt 2>> logs/curl.err.txt
rm gsl.zip

echo "Downloading Dieharder"
curl -L -o dieharder.zip https://github.com/eddelbuettel/dieharder/archive/refs/tags/3.31.1.4.zip >> logs/curl.std.txt 2>> logs/curl.err.txt
unzip -u dieharder.zip 						>> logs/curl.std.txt 2>> logs/curl.err.txt
rm dieharder.zip

#Patching missing automake files in dieharder.
cp -f gsl-2.8/config.guess dieharder-3.31.1.4/config.guess
cp -f gsl-2.8/config.sub dieharder-3.31.1.4/config.sub

echo "Verifying brew."
if [ -x "$(command -v brew)" ]
then
echo Brew is installed
else
echo "Brew is not installed on your system."
echo "To install, follow the instructions on the webpage brew.sh."
echo "I will open the page for you after you hit enter."
read -n 1 key
open https://brew.sh
echo "Pressing enter when Brew is installed."
read -n 1 key
fi

echo "Installing libtool automake m4"
echo "BREW" 								> brew.std.txt
echo "BREW" 								> brew.err.txt
brew install libtool automake m4 			>> brew.std.txt 2>> brew.err.txt
echo 'export PATH="/opt/homebrew/opt/m4/bin:$PATH"' >> ~/.zshrc 2>> brew.err.txt

echo "Building GNU Scientific Library."
cd gsl-2.8
make 										>> ../logs/gsl.std.txt 2>> ../logs/gsl.err.txt
echo "Your password is needed to install GSL on your system."
sudo make install 							>> ../logs/gsl.std.txt 2>> ../logs/gsl.err.txt
cd ..

echo "Building DieHarder"
echo "DIEHARDER INSTALL LOG (stdout)"	 	> logs/dieharder.std.txt
echo "DIEHARDER ERROR LOG (stderr)" 		> logs/dieharder.err.txt
cd dieharder-3.31.1.4
./autogen.sh 								>> ../logs/dieharder.std.txt 2>> ../logs/dieharder.err.txt
./configure 								>> ../logs/dieharder.std.txt 2>> ../logs/dieharder.err.txt
make 										>> ../logs/dieharder.std.txt 2>> ../logs/dieharder.err.txt
echo "Your password is needed to install Dieharder on your system."
sudo make install 							>> ../logs/dieharder.std.txt 2>> ../logs/dieharder.err.txt
cd ..
