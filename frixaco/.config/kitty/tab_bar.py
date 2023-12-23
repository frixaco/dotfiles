import getpass
import socket
import subprocess
from pathlib import Path
from typing import Any, Dict, Tuple

from kittens.ssh.utils import get_connection_data
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.rgb import Color
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int
from kitty.window import Window

REFRESH_TIME = 2.0

SSH_CONFIG_FILE = "~/.ssh/config"

RIGHT_ROUNDED_EDGE = ""
LEFT_ROUNDED_EDGE = ""
RIGHT_SOFT_ROUNDED_EDGE = ""
LEFT_SOFT_ROUNDED_EDGE = ""
SOFT_SEP = "│"
EMPTY_CELL = " "
BRANCH_ICON = "󰘬"
USER_ICON = ""
HOST_ICON = "󱡶"
DIRECTORY_ICON = "󰎁"

timer_id = None


def redraw_tab_bar(timer_id: int | None):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()


def get_git_info(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
    active_window: Window,
) -> Tuple[str, str, str]:
    cwd = active_window.cwd_of_child
    proc = subprocess.run(["git", "branch", "--show-current"], capture_output=True, cwd=cwd)
    # If the command fails we're probably not in a Git repo (note that often the command
    # does not error out, so checking the stderr protects against false negatives)
    if proc.returncode != 0 or len(proc.stderr) > 0:
        return "", "", ""
    branch = str(proc.stdout, "utf-8").strip() or "DETACHED"

    # git status --porcelain --untracked-files=all | wc -l | sed 's/ //g'
    unstaged_status = subprocess.run(['git', 'status', '--porcelain', '--untracked-files=all'], capture_output=True, cwd=cwd)
    unstaged_files = subprocess.run(['wc', '-l'], capture_output=True, input=unstaged_status.stdout, cwd=cwd)
    unstaged_count = "*" + str(unstaged_files.stdout, "utf-8").strip()

    # git diff --cached --name-only | wc -l | sed 's/ //g'
    staged_status = subprocess.run(['git', 'diff', '--cached', '--name-only'], capture_output=True, cwd=cwd)
    staged_files = subprocess.run(['wc', '-l'], capture_output=True, input=staged_status.stdout, cwd=cwd)
    staged_count = "+" + str(staged_files.stdout, "utf-8").strip()

    return unstaged_count, staged_count, branch


def get_system_info(active_window: Window) -> Tuple[str, str, bool]:
    # Local info (and fallback for errors on remote info)
    user = getpass.getuser()
    host = socket.gethostname()
    is_ssh = False

    ssh_cmdline = []
    # The propery "child_is_remote" is True when the command being executed is a
    # standard "ssh" command, without using the SSH kitten
    if active_window.child_is_remote:
        procs = sorted(active_window.child.foreground_processes, key=lambda p: p["pid"])
        for p in procs:
            if p["cmdline"][0] == "ssh":
                ssh_cmdline = p["cmdline"]
    # The command line is not an empty list in case we're running the ssh kitten
    ssh_cmdline = active_window.ssh_kitten_cmdline()

    if ssh_cmdline != []:
        is_ssh = True

    return user, host, is_ssh


def draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
    active_window: Window,
) -> int:
    screen.cursor.bg = 1
    screen.cursor.fg = 0

    sys_info = get_system_info(active_window)
    user, host, is_ssh = sys_info
    screen.draw(f"{USER_ICON} {user}")
    if is_ssh:
        screen.draw(f" {HOST_ICON} {host}")

    screen.cursor.bg = 0
    screen.cursor.fg = 1
    screen.draw(RIGHT_ROUNDED_EDGE)
    # screen.draw(4 * EMPTY_CELL)
    screen.cursor.x += 2

    return screen.cursor.x


def draw_right_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
    active_window: Window,
) -> int:
    global timer_id
    if timer_id is None:
        timer_id = add_timer(redraw_tab_bar, REFRESH_TIME, True)

    unstaged_count, staged_count, git_branch = get_git_info(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data, active_window)
    status = f" {BRANCH_ICON} {git_branch} {SOFT_SEP} {unstaged_count} {staged_count}"
    if git_branch == "":
        status = " "

    left_space = screen.columns - screen.cursor.x - len(status) - len(LEFT_ROUNDED_EDGE)
    screen.cursor.x += left_space

    screen.cursor.bg = 0
    screen.cursor.fg = 1
    screen.draw(LEFT_ROUNDED_EDGE)

    screen.cursor.bg = 1
    # screen.cursor.fg = 0
    screen.cursor.fg = as_rgb(0xA6E3A1)

    screen.draw(status)

    return screen.cursor.x


def draw_active_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    screen.cursor.bg = as_rgb(color_as_int(draw_data.active_fg))
    screen.cursor.fg = as_rgb(color_as_int(draw_data.active_bg))
    screen.draw(LEFT_ROUNDED_EDGE)

    screen.cursor.bg = as_rgb(color_as_int(draw_data.active_bg))
    screen.cursor.fg = as_rgb(color_as_int(draw_data.active_fg))
    screen.draw(f"{index}:{tab.title}")

    screen.cursor.bg = as_rgb(color_as_int(draw_data.active_fg))
    screen.cursor.fg = as_rgb(color_as_int(draw_data.active_bg))
    screen.draw(RIGHT_ROUNDED_EDGE)

    return screen.cursor.x


def draw_inactive_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    screen.cursor.bg = 0
    screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
    screen.draw(LEFT_ROUNDED_EDGE)

    screen.cursor.bg = 0
    screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
    screen.draw(f"{index}:{tab.title}")

    screen.cursor.bg = 0
    screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_bg))
    screen.draw(RIGHT_ROUNDED_EDGE)

    screen.cursor.bg = 1
    screen.cursor.fg = 0

    return screen.cursor.x


def get_current_tab_title(active_window: Window, tab: TabBarData) -> str:
    boss = get_boss()
    current_tab = boss.tab_for_id(active_window.tab_id)
    tab_title = tab.title
    if current_tab is not None:
        tab_title = current_tab.effective_title

    return tab_title


# def draw_current_cwd(
#     draw_data: DrawData,
#     screen: Screen,
#     tab: TabBarData,
#     before: int,
#     max_title_length: int,
#     index: int,
#     is_last: bool,
#     extra_data: ExtraData,
#     active_window: Window,
# ) -> int:
#     screen.cursor.bg = 0
#     screen.cursor.fg = 1
#     screen.draw(LEFT_ROUNDED_EDGE)
#
#     cwd = active_window.cwd_of_child
#     if cwd is None:
#         cwd = "-"
#     screen.cursor.bg = 1
#     screen.cursor.fg = 0
#
# # Issue with resizing when directory is too long/changed
#     tab_title = get_current_tab_title(active_window, tab)
#
#     screen.draw(f"{DIRECTORY_ICON} {tab_title}")
#
#     screen.cursor.bg = 0
#     screen.cursor.fg = 1
#     screen.draw(RIGHT_ROUNDED_EDGE)
#
#     # screen.draw(4 * EMPTY_CELL)
#     screen.cursor.x += 2
#
#     return screen.cursor.x


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    boss = get_boss()
    active_window = boss.active_window
    if active_window is None:
        return screen.cursor.x

    if index == 1:
        draw_left_status(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data, active_window)
        # draw_current_cwd(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data, active_window)

    if tab.is_active:
        draw_active_tab(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data)
    else:
        draw_inactive_tab(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data)

    if is_last:
        draw_right_status(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data, active_window)

    return screen.cursor.x
