Config
  { font = "FiraMono Nerd Font Mono 14"
  , additionalFonts = []
  , dpi = 120
  , bgColor = "#282828"
  , fgColor = "#b3deef"
  , position = BottomSize C 100 34
  , lowerOnStart = True
  , allDesktops = True
  , persistent = True
  , commands =
      [ Run Date "%Y-%m-%d" "date" 600
      , Run Date "%H:%M" "time" 14
      ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = "}{ <fc=#d3b987>%date%</fc> %time% "
  }
