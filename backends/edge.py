#!/usr/bin/env python3
import asyncio
import os
import subprocess
import sys

import edge_tts

voice = sys.argv[1]
rate = int((float(sys.argv[2]) - 1) * 100)
nvim_data_dir = sys.argv[3]
to_file = sys.argv[4] if len(sys.argv) > 4 else None

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
    # lines = [f"{this_script_pid}\n", f"{ffplay_pid}"]
    lines = [f"{ffplay_pid}"]
    with open(pid_file, "w") as f:
        f.writelines(lines)


async def stream_audio(text):
    communicate = edge_tts.Communicate(text, voice, rate="+" + str(rate) + "%")
    
    kill_existing_process()
    ffplay = subprocess.Popen(
        ["ffplay", "-i", "-", "-autoexit"],
        stdin=subprocess.PIPE,
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    thispid = os.getpid()
    write_pids_to_file(thispid, ffplay.pid)

    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            try:
                ffplay.stdin.write(chunk["data"])
                ffplay.stdin.flush()
            except BrokenPipeError:
                break
        elif chunk["type"] == "WordBoundary":
            pass


async def save_to_file(text):
    communicate = edge_tts.Communicate(text, voice, rate="+" + str(rate) + "%")
    await communicate.save(to_file)


def listen_to_stdin():
    EOF = "\x1A"
    text = ""
    while True:
        character = sys.stdin.read(1)
        if character == EOF:
            print("Received EOF.", file=sys.stderr)
            print("text is:", repr(text), file=sys.stderr)
            send_to_file = text[-1] == "F"
            text = text[:-1]
            if send_to_file:
                asyncio.run(save_to_file(text))
            else:
                asyncio.run(stream_audio(text))
            text = ""
        text += character
    print("Stdin closed.", file=sys.stderr)


listen_to_stdin()
