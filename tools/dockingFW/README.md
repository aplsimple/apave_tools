# What is this

The *dockingFW.tcl* is a tool to create the paned GUI.
It can be run with various arguments, to create Tcl/Tk files as results.

Both resulting .tcl files can be used as templates for further development.

If the script *dockingFW.tcl* runs as stand-alone app, then its arguments are used to set the variables:

  * *::dockfile* - file name for resulting file used with docking framework
  * *::apavefile* - file name for resulting apave file used with apave package
  * *::apavedir* - path to apave package
  * *::commands* - optional command(s) for $::dockfile (e.g. comments)

For example, this call

    tclsh dockingFW.tcl DFWfile.tcl apavefile.tcl ./lib/apave

uses arguments

  * *DFWfile.tcl* is the resulting *docking framework* GUI file name
  * *apavefile.tcl* is the resulting *apave* GUI file name
  * *./lib/apave* is a path to [apave package](https://github.com/aplsimple/pave) which should be referred to in the resulting *apavefile.tcl*

# Usage

After start, *dockingFW.tcl* shows 10 notebook tabs and sashes ("rulers").

Any tab can be dragged and dropped so that it's included as a neighbor tab or placed at left, right, top or bottom side of a tab or the window.

For this, click a tab's title with the left mouse button and move the tab to left / right/ top / bottom of a tab or the whole window.

Use the *rulers* to change the panes' sizes.

To *remove a tab*, click its title with the right mouse button.

Clicking *Save layout* button will save the current layout to *$::dockfile* and *$::apavefile*, as described above.

Clicking *Load layout* button will restore the saved layout.

<img src="https://github.com/aplsimple/apave_tools/releases/download/DockingFW-2.0/dfw1.jpg" class="media" alt="">

# 1st resulting file

If the script  *dockingFW.tcl* is sourced by a script, the variables are beforehand set by the latter this way:

  * *::dockfile* - file name for resulting file used with docking framework
  * *::apavefile* - *-l* or *-load* (means that $::dockfile has to be loaded)
  * *::apavedir* - "" (not used)
  * *::commands* - "" (not used)

If these values are arguments of the script as stand-alone app, it leads to loading the resulting *$::dockfile* as well.

So, the resulting *DFWfile.tcl* can be run with the *docking framework* as follows:

    tclsh dockingFW.tcl DFWfile.tcl -load

or

    tclsh dockingFW.tcl DFWfile.tcl -l

Also, you can *source* the resulting script *DFWfile.tcl* and enhance it with your Tk commands.

If, for example, your *main.tcl* is supposed to be the application's main script, then it can have the following structure:

    #! /usr/bin/env tclsh
    #
    #############################################################
    # Name:     main.tcl
    # Author:   my name
    # Date:     Mar 15, 2025
    # Brief:    my application's main script
    # License:  MIT.
    ############################################################
    #
    package require Tk
    wm withdraw .
    toplevel .dFW
    wm withdraw .dFW
    #...
    #... initial commands
    #... (creating Tk widgets etc.)
    #...
    set ::dockfile "DFWfile.tcl" ;# contains dockingFW layout
    set ::apavefile -load        ;# means DFWfile.tcl has to be loaded
    source dockingFW.tcl
    #...
    #... final commands
    #... (inserting Tk widgets into panes etc.)
    #...
    wm deiconify .dFW
    #...

**Note**: In the above code, *toplevel .dFW* creates the main form of application. The *.dFW* path is used by *dockingFW.tcl* for its *toplevel*: it contains the safe *catch {toplevel .dFW}* command, so there will be no problem with it.

# 2nd resulting file

When you want to use [apave package](https://github.com/aplsimple/pave), then take the resulting *apavefile.tcl*. Apart from *DFWfile.tcl*, it's a full featured Tcl/Tk script that is run independently.

Of course, you can enhance this *apavefile.tcl* with your layout items. It's a straightforward case, if you know what is the [apave package](https://github.com/aplsimple/pave).

# Links

  * [Source on ChiselApp](https://chiselapp.com/user/aplsimple/repository/apave_tools/download)

  * [Source on GitHub](https://github.com/aplsimple/apave_tools)

  * [Demo: DockingFW-2.0.mp4](https://github.com/aplsimple/apave_tools/releases/download/DockingFW-2.0/DockingFW-2.0.mp4) of using *dockingFW.tcl* in [alited](https://github.com/aplsimple/alited)

  * original *docking framework* at [wiki.tcl-lang.org](https://wiki.tcl-lang.org/page/Docking+framework)
