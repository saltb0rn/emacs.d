import os
import shlex
from subprocess import (
    CalledProcessError, DEVNULL, Popen, PIPE, run)
import sys


def execute(command, password=None):
    if not isinstance(command, list):
        command = shlex.split(command)
    try:
        proc = run(command, check=True, stderr=DEVNULL)
    except CalledProcessError:
        proc = Popen(
            ["sudo", "-S"]+command,
            stdin=PIPE,
            stderr=PIPE,
            universal_newlines=True)
        proc.communicate(password+"\n")
    return proc.returncode


def main():
    password = os.getenv("EMACS_INPUT")
    assert execute("apt-get update", password) == 0
    return execute("apt-get upgrade -y", password)


if __name__ == "__main__":
    os.environ["EMACS_INPUT"] = sys.argv[1]
    main()
