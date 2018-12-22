import QtQuick 2.0
import Sailfish.Silica 1.0

import "sailfishos/pages"
import "common"

ApplicationWindow
{
    initialPage: Component { StartupPage { } }
    cover: Qt.resolvedUrl("sailfishos/cover/CoverPage.qml")

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
}
