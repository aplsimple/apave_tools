This is a squeezed [apave package](https://github.com/aplsimple/pave).

It's only used here to get a regular Tk layout from [apave layout](https://github.com/aplsimple/pave) (that is feeded to *paveWindow* method of [apave package](https://github.com/aplsimple/pave)).

When a script with [apave layout](https://github.com/aplsimple/pave) loads this squeezed [apave package](https://github.com/aplsimple/pave) and calls *paveWindow* method of it, the regular Tk layout is put out to *stdout* channel. Thus, it can be redirected to a file, for example:

    tclsh ./.bak/apavetest.tcl > regularTklayout.tcl

Then the resulting *regularTklayout.tcl* can be run as a regular Tk GUI script (with adding inevitable code lines like "package require..." etc.):

    tclsh regularTklayout.tcl

Thus, you can use the squeezed [apave package](https://github.com/aplsimple/pave) to get a sophisticated GUI that doesn't require [apave package](https://github.com/aplsimple/pave) by itself, while originating from the [apave](https://github.com/aplsimple/pave)'s simple layout.