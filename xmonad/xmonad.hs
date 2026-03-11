import XMonad
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks)
import XMonad.ManageHook (composeAll, (-->))
import Data.Bits ((.|.))
import qualified Data.Map as M
import qualified XMonad.StackSet as W

main :: IO ()
main = xmonad . docks $ def
  { terminal = "alacritty"
  , borderWidth = 0
  , modMask = mod4Mask
  , startupHook = do
      spawn "pgrep -x alacritty >/dev/null || alacritty"
      spawn "pgrep -x brave >/dev/null || brave"
      spawn "command -v taffybar >/dev/null && (pkill -f '[t]affybar-linux-x86_64\\.taffybar-wrapped' >/dev/null 2>&1 || true; pkill -x taffybar >/dev/null 2>&1 || true; XDG_CONFIG_HOME=/home/johan/dotfiles taffybar >/tmp/taffybar.log 2>&1 &)"
      windows $ W.greedyView "4"
      startupHook def
  , manageHook =
      composeAll
        [ className =? "Alacritty" --> doShift "4"
        , className =? "Brave-browser" --> doShift "5"
        , className =? "Brave" --> doShift "5"
        ]
      <+> manageDocks
      <+> manageHook def
  , layoutHook = avoidStruts $ layoutHook def
  , keys = \c ->
      M.union (M.fromList (customKeys c)) (keys def c)
  }

customKeys :: XConfig Layout -> [((KeyMask, KeySym), X ())]
customKeys c =
  [ ((modm, xK_r), spawn "xmonad --recompile; xmonad --restart")
  , ((modm, xK_p), spawn "rofi -show drun || dmenu_run")
  , ((0, xK_Print), spawn "flameshot gui")
  , ((shiftMask, xK_Print), spawn "flameshot gui")
  , ((modm, xK_m), windows $ W.greedyView "1")
  , ((modm, xK_comma), windows $ W.greedyView "2")
  , ((modm, xK_period), windows $ W.greedyView "3")
  , ((modm, xK_j), windows $ W.greedyView "4")
  , ((modm, xK_k), windows $ W.greedyView "5")
  , ((modm, xK_l), windows $ W.greedyView "6")
  , ((modm, xK_u), windows $ W.greedyView "7")
  , ((modm, xK_i), windows $ W.greedyView "8")
  , ((modm, xK_o), windows $ W.greedyView "9")
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
