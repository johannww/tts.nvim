#!/usr/bin/env python3
import concurrent.futures
import os
import subprocess
import sys
import tempfile

import common
from openai import OpenAI

voice = sys.argv[1]
model = sys.argv[2]
speed = float(sys.argv[3])
nvim_data_dir = sys.argv[4]
to_file = sys.argv[5] if len(sys.argv) > 5 else None

# Get API key from environment variable
api_key = os.getenv("OPENAI_API_KEY")

pid_file = os.path.join(nvim_data_dir, "pid.txt")


def generate_audio(text, send_to_file=False):
    if not api_key:
        print("Error: OpenAI API key not provided", file=sys.stderr)
        sys.exit(1)

    client = OpenAI(api_key=api_key)

    # OpenAI TTS speed ranges from 0.25 to 4.0
    openai_speed = max(0.25, min(4.0, speed))

    with client.audio.speech.with_streaming_response.create(
        model=model, voice=voice, input=text, speed=openai_speed
    ) as response:
        if send_to_file:
            # Save directly to file
            response.stream_to_file(to_file)
        else:
            # Stream to ffplay
            common.kill_existing_process(pid_file)

            # Play the audio with ffplay
            ffplay_proc = subprocess.Popen(
                ["ffplay", "-i", "-", "-autoexit"],
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )

            thispid = os.getpid()
            common.write_pids_to_file(pid_file, thispid, ffplay_proc.pid)

            for chunk in response.iter_bytes():
                try:
                    ffplay_proc.stdin.write(chunk)
                    ffplay_proc.stdin.flush()
                except BrokenPipeError:
                    break

            ffplay_proc.stdin.close()


def listen_to_stdin():
    EOF = "\x1a"
    text = ""
    ex = concurrent.futures.ThreadPoolExecutor()
    while True:
        character = sys.stdin.read(1)
        if character == EOF:
            send_to_file = text[-1] == "F"
            text = text[:-1]
            ex.submit(generate_audio, text, send_to_file)
            text = ""
        text += character


common.SigTermHandler(pid_file)
listen_to_stdin()
