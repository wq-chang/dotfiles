import PopupWindow from 'components/PopupWindow';
import { workspace } from 'options';
import Workspace from './Workspace';

const hyprland = await Service.import('hyprland');
export const OVERVIEW_WINDOW_NAME = 'overview';

const Overview = (ws: number) =>
    Widget.Box({
        className: 'overview horizontal',
        children:
            ws > 0
                ? Array.from({ length: ws }, (_, i) => i + 1).map(Workspace)
                : hyprland.workspaces
                      .map(({ id }) => Workspace(id))
                      .sort((a, b) => a.attribute.id - b.attribute.id),

        setup: (w) => {
            if (ws > 0) return;

            w.hook(
                hyprland,
                (w, id?: string) => {
                    if (id === undefined) return;

                    w.children = w.children.filter(
                        (ch) => ch.attribute.id !== Number(id),
                    );
                },
                'workspace-removed',
            );
            w.hook(
                hyprland,
                (w, id?: string) => {
                    if (id === undefined) return;

                    w.children = [...w.children, Workspace(Number(id))].sort(
                        (a, b) => a.attribute.id - b.attribute.id,
                    );
                },
                'workspace-added',
            );
        },
    });

const OverviewWindow = PopupWindow({
    name: OVERVIEW_WINDOW_NAME,
    layout: 'center',
    child: Overview(workspace.workspaceNum),
});

export default OverviewWindow;
