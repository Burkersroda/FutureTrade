![Space In Motion: FutureTrade](documentation/FutureTrade_title_on_white.png "Space In Motion: FutureTrade")

# Space In Motion: FutureTrade

This repository contains the source code, assets and executable binaries using the [DOSBox-X](https://dosbox-x.com) emulator for my first commercially released software product. It is a economy simulation game for [DOS](https://en.wikipedia.org/wiki/DOS), which had been mainly programmed in [Turbo Pascal](https://en.wikipedia.org/wiki/Turbo_Pascal) and artistically designed in [Reflections/Monzoom](https://en.wikipedia.org/wiki/Amiga_Reflections). Except music and sound, which were produced by [Marcus Franke](https://www.mobygames.com/developer/sheet/view/developerId,369124/), I made everything (code, art, logic, design) by myself in four years of development and private studies besides school, military service and university. In 2000 the game was released to the German, Austrian and Swiss retail market in a cardboard box including a CD-ROM by Kelly Media, which was a software publisher that does not exist anymore.

## Documentation

Because the game was released in German speaking territories only the binaries and the manual are not available in another language up to now. Even most of the code comments are German while most of the function names are English.

**[German Manual](https://lightrocker.lightrock.biz/FutureTrade/manual/de-de/)** ([GitHub folder](./manual/German/index.html))

![Capital](documentation/Capital.jpg "Capital")

## History

For me that product was the result of an autodidactic education, which allowed me to offer my programming abilities as a freelancer for other commercial game projects. Up to this time I already worked as a editor and animation creator for a local TV station. And I was only able to create those animations because I had already gained the skills to build 3D models and animate them. Later that experience became a key factor to design and implement multiple realtime 3D graphic engines and was very helpful as a programmer to communicate with artists and plan projects.

Even I had learnt many things for my job, not everything is represented in this project because of the long development time and I improved myself further a lot since then. There are flaws, which you can discover yourself in the repository: German texts only, missing comments in a lot of files, procedural instead of object oriented code or 16 bit DOS executables. Because of the system requirements for the performance the game needs a 32 bit CPU at least, so using only 16 bit instructions wastefully prevents from speed optimizations. And in the year 2000 nearly nobody used pure DOS operating systems anymore. The product had support for [Microsoft Windows 95/98/Me](https://en.wikipedia.org/wiki/Windows_9x) like the creation of start menu entries or improved installation speed but later incompatibility problems occurred and the program could not be executed without issues on newer Windows systems. It is not even possible to play the game using the original [DOSBox](https://www.dosbox.com/) because of trouble with the mouse emulation.

The project occupied a large part of my adolescence and is the foundation of profession, so I had the demand to make it playable again and to archive it for the future. After being able to do so using DOSBox-X I decided to create a setup package, which is working as easy as possible for the user, and to officially make the formerly commercial product available as [freeware](https://en.wikipedia.org/wiki/Freeware) to the public. But I did not stop there and am also publishing the source code under the [GPL](https://github.com/Burkersroda/FutureTrade/blob/main/LICENSE) now. Maybe it is interesting for some retro research. Have fun! Otherwise I hope my work can be preserved for eternity that way. ;-)

## Key Features

- Release package, executable on Windows system up to version 10 at least
- Source code of a complete game
	- [2.5D](https://en.wikipedia.org/wiki/2.5D) terrain visualization with multiple levels, [scanline rendering](https://en.wikipedia.org/wiki/Scanline_rendering), [Gouraud shading](https://en.wikipedia.org/wiki/Gouraud_shading) and [8 bit color](https://en.wikipedia.org/wiki/8-bit_color) [dithering](https://en.wikipedia.org/wiki/Dither) completely written in [Assembler](https://en.wikipedia.org/wiki/Assembly_language)
	- [RLE](https://en.wikipedia.org/wiki/Run-length_encoding) image compression with improvements for a proprietary [video codec](https://en.wikipedia.org/wiki/Video_codec)
	- [SVGA](https://en.wikipedia.org/wiki/Super_VGA) rendering (640x480x8 bit = 300kB) with [16 bit instructions](https://en.wikipedia.org/wiki/16-bit_computing) (restricted to 64kB memory blocks)
	- own [archive file format](https://en.wikipedia.org/wiki/Archive_file) to combine multiple asset files into single ones
	- procedural generated maps (levels)
	
One feature that could not be transferred into this repository is CD music. First DOSBox-X is not able to mount the image of the original CD-ROM and on the other hand I am out of touch with the composer to ask for permission.

## Credits

This project makes use of the [SMIX Programming Library by Ethan Brodsky](http://homepages.cae.wisc.edu/~brodskye/smix/smix.html).

![Truck model](documentation/Truck_model.jpg "Truck model with wireframe display")