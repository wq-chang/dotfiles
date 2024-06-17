import Gdk from 'gi://Gdk';
import Gtk from 'gi://Gtk?version=3.0';
import { workspace } from 'options';
import { type Client } from 'types/service/hyprland';
import icons, { getIconName } from 'utils/icon';

const TARGET = [Gtk.TargetEntry.new('text/plain', Gtk.TargetFlags.SAME_APP, 0)];
const hyprland = await Service.import('hyprland');
const apps = await Service.import('applications');
const dispatch = (args: string) => hyprland.messageAsync(`dispatch ${args}`);

const getAppIconName = (c: string) => {
    const app = apps.list.find((app) => app.match(c));
    if (!app) return `${icons.fallback.executable}-symbolic`;

    return getIconName(
        app.icon_name ?? '',
        `${icons.fallback.executable}-symbolic`,
        c,
    );
};

const AppIcon = (width: number, height: number, clientClass: string) =>
    Widget.Icon({
        css: `
            	min-width: ${String((workspace.scale / 100) * width)}px;
            	min-height: ${String((workspace.scale / 100) * height)}px;
			`,
        icon: getAppIconName(clientClass),
    });

const Window = ({ address, size: [w, h], class: c, title }: Client) =>
    Widget.Button({
        className: 'client',
        attribute: { address },
        // tooltipText: `${c}: ${getAppIconName(c)}`,
        tooltipText: title,
        child: AppIcon(w, h, c),
        onClicked: () => {
            void dispatch(`focuswindow address:${address}`);
            App.closeWindow('overview');
        },
        onMiddleClick: () => dispatch(`closewindow address:${address}`),
        setup: (btn) => {
            btn.drag_source_set(
                Gdk.ModifierType.BUTTON1_MASK,
                TARGET,
                Gdk.DragAction.MOVE,
            );

            btn.on('drag-begin', () => {
                btn.toggleClassName('hidden', true);
            });

            btn.on('drag-data-get', (_w, _c, data) => {
                // eslint-disable-next-line @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
                data.set_text(address, address.length);
            });
        },
    });

export default Window;
