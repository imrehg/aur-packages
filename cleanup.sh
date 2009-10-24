#!/bin/bash

AUR_DIR=`dirname $0`

# Get a list of directories (ie, packages) in this directory
PKGS=`ls -lh $AUR_DIR | grep -E '^d' | awk '{ print $8 }'`

source /etc/makepkg.conf

# Loop through each package
for PKG in $PKGS ; do
	echo "Cleaning up $PKG"
	
	#echo "   Inspecting with namcap..."
	namcap --exclude=fileownership,tags $AUR_DIR/$PKG/PKGBUILD
	
	#echo -n "   Removing build files... "
	rm -Rf $AUR_DIR/$PKG/pkg
	if [ ${PKG:(-4)} != "-svn" ] ; then
		rm -Rf $AUR_DIR/$PKG/src	
	fi
	source $AUR_DIR/$PKG/PKGBUILD
	for SRC in ${source[@]} ; do
		IS_URL=`echo $SRC | grep -E '(http|ftp)://'`
		FNAME=`basename $SRC`
		if [ ! -z $IS_URL ] && [ -e "$AUR_DIR/$PKG/$FNAME" ] ; then
			rm "$AUR_DIR/$PKG/$FNAME"
		fi
	done
	#echo "Done"

	BUILT=`find $AUR_DIR/$PKG -maxdepth 1 -name \*.pkg.tar.gz -o -name \*.src.tar.gz`
	if [ ! -z "$BUILT" ] ; then
		#echo -n "   Moving built packages to $PKG/built... "
		if [ ! -d "$AUR_DIR/$PKG/built" ] ; then
			mkdir "$AUR_DIR/$PKG/built"
		fi
		for F in $BUILT ; do
			mv $F $AUR_DIR/$PKG/built/
		done
		#echo "Done"
	fi

	#echo -n "   Fixing permissions... "
	chmod 640 $AUR_DIR/$PKG/PKGBUILD
	chmod 750 $AUR_DIR/$PKG
	#echo "Done"
done

exit 0
