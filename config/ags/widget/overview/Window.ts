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

const AppIcon = (width: number, height: number, iconName: string) =>
    Widget.Icon({
        css: `
            	min-width: ${String((workspace.scale / 100) * width)}px;
            	min-height: ${String((workspace.scale / 100) * height)}px;
			`,
        icon: getAppIconName(iconName),
    });

const Window = ({ address, size: [w, h], class: c, title }: Client) => {
    const iconName = getAppIconName(c);

    return Widget.Button({
        className: 'client',
        attribute: { address },
        // tooltipText: `${c}: ${getAppIconName(c)}`,
        tooltipText: title,
        child: AppIcon(w, h, iconName),
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
            btn.drag_source_set_icon_name(iconName);
            btn.on('drag-begin', () => {
                btn.toggleClassName('hidden', true);
            });
            btn.on('drag-data-get', (_self, _c, data: Gtk.SelectionData) => {
                data.set_text(address, address.length);
            });
        },
    });
};

export default Window;
