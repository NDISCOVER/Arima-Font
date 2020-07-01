#!/bin/sh
set -e

echo "Arima Fonts"

mkdir -p ./fonts ./fonts/static/ttf ./fonts/static/otf ./fonts/variable

echo "Generating static fonts"
fontmake -g ./sources/Arima.glyphs -i -o ttf --output-dir ./fonts/static/ttf
fontmake -g ./sources/Arima.glyphs -i -o otf --output-dir ./fonts/static/otf

echo "Post processing TTFs"
ttfs=$(ls ./fonts/static/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf
	ttfautohint $ttf $ttf.fix
	[ -f $ttf.fix ] && mv $ttf.fix $ttf
	gftools fix-hinting $ttf
	[ -f $ttf.fix ] && mv $ttf.fix $ttf
done

echo "Post processing OTFs"
otfs=$(ls ./fonts/static/otf/*.otf)
for otf in $otfs
do
	gftools fix-dsig --autofix $otf
	gftools fix-weightclass $otf
	[ -f $otf.fix ] && mv $otf.fix $otf
done

echo "Generating variable font"
fontmake -g ./sources/Arima.glyphs -o variable --output-path ./fonts/variable/Arima[wght].ttf

echo "Post processing VFs"
for ttf in ./fonts/variable/*.ttf
do
	gftools fix-dsig --autofix $ttf
	gftools fix-nonhinting $ttf $ttf.fix
	mv $ttf.fix $ttf
	gftools fix-unwanted-tables --tables MVAR $ttf
	gftools fix-vf-meta $ttf;
	mv $ttf.fix $ttf;
done

rm ./fonts/variable/*gasp*

rm -rf master_ufo/ instance_ufo/

echo "Complete!"
