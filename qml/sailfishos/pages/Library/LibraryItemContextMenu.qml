import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
    id: contextMenu
    ContextMenu {
        property var newMedia

        MenuLabel {
            visible: newMedia.input !== ""
            text: qsTr("Input")
        }
        TextField {
            visible: newMedia.input !== ""
            id: inputtext
            width: parent.width
            focus: true
            placeholderText: qsTr("Type here...")
            Keys.onReturnPressed: pageStack.push(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
                                                     "selectedMedia": player.media_go(newMedia, "go", text),
                                                     "selectedInputText": text
                                                 })
        }
        MenuItem {
            visible: newMedia.input !== ""
            text: qsTr("OK")
            onClicked: pageStack.push(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
                                          "selectedMedia": player.media_go(newMedia, "go", inputtext.text),
                                          "selectedInputText": inputtext.text
                                      })
        }
        MenuItem {
            visible: newMedia.input === ""
            enabled: newMedia.play !== ""
            text: qsTr("Play")
            onClicked: {
                player.media_go(newMedia, "play", "");
                goToWindow("nowPlaying");
            }
        }
        MenuItem {
            visible: newMedia.input === ""
            enabled: newMedia.add !== ""
            text: qsTr("Add")
            onClicked: player.media_go(newMedia, "add", "")
        }
        MenuItem {
            visible: newMedia.input === ""
            enabled: newMedia.more !== ""
            text: qsTr("More")
            onClicked: pageStack.push(Qt.resolvedUrl("LibraryPage.qml"), {
                                          "selectedMedia": player.media_go(newMedia, "more", "")
                                      })
        }
        Component.onCompleted: inputtext.forceActiveFocus()
    }
}
