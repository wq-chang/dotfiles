import { getNetworkTray, TrayButton } from './SystemTray';

const network = await Service.import('network');

const toggleWifi = () => (network.wifi.enabled = !network.wifi.enabled);
const NetworkIcon = () =>
    network
        .bind('primary')
        .as((primary) => (primary === 'wired' ? WiredIcon : WifiIcon));

const WifiIcon = Widget.Icon({
    icon: network.wifi.bind('icon_name'),
    tooltipText: network.wifi.bind('ssid').as((ssid) => ssid ?? 'Unknown'),
});

const WiredIcon = Widget.Icon({
    icon: network.wired.bind('icon_name'),
});

const NetworkButton = Widget.Button({
    onSecondaryClick: toggleWifi,
    child: NetworkIcon(),
});

const networkTray = getNetworkTray();

const NetworkIndicator = Widget.Box({
    child: networkTray.as((tray) => {
        return tray ? TrayButton(tray) : NetworkButton;
    }),
});

export default NetworkIndicator;
