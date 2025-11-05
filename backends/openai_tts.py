#!/usr/bin/env python3
import os
import subprocess
import sys
import tempfile

text = sys.argv[1]
voice = sys.argv[2]
model = sys.argv[3]
speed = float(sys.argv[4])
nvim_data_dir = sys.argv[5]
to_file = sys.argv[6] if len(sys.argv) > 6 else None

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
    lines = [f"{this_script_pid}\n", f"{ffplay_pid}"]
    with open(pid_file, "w") as f:
        f.writelines(lines)


def generate_audio():
    try:
        from openai import OpenAI
    except ImportError:
        print("Error: openai package not installed. Install it with: pip install openai", file=sys.stderr)
        sys.exit(1)
    
    if not api_key:
        print("Error: OpenAI API key not provided", file=sys.stderr)
        sys.exit(1)
    
    client = OpenAI(api_key=api_key)
    
    # OpenAI TTS speed ranges from 0.25 to 4.0
    openai_speed = max(0.25, min(4.0, speed))
    
    try:
        response = client.audio.speech.create(
            model=model,
            voice=voice,
            input=text,
            speed=openai_speed
        )
        
        if to_file:
            # Save directly to file
            response.stream_to_file(to_file)
        else:
            # Stream to ffplay
            kill_existing_process()
            
            # Create a temporary file to store the audio
            with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as tmp_file:
                tmp_filename = tmp_file.name
                response.stream_to_file(tmp_filename)
            
            # Play the audio with ffplay
            ffplay_proc = subprocess.Popen(
                ["ffplay", "-i", tmp_filename, "-autoexit", "-nodisp"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True
            )
            
            thispid = os.getpid()
            write_pids_to_file(thispid, ffplay_proc.pid)
            
            ffplay_proc.wait()
            
            # Clean up temporary file
            try:
                os.unlink(tmp_filename)
            except Exception:
                pass
                
    except Exception as e:
        print(f"Error generating audio: {e}", file=sys.stderr)
        sys.exit(1)


generate_audio()
