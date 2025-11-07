#!/usr/bin/env python3
import asyncio
import concurrent.futures
import os
import signal
import subprocess
import sys

import common
import edge_tts

voice = sys.argv[1]
rate = int((float(sys.argv[2]) - 1) * 100)
nvim_data_dir = sys.argv[3]
to_file = sys.argv[4] if len(sys.argv) > 4 else None

pid_file = os.path.join(nvim_data_dir, "pid.txt")


async def stream_audio(text):
    communicate = edge_tts.Communicate(text, voice, rate="+" + str(rate) + "%")

    common.kill_existing_process(pid_file)
    ffplay = subprocess.Popen(
        ["ffplay", "-i", "-", "-autoexit"],
        stdin=subprocess.PIPE,
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    thispid = os.getpid()
    common.write_pids_to_file(pid_file, thispid, ffplay.pid)

    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            try:
                ffplay.stdin.write(chunk["data"])
                ffplay.stdin.flush()
            except BrokenPipeError:
                break
            except Exception as e:
                print(f"Another error occurred: {e}", file=sys.stderr)
        elif chunk["type"] == "WordBoundary":
            pass

    print("Finished streaming", file=sys.stderr)
    ffplay.stdin.close()


async def save_to_file(text):
    communicate = edge_tts.Communicate(text, voice, rate="+" + str(rate) + "%")
    await communicate.save(to_file)


def listen_to_stdin():
    EOF = "\x1a"
    text = ""
    ex = concurrent.futures.ThreadPoolExecutor()
    while True:
        character = sys.stdin.read(1)
        if character == EOF:
            send_to_file = text[-1] == "F"
            text = text[:-1]
            if send_to_file:
                asyncio.run(save_to_file(text))
            else:
                ex.submit(lambda: asyncio.run(stream_audio(text)))
            text = ""
        text += character


common.SigTermHandler(pid_file)
listen_to_stdin()
