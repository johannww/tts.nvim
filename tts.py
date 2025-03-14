#!/usr/bin/env python3
import os,threading,subprocess
import time

import edge_tts
import asyncio

text = os.sys.argv[1]
voice = os.sys.argv[2]
rate = int((float(os.sys.argv[3])-1)*100)

communicate = edge_tts.Communicate(text, voice, rate="+"+str(rate)+"%")

async def stream_audio():
    ffplay = subprocess.Popen(["ffplay", "-i", "-", "-autoexit"],
                              stdin=subprocess.PIPE, start_new_session=True,
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    async for chunk in communicate.stream():
        if chunk["type"] == "audio":
            ffplay.stdin.write(chunk["data"])
            ffplay.stdin.flush()
        elif chunk["type"] == "WordBoundary":
            pass

asyncio.run(stream_audio())

