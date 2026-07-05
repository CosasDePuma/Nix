import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import ".."
import "../utils/" as Utils

RowLayout {
    id: workspaces
    spacing: 3
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter

    property var currentWorkspaces: Hyprland.workspaces.values.filter(w => w.monitor.name == taskbar.screen.name)
    Repeater {
        model: parent.currentWorkspaces
        Button {
            id: control
            anchors.centerIn: parent.centerIn
            contentItem: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Utils.TextUtils.toRomanNumeral(modelData.id)

                font.family: fontBoska.name
                font.weight: 650
                width: 10
                height: 10
                font.pixelSize: 13
                color: control.getColor()
            }
            onPressed: event => {
                Hyprland.dispatch(`hl.dsp.focus({workspace = "${modelData.id}"})`);
                event.accepted = true;
            }

            // TODO: Improve this, it's very messy right now.
            property int focusedWindowId: 0
            function getColor() {
                focusedWindowId = Hyprland.focusedWorkspace.id;
                if (modelData.urgent) {
                    return Config.colors.urgent;
                } else if (modelData.id == focusedWindowId || mouse.hovered) {
                    return Config.colors.accent;
                }
                return Config.colors.text;
            }
            background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: 18
                height: 18
                border.width: 0
                color: "transparent"
            }

            HoverHandler {
                id: mouse
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
