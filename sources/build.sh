#!/bin/sh
set -e

echo "Arima Naxos Fonts"

mkdir -p ./fonts ./fonts/Naxos/static/ttf ./fonts/Naxos/static/otf ./fonts/Naxos/variable

echo "Generating Arima Naxos Variable"
fontmake -g ./sources/ArimaNaxos.glyphs -o variable --output-path ./fonts/Naxos/variable/ArimaNaxos[wght].ttf

echo "Post processing VFs"
for ttf in ./fonts/Naxos/variable/*.ttf
do
	gftools fix-dsig --autofix $ttf
	gftools fix-nonhinting $ttf $ttf.fix
	mv $ttf.fix $ttf
	gftools fix-unwanted-tables --tables MVAR $ttf
	gftools fix-vf-meta $ttf;
	mv $ttf.fix $ttf;
done

rm ./fonts/Naxos/variable/*gasp*


echo "Generating Static fonts"
fontmake -g ./sources/ArimaNaxos.glyphs -i -o ttf --output-dir ./fonts/Naxos/static/ttf
fontmake -g ./sources/ArimaNaxos.glyphs -i -o otf --output-dir ./fonts/Naxos/static/otf


echo "Post processing TTFs"
ttfs=$(ls ./fonts/Naxos/static/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf
	ttfautohint $ttf $ttf.fix
	[ -f $ttf.fix ] && mv $ttf.fix $ttf
	gftools fix-hinting $ttf
	[ -f $ttf.fix ] && mv $ttf.fix $ttf
done


echo "Post processing OTFs"
otfs=$(ls ./fonts/Naxos/static/otf/*.otf)
for otf in $otfs
do
	gftools fix-dsig --autofix $otf
	gftools fix-weightclass $otf
	[ -f $otf.fix ] && mv $otf.fix $otf
done

rm -rf master_ufo/ instance_ufo/

echo "Complete!"
