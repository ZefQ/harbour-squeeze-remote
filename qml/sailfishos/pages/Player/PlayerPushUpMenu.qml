import QtQuick 2.0
import Sailfish.Silica 1.0

PushUpMenu {
    id: playerMenu
    width: parent.width

    Slider {
        width: parent.width
        handleVisible: true
        minimumValue: 0
        maximumValue: 100
        valueText: value.toFixed(0) + " %"
        label: qsTr("Volume")
        onDownChanged: if (!down) {
                           player.slider_volume(value)
                       }

        Binding on value {
            when: !parent.down
            value: player.volume
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge

        Switch {
            icon.source: "image://theme/icon-m-battery"
            automaticCheck: false
            onClicked: player.button_power(!player.power)
            checked: player.power
        }

        Switch {
            icon.source: "image://theme/icon-m-shuffle"
            automaticCheck: false
            onClicked: player.button_shuffle(!player.shuffle)
            checked: player.shuffle
        }

        Switch {
            icon.source: "image://theme/icon-m-repeat"
            automaticCheck: false
            onClicked: player.button_repeat((player.repeat) ? 0 : 2)
            checked: player.repeat
        }
    }

    MenuLabel { text: qsTr("Connected to") + ": " + player.name }
}
