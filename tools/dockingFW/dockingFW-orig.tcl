# DockingFramework

# published under BSD license

package require Tk
package require Ttk

namespace eval DockingFramework {

# tbs(tab_path)=panedwindow
# tbs(panedwindow_path)=parent_panedwindow
# tbs(path,path)=tab_path
variable tbs
variable tbcnt 0

# find notebook, corresponding to path
proc find_tbn {path} {
  variable tbs
  if {$path==""} { return "" }
  set top [winfo toplevel $path]
  while {$path!=$top} {
    if {[info exists tbs($path,path)]} {
      return $tbs($path,path)
    }
    if {[info exists tbs($path)]} {
      return $path
    }
    set path [winfo parent $path]
  }
  return {}
}

proc replace_tbn_with_pw {tbn anchor} {
  variable tbs
  variable tbcnt
  set pw $tbs($tbn)
  if {$tbn!=""} {
    set index [lsearch -exact [$pw panes] $tbn]
  }
  if {$anchor=="w" || $anchor=="e"} {
    set orient "horizontal"
  } else {
    set orient "vertical"
  }
  set npw [ttk::panedwindow [winfo toplevel $pw].pw$tbcnt -orient $orient]
  incr tbcnt
  set tbs($tbn) $npw
  if {$tbn==""} { # toplevel
    set grid_options [grid info $pw]
    grid forget $pw
    eval grid $npw $grid_options
    set tbn $pw
    set tbs($pw) $npw
    set tbs($npw) {}
  } else {
    $pw insert $index $npw -weight 1
    $pw forget $tbn
    set tbs($npw) $pw
  }
  set ntb [ttk::notebook [winfo toplevel $pw].tb$tbcnt]
  incr tbcnt
  set tbs($ntb) $npw
  if {$anchor=="s" || $anchor=="e"} {
    $npw add $tbn -weight 1
    $npw add $ntb -weight 1
  } else {
    $npw add $ntb -weight 1
    $npw add $tbn -weight 1
  }
  _raise_tree $tbn
  _raise_tree $ntb
  if {[get_class $tbn]=="TPanedwindow"} {
    _cleanup_pws $tbn
  }
  return $ntb
}

proc _raise_tree {path} {
  raise $path
  switch -exact [get_class $path] {
    TPanedwindow {
      foreach pane [$path panes] {
        _raise_tree $pane
      }
    }
    TNotebook {
      foreach tab [$path tabs] {
        raise $tab
      }
    }
  }
}

# add a new notebook to the side anchor of the notebook tbn
proc add_tbn {tbn anchor} {
  variable tbs
  variable tbcnt

  set pw $tbs($tbn)
  if {$pw==""} {return {}}
  set orient [$pw cget -orient]

  if {$anchor=="t"} {
    if {$tbn!=""} {
      return $tbn
    } else {
      set anchor [expr {$orient=="horizontal" ? "e" : "s"}]
    }
  }

  # if orientation of the uplevel panedwindow is consistent with anchor, just add the pane
  if {   ( $orient=="horizontal" && ($anchor=="w" || $anchor=="e") ) ||
         ( $orient=="vertical" && ($anchor=="n" || $anchor=="s") )      } {
    if {$tbn==""} {
      if {$anchor=="e" || $anchor=="s"} {
        set i [llength [$pw panes]]
      } else {
        set i 0
      }
    } else {
      set i [lsearch -exact [$pw panes] $tbn]
      if {$anchor=="e" || $anchor=="s"} { incr i }
    }
    set tbn [ttk::notebook [winfo toplevel $pw].tb$tbcnt]
    incr tbcnt
    set tbs($tbn) $pw
    if {$i>=[llength [$pw panes]] || $i<0} {
      $pw add $tbn -weight 1
    } else {
      $pw insert $i $tbn -weight 1
    }
    _raise_tree $tbn
  } else {
    set tbn [replace_tbn_with_pw $tbn $anchor]
  }
  return $tbn
}

proc get_class {path} { return [lindex [bindtags $path] 1] }

proc get_anchor {path x y} {
  variable tbs
  set tb [find_tbn $path]

  set rev {}
  if {$tb==""} {
    set tb $tbs()
    set rev -
  }
  set w [winfo width $tb]
  set h [winfo height $tb]

  set x [expr $x-[winfo rootx $tb]]
  set y [expr $y-[winfo rooty $tb]]

  set in_bbox [expr {(($x>=0 && $y>=0 && $x<=$w && $y<=$h) ? 1 : 0)}]

  if {($rev=="" && !$in_bbox) || ($rev!="" && $in_bbox) || $path==$tb} {
    return {}
  }

  if {[$tb identify [expr $x-[winfo rootx $tb]] [expr $y-[winfo rooty $tb]]]!=""} {
    set anchor "t"
  } elseif {$x>=[expr $w/3] && $x<=[expr $w*2/3] && $y>=[expr $h/3] && $y<=[expr $h*2/3]} {
    set anchor "t"
  } else {
    # determine the closest side to the cursor
    set side 1
    set rdist 1e6
    foreach {x0 y0} {0 0 0 0 $w 0 0 $h} a {w n e s} {
      set dist [expr abs($x-$x0)*$side+abs($y-$y0)*(1-$side)]
      set side [expr 1-$side]
      if {$dist<$rdist} {
        set rdist $dist
        set anchor $a
      }
    }
  }
  set rev {}
  if {$x<0 || $y<0 || $x>$w || $y>$h} {
    set rev -
  }
  array set cursors {
    s bottom_side
    w left_side
    e right_side
    n top_side
    t based_arrow_down
    {} {}
    -s top_side
    -w right_side
    -e left_side
    -n bottom_side
    -t {}
  }
  return [list $anchor $cursors($rev$anchor)]
}

proc _cleanup_pws {pw} {
  variable tbs
  while {$pw!=$tbs() && [$pw panes]==""} {
    destroy $pw
    set npw $tbs($pw)
    unset tbs($pw)
    set pw $npw
  }
}


proc _cleanup_tabs {srctab} {
  variable tbs
  if {[llength [$srctab tabs]]==0} {
    destroy $srctab
    _cleanup_pws $tbs($srctab)
    unset tbs($srctab)
  }
}

proc move_tab {srctab dsttab} {
  variable tbs
  # move tab
  set f [$srctab select]
  set o [$srctab tab $f]
  $srctab forget $f
  eval $dsttab add $f $o
  raise $f
  $dsttab select $f
  _cleanup_tabs $srctab
  set tbs($f,path) $dsttab
}

variable c_path {}
variable s_cursor {}

proc start_motion {path} {
  variable c_path
  variable s_cursor
  if {$path!=$c_path} {
    set c_path [find_tbn $path]
    if {$c_path=="" || [get_class $c_path]!="TNotebook" || [llength [$c_path tabs]]==0} {
      set c_path {}
      return
    }
    set s_cursor [$c_path cget -cursor]
  }
}

proc motion {x y} {
  variable c_path
  variable s_cursor
  if {$c_path!=""} {
    set path [winfo containing $x $y]
    if {$path==$c_path} {
      $c_path configure -cursor $s_cursor
    } else {
      $c_path configure -cursor [lindex [get_anchor $path $x $y] 1]
    }
  }
}

proc end_motion {x y} {
  variable c_path
  variable s_cursor
  if {$c_path==""} { return }
  set path [winfo containing $x $y]
  set anchor [lindex [get_anchor $path $x $y] 0]
  $c_path configure -cursor $s_cursor
  set tbn [find_tbn $path]
  if {$anchor!="" && ($tbn!=$c_path || ($path!=$c_path && $anchor!="t"))} {
    if {$anchor=="t"} {
      move_tab $c_path $tbn
    } else {
      move_tab $c_path [add_tbn $tbn $anchor]
    }
  }
  set c_path {}
}

bind TNotebook <Button-1> +[namespace code {start_motion %W}]
bind TNotebook <B1-Motion> +[namespace code {motion %X %Y}]
bind TNotebook <ButtonRelease-1> +[namespace code {end_motion %X %Y}]
bind TNotebook <Button-3> +[namespace code {__undock_tab %W}]

proc undock_tab {tab} {
  variable tbs

  set tbn $tbs($tab,path)
  set name [$tbn tab $tab -text]
  set opts [$tbn tab $tab]
  unset tbs($tab,path)
  set tbs($tab,undocked) [list $tbn $opts]

  $tbn forget $tab
  _cleanup_tabs $tbn

  wm manage $tab
  catch {wm attributes $tab -toolwindow 1}
  wm title $tab $name
  wm protocol $tab WM_DELETE_WINDOW [namespace code [list __dock $tab]]
  wm deiconify $tab
}

proc __dock {wnd} {
  variable tbs
  wm withdraw $wnd
  wm forget $wnd
  set tbn [lindex $tbs($wnd,undocked) 0]
  set opts [lindex $tbs($wnd,undocked) 1]
  unset tbs($wnd,undocked)

  if {![winfo exists $tbn]} {
    if {[$tbs() panes]==""} {
      set tbn [add_tbn {} t]
    } else {
      foreach tbn [array names tbs] {
        if {[winfo exists $tbn] && [get_class $tbn]=="TNotebook"} { break }
      }
    }
  }
  eval $tbn add $wnd $opts
  set tbs($wnd,path) $tbn
  raise $wnd
}

proc __undock_tab {wnd} {
  set tbn [find_tbn $wnd]
  if {$tbn=="" || [$tbn select]==""} { return }
  undock_tab [$tbn select]
}
proc __hide_tab {wnd} {
  set tbn [find_tbn $wnd]
  if {$tbn=="" || [$tbn select]==""} { return }
  hide_tab [$tbn select]
}

proc is_managed_tab {wnd} {
  if {[find_tbn $wnd]==""} { return 0 } else { return 1 }
}

proc create_framework {path} {
  variable tbs
  variable tbcnt
  set npw [ttk::panedwindow [winfo toplevel $path].pw$tbcnt -orient vertical]
  incr tbcnt
  set tbs($npw) {}
  set tbs() $npw
  grid $npw -in $path -sticky news
  grid columnconfigure $path 0 -weight 1
  grid rowconfigure $path 0 -weight 1
}

proc add_tab {tab path anchor args} {
  variable tbs
  if {$anchor=="t" && $path==""} {
    set anchor "e"
  } elseif {$anchor=="t"} {
    set tbn $tbs($path,path)
  } else {
    set tbn [add_tbn [find_tbn $path] $anchor]
  }
  eval [list $tbn add $tab] $args
  set tbs($tab,path) $tbn
  raise $tab
}

proc remove_tab {path} {
  variable tbs
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error "window $path is not managed by the framework"
  }
  catch {$tb forget $path}
  unset tbs($path,path)
  _cleanup_tabs $tb
}

proc select_tab {path} {
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error "window $path is not managed by the framework"
  }
  $tb select $path
}

proc hide_tab {path} {
  variable tbs
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error "window $path is not managed by the framework"
  }
  $tb hide $path
}

proc show_tab {path} {
  set tb [find_tbn $path]
  if {$tb=="" || [get_class $tb]!="TNotebook"} {
    error -code "window $path is not managed by the framework"
  }
  $tb add $path
}

proc get_managed_windows {}  {
  variable tbs
  set res {}
  foreach t [array names tbs *,path] {
    lappend res [string range $t 0 end-5]
  }
  return $res
}

proc serialize_widget {path} {
  variable tbs
  set class [get_class $path]
  upvar script script
  upvar sashscript sashscript
  if {[info exists tbs($path)]} {
    switch $class {
      TNotebook {
        append script "ttk::notebook $path\n"
        foreach tab [$path tabs] {
          serialize_widget $tab
          append script "$path add $tab [$path tab $tab]\n"
          append script "raise $tab\n"
          append script "$path select $tab\n"
        }
        append script "$path select [list [$path select]]\n"
      }
      TPanedwindow {
        append script "ttk::panedwindow $path -orient [$path cget -orient]\n"
        if {$path==$tbs()} {
          append script "eval grid \$tbs() \$tbs(grid_options)\n"
        }
        set i 0
        append sashscript "tkwait visibility $path\n"
        foreach pane [$path panes] {
          serialize_widget $pane
          append script "$path add $pane [$path pane $pane]\n"
          if {$i>0} {
            append sashscript "$path sashpos [expr $i-1] [$path sashpos [expr $i-1]]\n"
          }
          incr i
        }
      }
      default {
        error "serialization is not supported for the class $class"
      }
    }
  } else {
    catch {::serialize $path}
  }
}


proc serialize {} {
  variable tbs
  variable tbcnt
  set top [winfo toplevel $tbs()]
  set script "namespace eval ::DockingFramework \{\n"
  append script "if {\[\$tbs() panes]!=\"\"} { error \"Trying to overwrite existing layout\" }\n"
  append script "set tbs(grid_options) \[grid info \$tbs()\]\n"
  append script "destroy \$tbs()\n"
  append script "unset tbs(\$tbs())\n"
  append script "array set tbs [list [array get tbs]]\n"
  append script "set tbcnt $tbcnt\n"
  append script "wm geometry $top [wm geometry $top]\n"
  set sashscript ""
  serialize_widget $tbs()
  append script $sashscript
  foreach w [array names tbs *,undocked] {
    set w [string range $w 0 end-[string length ",undocked"]]
    append cmd "wm manage $w\n"
    append cmd "catch {wm attributes $w -toolwindow 1}\n"
    append cmd "wm title $w [list [wm title $w]]\n"
    append cmd "wm protocol $w WM_DELETE_WINDOW \[namespace code \[list __dock $w\]\]\n"
    append cmd "wm deiconify $w\n"
    append cmd "wm geometry $w [wm geometry w]\n"
  }
  append script "\}\n"
  return $script
}

}

if {1} {
toplevel .t1
pack [frame .t1.df] -fill both -expand true
pack [frame .t1.bc] -fill x

DockingFramework::create_framework .t1.df

for {set i 0} {$i<8} {incr i} {
  set ntab [label .t1.lb$i -text "notebook $i" -borderwidth 10]
  DockingFramework::add_tab $ntab {} e -text "tab $i"
}

pack [button .t1.bc.sl -text " Save layout " -command save_l] -side left -padx 4
pack [button .t1.bc.ll -text " Load layout " -command load_l] -side left -padx 4
pack [button .t1.bc.qq -text " Quit " -command exit] -side right -padx 8 -pady 4

proc save_l {} {
  variable layout
  set layout [DockingFramework::serialize]
  puts "layout: \n$layout"
}

proc load_l {} {
  variable layout
  if {![info exists layout]} { error "Save layout before loading" }
  foreach w [array names DockingFramework::tbs] {
    catch {destroy $w}
  }
  array set DockingFramework::tbs {}
  DockingFramework::create_framework .t1.df
  eval $layout
}

wm withdraw .

}