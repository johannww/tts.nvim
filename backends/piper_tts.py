#!/usr/bin/env python3
import concurrent.futures
import os
import subprocess
import sys
import wave

import piper

model = sys.argv[1]
speed = float(sys.argv[2])
nvim_data_dir = sys.argv[3]
to_file = sys.argv[4] if len(sys.argv) > 4 else None

pid_file = os.path.join(nvim_data_dir, "pid.txt")

voices_dir = os.path.join(nvim_data_dir, "piper_voices")
os.makedirs(voices_dir, exist_ok=True)


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
    lines = [f"{ffplay_pid}"]
    # lines = [f"{this_script_pid}\n", f"{ffplay_pid}"]
    with open(pid_file, "w") as f:
        f.writelines(lines)


def stream_audio(text, send_to_file=False):
    kill_existing_process()

    # Adjust speed for piper (piper uses --length-scale, where values < 1.0 = faster, > 1.0 = slower)
    # Convert speed (where 1.0 = normal, 2.0 = 2x faster) to length_scale
    length_scale = 1.0 / speed if speed > 0 else 1.0
    syn_config = piper.SynthesisConfig(length_scale=length_scale, normalize_audio=True)
    model_path = os.path.join(voices_dir, model + ".onnx")
    voice = piper.PiperVoice.load(model_path=model_path)

    if send_to_file:
        with wave.open(to_file, "wb") as wav_file:
            voice.synthesize_wav(text=text, wav_file=wav_file, syn_config=syn_config)
    else:
        iterable = voice.synthesize(text, syn_config=syn_config)
        ffplay_proc = subprocess.Popen(
            [
                "ffplay",
                "-f",
                "s16le",
                "-ar",
                "22050",
                # "-ac",
                # "1",
                "-i",
                "-",
                "-autoexit",
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )

        thispid = os.getpid()
        write_pids_to_file(thispid, ffplay_proc.pid)

        for chunk in iterable:
            ffplay_proc.stdin.write(chunk.audio_int16_bytes)
            ffplay_proc.stdin.flush()


def download_voice_if_needed():
    if not os.path.exists(os.path.join(voices_dir, model + ".onnx")):
        print(f"Downloading voice model '{model}'...", file=sys.stderr)
        voice_download = subprocess.run(
            [
                "python3",
                "-m",
                "piper.download_voices",
                "--download-dir",
                voices_dir,
                model,
            ]
        )


def listen_to_stdin():
    EOF = "\x1a"
    text = ""
    ex = concurrent.futures.ThreadPoolExecutor()
    while True:
        character = sys.stdin.read(1)
        if character == EOF:
            send_to_file = text[-1] == "F"
            text = text[:-1]
            ex.submit(stream_audio, text, send_to_file)
            text = ""
        text += character


download_voice_if_needed()
listen_to_stdin()
