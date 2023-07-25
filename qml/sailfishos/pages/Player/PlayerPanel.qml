import QtQuick 2.0
import Sailfish.Silica 1.0

DockedPanel {
    id: panel

    property Item player
    property real hightPadding: Theme.paddingMedium

    width: parent.width
    height: column.height
    contentHeight: column.height
    dock: Dock.Bottom

    open: !Qt.inputMethod.visible
          && pageStack.currentPage != playerPage
          && player.frontendready

    Behavior on height {
        PropertyAnimation {}
    }

    MouseArea {
        anchors.fill: parent
        onClicked: pageStack.push(playerPage)
    }

    PlayerPage {
        id: playerPage
    }

    PlayerPushUpMenu {}

    Column {
        id: column
        width: parent.width

        Item {
            width: parent.width
            height: Theme.itemSizeSmall + (hightPadding * 2)

            Image {
                id: cover

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    rightMargin: Theme.horizontalPageMargin
                }

                source: player.cover
                smooth: true
                cache: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }

            Column {
                anchors {
                    left: cover.right
                    leftMargin: Theme.paddingMedium
                    right: playbutton.left
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    visible: text
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: player.artist
                    truncationMode: TruncationMode.Fade
                    width: parent.width
                }

                Label {
                    font.pixelSize: Theme.fontSizeSmall
                    text: player.song
                    truncationMode: TruncationMode.Fade
                    width: parent.width
                }
            }


            IconButton {
                id: playbutton
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                height: parent.height

                icon.source: player.isPlaying ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                onClicked: player.isPlaying ? player.button_pause() : player.button_play()
            }
        }
    }
}
