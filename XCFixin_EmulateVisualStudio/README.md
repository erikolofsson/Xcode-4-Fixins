### Description

This fixin aims to emulate the editor behavior of the Visual Studio editor. The following features are implemented

+ `HOME` (`fn←` and `⌘←` on a Mac keyboard) jumps to first non-white space character and then cycles between start of line and first non-white space character
+ Text is not automatically indented when pasted
+ Insert tab indents selection instead of deleting it
+ Insert back tab unindents selection instead of deleting it
+ Move whole word left and right commands emulates the behavior in Visual Studio, where the location is the same when moving forward or backword
+ You can double-click on a <source>:<line>: formatted string in the the console to get to the location in the editor
+ `⌘-N` / `⌘-Shift-N` keyboard shortcuts moves to the next/previous location as in Visual Studio. This means:
 + Results in the issue navigator
 + Issues in the issue navigator
 + Source locations in the console output
 + It will use the same shortcut for all of these and use last active of them to go to the source location
+ Emulate keyboard behaviour of find and replace:
 + `Tab` / `Shift+Tab` goes between find and replace fields instead of stopping at find button first
 + Down arrow centers on the last recent item instead of on the options menu item
 + `Ctrl-N` finds next search result
 + `Ctrl-Shift-N` finds previous search result
 + `Ctrl-R` Replaces one result
 + `Ctrl-A` Replaces all results
 + `Ctrl-O` Shows the options panel
 + `Ctrl-C` Toggels match case
 + `Ctrl-E` Toggels regular expression
 + `Ctrl-W` Toggles whole word only matching
+ Run multiple schemes with `⌘-G` from one scheme by setting Custom working directory to "[MulitLaunchSchemes]" and the scheme names as arguments
 

### TODO
+ Keyboard shortcuts in batch find
+ Fix bug where breakpoint is not removed

### Installation

Download and compile the project (the plugin will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/` during build process)

### Credits

This fixin is based on [Xcode_beginning_of_line plugin](https://github.com/insanehunter/XCode4_beginning_of_line) written by [Sergei](https://github.com/insanehunter)

