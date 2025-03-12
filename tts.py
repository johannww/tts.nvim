#!/usr/bin/python3
import os,threading,subprocess
import time

import edge_tts
import asyncio

text = os.sys.argv[1]
VOICE = "en-GB-SoniaNeural"

communicate = edge_tts.Communicate(text, VOICE)

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

