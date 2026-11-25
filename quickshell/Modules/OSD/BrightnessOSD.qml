import QtQuick
import qs.Common
import qs.Modules.ControlCenter.Details
import qs.Services

LevelOSD {
    id: root

    osdKind: "brightness"

    property string osdDeviceId: ""
    readonly property string deviceId: osdDeviceId || BrightnessService.screenLeadDevice(screen)
    readonly property var device: BrightnessService.getCurrentDeviceInfoByName(deviceId)
    property int displayLevel: BrightnessService.getDeviceBrightness(deviceId)

    iconName: BrightnessService.brightnessIconName(device, displayLevel)
    insetIconName: BrightnessService.brightnessIconName(device)
    endIconName: {
        switch (device?.class) {
        case "backlight":
        case "ddc":
        case "software":
            return "monitor";
        default:
            return BrightnessService.brightnessIconName(device);
        }
    }
    endIconLabel: I18n.tr("Brightness")
    iconColor: Theme.onPrimary
    value: displayLevel
    minimum: BrightnessService.brightnessMinimum(device)
    maximum: BrightnessService.brightnessMaximum(device)
    unit: BrightnessService.brightnessUnit(device)
    available: BrightnessService.brightnessAvailable

    sheet: OsdDetailSheet {
        BrightnessDetail {
            anchors.fill: parent
            initialDeviceName: root.device?.name ?? ""
            screenName: root.screen?.name ?? ""
            screenModel: root.screen?.model ?? ""
        }
    }

    onLevelRequested: level => {
        displayLevel = level;
        BrightnessService.setGroupBrightness(level, BrightnessService.screenOsdTargets(screen, deviceId), true);
    }

    Connections {
        target: BrightnessService

        function onBrightnessChanged(showOsd, deviceIds) {
            const osdDevice = showOsd && SettingsData.osdBrightnessEnabled ? BrightnessService.screenOsdDevice(root.screen, deviceIds) : "";
            if (osdDevice)
                root.osdDeviceId = osdDevice;
            root.displayLevel = BrightnessService.getDeviceBrightness(root.deviceId);
            if (osdDevice)
                root.show();
        }
    }
}
