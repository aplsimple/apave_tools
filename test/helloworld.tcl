#! /usr/bin/env tclsh
#
#############################################################
# Name:     helloworld.tcl
# Author:   wiki.tcl-lang.org
# Date:     Mar 15, 2025
# Brief:    Demonstrates application's main script.
# License:  MIT.
############################################################
#
package require Tk
wm withdraw .
ttk::style theme use clam
toplevel .dFW
wm withdraw .dFW
#...
#... initial commands
#... (creating Tk widgets etc.)
#...
set ::dockfile "../.bak/DFWtest.tcl"  ;# contains dockingFW layout
set ::apavefile -load                 ;# means DFWfile.tcl has to be loaded
source ../tools/dockingFW/dockingFW.tcl
#...
#... final commands
#... (inserting Tk widgets into panes etc.)
#...
pack [label .dFW.frant0.lab -text "Hello, world!" \
    -fg green -font {-size 20 -weight bold}] -fill both -exp 1
wm deiconify .dFW
#...
# ________________________ EOF _________________________ #
