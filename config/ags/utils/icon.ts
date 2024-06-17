import Gtk from 'types/@girs/gtk-3.0/gtk-3.0';

export const getIconName = (
    iconName: string | null,
    fallback = icons.missing,
    appName?: string,
) => {
    if (!iconName) {
        return fallback;
    }

    let iconN = iconName;
    if (appName?.match('steam')) {
        iconN = appName;
    }
    const iconTheme = Gtk.IconTheme.get_default();
    if (iconTheme.has_icon(iconN)) {
        return iconN;
    }

    return fallback;
};

const icons = {
    fallback: {
        audio: 'audio-x-generic-symbolic',
        executable: 'application-x-executable',
        notification: 'dialog-information-symbolic',
        video: 'video-x-generic-symbolic',
    },
    missing: 'image-missing-symbolic',
};

export default icons;
