import argparse
import itertools
import os
import shlex
import sys
from subprocess import (DEVNULL, Popen,
                        PIPE, run)


PASSWORD_KEYNAME = "PASSWORD"
PYTHON_VERSION = '3'
INSTALL_IPYTHON_COMMAND = "apt-get install ipython{}".format(PYTHON_VERSION)
INSTALL_PYTHON_COMMAND = "apt-get install python{}".format(PYTHON_VERSION)
INSTALL_PIP_COMMAND = "apt-get install python{}-pip".format(PYTHON_VERSION)


def execute(command):
    if not isinstance(command, list):
        command = shlex.split(command)
    password = os.getenv(PASSWORD_KEYNAME, '')
    proc = Popen(
        ["sudo", "-S"]+command,
        stdin=PIPE,
        stderr=PIPE,
        universal_newlines=True)
    proc.communicate(password+"\n")
    return proc.returncode


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
    (I will do this one later since I want the developer edition of it)
    https://download-installer.cdn.mozilla.net/pub/devedition/releases/57.0b9/linux-x86_64/en-US/firefox-57.0b9.tar.bz2
    https://download-installer.cdn.mozilla.net/pub/devedition/releases/57.0b9/linux-x86_64/en-US/

    '<!DOCTYPE html>\n<html>\n\t<head>\n\t\t<meta charset="UTF-8">\n\t\t<title>Directory Listing: /pub/devedition/releases/57.0b9/linux-x86_64/en-US/</title>\n\t</head>\n\t<body>\n\t\t<h1>Index of /pub/devedition/releases/57.0b9/linux-x86_64/en-US/</h1>\n\t\t<table>\n\t\t\t<tr>\n\t\t\t\t<th>Type</th>\n\t\t\t\t<th>Name</th>\n\t\t\t\t<th>Size</th>\n\t\t\t\t<th>Last Modified</th>\n\t\t\t</tr>\n\t\t\t\n\t\t\t<tr>\n\t\t\t\t<td>Dir</td>\n\t\t\t\t<td><a href="/pub/devedition/releases/57.0b9/linux-x86_64/">..</a></td>\n\t\t\t\t<td></td>\n\t\t\t\t<td></td>\n\t\t\t</tr>\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t<tr>\n\t\t\t\t<td>File</td>\n\t\t\t\t<td><a href="/pub/devedition/releases/57.0b9/linux-x86_64/en-US/firefox-57.0b9.tar.bz2">firefox-57.0b9.tar.bz2</a></td>\n\t\t\t\t<td>57M</td>\n\t\t\t\t<td>17-Oct-2017 03:18</td>\n\t\t\t</tr>\n\t\t\t\n\t\t\t\n\t\t</table>\n\t</body>\n</html>\n'
    This is the content of html, maybe i can use


    Why not emacs and git?
    Because they are already installed before executing script.
    """
    execute(INSTALL_PYTHON_COMMAND)
    execute(["apt-get", "install", "polipo"])
    pass


def update_and_upgrade():
    retcode = execute("apt-get update")
    return execute("apt-get upgrade -y") if not retcode else retcode


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="EMACS input processor",
        description='Process the input from EMACS.')
    parser.add_argument("command", type=str, metavar="COMMAND",
                        help="The command you want to execute",
                        choices=["upgrade", "init", "pip"])
    parser.add_argument("-p", "--password", type=str,
                        help="input the password (that is used for root)")
    args = parser.parse_args()
    if args.password:
        os.environ[PASSWORD_KEYNAME] = args.password
    command = {
        "init": lambda: init(),
        "upgrade": lambda: update_and_upgrade(),
        "pip": lambda: init_pip(),
    }.get(args.command)
    retcode = command()
    sys.exit(retcode)
