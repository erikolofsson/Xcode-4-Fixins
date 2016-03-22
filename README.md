__These plugins are only maintained for the latest version of Xcode (currently 7.3)__

__===== DESCRIPTION =====__

This project includes plugins (known as _fixins_) that extend Xcode
and fix some of its annoying behaviors.

__===== INSTALLATION (Xcode 7) =====__

Despite the name, the Xcode 4 Fixins are compatible with Xcode 7.

To install the fixins:

1. Open the XCFixins workspace
2. Change the scheme to "Release All maintained"
3. Build the fixins

The fixins will automatically be installed as a part of the build
process. Xcode must be relaunched for the fixins to take effect.

Fixins are installed into ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/.

__===== MAINTAINED FIXINS =====__

__EmulateVisualStudio__:
This fixin aims to emulate the editor behavior of the Visual Studio editor. The following features are implemented

+ `HOME` (`fn←` and `⌘←` on a Mac keyboard) jumps to first non-white space character and then cycles between start of line and first non-white space character
+ Text is not automatically indented when pasted
+ Insert tab indents selection instead of deleting it
+ Insert back tab unindents selection instead of deleting it
+ Move whole word left and right commands emulates the behavior in Visual Studio, where the location is the same when moving forward or backword
+ You can double-click on a <source>:<line>: formatted string in the the console to get to the location in the editor
+ `⌘-N` / `⌘-Shift-N` keyboard shortcuts moves to the next/previous location as in Visual Studio. This means:
 + Results in the batch find navigator
 + Issues in the issue navigator
 + Source locations in the console output
 + Files in the project navigator
 + It will use the same shortcut for all of these and use last active of them to go to the source location
+ `Option-N` keyboard shortcuts opens folder in navigator and moves to the next location. This means:
 + Issues in the issue navigator
 + Files in the project navigator
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
 + `Esc` Returns to editor from batch find

Also fixes limitations bugs in Xcode

+ Run multiple schemes with `⌘-G` from one scheme by setting Custom working directory to "[MulitLaunchSchemes]" and the scheme names as arguments
+ `Ctrl-H` Toggles breakpoints more reliably than the built in shortcut for toggling breakpoints (workaround for Xcode bug)
+ Ability to stop the debugger from setting DYLD_INSERT_LIBRARIES, DYLD_LIBRARY_PATH and DYLD_FRAMEWORK_PATH. Accessbile from Edit->Xcode fixes options... or `Ctrl+O`
+ Batches external updates and automatically reloads them. .xcworkspace and .xcproj folders needs to have a 'generatedContainer' file in them to enable. For use with external project generators.
+ Disable the build queue throttling in Xcode

__CurrentLineHighlighter__: This fixin highlights the line currently
being edited in the source editor, making it easier to track the
current insertion point. This fixin adds a "Current Line Highlight
Color..." menu item to the Editor menu to set the highlight color.

__CustomizeWarningErrorHighlights__: Customize the inline
error/warning message highlight color. Useful if want to be able to
read your code when using a dark background color.

Note that the CustomizeWarningErrorHighlights fixin includes a
reference to an Xcode framework; to build this fixin, Xcode must be
installed in the default location of /Applications/Xcode.app/.

__DisableAnimations__: This fixin disables Xcode's various
NSAnimation-based animations, such as the Show/Hide Debug Area,
Show/Hide Navigator, and Show/Hide Utilities animations.

__HideDistractions__: This fixin adds a "Hide Distractions" menu item
to the View menu, which focuses the current editor by hiding auxiliary
views and maximizing the active window. This fixin works best when the
XCFixin_DisableAnimations fixin is also installed.

The default key combination for the 'Hide Distractions' menu item is
command-shift-D, which interferes with Xcode's default key combination
for 'Jump to Instruction Pointer' (under the Navigate menu), so you
may want remove that key binding to free up command-shift-D.
Alternatively, you can modify the 'Hide Distractions' key combination
by editing XCFixin_HideDistractions.m and changing the
kHideDistractionsKey and kHideDistractionsKeyModifiers constants at
the top of the file.

__InhibitTabNextPlaceholder__: This fixin disables using the tab key
to select between argument placeholders of a synthesized (by Xcode's
code completion) method call. Xcode's default tab functionality can be
annoying if you've synthesized a method invocation and attempt to
indent something nearby before filling-in the argument placeholders;
in such a case, Xcode jumps to the nearest argument placeholder
instead of indenting. This fixin does not affect the "Jump to Next
Placeholder" key binding in the Xcode preferences.

__P4Checkout__:
This fixin checks out files controlled by Perforce when trying to edit a read only file.

***Prerequisites***

* p4 executable in path
* Perforce configured to use P4CONFIG files
* A $P4CONFIG (usually .p4config) file in any parent directories of file being checked out

__Highlight__:
This fixin adds additional highlighting functionality to C dialects. Currently hardcoded with prefixes used to identify different language constructs.

__===== UNMAINTAINED FIXINS =====__

These fixins ane not maintained, but might still work.

__MiniXcode__:
This is a plugin that makes it easier to run Xcode without the main toolbar. It adds keyboard shortcuts for selecting the active scheme and device (`Ctrl`+`7` / `Ctrl` + `8`), and a compact popup menu in the window title bar that shows the currently selected run configuration.

While building a target, a circular spinner, the current progress (%) and all eventual errors, warnings and analyzer results are shown. 

You can disable the popup from the _View_ menu if you find it distracting, the keyboard shortcuts will also work without it. The popup is automatically hidden when the main toolbar is visible.

__FindFix__: By default, when Xcode's inline find bar opens, it
doesn't display any options to customize searching. This fixin makes
Xcode show all find options (such as "Ignore Case") in the find bar
when it opens. This fixin also makes text-replacement the default mode
in the inline find bar, giving immediate access to the "Replace" and
"Replace All" buttons.

The FindFix fixin also installs an additional option in the Find menu:
__Auto Populate Find Bar__. When ticked, and the find bar is
activated, the search text will be set to the text of the current
selection, if any, or the word at the cursor.

__TabAcceptsCompletion__: Upon pressing tab, this fixin makes Xcode
accept the currently-highlighted completion suggestion in the popup
list. (Xcode's default tab behavior accepts only as much of the
highlighted completion that is common amongst other suggestions.)

__UserScripts__: Reinstates some semblance of the Xcode 3.x User
Scripts menu. See documentation in the XCFixin_UserScripts directory.


