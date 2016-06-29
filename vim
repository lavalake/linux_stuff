https://courses.cs.washington.edu/courses/cse451/12sp/tutorials/tutorial_cscope.html

Cscope Tutorial
 
Cscope is a Linux tool for browsing source code in a terminal environment. C was originally built to work with C code, but also works well with C++, Java, and some other languages. Cscope is already well-documented, but this tutorial will explain its basic usage and explain how to use it with the Linux kernel code. For instructions beyond this tutorial, see the following resources:
 
•man 1 cscope
 •Cscope Home Page
 •Using Cscope on large projects (e.g. the Linux kernel)
 •Vim + Cscope tutorial
 
Cscope should already be installed on most Linux systems, including all CSE servers.
 

Cscope for a small project
 
There are a few easy steps required to start using Cscope. First, you need to tell it where all of your source code files are. Second, you need to generate the Cscope database. Finally, you can launch the Cscope browser to search for functions and symbols in your source code. Here are commands to perform these steps for a small C project, assumed to be in the directory ~/small-project/.
 1.
First, a small bit of setup: you should set the editor that Cscope will open your search results in. The default editor is vi; if you want to change it to something else, set the CSCOPE_EDITOR environment variable, e.g.:
 export CSCOPE_EDITOR=`which emacs`
 
Note that those are backticks, not single-quotes, in that command. Put this command in your .bashrc file if you'd like.
 
2.
cd to the top-level of your project directory and then use a find command to gather up all of the source code files in your project. The following command will recursively find all of the .c, .cpp, .h, and .hpp files in your current directory and any subdirectories, and store the list of these filenames in cscope.files:
 cd ~/small-project/
find . -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > cscope.files
 
Depending on your project, you can use additional file extensions in this command, such as .java, .py, .s, etc.
 
3.
Now, pass the list of source files to Cscope, which will build a reference database:
 cscope -q -R -b -i cscope.files
 
The -q flag is used to build a faster (but larger) database. -R tells Cscope to search for symbols recursively. -b builds the database only, but does not start the Cscope browser. -i cscope.files specifies the list of source files. The output of this command will be a set of files in your current directory: cscope.in.out, cscope.out, and cscope.po.out.
 
4.
Finally, start the Cscope browser:
 cscope -d
 
The -d flag tells Cscope not to regenerate the database (which you already did in the previous step). Within the Cscope browser, type ? to see the help page, and type Ctrl-d to exit. The browser will show you a list of the searches you can perform in your code:
 Find this C symbol:
Find this global definition:
Find functions called by this function:
Find functions calling this function:
Find this text string:
Change this text string:
Find this egrep pattern:
Find this file:
Find files #including this file:
 
Most of these should be self-explanatory. C symbols include pretty much anything that you can think of in a C file: function names, variable names, things that are #define'd, etc. You can search for all instances of a symbol, or find its original definition. Cscope can find all of the functions that call a particular function, which can be extremely useful; this is a feature of Cscope that other tools like Ctags do not have. If you find that the C symbol and function searches do not find what you are looking for, you can fall back to the text search options at the bottom of the list.
 


Select the type of search that you'd like to perform, type in your search term and hit Enter. At the top of the screen Cscope will display a list of results with the file, function, and line where the search term was found. If you select one of these results and hit Enter, Cscope will open up the editor to the matching line in the file. You can manipulate the file as you please, and when you close it the browser will appear again. When you're finished, press Ctrl-d to exit.
 

Caution!
 
When using Cscope on forkbomb, I've noticed some weirdness with searches being executed as case-sensitive when they shouldn't be, or vice-versa. If Cscope is returning no results from your search when you expect that there should be some, try toggling case-sensitive mode by pressing Ctrl-c inside of the Cscope browser (you'll see a toggle message at the top of the window).
 

Note
 
After making modifications to your source code, the cscope database will become out of sync, so you can periodically regenerate the database by running the find and cscope commands again.
 

Tip
 
When searching for "global definitions," sometimes Cscope will return multiple definitions, which is annoying. It appears that many forward declarations (i.e. function prototypes or declarations of structures that declare it but don't define it), and not just definitions, appear in Cscope's results. We haven't figured out a workaround for this issue, but usually you can find the function or structure definition that you're looking for by scanning through the results for a line with an open curly brace ({) or a line that doesn't end in a semicolon.
 

Tip
 
See the Cscope man page and help page (press ?) for some other useful arguments and commands for Cscope. For example:
 •-C disables case-sensitive search (this can also be toggled from within Cscope with Ctrl-c).
 •-p4 causes Cscope to prepend the directories (up to 4) leading to a source file in your tree when displaying its results.
 •Pressing Ctrl-b allows you to search for previous search terms again.
 
For more information on executing Cscope commands from directly within your editor (especially vi), see the list of resource links at the top of this tutorial.
 

Cscope for Project 1
 
Cscope (along with Ctags) is an invaluable tool for navigating through the Linux kernel code that is used in project 1. To begin, follow the instructions in the project 1 description or the git tutorial to get a copy of the Linux kernel source code. This tutorial will assume that your kernel code is located in the directory ~/cse451/project1-git/linux-2.6.38.2/. Using Cscope with the Linux kernel is mostly the same as with any other project, except that we use a more advanced find command to only search through the relevant files in the Linux code. Read the instructions in the previous section before following these steps.
 

Warning
 
Generating the entire Cscope database for the entire linux-2.6.38.2 kernel will require just over 400 MB of disk space if the -q flag is used. The size of the database can be reduced to about 225 MB if -q is omitted, but lookups may take longer. If this is still too large, you can try cd'ing into a subdirectory of the kernel and running the Cscope commands in just that directory.
 1.
Again, first make sure that Cscope is set to use your preferred editor, e.g.:
 export CSCOPE_EDITOR=`which emacs`
 
2.
We will now use a basic shell script to perform a more sophisticated find of the source files and build the Cscope database. Here is the code that should be put into the script:
 #!/bin/bash

LNX="."

echo "Finding relevant source files..."
find $LNX                                                                \
    -path "$LNX/arch/*" ! -path "$LNX/arch/x86*" -prune -o               \
    -path "$LNX/include/asm-*" ! -path "$LNX/include/asm-generic*"       \
                               ! -path "$LNX/include/asm-x86*" -prune -o \
    -path "$LNX/tmp*" -prune -o                                          \
    -path "$LNX/Documentation*" -prune -o                                \
    -path "$LNX/scripts*" -prune -o                                      \
    -name "*.[chxsS]" -print > $LNX/cscope.files

echo "Building cscope database..."
time cscope -q -k -b -i cscope.files

exit 0
 
To create and execute this script, run the following commands:
 cd ~/cse451/project1-git/linux-2.6.38.2/
edit cscope_kernel.sh
<copy the entire script from above into the file, save and exit>
chmod u+x cscope_kernel.sh
./cscope_kernel.sh
 
On a standard server, it may take 1-3 minutes for the script to run.
 

Details
 
The find command in the script above "prunes" (omits) the files that are found in several directories: the non-x86 directories under arch/ and include/asm-*, the Documentation/ and scripts/ directories, and any tmp directories. We use the -k flag with Cscope to tell it not to look for definitions in header files under /usr/include (usually Cscope automatically includes these header files in its searches, but these headers are for user-mode programs only and are not applicable to kernel code).
 
3.
After running the script to generate the database, you can start Cscope as described in the previous section:
 cscope -d
 
Don't forget the -d argument! Otherwise, Cscope may attempt to re-build its database, and it will do so with the wrong settings, so you'll have to run ./cscope_kernel.sh again.
 

--------------------------------------------------------------------------------

If you find any bugs in this tutorial, please e-mail them to the CSE 451 TAs. If you have any problems while using Cscope that are not covered in this tutorial, try the resources listed at the beginning of the tutorial, and then contact the TAs. If you find any cool new uses or features, post them to the class discussion board.
 
Author: Peter Hornyack (pjh@cs)
 

--------------------------------------------------------------------------------
View document source. Generated on: 2012-04-14 00:15 UTC. Generated by Docutils from reStructuredText source.




ctags & cscope: the fastest IDE
https://tuxdiary.com/2012/04/03/code-browsing-using-ctags-and-cscope/

 
