/*  Squeezeui - Graphical user interface for Squeezebox players.
#
#  Copyright (C) 2014 Frode Holmer <fholmer+squeezeui@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    canAccept: ((serverip.text !== "") && (serverhttpport.text !== ""))

    acceptDestination: Qt.resolvedUrl("StartupPage.qml")
    acceptDestinationAction: PageStackAction.Replace

    DialogHeader {
        defaultAcceptText: "Connect"
    }

    SilicaFlickable {
        clip: true
        contentHeight: dialogcolumn.height
        anchors {
            fill: parent
            centerIn: parent
            topMargin: 100
        }

        Column {
            id: dialogcolumn
            width: parent.width - ( Theme.paddingLarge * 4)

            anchors {
                centerIn: parent
            }

            spacing: Theme.paddingMedium

            Label {
                //anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                text: "Squeezebox server settings."
            }

            TextField {
                id: serverip
                anchors {
                    left: parent.left
                    right: parent.right
                }
                placeholderText: "0.0.0.0"
                text: player.backendServerAddress
                label: "Server address"
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
            TextField {
                id: serverhttpport
                width: parent.width
                placeholderText: ""
                text: player.backendServerPort
                label: "Server http port"
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
            TextSwitch {
                id: savesettingstofile
                text: "Set as default"
                description: "Save address and port to settings file."
            }
            TextSwitch {
                id: deletesettings
                text: "Clear"
                description: "Clear all existing data in settings file."
            }

            Label {
                color: Theme.highlightColor
                text: "Audio playback"
            }

            TextSwitch {
                id: enableaudioplayer
                text: "Enable audio player"
                description: "Experimental audio support. Sync with other players does not work."
                checked: player.enableAudioPlayer
            }

            TextField {
                id: servertcpport
                anchors {
                    left: parent.left
                    right: parent.right
                }
                placeholderText: ""
                text: player.serverTcpPort
                label: "Server tcp port (audio)"
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
        }
    VerticalScrollDecorator { flickable: parent }

    }
    onAccepted: {
        var _settings;

        if (deletesettings.checked) {
            player.setSettings({});
        }

        if (enableaudioplayer.checked !== player.enableAudioPlayer) {

            _settings = player.getSettings();
            _settings["enable_audio_player"] = enableaudioplayer.checked;
            player.setSettings(_settings);
        }

        if (savesettingstofile.checked) {

            _settings = player.getSettings();
            _settings["server_address"] = serverip.text;
            _settings["server_port"] = serverhttpport.text; // need to be deleted
            _settings["server_http_port"] = serverhttpport.text;
            _settings["server_tcp_port"] = parseInt(servertcpport.text);


            player.setSettings(_settings);
            //player.saveSettings(); //not needed
        }

        player.backendServerAddress = serverip.text;
        player.backendServerPort = serverhttpport.text;
        player.serverTcpPort = parseInt(servertcpport.text);
        player.backendready = true;
        player.enableAudioPlayer = enableaudioplayer.checked;
        player.initFrontend();
    }
}
