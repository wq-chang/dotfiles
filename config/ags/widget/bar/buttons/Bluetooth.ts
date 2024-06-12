import { getBluemanTray, TrayButton } from './SystemTray';

const bluetooth = await Service.import('bluetooth');

const toggleBluetooth = () => (bluetooth.enabled = !bluetooth.enabled);
const getConnectedDevice = () =>
    bluetooth.bind('connected_devices').as((devices) => {
        if (!devices.length) {
            return '';
        }

        return String(devices[0].icon_name) + String(devices[0].name);
    });
const getBluetoothIconName = () =>
    bluetooth
        .bind('enabled')
        .as((on) => `bluetooth-${on ? 'active' : 'disabled'}-symbolic`);

const BluetoothIcon = Widget.Icon({
    icon: getBluetoothIconName(),
    tooltipText: getConnectedDevice(),
});

const BluetoothButton = Widget.Button({
    onSecondaryClick: toggleBluetooth,
    child: BluetoothIcon,
});

const bluemanTray = getBluemanTray();

const BluetoothIndicator = Widget.Box({
    child: bluemanTray.as((tray) => {
        return tray ? TrayButton(tray) : BluetoothButton;
    }),
});

export default BluetoothIndicator;
