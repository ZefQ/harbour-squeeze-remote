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

/*
    This (PlayerRemoteWorkerscript.qml) loads javascript into a background thread.
    If this do not work (broken in qt5.2) consider using PlayerRemoteJavascript.qml instead.
  */

import QtQuick 2.0
import "base" as Base

Base.PlayerRemoteBase {
    id: player

    // redirect answer from backend to frontend
    Connections {
        target: shared
        onHttpResponseChanged: frontend.handleHttpResponse(shared.httpResponse)
    }

    Timer {
        id: ajax
        interval: 100; running: false; repeat: true
        onTriggered: frontend.statusCommand();

        function init() {
            if (player.backendready) {
                frontend.init();
                frontend.statusCommand();
                ajax.start()
            }
        }
    }

    onBackendreadyChanged: ajax.init()

    // WorkerScript for the javascript frontend
    frontend: WorkerScript {
        id: frontend
        source: "../../js/common/remotecontrol.js"

        function cmdAjax(cmd) {
            sendMessage({"type": "buttonCommand", "value": cmd});
        }
        function menuAjax(cmd) {
            menuReady = false;
            menuDone = false;
            sendMessage({"type": "menuCommand", "value": cmd});
        }
        function media_go(mediaobj, actionstr, inputstr) {
            menuReady = false;
            menuDone = false;
            sendMessage({"type": "menuMedia", "value": [mediaobj, actionstr, inputstr]});
        }
        function setMenuModel(mm) {
            sendMessage({"type": "menuModel", "value": mm});
        }
        function handleHttpResponse(httpResponse) {
            sendMessage({"type": "httpResponse", "value": httpResponse});
        }
        function statusCommand() {
            sendMessage({"type": "statusCommand"});
        }
        function init() {
            sendMessage({
                            "type": "init",
                            "server": backendServerAddress,
                            "playerid": backendPlayerid,
                            "serverport" : backendServerPort,
                            "model": menuModel});
        }

        onMessage: {
            var _settings;

            if (messageObject.type === "updateSongInfo") {

                name = messageObject.name;
                song = messageObject.song;
                artist = messageObject.artist;
                album = messageObject.album;
                meta = messageObject.meta;
                cover = messageObject.cover;
                power = messageObject.power;
                time = messageObject.time;
                volume = messageObject.volume;
                timeplayed = messageObject.timeplayed;
                timeleft = messageObject.timeleft;
                duration = messageObject.duration;
                popup = messageObject.popup;
                player.repeat = messageObject.repeat;
                shuffle = messageObject.shuffle;
                cur_index = messageObject.cur_index;
                tracks = messageObject.tracks
                frontendready = true;
            }
            else if (messageObject.type === "updateMenuReady") {
                menuReady = true;
            }
            else if (messageObject.type === "updateMenuDone") {
                menuReady = true;
                menuDone = true;
            }
            else if (messageObject.type === "sendHttpRequest") {

                shared.sendHttpRequest(messageObject.value[0], messageObject.value[1], messageObject.value[2]);
            }
            else if (messageObject.type === "newPlayerid") {

                _settings = getSettings();
                _settings["playerid"] = messageObject.value;
                setSettings(_settings);
            }
            else if (messageObject.type === "newServerAddress") {

                for (var i = 0; i < shared.serverAddressList.length; i++) {

                    if (messageObject.value === shared.serverAddressList[i]) {
                        _settings = getSettings();
                        _settings["server_address"] = shared.serverAddressList[i];
                        _settings["server_tcp_port"] = shared.serverTcpPortList[i];
                        setSettings(_settings);
                        break;
                    }
                }

            }
        }
    }
}
