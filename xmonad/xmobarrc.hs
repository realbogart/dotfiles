Config
  { font = "FiraMono Nerd Font Mono 12"
  , additionalFonts = ["FiraMono Nerd Font Mono 12"]
  , dpi = 120
  , bgColor = "#282828"
  , fgColor = "#b3deef"
  , position = BottomSize C 100 32
  , lowerOnStart = True
  , allDesktops = True
  , persistent = True
  , commands =
      [ Run UnsafeStdinReader
      , Run Date "%Y-%m-%d" "date" 600
      , Run Date "%H:%M" "time" 10
      ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = " %UnsafeStdinReader% }{ <action=`gsimplecal` button=1><fc=#d3b987>%date%</fc></action> <fc=#7c6f64>·</fc> <fc=#eeeeee>%time%</fc> "
  }
