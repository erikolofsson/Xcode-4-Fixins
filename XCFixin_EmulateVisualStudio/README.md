### Description

This fixin aims to emulate the editor behavior of the Visual Studio editor. The following features are implemented

+ `HOME` (`fn←` and `⌘←` on a Mac keyboard) jumps to first non-white space character and then cycles between start of line and first non-white space character
+ Text is not automatically indented when pasted
+ Insert tab indents selection instead of deleting it
+ Insert back tab unindents selection instead of deleting it
+ Move whole word left and right commands emulates the behavior in Visual Studio, where the location is the same when moving forward or backword


### Installation

Download and compile the project (the plugin will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/` during build process)

### Credits

This fixin is based on [Xcode_beginning_of_line plugin](https://github.com/insanehunter/XCode4_beginning_of_line) written by [Sergei](https://github.com/insanehunter)

