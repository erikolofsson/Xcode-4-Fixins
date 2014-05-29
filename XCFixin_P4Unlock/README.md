### Description

This fixin checks out files controlled by Perforce when trying to delete a read only file.

**Prerequisites**

* p4 executable in path
* Perforce configured to use P4CONFIG files
* A $P4CONFIG (usually .p4config) file in any parent directories of file being checked out

### Installation

Download and compile the project (the plugin will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/` during build process)

### Credits

Thanks to Dave Keck for XCode 4 Fixins project (https://github.com/davekeck/Xcode-4-Fixins)
