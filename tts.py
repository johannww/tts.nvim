#!/usr/bin/env python3
import os,threading,subprocess
import time

import edge_tts
import asyncio

text = os.sys.argv[1]
voice = os.sys.argv[2]
rate = int((float(os.sys.argv[3])-1)*100)
nvim_data_dir = os.sys.argv[4]
to_file = os.sys.argv[5] if len(os.sys.argv)>5 else None

pid_file = os.path.join(nvim_data_dir, "pid.txt")

communicate = edge_tts.Communicate(text, voice, rate="+"+str(rate)+"%")

def kill_existing_process():
    if os.path.exists(pid_file):
        with open(pid_file, "r") as f:
            existing_pid = int(f.read().strip())
        try:
            os.kill(existing_pid, 9)
        except ProcessLookupError:
            pass

def write_ffplay_pid(pid: int):
    with open(pid_file, "w") as f:
        f.write(str(pid))

async def stream_audio():
    kill_existing_process()
    ffplay = subprocess.Popen(["ffplay", "-i", "-", "-autoexit"],
                              stdin=subprocess.PIPE, start_new_session=True,
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    write_ffplay_pid(ffplay.pid)

    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            ffplay.stdin.write(chunk["data"])
            ffplay.stdin.flush()
        elif chunk["type"] == "WordBoundary":
            pass

if to_file:
    asyncio.run(communicate.save(to_file))
    exit(0)

asyncio.run(stream_audio())

