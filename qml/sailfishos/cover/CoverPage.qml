import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
        Image {
            id: img
            anchors {
                //horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            fillMode: Image.PreserveAspectFit
            source: player.cover
            width: parent.width
            height: parent.width
        }
        Label {
            id: songlabel
            font.pixelSize: Theme.fontSizeExtraSmall
            anchors.top: img.bottom
            text: (player.song || "Squeeze Ui")
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            width: parent.width
        }
        Label {
            font.pixelSize: Theme.fontSizeTiny
            anchors.top: songlabel.bottom
            text: ((player.tracks > 1)?((player.cur_index + 1) + " / " + player.tracks):"")
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            width: parent.width
        }


    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
            onTriggered: player.button_pause()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: player.button_jump_fwd()
        }
    }
}
