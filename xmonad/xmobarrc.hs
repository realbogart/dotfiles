Config
  { font = "FiraMono Nerd Font Mono 14"
  , additionalFonts = []
  , dpi = 120
  , bgColor = "#1f2430"
  , fgColor = "#d8dee9"
  , position = BottomSize C 100 34
  , lowerOnStart = True
  , allDesktops = True
  , persistent = True
  , commands =
      [ Run Date "%Y-%m-%d %H:%M" "date" 14
      ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = "}{ %date% "
  }
