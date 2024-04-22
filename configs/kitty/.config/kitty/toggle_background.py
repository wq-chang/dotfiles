from typing import List

import kitty.fast_data_types as f
from kittens.tui.handler import result_handler
from kitty.boss import Boss


def main(args: List[str]):
    pass


@result_handler(no_ui=True)
def handle_result(args: List[str], stdin_data: str, target_window_id: int, boss: Boss):
    os_window_id = f.current_focused_os_window_id()
    current_opacity = f.background_opacity_of(os_window_id)
    current_opacity = round(current_opacity, 2)
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        w.paste_text(str(current_opacity))
    if current_opacity == 0.85:
        boss.set_background_opacity("default")
    else:
        boss.set_background_opacity("0.85")
