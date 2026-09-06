# Screenshots and rectangle recordings

The launcher is `~/.local/bin/screen-capture`. Its dependencies are pinned by
`/etc/nixos/flake.lock` and declared in `/etc/nixos/home.nix`; the implementation
is `~/dotfiles/xmonad/screen-capture`. Home Manager installs the launcher.

| Shortcut | Action |
| --- | --- |
| Print Screen | Drag a rectangle, or click a window; save and copy a PNG |
| Shift + Print Screen | Flameshot annotation editor; **Enter** or the accept button saves and copies |
| Ctrl + Print Screen | Save and copy the entire desktop |
| Alt + Print Screen | Drag a rectangle and record with desktop sound; press again to stop and save |

Escape or right-click cancels rectangle selection.
For video, release the shortcut keys, then **click and drag** the rectangle;
clicking a window or Xmobar alone will not start a recording. The minimum area
is 16×16 pixels. Recordings start after a two-second delay, with a notification
showing the selected dimensions and desktop sound. Xmobar shows **REC + SOUND**;
clicking it also stops recording. Alt+Print is the only video keyboard shortcut.
A thin border shows the recorded area.

PNGs go to `~/Pictures/Screenshots`, and videos to `~/Videos/Recordings`.
Configured XDG Pictures/Videos directories take precedence. Every screenshot
is saved before copying, and the clipboard is checked twice from an independent
X11 client before success is reported. Use Ctrl+V to paste into an application
that accepts images; middle-click uses X11's separate primary selection.

Videos use H.264, 30 fps, and MP4; desktop sound uses AAC. Odd rectangle sizes
are padded by at most one pixel for compatibility. During recording, a
`.recording.mkv` file is retained so an interrupted session can be recovered.
It is removed after successful MP4 finalization. Capture stays local.

Desktop sound is the default for both the shortcut and `screen-capture record`.
It uses the current default output's monitor source. Advanced terminal-only
options remain available: `screen-capture record mic` uses the default microphone,
and `screen-capture record silent` explicitly disables audio.

## Why this setup

Investigated on 2026-09-06 for this XMonad/X11 session:

- [maim](https://github.com/naelstrof/maim) and
  [slop](https://github.com/naelstrof/slop) provide lightweight X11 rectangle
  capture and selection. Both image and video selection use slop here.
- [Flameshot](https://flameshot.org/docs/advanced/commandline-options/) remains
  useful for annotations. Its raw PNG output goes through the same save/copy
  path as maim, bypassing its built-in clipboard action.
- [FFmpeg's X11 capture](https://ffmpeg.org/ffmpeg-devices.html#x11grab) integrates
  directly with selection and shortcuts, with no recording window to arrange.
  Nix's `ffmpeg-full` is required: the regular `ffmpeg` in the pinned nixpkgs
  does not include x11grab.
- [SimpleScreenRecorder](https://www.maartenbaert.be/simplescreenrecorder/) is
  a capable X11 GUI alternative, but involves more setup for each quick clip.
- Spectacle can take screenshots on X11, but its recording function
  [requires Wayland](https://bugs.kde.org/show_bug.cgi?id=509812).
  [Kooha](https://github.com/SeaDve/Kooha) requires a working screencast portal,
  so it is a less direct fit for this XMonad session.

CopyQ was already running, with clipboard monitoring enabled and primary
selection synchronization disabled. Flameshot logs showed Qt painting warnings,
but those do not establish the cause of the intermittent clipboard failure.
No unrelated clipboard settings were changed. Persistent xclip ownership,
explicit `image/png`, independent verification and saved PNGs address the
capture workflow without depending on Flameshot's clipboard handoff.

## Verification and troubleshooting

Verification on the live 3840×2160 XMonad desktop includes the screenshot
shortcuts, Flameshot acceptance, PNG clipboard contents, dragged video rectangles,
recording start/stop and actual audio samples from a test tone played through
the Fireface output. XMonad compilation, Home Manager activation and ShellCheck
also passed. Test captures are removed after verification.

The integration checks use a disposable Xvfb display and a separate CopyQ
session. They exercise real captures, mouse selection, cancellation, clipboard
image access, video encoding, stop/start, audio, and complete video decoding.
The real desktop pointer and clipboard are not touched by this test script.
The desktop-audio test plays a quiet three-second tone through the default
output and checks that it reaches the recorded audio samples; its temporary
recordings are deleted when the test finishes.

```sh
nix shell --inputs-from /etc/nixos \
  nixpkgs#python3 nixpkgs#xorg-server nixpkgs#xterm nixpkgs#xdotool \
  nixpkgs#xclip nixpkgs#copyq nixpkgs#ffmpeg-full nixpkgs#pulseaudio \
  -c python3 ~/dotfiles/xmonad/test-screen-capture.py ~/.local/bin/screen-capture
```

Recording diagnostics:

```sh
journalctl --user -u xmonad-screen-record.service
~/.local/bin/screen-capture stop
```

An interrupted MKV can be remuxed without re-encoding:

```sh
nix shell --inputs-from /etc/nixos nixpkgs#ffmpeg-full -c \
  ffmpeg -i /path/to/Recording.recording.mkv -c copy -movflags +faststart recovered.mp4
```
