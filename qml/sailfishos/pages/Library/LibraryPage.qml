

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
    property var selectedMedia
    property string selectedAction: "go"
    property string selectedInputText: ""

    property int higlightLine: -1
    property bool jumpToHiglightLine: false
    property bool isPlaylist: false
    property bool isSelectPlayer: false

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
        }
        else if (windowtype === "refresh") {
            pageStack.replace(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
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
        }

        spacing: Theme.paddingMedium
        visible: ((parent.status === PageStatus.Active) && menuModel.menuReady)

        LibraryPushDownMenu {
            hideLibrary: !isPlaylist && !isSelectPlayer
            hidePlaylist: isPlaylist
            hideSelectPlayer: isSelectPlayer
        }

        header: PageHeader {
            title: selectedMedia && selectedMedia.name || ""
        }

        ViewPlaceholder {
            enabled: menuModel.menuReady && listView.count === 0
            text: qsTr("No items found")
        }

        delegate: LibraryItemDelegate {
            id: delegate
            menu: LibraryItemContextMenu {}
            thumbnail: model.media.thumb
            fullTitle: model.media.name || ""
            openMenuOnPressAndHold: false

            onPressAndHold: {
                delegate.openMenu({
                                      "newMedia": media
                                  });
            }

            onClicked: {
                if (model.media.window === "") {
                    if (model.media.input !== "") {
                        myDelegate.showMenu({
                                                "newMedia": media
                                            });
                    }
                    else {
                        pageStack.push(Qt.resolvedUrl("../../pages/Library/LibraryPage.qml"), {
                                           "selectedMedia": player.media_go(model.media, "go", "")
                                       });
                    }
                }
                else {
                    player.media_go(model.media, "go", "");
                    goToWindow(model.media.window);
                }
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
                listView.currentIndex = listView.currentIndex + 100;
                listView.positionViewAtIndex(listView.currentIndex, ListView.Beginning);
            }
        }
        IconButton {
            visible: ((listView.currentIndex - 100) > 0)
            icon.source: "image://theme/icon-m-up"
            onClicked: {
                listView.currentIndex = listView.currentIndex - 100;
                listView.positionViewAtIndex(listView.currentIndex, ListView.Beginning);
            }
        }
    }
}
