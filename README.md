# vrsn
Get the version of software tools.

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

$ go version
go version go1.9.3 darwin/amd64

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
# One command
$ vrsn ruby
2.4.3

$ vrsn java
9.0.1

# Multiple commands
$ vrsn ruby java go node convert
ruby    2.4.1
java    9.0.1
go      1.9.3
node    8.9.3
convert 7.0.7
```

## Installation

```
git clone
make install
```

## Usage

See also `vrsn --help` for documentation.

```
vrsn [options] <commands>

-r, --raw

Runs the provided command and presents its version output verbatim. Handy for when you don't care to remember the version flag for a command or when running with multiple commands
```

## Development

### Run tests

```
test/run.rb
```

### Support a new command

To add a new command, run `bin/generate`. It will prompt you interactively for the command, version flag, and version that it should extract. This will add a test case to the appropriate file in the `test/examples` directory and output a stub implementation to add to `lib/vrsn`.

You can also use it non-interactively with `test/generate.rb <cmd> <flag> <expected version>`

Commit your test and change together with the message "Support command `<name of command>`" and make a pull request.
