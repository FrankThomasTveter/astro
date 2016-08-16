# astro

The yr.no astronomical almanac library.

Installation should go something like this:

 git clone https://github.com/FrankThomasTveter/astro
 cd astro/src
 make
 cd astro/Metno-Astro-AlmanacAlgorithm/
 perl Makefile.PL
 make
 sudo make install
 debuild -i -us -uc -b
 
The resulting debian-packages are found at:
 cd ..
 ls libmetno-astro-almanacalgorithm-perl_0.10-1.deb

Good luck,
 Frank Tveter
