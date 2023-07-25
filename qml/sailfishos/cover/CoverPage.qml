import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        id: img

        anchors.top: parent.top
        fillMode: Image.PreserveAspectFit
        source: player.cover
        width: parent.width
        height: parent.width
        opacity: 0.3

        transform: Rotation {
            origin.x: 500
            origin.y: 200
            angle: 45

            axis {
                x: 0
                y: 1
                z: 0
            }
        }
    }

    Label {
        id: songlabel

        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.top: img.bottom
        text: (player.song || "Squeeze Ui")
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
    }

    Label {
        font.pixelSize: Theme.fontSizeTiny
        anchors.top: songlabel.bottom
        text: ((player.tracks > 1) ? ((player.cur_index + 1) + " / " + player.tracks) : "")
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
    }

    CoverActionList {
        id: singleCoverAction

        enabled: player.tracks === 1

        CoverAction {
            iconSource: root.isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
            onTriggered: {
                root.isPlaying ? player.button_pause() : player.button_play();
                root.isPlaying = !root.isPlaying;
            }
        }
    }

    CoverActionList {
        id: twoCoverAction

        enabled: player.tracks > 1

        CoverAction {
            iconSource: root.isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
            onTriggered: {
                root.isPlaying ? player.button_pause() : player.button_play();
                root.isPlaying = !root.isPlaying;
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: player.button_jump_fwd()
        }
    }
}
