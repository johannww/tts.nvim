#!/usr/bin/env python3
import os
import subprocess
import sys

text = sys.argv[1]
model = sys.argv[2]
speed = float(sys.argv[3])
nvim_data_dir = sys.argv[4]
to_file = sys.argv[5] if len(sys.argv) > 5 else None

pid_file = os.path.join(nvim_data_dir, "pid.txt")


def kill_existing_process():
    if os.path.exists(pid_file):
        with open(pid_file, "r") as f:
            lines = f.readlines()
        try:
            for line in lines:
                if line.strip().isdigit():
                    pid = int(line.strip())
                    os.kill(pid, 9)
        except Exception:
            pass


def write_pids_to_file(this_script_pid: int, ffplay_pid: int):
    lines = [f"{this_script_pid}\n", f"{ffplay_pid}"]
    with open(pid_file, "w") as f:
        f.writelines(lines)


def stream_audio():
    kill_existing_process()
    
    # Adjust speed for piper (piper uses --length-scale, where values < 1.0 = faster, > 1.0 = slower)
    # Convert speed (where 1.0 = normal, 2.0 = 2x faster) to length_scale
    length_scale = 1.0 / speed if speed > 0 else 1.0
    
    if to_file:
        # Generate audio to file
        piper_proc = subprocess.Popen(
            ["piper", "--model", model, "--length_scale", str(length_scale), "--output-raw"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL
        )
        piper_proc.stdin.write(text.encode())
        piper_proc.stdin.close()
        
        # Convert raw audio to mp3 using ffmpeg
        ffmpeg_proc = subprocess.Popen(
            ["ffmpeg", "-f", "s16le", "-ar", "22050", "-ac", "1", "-i", "-", "-y", to_file],
            stdin=piper_proc.stdout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        ffmpeg_proc.wait()
    else:
        # Stream audio to ffplay
        piper_proc = subprocess.Popen(
            ["piper", "--model", model, "--length_scale", str(length_scale), "--output-raw"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )
        
        ffplay_proc = subprocess.Popen(
            ["ffplay", "-f", "s16le", "-ar", "22050", "-ac", "1", "-i", "-", "-autoexit", "-nodisp"],
            stdin=piper_proc.stdout,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )
        
        thispid = os.getpid()
        write_pids_to_file(thispid, ffplay_proc.pid)
        
        piper_proc.stdin.write(text.encode())
        piper_proc.stdin.close()
        ffplay_proc.wait()


stream_audio()
