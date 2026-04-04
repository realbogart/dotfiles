import XMonad
import XMonad.Actions.CycleRecentWS (cycleRecentNonEmptyWS)
import XMonad.Actions.GridSelect (goToSelected)
import XMonad.Actions.RotSlaves (rotAllDown)
import XMonad.Actions.SpawnOn (manageSpawn, spawnOn)
import Control.Monad (unless, when)
import Data.Char (chr)
import Data.List (find)
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, ppCurrent, ppHidden, ppHiddenNoWindows, ppLayout, ppOutput, ppRename, ppSep, ppTitle, ppVisible, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.InsertPosition (Focus (Newer), Position (End), insertPosition)
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks)
import XMonad.Hooks.Place (fixed, placeHook, withGaps)
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.ResizableTile (ResizableTall (ResizableTall))
import XMonad.Layout.Spacing (spacingWithEdge)
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Util.ClickableWorkspaces (clickablePP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce (spawnOnce)
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
    , normalBorderColor = "#3c3836"
    , focusedBorderColor = "#d79921"
    , modMask = mod4Mask
    , startupHook = do
        spawnOnce "/run/current-system/sw/bin/xrdb -merge /home/johan/dotfiles/.Xresources"
        spawnOnce "/run/current-system/sw/bin/xset s 600 5"
        spawnOnce "/run/current-system/sw/bin/xset +dpms"
        spawnOnce "xss-lock --transfer-sleep-lock -- /run/wrappers/bin/slock"
        spawnOnce "lxqt-policykit-agent"
        spawnOnce "dunst"
        windows $ W.greedyView "4"
        XS.put (WorkspaceAutostartState True (Just "4"))
        autostartWorkspaceApp "4"
        startupHook def
    , manageHook =
        gsimplecalManageHook
        <+> insertPosition End Newer
        <+> manageSpawn
        <+> chatClientManageHook
        <+> manageDocks
        <+> manageHook def
    , layoutHook = myLayoutHook
    , mouseBindings = \XConfig {XMonad.modMask = modm} ->
        M.fromList
          [ ((modm, button1), \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
          , ((modm, button2), \w -> focus w >> kill)
          , ((modm, button3), \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)
          ]
    , logHook =
        autostartWorkspaceApps
        >> do
          clickable <- clickablePP $
            xmobarPP
              { ppOutput = \line -> catchIOError (hPutStrLn xmproc line) (\_ -> pure ())
              , ppRename = \_ ws -> baseWorkspaceLabel (W.tag ws)
              , ppCurrent = xmobarColor "#282828" "#d79921" . wrap "  " "  "
              , ppVisible = xmobarColor "#b8bb26" "" . wrap "  " "  "
              , ppHidden = xmobarColor "#ebdbb2" "" . wrap "  " "  "
              , ppHiddenNoWindows = xmobarColor "#7c6f64" "" . wrap "  " "  "
              , ppLayout = clickableLayout . xmobarColor "#83a598" "" . wrap " " " " . formatLayoutName
              , ppTitle = xmobarColor "#d5c4a1" "" . shorten 96
              , ppSep = "  <fc=#504945>·</fc>  "
              }
          dynamicLogWithPP clickable
    , keys = \c ->
        M.union (M.fromList (customKeys c)) (keys def c)
    }

customKeys :: XConfig Layout -> [((KeyMask, KeySym), X ())]
customKeys c =
  [ ((modm, xK_r), spawn "xmonad --recompile; xmonad --restart")
  , ((modm, xK_odiaeresis), spawn "/home/johan/.local/bin/rofi-launcher")
  , ((mod1Mask, xK_Tab), cycleRecentNonEmptyWS [xK_Alt_L, xK_Alt_R] xK_Tab xK_grave)
  , ((modm, xK_y), rotAllDown)
  , ((modm, xK_space), spawn "/home/johan/dotfiles/xmonad/toggle-media.sh")
  , ((modm .|. shiftMask, xK_space), spawn "/run/wrappers/bin/slock")
  , ((controlMask .|. mod1Mask, xK_Delete), spawn "/run/wrappers/bin/slock")
  , ((modm, xK_p), sendMessage NextLayout)
  , ((0, xK_Print), spawn "flameshot gui")
  , ((shiftMask, xK_Print), spawn "flameshot gui")
  , ( (modm, xK_m)
    , windows (W.greedyView "1")
    )
  , ( (modm, xK_comma)
    , windows (W.greedyView "2")
    )
  , ((modm, xK_period), windows $ W.greedyView "3")
  , ((modm, xK_j), windows $ W.greedyView "4")
  , ((modm, xK_k), windows $ W.greedyView "5")
  , ((modm, xK_l), windows $ W.greedyView "6")
  , ((modm, xK_u), windows $ W.greedyView "7")
  , ((modm, xK_i), windows $ W.greedyView "8")
  , ((modm, xK_o), windows $ W.greedyView "9")
  , ((modm, xK_h), sendMessage Shrink)
  , ((modm, xK_adiaeresis), sendMessage Expand)
  , ((modm, xK_0), kill)
  , ((modm, xK_1), windows $ W.shift "1")
  , ((modm, xK_2), windows $ W.shift "2")
  , ((modm, xK_3), windows $ W.shift "3")
  , ((modm, xK_4), windows $ W.shift "4")
  , ((modm, xK_5), windows $ W.shift "5")
  , ((modm, xK_6), windows $ W.shift "6")
  , ((modm, xK_7), windows $ W.shift "7")
  , ((modm, xK_8), windows $ W.shift "8")
  , ((modm, xK_9), windows $ W.shift "9")
  ]
  where
    modm = modMask c

baseWorkspaceLabel :: WorkspaceId -> String
baseWorkspaceLabel ws = case ws of
  "1" -> workspaceLabel "1" 0xf080 "btop"
  "2" -> workspaceLabel "2" 0xf1bc "spotify"
  "3" -> workspaceLabel "3" 0xf086 "chats"
  "4" -> workspaceLabel "4" 0xf120 "tmux"
  "5" -> workspaceLabel "5" 0xf0ac "web"
  "6" -> workspaceLabel "6" 0xf16a "youtube"
  "7" -> workspaceLabel "7" 0xf07b "misc"
  "8" -> workspaceLabel "8" 0xf07b "misc"
  "9" -> workspaceLabel "9" 0xf07b "misc"
  _ -> ws

workspaceLabel :: String -> Int -> String -> String
workspaceLabel n iconCode label = n ++ " " ++ xmobarIcon iconCode ++ " " ++ label

xmobarIcon :: Int -> String
xmobarIcon iconCode = "<fn=1>" ++ [chr iconCode] ++ "</fn>"

formatLayoutName :: String -> String
formatLayoutName layout = case layout of
  "Tall" -> "stack"
  "ResizableTall" -> "stack"
  "Mirror Tall" -> "row"
  "Mirror ResizableTall" -> "row"
  "Full" -> "full"
  other -> other

clickableLayout :: String -> String
clickableLayout label =
  "<action=`xdotool key Super_L+p` button=1>" ++ label ++ "</action>"

myLayouts =
  spacingWithEdge 8 tiled
    ||| spacingWithEdge 8 (Mirror tiled)
    ||| Full
  where
    tiled = ResizableTall 1 (3 / 100) (1 / 2) []

myLayoutHook = avoidStruts $ smartBorders myLayouts

gsimplecalManageHook :: ManageHook
gsimplecalManageHook =
  composeAll
    [ appName =? "gsimplecal" --> placeHook (withGaps (0, 0, 32, 0) (fixed (1, 1)))
    , className =? "Gsimplecal" --> placeHook (withGaps (0, 0, 32, 0) (fixed (1, 1)))
    ]

autostartWorkspaceApps :: X ()
autostartWorkspaceApps = do
  currentWs <- gets (W.currentTag . windowset)
  WorkspaceAutostartState initialized lastWs <- XS.get
  when (initialized && Just currentWs /= lastWs) $ do
    XS.put (WorkspaceAutostartState True (Just currentWs))
    autostartWorkspaceApp currentWs

autostartWorkspaceApp :: WorkspaceId -> X ()
autostartWorkspaceApp currentWs = case currentWs of
  "1" ->
    ensureWindowOnWorkspace
      ["btop", "Btop"]
      "1"
      "alacritty --class btop,btop -e sh -lc \"exec btop\""
  "2" ->
    ensureWindowOnWorkspace
      ["spotify", "Spotify", "com.spotify.Client"]
      "2"
      "flatpak run com.spotify.Client"
  "3" ->
    pure ()
  "4" ->
    ensureWindowOnWorkspace ["Alacritty"] "4" "alacritty"
  "5" ->
    ensureWindowOnWorkspace
      ["Brave-browser", "brave-browser", "Brave Browser", "com.brave.Browser"]
      "5"
      "flatpak run com.brave.Browser"
  "6" ->
    ensureWindowOnWorkspace
      ["Brave-browser", "brave-browser", "Brave Browser", "com.brave.Browser"]
      "6"
      "flatpak run com.brave.Browser --new-window https://www.youtube.com"
  _ -> pure ()

data WorkspaceAutostartState = WorkspaceAutostartState Bool (Maybe WorkspaceId)
  deriving (Read, Show)

instance ExtensionClass WorkspaceAutostartState where
  initialValue = WorkspaceAutostartState False Nothing
  extensionType = StateExtension

chatClientManageHook :: ManageHook
chatClientManageHook =
  composeAll
    [ className =? "discord" --> doShift "3"
    , className =? "Discord" --> doShift "3"
    , className =? "com.discordapp.Discord" --> doShift "3"
    , className =? "signal" --> doShift "3"
    , className =? "Signal" --> doShift "3"
    , className =? "org.signal.Signal" --> doShift "3"
    , className =? "element" --> doShift "3"
    , className =? "Element" --> doShift "3"
    , className =? "im.riot.Riot" --> doShift "3"
    , className =? "zapzap" --> doShift "3"
    , className =? "ZapZap" --> doShift "3"
    , className =? "com.rtosta.zapzap" --> doShift "3"
    ]

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
