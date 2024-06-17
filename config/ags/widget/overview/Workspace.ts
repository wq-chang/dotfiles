import Gdk from 'gi://Gdk';
import Gtk from 'gi://Gtk?version=3.0';
import { workspace } from 'options';
import Window from './Window';

const TARGET = [Gtk.TargetEntry.new('text/plain', Gtk.TargetFlags.SAME_APP, 0)];
const scale = (size: number) => (workspace.scale / 100) * size;
const hyprland = await Service.import('hyprland');

const dispatch = (args: string) => hyprland.messageAsync(`dispatch ${args}`);

const getSize = (id: number) => {
    const def = { h: 1080, w: 1920 };
    const ws = hyprland.getWorkspace(id);
    if (!ws) return def;

    const mon = hyprland.getMonitor(ws.monitorID);
    return mon ? { h: mon.height, w: mon.width } : def;
};

const Workspace = (id: number) => {
    const fixed = Widget.Fixed();

    const update = () => {
        const json = hyprland.message('j/clients');
        if (!json) {
            return;
        }

        fixed.get_children().forEach((ch) => {
            ch.destroy();
        });
        const clients = JSON.parse(json) as typeof hyprland.clients;
        clients
            .filter(({ workspace }) => workspace.id === id)
            .forEach((c) => {
                const x = c.at[0] - (hyprland.getMonitor(c.monitor)?.x ?? 0);
                const y = c.at[1] - (hyprland.getMonitor(c.monitor)?.y ?? 0);
                c.mapped && fixed.put(Window(c), scale(x), scale(y));
            });
        fixed.show_all();
    };

    const size = getSize(id);
    const minHeight = (workspace.scale / 100) * size.w;
    const minWidth = (workspace.scale / 100) * size.h;

    return Widget.Box({
        attribute: { id },
        tooltipText: String(id),
        className: 'workspace',
        vpack: 'center',
        css: `
            min-width: ${String(minWidth)}px;
            min-height: ${String(minHeight)}px;
        `,
        setup(box) {
            box.hook(hyprland, update, 'notify::clients');
            box.hook(hyprland.active.client, update);
            box.hook(hyprland.active.workspace, () => {
                box.toggleClassName(
                    'active',
                    hyprland.active.workspace.id === id,
                );
            });
        },
        child: Widget.EventBox({
            expand: true,
            onPrimaryClick: () => {
                App.closeWindow('overview');
                void dispatch(`workspace ${String(id)}`);
            },
            setup: (eventbox) => {
                eventbox.drag_dest_set(
                    Gtk.DestDefaults.ALL,
                    TARGET,
                    Gdk.DragAction.MOVE,
                );
                eventbox.connect(
                    'drag-data-received',
                    (_self, _c, _x, _y, data: Gtk.SelectionData) => {
                        const address = new TextDecoder().decode(
                            data.get_data(),
                        );
                        void dispatch(
                            `movetoworkspacesilent ${String(id)},address:${address}`,
                        );
                    },
                );
            },
            child: fixed,
        }),
    });
};

export default Workspace;
