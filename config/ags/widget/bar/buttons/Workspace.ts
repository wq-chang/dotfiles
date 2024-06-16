const hyprland = await Service.import('hyprland');

const dispatch = (arg: string | number) => {
    Utils.execAsync(`hyprctl dispatch workspace ${String(arg)}`).catch(
        (err: unknown) => {
            console.error(String(err));
        },
    );
};

const Workspaces = (ws: number) =>
    Widget.Box({
        className: 'bar-component',
        children: Array.from({ length: ws }, (_, i) => i + 1).map((i) =>
            Widget.Button({
                className: 'workspace-btn',
                onPrimaryClick: () => {
                    dispatch(i);
                },
                onScrollUp: () => {
                    dispatch('m-1');
                },
                onScrollDown: () => {
                    dispatch('m+1');
                },
                child: Widget.Label({
                    attribute: i,
                    vpack: 'center',
                    label: String(i),
                }),
                setup: (self) =>
                    self.hook(hyprland, () => {
                        self.toggleClassName(
                            'active',
                            hyprland.active.workspace.id === i,
                        );
                        self.toggleClassName(
                            'occupied',
                            (hyprland.getWorkspace(i)?.windows ?? 0) > 0,
                        );
                    }),
            }),
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
    child: Workspaces(10),
});

export default WorkspacesIndicator;
