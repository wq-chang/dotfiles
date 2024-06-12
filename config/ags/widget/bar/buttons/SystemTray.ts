import { TrayItem } from 'types/service/systemtray';

const systemtray = await Service.import('systemtray');

const blueman = 'blueman';
const network = 'Network';
const ignored = [blueman, network];

const getTrayByTitle = (title: string) => {
    return systemtray
        .bind('items')
        .as((items) => items.find((item) => item.title === title));
};

const getTooltip = (tray: TrayItem) =>
    Utils.merge(
        [tray.bind('tooltip_markup'), tray.bind('title')],
        (tooltipMarkup, title) =>
            tooltipMarkup === '' ? title : tooltipMarkup,
    );

export const getBluemanTray = () => getTrayByTitle(blueman);
export const getNetworkTray = () => getTrayByTitle(network);

export const TrayButton = (tray: TrayItem) =>
    Widget.Button({
        child: Widget.Icon({ icon: tray.bind('icon') }),
        onPrimaryClick: (_, event) => {
            tray.activate(event);
        },
        onSecondaryClick: (_, event) => {
            tray.openMenu(event);
        },
        tooltip_markup: getTooltip(tray),
    });

const SystemTray = () => {
    const items = systemtray
        .bind('items')
        .as((items) =>
            items
                .filter((item) => !ignored.includes(item.title))
                .map((item) => TrayButton(item)),
        );

    return Widget.Box({
        children: items,
    });
};

export default SystemTray();
