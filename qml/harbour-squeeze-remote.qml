import QtQuick 2.0
import Sailfish.Silica 1.0

import "sailfishos/pages/Player"
import "common"

ApplicationWindow {
    id: root

    property bool isPlaying: false

    bottomMargin: playerPanel.parent == contentItem ? 0 : playerPanel.visibleSize
    initialPage: Qt.resolvedUrl("sailfishos/pages/Startup/StartupPage.qml")
    cover: Qt.resolvedUrl("sailfishos/cover/CoverPage.qml")


    Binding on isPlaying {
        when: !player.isPlaying || player.isPlaying
        value: player.isPlaying
    }

    PlayerRemoteWorkerscript {
        id: player

        onEnableAudioPlayerChanged: {
            // triggered at startup
            if (enableAudioPlayer && backendready) {
                audioplayer.start();
            }
            else {
                audioplayer.close();
            }
        }

        onBackendreadyChanged: {
            if (enableAudioPlayer && backendready) {
                audioplayer.start();
            }
        }
    }

    AudioPlayerJavascript {
        id: audioplayer
    }

    PlayerPanel {
        id: playerPanel
        player: player
    }
}
