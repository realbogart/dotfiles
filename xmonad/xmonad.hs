import XMonad
import XMonad.Actions.CycleRecentWS (cycleRecentNonEmptyWS)
import XMonad.Actions.GridSelect (goToSelected)
import XMonad.Actions.SpawnOn (manageSpawn, spawnOn)
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, ppCurrent, ppOutput, ppSep, ppTitle, shorten, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks)
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import XMonad.Util.Run (spawnPipe)
import System.IO (hPutStrLn)
import System.IO.Error (catchIOError)

main :: IO ()
main = do
  xmproc <-
    spawnPipe
      "sh -c 'pkill -x xmobar >/dev/null 2>&1 || true; exec /run/current-system/sw/bin/xmobar /home/johan/dotfiles/xmonad/xmobarrc.hs'"
  xmonad . ewmhFullscreen . ewmh . docks $ def
    { terminal = "alacritty"
    , borderWidth = 0
    , modMask = mod4Mask
    , startupHook = do
        spawnOn "4" "sh -c 'pgrep -x alacritty >/dev/null || exec alacritty'"
        spawnOn "5" "sh -c 'pgrep -x brave >/dev/null || exec flatpak run com.brave.Browser'"
        -- spawn "sh -c 'pgrep -x xbanish >/dev/null || exec xbanishf"
        windows $ W.greedyView "4"
        startupHook def
    , manageHook =
        manageSpawn
        <+> manageDocks
        <+> composeAll
          [ className =? c --> doShift "3"
          | c <-
              [ "discord"
              , "Discord"
              , "com.discordapp.Discord"
              , "signal"
              , "Signal"
              , "org.signal.Signal"
              , "element"
              , "Element"
              , "im.riot.Riot"
              ]
          ]
        <+> manageHook def
    , layoutHook = avoidStruts $ layoutHook def
    , logHook =
        dynamicLogWithPP
          xmobarPP
            { ppOutput = \line -> catchIOError (hPutStrLn xmproc line) (\_ -> pure ())
            , ppCurrent = xmobarColor "#ffc24b" ""
            , ppTitle = xmobarColor "#b3deef" "" . shorten 70
            , ppSep = "  |  "
            }
    , keys = \c ->
        M.union (M.fromList (customKeys c)) (keys def c)
    }

customKeys :: XConfig Layout -> [((KeyMask, KeySym), X ())]
customKeys c =
  [ ((modm, xK_r), spawn "xmonad --recompile; xmonad --restart")
  , ((modm, xK_odiaeresis), spawn "/home/johan/.local/bin/rofi-launcher")
  , ((mod1Mask, xK_Tab), cycleRecentNonEmptyWS [xK_Alt_L, xK_Alt_R] xK_Tab xK_grave)
  , ((modm, xK_y), windows W.swapDown)
  , ((modm, xK_space), spawn "/home/johan/dotfiles/xmonad/toggle-media.sh")
  , ((modm, xK_p), sendMessage NextLayout)
  , ((0, xK_Print), spawn "flameshot gui")
  , ((shiftMask, xK_Print), spawn "flameshot gui")
  , ((modm, xK_m), windows $ W.greedyView "1")
  , ((modm, xK_comma), windows $ W.greedyView "2")
  , ((modm, xK_period), windows $ W.greedyView "3")
  , ((modm, xK_j), windows $ W.greedyView "4")
  , ((modm, xK_k), windows $ W.greedyView "5")
  , ((modm, xK_l), windows $ W.greedyView "6")
  , ((modm, xK_u), sendMessage Shrink)
  , ((modm, xK_i), goToSelected def)
  , ((modm, xK_o), sendMessage Expand)
  , ((modm, xK_n), kill)
  , ((modm, xK_1), windows $ W.shift "1")
  , ((modm, xK_2), windows $ W.shift "2")
  , ((modm, xK_3), windows $ W.shift "3")
  , ((modm, xK_4), windows $ W.shift "4")
  , ((modm, xK_5), windows $ W.shift "5")
  , ((modm, xK_6), windows $ W.shift "6")
  ]
  where
    modm = modMask c
