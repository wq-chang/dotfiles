import VolumeIndicator from './buttons/Audio';
import SystemTray from './buttons/SystemTray';

const Bar = (monitor: number) =>
    Widget.Window({
        monitor,
        name: `bar${monitor.toString()}`,
        anchor: ['top', 'left', 'right'],
        exclusivity: 'exclusive',
        child: Widget.CenterBox({
            startWidget: Widget.Label({
                hpack: 'start',
                label: 'Welcome to AGS!',
            }),
            centerWidget: Widget.Label({
                hpack: 'center',
                label: 'WTF',
            }),
            endWidget: Widget.Box({
                hpack: 'end',
                children: [SystemTray, VolumeIndicator],
            }),
        }),
    });

export default Bar;
