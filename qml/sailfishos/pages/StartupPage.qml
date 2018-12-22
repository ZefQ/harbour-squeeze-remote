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

Page {

    BusyIndicator {
        id:waitforserver
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: true

    }
    Label {
        id:infolabel
        anchors {
            top: waitforserver.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }

        text: qsTr("Connecting ...")
        color: Theme.highlightColor
    }

    Timer {
        id: settingstimer
        interval: 10000; running: false; repeat: false
        onTriggered: {
            settingstimer.stop();
            infolabel.text = qsTr("Failed");
            pageStack.replace(Qt.resolvedUrl("SettingsPage.qml"));
        }
    }
    Connections {
        target: player
        onFrontendreadyChanged: {
            if (player.frontendready) {
                settingstimer.stop();
                infolabel.text = qsTr("Connected")
                pageStack.replace(Qt.resolvedUrl("PlayerPage.qml"), null, PageStackAction.Immediate);
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            player.frontendready = false;
            settingstimer.start();
        }
    }
}
