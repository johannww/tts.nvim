import os
import signal
import sys


class SigTermHandler:
    def __init__(self, pid_file: str):
        self.pid_file = pid_file
        signal.signal(signal.SIGTERM, self.handle_sigterm)

    def handle_sigterm(self, signum, frame):
        kill_existing_process(self.pid_file)
        sys.exit(0)


def kill_existing_process(pid_file: str):
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


def write_pids_to_file(pid_file: str, this_script_pid: int, ffplay_pid: int):
    # lines = [f"{this_script_pid}\n", f"{ffplay_pid}"]
    lines = [f"{ffplay_pid}"]
    with open(pid_file, "w") as f:
        f.writelines(lines)
