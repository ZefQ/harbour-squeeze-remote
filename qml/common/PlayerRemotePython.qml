

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
import io.thp.pyotherside 1.3

import "base"


/*
    Not implemented yet

*/
PlayerRemoteBase {
    id: player

    //onBackendreadyChanged: ajax.init()

    // WorkerScript for the javascript frontend
    frontend: Python {

        function media_go(o) {
            call('playerotherside.player.media_go', [o]);
        }

        function cmdAjax(cmd) {
            call('playerotherside.player.buttonCommand', [cmd]);
        }
        function menuAjax(cmd) {
            menuReady = false;
            menuDone = false;
            call('playerotherside.player.menuCommand', [cmd]);
        }
        function media_go(mediaobj, actionstr, inputstr) {
            menuReady = false;
            menuDone = false;
            call('playerotherside.player.menuMedia', [mediaobj, actionstr, inputstr]);
        }
        function setMenuModel(mm) {
            call('playerotherside.player.menuModel', [mm]);
        }
        function statusCommand() {
            call('playerotherside.player.statusCommand', []);
        }
        function init() {
            call('playerotherside.player.menuMedia', [backendServerAddress, backendPlayerid, backendServerPort, menuModel]);
        }

        Component.onCompleted: {
            player.song = Controller.test();
            console.log(Qt.resolvedUrl('../../common'));
            addImportPath(Qt.resolvedUrl('../../common').substr('file://'.length));
            addImportPath(Qt.resolvedUrl('../../..').substr('file://'.length));
            importModule('playerotherside', function () {});
        }
        onReceived: {
            var command = data[0], args = data.splice(1);

            if (command === 'notify') {
                if (args[0] === 'newdata') {
                    call('playerotherside.player.get_new_data', [], function (messageObject) {
                        time = messageObject.time;
                        timeplayed = messageObject.timeplayed;
                        timeleft = messageObject.timeleft;
                        duration = messageObject.duration;
                    });
                }
                else if (args[0] === 'new_song_info') {
                    call('playerotherside.player.get_new_song_info', [], function (messageObject) {
                        name = messageObject.name;
                        song = messageObject.song;
                        artist = messageObject.artist;
                        album = messageObject.album;
                        meta = messageObject.meta;
                        cover = messageObject.cover;
                        power = messageObject.power;
                        volume = messageObject.volume;
                        popup = messageObject.popup;
                        player.repeat = messageObject.repeat;
                        shuffle = messageObject.shuffle;
                        cur_index = messageObject.cur_index;
                        tracks = messageObject.tracks;
                        frontendready = true;
                    });
                }
                else if (args[0] === 'menu') {
                    call('playerotherside.player._get_menu', [], function (res) {
                        player.menuModel.clear();
                        for (var i = 0; i < res.length; i++) {
                            player.menuModel.append(res[i]);
                        }
                    });
                }
                else if (args[0] === 'popup') {
                    call('playerotherside.player._get_popup', [], function (res) {
                        popup = res;
                    });
                }
            }
            else {
                song = args;
            }
        }
        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
