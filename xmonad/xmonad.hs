import XMonad
import Data.Bits ((.|.))
import qualified Data.Map as M
import qualified XMonad.StackSet as W

main :: IO ()
main = xmonad $ def
  { terminal = "alacritty"
  , borderWidth = 0
  , modMask = mod4Mask
  , keys = \c ->
      M.union (M.fromList (customKeys c)) (keys def c)
  }

customKeys :: XConfig Layout -> [((KeyMask, KeySym), X ())]
customKeys c =
  [ ((modm .|. shiftMask, xK_r), spawn "xmonad --recompile; xmonad --restart")
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
