const audio = await Service.import('audio');

type VolumeThreshold = {
    volume: number;
    name: string;
};

const volumeScaling = 0.01;

const toggleMute = () => (audio.speaker.is_muted = !audio.speaker.is_muted);
const adjustVolume = (action: 'increase' | 'decrease') =>
    (audio.speaker.volume =
        audio.speaker.volume +
        volumeScaling * (action === 'decrease' ? -1 : 1));

const VolumeIcon = Widget.Icon().hook(audio.speaker, (self) => {
    const vol = Math.ceil(audio.speaker.volume * 100);
    const thresholds: VolumeThreshold[] = [
        { volume: 101, name: 'overamplified' },
        { volume: 67, name: 'high' },
        { volume: 34, name: 'medium' },
        { volume: 1, name: 'low' },
        { volume: 0, name: 'muted' },
    ];
    const icon =
        thresholds.find((threshold) => threshold.volume <= vol)?.name ?? '';

    self.icon = `audio-volume-${icon}-symbolic`;
    self.tooltip_text = `Volume: ${String(vol)}%`;
});

const VolumeIndicator = Widget.Button({
    onClicked: toggleMute,
    onScrollUp: () => adjustVolume('increase'),
    onScrollDown: () => adjustVolume('decrease'),
    child: VolumeIcon,
});

export default VolumeIndicator;
