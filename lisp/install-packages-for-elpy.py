'''
def process_pip_on_system():
    try:
        from pip import commands
        pass
    except ImportError:
        import subprocess
        ret = subprocess.run(
            "sudo apt-get update && apt-get install python3-pip",
            shell=True, check=True)
        if not ret.returncode:
            process_pip_on_system()
'''


def main():
    import subprocess
    subprocess.run("apt-get update", shell=True)


if __name__ == "__main__":
    main()
