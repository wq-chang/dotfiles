import VolumeIndicator from './buttons/Audio';
import BluetoothIndicator from './buttons/Bluetooth';
import NetworkIndicator from './buttons/Network';
import SystemTray from './buttons/SystemTray';
import WorkspacesIndicator from './buttons/Workspace';

const Bar = (monitor: number) =>
    Widget.Window({
        monitor,
        name: `bar${monitor.toString()}`,
        anchor: ['top', 'left', 'right'],
        exclusivity: 'exclusive',
        child: Widget.CenterBox({
            startWidget: Widget.Box({
                hpack: 'start',
                children: [WorkspacesIndicator],
            }),
            centerWidget: Widget.Label({
                hpack: 'center',
                label: 'WTF',
            }),
            endWidget: Widget.Box({
                hpack: 'end',
                children: [
                    SystemTray,
                    VolumeIndicator,
                    BluetoothIndicator,
                    NetworkIndicator,
                ],
            }),
        }),
    });

export default Bar;
