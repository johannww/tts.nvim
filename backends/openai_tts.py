#!/usr/bin/env python3
import concurrent.futures
import os
import subprocess
import sys
import tempfile
from openai import OpenAI

voice = sys.argv[1]
model = sys.argv[2]
speed = float(sys.argv[3])
nvim_data_dir = sys.argv[4]
to_file = sys.argv[5] if len(sys.argv) > 5 else None

# Get API key from environment variable
api_key = os.getenv("OPENAI_API_KEY")

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
            kill_existing_process()

            # Play the audio with ffplay
            ffplay_proc = subprocess.Popen(
                ["ffplay", "-i", "-", "-autoexit"],
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )

            thispid = os.getpid()
            write_pids_to_file(thispid, ffplay_proc.pid)

            for chunk in response.iter_bytes():
                try:
                    ffplay_proc.stdin.write(chunk)
                    ffplay_proc.stdin.flush()
                except BrokenPipeError:
                    break


def listen_to_stdin():
    EOF = "\x1A"
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

listen_to_stdin()
