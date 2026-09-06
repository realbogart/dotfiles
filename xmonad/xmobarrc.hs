Config
  { font = "FiraMono Nerd Font Mono 11"
  , additionalFonts = ["FiraMono Nerd Font Mono 13"]
  , dpi = 120
  , bgColor = "#282828"
  , fgColor = "#ebdbb2"
  , position = BottomSize C 100 36
  , lowerOnStart = True
  , allDesktops = True
  , persistent = True
  , commands =
      [ Run UnsafeStdinReader
      , Run Com "/home/johan/.local/bin/screen-capture" ["status"] "recording" 10
      , Run Date "%Y-%m-%d" "date" 600
      , Run Date "%H:%M" "time" 10
      ]
  , sepChar = "%"
  , alignSep = "}{"
  , template = "  %UnsafeStdinReader% }{ <action=`/home/johan/.local/bin/screen-capture stop` button=1>%recording%</action><action=`gsimplecal` button=1><fc=#d5c4a1>%date%</fc></action>  <fc=#504945>·</fc>  <fc=#fbf1c7>%time%</fc>  "
  }
