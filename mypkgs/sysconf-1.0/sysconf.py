from __future__ import nested_scopes, print_function

import argparse
import datetime
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
LINUX_DISTRO, DISTRO_VERSION, DISTRO_ALIAS = platform.linux_distribution()
SUPPORT_DISTROS = [
    x for x in map(lambda x: x.lower(), ["Ubuntu", "LinuxMint", "Debian"])]


def root_(filename, last_dir=None):
    """
    Get the path to files/directories
    """
    args = [filename]
    if isinstance(last_dir, str):
        args.append(last_dir)
    return os.path.join(os.path.abspath("."), *args)


def symlink_with_log(src, dst, target_is_directory=False):
    """
    The `symlink_with_log' function is custom version to os.symlink
    """
    try:
        command = "ln -s {src} {dst}".format(src=src, dst=dst)
        os.symlink(src, dst, target_is_directory)
    except FileExistsError as err:
        execute.tracebacks["result"].append(
            {
                "retcode": 1,
                "errs": err.strerror,
                "command": command
            })
    else:
        execute.outputs["result"].append(
            {
                "retcode": 0,
                "outs": "",
                "command": command
            })


def mk_execute():
    def execute(command):
        password = os.getenv(PASSWORD_KEYNAME, '')
        # password = 'saltborn'
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
                "command": " ".join(command),
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
    # update_and_upgrade()
    init_pkg()
    init_pip()
    # init_dotfile()


def init_dotfile():
    """
    Place dotfiles in the right place

    Copy files with shutil module instead of os module
    Create symbolic link with os module
    I think create symbolic link is better,
    the dotfiles and the location they should be placed:
    Program            Location
    i3wm               ~/.i3
    pip                ~/.pip
    """
    home = os.environ["HOME"]
    symlink_with_log(root_("dotfiles", "i3"),
                     os.path.join(home, ".i3"),
                     True)
    symlink_with_log(root_("dotfiles", "pip"),
                     os.path.join(home, ".pip"),
                     True)


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
        "beautifulsoup4",
        # For elpy
        "elpy",
        "autopep8",
        "yapf",
        "virtualenv",
        # For ss
        # "shadowsocks",
        "git+https://github.com/shadowsocks/shadowsocks.git@master",
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
    TODO: There is a bug here that it cannot install the packages
    '''
    if LINUX_DISTRO.lower() in SUPPORT_DISTROS:
        # execute(["add-apt-repository", "ppa:hda-me/proxychains-ng", "-y"])
        # execute(["apt-get", "update"])
        execute([
            "apt-get", "install", "compton",
            "i3", "i3status", "i3blocks",
            "lxappearance", "sbcl", "suckless-tools",
            "python3-pip", "polipo", "rofi"
        ])
    else:
        pass
    # install_firefox()


def init_service():

    if LINUX_DISTRO not in SUPPORT_DISTROS:
        return
    if LINUX_DISTRO in ["Ubuntu", "LinuxMint"]:
        # For shadowsocks
        # os.symlink("shfiles/shadowsocks", "/etc/shadowsocks")
        symlink_with_log(root_("shadowsocks"), "shfiles", "/etc/shadowsocks")
        execute("update-rc.d shadowsocks defaults")


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
    if LINUX_DISTRO.lower() not in SUPPORT_DISTROS:
        sys.exit(-1)
    parser = argparse.ArgumentParser(
        prog="sysconf",
        description='Process the input from EMACS.')
    parser.add_argument("command", type=str, metavar="COMMAND",
                        help="The command you want to execute",
                        choices=["init", "pip", "upgrade", "dot"])
    parser.add_argument("-pk", "--passwordkey", type=str,
                        help="The name of variable to passing password")
    args = parser.parse_args()
    if args.passwordkey:
        PASSWORD_KEYNAME = args.passwordkey
        # os.environ[PASSWORD_KEYNAME] = args.passwordkey
    exec_cmd = {
        "init": init,
        "upgrade": update_and_upgrade,
        "pip": init_pip,
        "dot": init_dotfile
    }.get(args.command)
    retcode = exec_cmd()
    print("Finished at %s" % datetime.datetime.now())
    print("Errors:")
    print(execute.tracebacks)
    print("Results:")
    print(execute.outputs)
    sys.exit(retcode)
