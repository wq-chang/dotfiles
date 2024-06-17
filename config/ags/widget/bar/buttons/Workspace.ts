import { workspace } from 'options';
import { OVERVIEW_WINDOW_NAME } from 'widget/overview/Overview';

const hyprland = await Service.import('hyprland');

const dispatch = (arg: string | number) => {
    Utils.execAsync(`hyprctl dispatch workspace ${String(arg)}`).catch(
        (err: unknown) => {
            console.error(String(err));
        },
    );
};

const WorkspaceButton = (workspaceNumber: number) =>
    Widget.Button({
        className: 'workspace-btn',
        onPrimaryClick: () => {
            dispatch(workspaceNumber);
        },
        onSecondaryClick: () => {
            App.toggleWindow(OVERVIEW_WINDOW_NAME);
        },
        onScrollUp: () => {
            dispatch('m-1');
        },
        onScrollDown: () => {
            dispatch('m+1');
        },
        child: Widget.Label({
            attribute: workspaceNumber,
            vpack: 'center',
            label: String(workspaceNumber),
        }),
        setup: (self) =>
            self.hook(hyprland, () => {
                self.toggleClassName(
                    'active',
                    hyprland.active.workspace.id === workspaceNumber,
                );
                self.toggleClassName(
                    'occupied',
                    (hyprland.getWorkspace(workspaceNumber)?.windows ?? 0) > 0,
                );
            }),
    });

const Workspaces = (ws: number) =>
    Widget.Box({
        className: 'bar-component',
        children: Array.from({ length: ws }, (_, i) => i + 1).map((i) =>
            WorkspaceButton(i),
        ),
        setup: (box) => {
            if (ws === 0) {
                box.hook(hyprland.active.workspace, () =>
                    box.children.map((btn) => {
                        btn.visible = hyprland.workspaces.some(
                            (ws) => ws.id === btn.attribute,
                        );
                    }),
                );
            }
        },
    });

const WorkspacesIndicator = Widget.Box({
    child: Workspaces(workspace.workspaceNum),
});

export default WorkspacesIndicator;
