

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
                pageStack.pushAttached(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
                                           "selectedMedia": player.get_media_menu_home()
                                       });
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: flex.height + main.height

        PlayerPushUpMenu {
            id: pushUpMenu
        }

        Column {
            id: flex
            height: page.height - main.height - Theme.paddingLarge
            width: parent.width
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }

            PageHeader {
                id: header
                title: qsTr("Now Playing")
            }
        }

        Column {
            id: main
            width: parent.width
            spacing: Theme.paddingMedium
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                top: flex.bottom
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: player.cover
                smooth: true
                fillMode: Image.PreserveAspectFit
                cache: true
                width: parent.width
                height: parent.width
            }

            Column {
                height: 150 * Theme.pixelRatio
                width: parent.width
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                text: player.song
                color: Theme.highlightColor
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: (player.tracks > 1) ? ((player.cur_index + 1) + " / " + player.tracks) : "" + "  " + player.album
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeTiny
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: player.artist
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                visible: (text !== "")
            }

            Slider {
                property double duration

                width: parent.width
                height: 120 * Theme.pixelRatio
                minimumValue: 0
                maximumValue: 1
                valueText: Math.floor((duration * player.duration) / 60) + ":" + ("00" + Math.floor((duration * player.duration) % 60)).slice(-2)
                handleVisible: player.isSeekable
                enabled: player.isSeekable
                onDownChanged: if (!down) {
                                   player.slider_time(duration * player.duration)
                               }
                Binding on value {
                    when: !parent.down
                    value: (player.isSeekable && player.duration > 0) ? player.time / player.duration : 0.5
                }

                Binding on duration {
                    when: !parent.down
                    value: (player.duration > 0) ? player.time / player.duration : 0
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

                IconButton {
                    icon.source: "image://theme/icon-m-previous"
                    enabled: (player.cur_index + 1) !== 1
                    onClicked: player.button_jump_rew();
                    anchors.verticalCenter: parent.verticalCenter
                }

                IconButton {
                    icon.source: player.isPlaying ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
                    onClicked: player.isPlaying ? player.button_pause() : player.button_play();
                    anchors.verticalCenter: parent.verticalCenter
                }

                IconButton {
                    icon.source: "image://theme/icon-m-next"
                    enabled: (player.cur_index + 1) !== player.tracks
                    onClicked: player.button_jump_fwd();
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
