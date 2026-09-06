#!/usr/bin/env python3
"""Integration checks using a disposable X11 display and real capture tools.

Requires Xvfb, xterm, xdotool, xclip, copyq, ffprobe, ffmpeg, pactl and paplay on PATH,
plus the active user's systemd manager. Pass the screen-capture launcher.
Does not move the real desktop pointer or change its clipboard.
"""
import array
import json
import math
import os
from pathlib import Path
import struct
import subprocess as sp
import sys
import tempfile
import time

capture = str(Path(sys.argv[1]).resolve())
env = os.environ.copy()


def run(*args, check=True):
    result = sp.run(args, env=env, capture_output=True, timeout=30)
    if check and result.returncode:
        raise RuntimeError(f"{args}: {result.stderr.decode(errors='replace')}")
    return result


def clip():
    return run("xclip", "-selection", "clipboard", "-t", "image/png", "-o").stdout


def dimensions(png):
    assert png.startswith(b"\x89PNG\r\n\x1a\n")
    return struct.unpack(">II", png[16:24])


def drag():
    run("xdotool", "mousemove", "120", "120", "mousedown", "1")
    time.sleep(0.15)
    run("xdotool", "mousemove", "441", "361")
    time.sleep(0.15)
    run("xdotool", "mouseup", "1")


assert not run(capture, "status").stdout, "Stop the existing recording before testing."
with tempfile.TemporaryDirectory(prefix="screen-capture-test-") as tmp:
    root = Path(tmp)
    pictures, videos = root / "Pictures with spaces", root / "Videos with spaces"
    pictures.mkdir()
    videos.mkdir()
    env["XDG_CONFIG_HOME"] = str(root)
    (root / "user-dirs.dirs").write_text(
        f'XDG_PICTURES_DIR="{pictures}"\nXDG_VIDEOS_DIR="{videos}"\n'
    )
    xvfb = sp.Popen(["Xvfb", "-displayfd", "1", "-screen", "0", "1024x768x24", "-nolisten", "tcp"],
                    stdout=sp.PIPE, stderr=sp.DEVNULL)
    env["DISPLAY"] = ":" + xvfb.stdout.readline().decode().strip()
    terminal = sp.Popen(["xterm", "-geometry", "100x35+0+0", "-bg", "#285070",
                         "-fg", "white", "-e", "sh", "-c",
                         "printf 'SCREEN CAPTURE TEST\nRectangle, clipboard, and video checks.\n'; sleep 180"],
                        env=env, stdout=sp.DEVNULL, stderr=sp.DEVNULL)
    session = "captest-" + str(os.getpid())
    copyq_log = open(root / "copyq.log", "w+")
    copyq = sp.Popen(["copyq", "--session", session], env=env,
                     stdout=copyq_log, stderr=copyq_log)
    try:
        time.sleep(1)
        if copyq.poll() is not None:
            copyq_log.seek(0)
            raise RuntimeError(copyq_log.read())
        for index in range(3):
            result = run(capture, "shot", f"321x241+{100 + index}+100")
            path = Path(result.stdout.decode().strip())
            assert dimensions(path.read_bytes()) == (321, 241)
            assert clip() == path.read_bytes()
        before = clip()
        time.sleep(1)
        assert clip() == before
        qt_image = run("copyq", "--session", session, "clipboard", "image/png").stdout
        assert dimensions(qt_image) == dimensions(before), (len(qt_image), len(before))
        def pixels(png):
            return sp.run(["ffmpeg", "-v", "error", "-i", "pipe:0", "-pix_fmt", "rgba",
                           "-f", "rawvideo", "pipe:1"], input=png, env=env,
                          capture_output=True, check=True).stdout
        assert pixels(qt_image) == pixels(before)
        print("PASS repeated PNG captures, independent clipboard reads, CopyQ image access", flush=True)

        pending = sp.Popen([capture, "shot"], env=env, stdout=sp.PIPE, stderr=sp.PIPE)
        time.sleep(0.7)
        drag()
        output, error = pending.communicate(timeout=10)
        assert pending.returncode == 0, error
        selected_size = dimensions(Path(output.decode().strip()).read_bytes())
        # Slop includes both endpoint pixels in an interactive drag.
        assert selected_size == (322, 242), selected_size
        print("PASS interactive rectangle selection", flush=True)

        before = clip()
        count = len(list(pictures.rglob("*.png")))
        pending = sp.Popen([capture, "shot"], env=env, stdout=sp.PIPE, stderr=sp.PIPE)
        time.sleep(0.7)
        run("xdotool", "key", "Escape")
        pending.communicate(timeout=10)
        assert pending.returncode == 0
        assert len(list(pictures.rglob("*.png"))) == count
        assert clip() == before
        assert run(capture, "shot", "100x100+1000+0", check=False).returncode != 0
        assert clip() == before
        print("PASS cancellation and out-of-bounds rejection preserve clipboard", flush=True)

        result = run(capture, "full")
        assert dimensions(Path(result.stdout.decode().strip()).read_bytes()) == (1024, 768)
        print("PASS full-screen PNG", flush=True)

        # Video must require a dragged rectangle, even over a window/panel.
        pending = sp.Popen([capture, "record"], env=env,
                           stdout=sp.PIPE, stderr=sp.PIPE)
        time.sleep(0.7)
        run("xdotool", "mousemove", "120", "120", "mousedown", "1")
        time.sleep(0.15)
        run("xdotool", "mouseup", "1")
        pending.communicate(timeout=10)
        assert pending.returncode != 0
        assert not run(capture, "status").stdout
        assert not list(videos.rglob("*.mp4"))
        print("PASS single click cannot start a window/panel recording", flush=True)

        pending = sp.Popen([capture, "record"], env=env,
                           stdout=sp.PIPE, stderr=sp.PIPE)
        time.sleep(0.7)
        drag()
        _, error = pending.communicate(timeout=10)
        assert pending.returncode == 0, error
        time.sleep(0.2)
        assert b"REC + SOUND" in run(capture, "status").stdout
        assert b"322x242+120+120" in run("systemctl", "--user", "show",
            "xmonad-screen-record.service", "-p", "ExecStart", "--value").stdout
        run(capture, "stop")
        print("PASS default recording uses desktop sound and the dragged rectangle", flush=True)

        run(capture, "record", "silent", "321x241+100+100")
        time.sleep(0.2)
        assert b"REC SILENT" in run(capture, "status").stdout
        time.sleep(4)
        # Pressing the start command again must stop, without opening selection.
        run(capture, "record")
        assert not run(capture, "status").stdout
        files = list(videos.rglob("*.mp4"))
        assert len(files) == 1, files
        info = json.loads(run("ffprobe", "-v", "error", "-show_streams", "-show_format", "-of", "json", str(files[0])).stdout)
        stream = info["streams"][0]
        assert stream["codec_name"] == "h264"
        assert (stream["width"], stream["height"]) == (322, 242)
        assert stream["pix_fmt"] == "yuv420p"
        assert len(info["streams"]) == 1
        assert float(info["format"]["duration"]) >= 1
        run("ffmpeg", "-v", "error", "-i", str(files[0]), "-f", "null", "-")
        assert not list(videos.rglob("*.mkv"))
        print("PASS recording toggle, REC indicator, odd dimensions, H.264/MP4, full decode", flush=True)

        run(capture, "record", "silent", "320x240+100+100")
        run(capture, "stop")
        assert len(list(videos.rglob("*.mp4"))) == 1
        assert not run(capture, "status").stdout
        run(capture, "stop")
        print("PASS countdown cancellation and idempotent stop", flush=True)

        # A present AAC stream is insufficient: record a quiet known tone through
        # the actual desktop output and check the decoded samples for a signal.
        tone = root / "tone.wav"
        run("ffmpeg", "-v", "error", "-f", "lavfi", "-i",
            "sine=frequency=523.25:sample_rate=48000:duration=3", "-af", "volume=0.2",
            "-ac", "2", str(tone))
        run(capture, "record", "desktop", "320x240+100+100")
        time.sleep(2.8)
        assert b"REC + SOUND" in run(capture, "status").stdout
        sink = run("pactl", "get-default-sink").stdout.decode().strip()
        run("paplay", "--device=" + sink, str(tone))
        time.sleep(0.3)
        run(capture, "stop")
        audio_file = max(videos.rglob("*.mp4"), key=lambda path: path.stat().st_mtime)
        info = json.loads(run("ffprobe", "-v", "error", "-show_streams", "-of", "json", str(audio_file)).stdout)
        assert {stream["codec_name"] for stream in info["streams"]} == {"h264", "aac"}
        run("ffmpeg", "-v", "error", "-i", str(audio_file), "-f", "null", "-")
        samples = array.array("f", run("ffmpeg", "-v", "error", "-i", str(audio_file),
            "-map", "0:a:0", "-f", "f32le", "-ac", "1", "-").stdout)
        peak = max(abs(sample) for sample in samples)
        rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples))
        assert peak > 0.005 and rms > 0.001, (peak, rms)
        assert not list(videos.rglob("*.mkv"))
        print("PASS desktop audio: real output tone captured in AAC, full video decode", flush=True)
    finally:
        run(capture, "stop", check=False)
        run("copyq", "--session", session, "exit", check=False)
        for process in (copyq, terminal, xvfb):
            if process.poll() is None:
                process.terminate()
            process.wait(timeout=10)
