import QtQuick 2.0
import Sailfish.Silica 1.0

PullDownMenu {
    property bool hideSettings: false
    property bool hideLibrary: false
    property bool hideNowPlaying: false
    property bool hideSelectPlayer: false
    property bool hidePlaylist: false

    MenuItem {
        text: qsTr("Settings")
        visible: !hideSettings
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../../pages/Settings/SettingsPage.qml"));
        }
    }

    MenuItem {
        text: qsTr("Music library")
        visible: !hideLibrary
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
                               "selectedMedia": player.get_media_menu_home()
                           });
        }
    }

    MenuItem {
        text: qsTr("Select another player")
        visible: !hideSelectPlayer
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
                               "selectedMedia": player.get_media_menu_settings(),
                               "isSelectPlayer": true
                           });
        }
    }

    MenuItem {
        text: qsTr("Playlist")
        visible: !hidePlaylist
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../../pages/Playlist/PlaylistPage.qml"), {
                               "selectedMedia": player.get_media_menu_playlist()
                           });
        }
    }
}
