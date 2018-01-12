# vrsn
Get the version of software tools

Versions are one of the 17 terrible things about computers. `vrsn` makes the problem a tiny bit better.

Every program has a different way to get its version and a different output. `vrsn` makes it simple by providing a uniform interface.

**Before**

```
$ ruby --version
ruby 2.4.3p205 (2017-12-14 revision 61247) [x86_64-darwin16]

$ java -version
java version "9.0.1"
Java(TM) SE Runtime Environment (build 9.0.1+11)
Java HotSpot(TM) 64-Bit Server VM (build 9.0.1+11, mixed mode)

$ python -V
Python 2.7.10

$ node --version
v8.9.4

$ convert -version
Version: ImageMagick 7.0.7-8 Q16 x86_64 2017-10-24 http://www.imagemagick.org
Copyright: © 1999-2017 ImageMagick Studio LLC
License: http://www.imagemagick.org/script/license.php
Features: Cipher DPC HDRI Modules 
Delegates (built-in): bzlib freetype jng jpeg ltdl lzma png tiff xml zlib
```

**After**

```
$ vrsn ruby
2.4.3

$ vrsn java
9.0.1

$ vrsn python
2.7.10

$ vrsn node
8.9.4

$ vrsn convert
7.0.7
```

## Installation

## Usage

## Development
