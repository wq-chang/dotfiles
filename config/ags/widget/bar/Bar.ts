import VolumeIndicator from './buttons/Audio';
import BluetoothIndicator from './buttons/Bluetooth';
import Clock from './buttons/Clock';
import NetworkIndicator from './buttons/Network';
import SystemTray from './buttons/SystemTray';
import WorkspacesIndicator from './buttons/Workspace';

const Bar = (monitor: number) =>
    Widget.Window({
        className: 'transparent',
        monitor,
        name: `bar${monitor.toString()}`,
        anchor: ['top', 'left', 'right'],
        exclusivity: 'exclusive',
        child: Widget.CenterBox({
            startWidget: Widget.Box({
                hpack: 'start',
                children: [WorkspacesIndicator],
            }),
            centerWidget: Widget.Box({
                hpack: 'center',
                child: Clock,
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
