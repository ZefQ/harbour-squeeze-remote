

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
import "../component"

Page {
    id: page
    property var selectedMedia
    property string selectedAction: "go"
    property string selectedInputText: ""

    property int higlightLine: -1
    property bool jumpToHiglightLine: false
    property bool isPlaylist: false


    /*RemorsePopup { id: remorse }
    Connections {
        target: player
        onPopupChanged: {
            remorse.execute(player.popup);
        }
    }*/
    ListModel {
        id: menuModel
        property bool menuReady: player.menuReady
        property bool menuDone: player.menuDone
        Component.onCompleted: {
            player.setMenuModel(menuModel);
        }
        onMenuDoneChanged: {
            if (menuDone) {
                menuDone = true; //disconnect binding to player
                menuReady = true; //disconnect binding to player

                if (jumpToHiglightLine) {
                    jumpToHiglightLine = false;
                    listView.currentIndex = higlightLine;
                    listView.positionViewAtIndex(listView.currentIndex, ListView.Contain);
                }
            }
        }
    }

    function goToWindow(windowtype) {
        if (windowtype === "parent" || windowtype === "grandparent") {
            pageStack.pop();
            if (windowtype === "grandparent") {
                pageStack.pop();
            }
        } else if (windowtype === "nowPlaying") {
            if (pageStack.depth === 2) {
                pageStack.pop();
            } else {
                pageStack.push(Qt.resolvedUrl("PlayerPage.qml"));
            }
        } else if (windowtype === "refresh") {
            pageStack.replace(Qt.resolvedUrl("LibraryPage.qml"), {
                                  "selectedMedia": player.media_go(selectedMedia, "go", "")
                              });
        }
    }

    SilicaListView {
        id: listView
        clip: true
        model: menuModel
        anchors {
            fill: parent
            bottomMargin: playerName.height
        }

        spacing: Theme.paddingMedium
        visible: ((parent.status === PageStatus.Active) && menuModel.menuReady)

        header: PageHeader {
            title: selectedMedia.name
        }

        ViewPlaceholder {
            enabled: menuModel.menuReady && listView.count === 0
            text: qsTr("No items found")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Go back home")
                //visible: (!isPlaylist)
                onClicked: {
                    pageStack.replaceAbove(null, Qt.resolvedUrl("PlayerPage.qml"));
                }
            }

            MenuItem {
                text: qsTr("Select another player")
                //visible: (!isPlaylist)
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LibraryPage.qml"), {
                                       "selectedMedia": player.get_media_menu_settings()
                                   });
                }
            }

            MenuItem {
                text: qsTr("Now playing")
                //visible: (!isPlaylist)
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PlayerPage.qml"));
                }
            }

            MenuItem {
                text: qsTr("Playlist")
                visible: (!isPlaylist)
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("PlaylistPage.qml"), {
                                       "selectedMedia": player.get_media_menu_playlist()
                                   });
                }
            }
        }

        delegate: SqueezeItemDelegate {
            id: myDelegate
            menu: contextMenu
            thumbnail: model.media.thumb
            fullTitle: model.media.name

            onPressAndHold: {
                myDelegate.openMenu({"newMedia": media});
            }

            onClicked: {
                if (model.media.window === "") {
                    if (model.media.input !== "") {
                        myDelegate.showMenu({"newMedia": media});
                    } else {
                        pageStack.push(Qt.resolvedUrl("LibraryPage.qml"), {
                                           "selectedMedia": player.media_go(model.media, "go", "")
                                       });
                    }
                } else {
                    player.media_go(model.media, "go", "");
                    goToWindow(model.media.window);
                }
            }
        }

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
                    Keys.onReturnPressed: pageStack.push(
                                              Qt.resolvedUrl("LibraryPage.qml"), {
                                                  "selectedMedia": player.media_go(newMedia, "go", text),
                                                  "selectedInputText": text
                                              });
                }
                MenuItem {
                    visible: newMedia.input !== ""
                    text: qsTr("OK")
                    onClicked: pageStack.push(Qt.resolvedUrl("LibraryPage.qml"), {
                                                  "selectedMedia": player.media_go(newMedia, "go", inputtext.text),
                                                  "selectedInputText": inputtext.text
                                              });
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
                    onClicked: pageStack.push(Qt.resolvedUrl(
                                                  "LibraryPage.qml"), {
                                                  "selectedMedia": player.media_go(newMedia, "more", "")
                                              });
                }
                Component.onCompleted: inputtext.forceActiveFocus()
            }
        }

        VerticalScrollDecorator {
            flickable: listView
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: ((parent.status === PageStatus.Active) && !listView.visible)
    }

    Separator {
        height: 5
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
    Row {
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        IconButton {
            visible: ((listView.currentIndex + 100) < listView.count)
            icon.source: "image://theme/icon-m-down"
            onClicked: {
                listView.currentIndex = listView.currentIndex + 100
                listView.positionViewAtIndex(listView.currentIndex, ListView.Beginning)
            }
        }
        IconButton {
            visible: ((listView.currentIndex - 100) > 0)
            icon.source: "image://theme/icon-m-up"
            onClicked: {
                listView.currentIndex = listView.currentIndex - 100
                listView.positionViewAtIndex(listView.currentIndex, ListView.Beginning)
            }
        }
    }

    PageHeader {
        id: playerName
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        title: player.name
    }
}
