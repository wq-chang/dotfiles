from typing import List

from kittens.tui.handler import result_handler
from kitty.boss import Boss


def main(args: List[str]):
    pass


@result_handler(no_ui=True)
def handle_result(args: List[str], stdin_data: str, target_window_id: int, boss: Boss):
    app_name = args[1]
    tabs = boss.active_tab_manager.tabs
    for tab in tabs:
        if tab.title == app_name:
            tab.make_active()
            return
    boss.launch("--type=tab", "--cwd=current", app_name)
