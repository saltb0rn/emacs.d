from __future__ import nested_scopes, print_function

import argparse
import itertools
import os
import platform
import shlex
import shutil
import sys
from subprocess import Popen, PIPE
from urllib.request import urlretrieve


PASSWORD_KEYNAME = "PASSWORD"
PYTHON_VERSION = '3'
INSTALL_IPYTHON_COMMAND = "apt-get install ipython{}".format(PYTHON_VERSION)
# INSTALL_PYTHON_COMMAND = "apt-get install python{}".format(PYTHON_VERSION)
# No Need the command to install Python since the script
# will never run if Python is not installed first
INSTALL_PIP_COMMAND = "apt-get install python{}-pip".format(PYTHON_VERSION)


def mk_execute():
    def execute(command):
        password = os.getenv(PASSWORD_KEYNAME, '')
        if not isinstance(command, list):
            command = shlex.split(command)
        proc = Popen(
            ["sudo", "-S"]+command,
            stdin=PIPE,
            stderr=PIPE,
            stdout=PIPE,
            universal_newlines=True)
        outs, errs = proc.communicate(password+"\n")
        retcode = proc.returncode
        if retcode:
            nonlocal _tracebacks
            _tracebacks["result"].append({
                "retcode": retcode,
                "errs": errs,
                "command": " ".join(command)
            })
        else:
            nonlocal _outputs
            _outputs["result"].append({
                "retcode": retcode,
                "outs": outs,
                "command": " ".join(command)
            })
    _tracebacks = {"result": []}
    _outputs = {"result": []}
    execute.tracebacks = _tracebacks
    execute.outputs = _outputs
    return execute


execute = mk_execute()


def init():
    """
    Configurate my system softwares
    """
    update_and_upgrade()
    init_dotfile()
    init_pip()
    init_pkg()


def init_dotfile():
    """
    Place dotfiles in the right place
    """
    # Copy files with shutil module instead of os module
    # Create symbolic link with os module
    pass


def init_pip():
    try:
        __import__("pip")
    except ImportError:
        update_and_upgrade()
        assert execute(INSTALL_PIP_COMMAND) == 0
    from pip import (
        # commands_dict, get_installed_distributions
        get_installed_distributions,
    )
    # install_command = commands_dict["install"]()
    packages_need_to_be_installed = [
        # For elpy
        "elpy",
        "autopep8",
        "yapf",
        "virtualenv",
        # For ss
        "shadowsocks",
        "beautifulsoup4"
    ]
    packages_installed = [
        pkg.key for pkg in get_installed_distributions()
    ]
    packages_need_to_be_installed = list(
        itertools.filterfalse(
            lambda pkg: pkg in packages_installed,
            packages_need_to_be_installed))
    if packages_need_to_be_installed:
        # install_command.main(packages_need_to_be_installed)
        return execute(["pip3", "install"]+list(packages_need_to_be_installed))
    return 1


def init_pkg():
    """
    Install the softwares needed:

    Python
    polipo
    Firefox

    Why there are NOT emacs and git above?
    Because they are already installed before executing script.
    """
    # execute(INSTALL_PYTHON_COMMAND)
    '''
    execute([
        "echo",
        "deb http://ppa.launchpad.net/ubuntu-elisp/ppa/ubuntu xenial main",
        ">>",
        "/etc/apt/sources.list"
    ])
    execute("apt-key adv --recv-key --keyserver keyserver.ubuntu.com D62FCE72")
    '''
    execute(["apt-get", "install", "polipo"])
    install_firefox()


def install_firefox(path=None):
    if path is None:
        path = "{}/Software".format(os.environ["HOME"])
    filename, headers = urlretrieve("https://download.mozilla.org/?"
                                    "product=firefox-devedition-latest-ssl"
                                    "&os=linux64&lang=en-US")
    path_to_firefox = os.path.join(path, "firefox")
    if not os.path.isdir(path) or not os.path.exists(path):
        os.mkdir(path)
    if os.path.isdir(path_to_firefox):
        return execute.tracebacks["result"].append({
            "retcode": 1,
            "errs": "Firefox is already installed,"
            " or the directory named 'firefox' exists",
            "command": None
        })
    shutil.unpack_archive(filename, path, "tar")


def update_and_upgrade():
    retcode = execute("apt-get update")
    return execute("apt-get upgrade -y") if not retcode else retcode


if __name__ == "__main__":
    distro, version, alias = platform.linux_distribution()
    if distro not in ["Ubuntu", "LinuxMint"]:
        sys.exit(-1)
    parser = argparse.ArgumentParser(
        prog="EMACS input processor",
        description='Process the input from EMACS.')
    parser.add_argument("command", type=str, metavar="COMMAND",
                        help="The command you want to execute",
                        choices=["init", "pip", "upgrade"])
    parser.add_argument("-p", "--password", type=str,
                        help="Input the password to the user)")
    args = parser.parse_args()
    if args.password:
        os.environ[PASSWORD_KEYNAME] = args.password
    exec_cmd = {
        "init": init,
        "upgrade": update_and_upgrade,
        "pip": init_pip
    }.get(args.command)
    retcode = exec_cmd()
    print(execute.tracebacks)
    print(execute.outputs)
    sys.exit(retcode)
