{-# LANGUAGE OverloadedStrings #-}

import System.Taffybar
import System.Taffybar.SimpleConfig
import System.Taffybar.Widget

main :: IO ()
main = do
  let clock =
        textClockNewWith
          defaultClockConfig
            { clockFormatString = "%Y-%m-%d kl %H:%M"
            }

      simpleConfig =
        defaultSimpleTaffyConfig
          { barPosition = Bottom
          , startWidgets = [workspacesNew defaultWorkspacesConfig]
          , centerWidgets = [windowsNew defaultWindowsConfig]
          , endWidgets =
              [ layoutNew defaultLayoutConfig
              , clock
              ]
          , cssPaths = ["/home/johan/dotfiles/taffybar/taffybar.css"]
          }

  simpleTaffybar simpleConfig
