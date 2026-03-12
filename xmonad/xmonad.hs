import XMonad
import XMonad.Actions.CycleRecentWS (cycleRecentNonEmptyWS)
import XMonad.Actions.GridSelect (goToSelected)
import XMonad.Actions.SpawnOn (manageSpawn, spawnOn)
import Control.Monad (unless, when)
import Data.List (find)
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, ppCurrent, ppHidden, ppHiddenNoWindows, ppOutput, ppSep, ppTitle, ppVisible, shorten, wrap, xmobarColor, xmobarPP)
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
        <+> composeAll
          [ className =? c --> doShift "1"
          | c <- ["btop", "Btop"]
          ]
        <+> manageHook def
    , layoutHook = avoidStruts $ layoutHook def
    , logHook =
        autostartWorkspaceApps
        >> 
        dynamicLogWithPP
          xmobarPP
            { ppOutput = \line -> catchIOError (hPutStrLn xmproc line) (\_ -> pure ())
            , ppCurrent = xmobarColor "#282828" "#ffc24b" . wrap " " " " . workspaceLabel
            , ppVisible = xmobarColor "#b3deef" "" . wrap " " " " . workspaceLabel
            , ppHidden = xmobarColor "#f0f0f0" "" . wrap " " " " . workspaceLabel
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
  , ( (modm, xK_m)
    , windows (W.greedyView "1")
        >> ensureWindowOnWorkspace
          ["btop", "Btop"]
          "1"
          "alacritty --class btop,btop -e sh -lc \"exec btop\""
    )
  , ( (modm, xK_comma)
    , windows (W.greedyView "2")
        >> ensureWindowOnWorkspace
          ["spotify", "Spotify", "com.spotify.Client"]
          "2"
          "flatpak run com.spotify.Client"
    )
  , ((modm, xK_period), windows $ W.greedyView "3")
  , ((modm, xK_j), windows (W.greedyView "4") >> ensureWindowOnWorkspace ["Alacritty"] "4" "alacritty")
  , ( (modm, xK_k)
    , windows (W.greedyView "5")
        >> ensureWindowOnWorkspace
          ["Brave-browser", "brave-browser", "Brave Browser", "com.brave.Browser"]
          "5"
          "flatpak run com.brave.Browser"
    )
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

workspaceLabel :: String -> String
workspaceLabel ws = case ws of
  "1" -> "1:btop"
  "2" -> "2:spotify"
  "3" -> "3:chats"
  "4" -> "4:tmux"
  "5" -> "5:web"
  "6" -> "6:misc"
  _ -> ws

autostartWorkspaceApps :: X ()
autostartWorkspaceApps = do
  currentWs <- gets (W.currentTag . windowset)
  when (currentWs == "1") $
    ensureWindowOnWorkspace
      ["btop", "Btop"]
      "1"
      "alacritty --class btop,btop -e sh -lc \"exec btop\""
  when (currentWs == "2") $
    ensureWindowOnWorkspace
      ["spotify", "Spotify", "com.spotify.Client"]
      "2"
      "flatpak run com.spotify.Client"
  when (currentWs == "4") $
    ensureWindowOnWorkspace ["Alacritty"] "4" "alacritty"
  when (currentWs == "5") $
    ensureWindowOnWorkspace
      ["Brave-browser", "brave-browser", "Brave Browser", "com.brave.Browser"]
      "5"
      "flatpak run com.brave.Browser"

ensureWindowOnWorkspace :: [String] -> WorkspaceId -> String -> X ()
ensureWindowOnWorkspace classes targetWs cmd = do
  hasWindow <- hasWindowClassOnWorkspace classes targetWs
  unless hasWindow $
    spawnOn targetWs cmd

hasWindowClassOnWorkspace :: [String] -> WorkspaceId -> X Bool
hasWindowClassOnWorkspace names targetWs = withWindowSet $ \ws -> do
  let wsWindows = case find ((== targetWs) . W.tag) (W.workspaces ws) of
        Just w -> W.integrate' (W.stack w)
        Nothing -> []
  classes <- mapM (runQuery className) wsWindows
  pure (any (`elem` names) classes)
