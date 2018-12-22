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
    id: page

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (pageStack.depth === 1) {
                pageStack.pushAttached(
                            Qt.resolvedUrl("LibraryPage.qml"), {
                                selectedMedia: player.get_media_menu_home()});
            }
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        visible: player.frontendready
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
                }
            }
            MenuItem {
                text: "Select another player"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LibraryPage.qml"), { selectedMedia: player.get_media_menu_settings() });
                }
            }
            MenuItem {
                text: "Playlist"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PlaylistPage.qml"), { selectedMedia: player.get_media_menu_playlist() });
                }
            }
            MenuItem {
                text: "Music library"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LibraryPage.qml"), { selectedMedia: player.get_media_menu_home() });
                }
            }
        }


        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            width: page.width
            spacing: Theme.paddingSmall

            PageHeader {
                title: player.name
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                height: 280
                fillMode: Image.PreserveAspectFit
                //antialiasing: true
                source: player.cover
            }
            Label {
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                anchors.leftMargin: 16; anchors.rightMargin: 16
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                text: player.song
                color: Theme.highlightColor
            }
            Label {
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                //anchors.leftMargin: 32
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: player.album
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                visible: (text !== "")
            }
            Label {
                anchors.left: parent.left; anchors.right: parent.right // wrapping
                //anchors.leftMargin: 32
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: player.artist
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                visible: (text !== "")
            }
            Label {
                anchors.left: parent.left; anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                text: ((player.tracks > 1)?((player.cur_index + 1) + " / " + player.tracks):"")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
            }
            Slider {
                width: parent.width
                height: 280
                handleVisible: true
                minimumValue: 0
                maximumValue: 1
                valueText:  Math.floor((value * player.duration) / 60) + ":" + ("00" + Math.floor((value * player.duration) % 60)).slice(-2)
                label: "Time played"
                onDownChanged: if (!down) { player.slider_time(value * player.duration) }
                Binding on value {
                    when: !parent.down
                    value: ((player.duration > 0)?player.time / player.duration:0)
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                IconButton {
                    icon.source: "image://theme/icon-m-previous"
                    onClicked: player.button_jump_rew()
                }
                IconButton {
                    icon.source: "image://theme/icon-m-pause"
                    onClicked: player.button_pause()
                }
                IconButton {
                    icon.source: "image://theme/icon-m-play"
                    onClicked: player.button_play()
                }
                IconButton {
                    icon.source: "image://theme/icon-m-next"
                    onClicked: player.button_jump_fwd()
                }
            }
            Slider {
                width: parent.width
                height: 110
                handleVisible: true
                //value: player.volume;
                minimumValue: 0
                maximumValue: 120
                valueText: value.toFixed(0)  + " %"
                label: "Volume"
                onDownChanged: if (!down) { player.slider_volume(value) }
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
                    onClicked: player.button_repeat((player.repeat)?0:2)
                    checked: player.repeat
                }
            }
        }
    }
}

