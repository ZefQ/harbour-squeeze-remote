

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
import "base" as Base
import "qrc:/js/common/remotecontrol.js" as Remote

Base.PlayerRemoteBase {
    id: player

    // redirect answer from backend to frontend
    Connections {
        target: shared
        onHttpResponseChanged: frontend.handleHttpResponse(shared.httpResponse)
    }

    Timer {
        id: ajax
        interval: 100
        running: false
        repeat: true
        onTriggered: frontend.statusCommand()

        function init() {
            if (player.backendready) {
                frontend.init();

                frontend.statusCommand();
                ajax.start();
            }
        }
    }

    onBackendreadyChanged: ajax.init()

    // WorkerScript for the javascript frontend
    frontend: Item {
        id: frontend

        function cmdAjax(cmd) {
            Remote.addCommandToQueue(cmd);
        }
        function menuAjax(cmd) {
            menuReady = false;
            menuDone = false;
            Remote.addCommandToQueue(cmd);
        }
        function media_go(mediaobj, actionstr, inputstr) {
            menuReady = false;
            menuDone = false;
            Remote.media_go(mediaobj, actionstr, inputstr);
        }
        function setMenuModel(mm) {
            Remote.setMenuModel(mm);
        }
        function handleHttpResponse(httpResponse) {
            Remote.handleHttpResponse(httpResponse);
        }
        function statusCommand() {
            Remote.dispatchCommand();
        }
        function init() {
            Remote.setServerAddress(backendServerAddress);
            Remote.setPreferredPlayerid(backendPlayerid);
            Remote.setServerPort(backendServerPort);
            Remote.setMenuModel(menuModel);
        }

        Component.onCompleted: {

            Remote.sendSongInfo = function () {
                name = Remote.name;
                song = Remote.song;
                artist = Remote.artist;
                album = Remote.album;
                meta = Remote.meta;
                cover = Remote.cover;
                power = Remote.power;
                time = Remote.time;
                volume = Remote.volume;
                timeplayed = Remote.timeplayed;
                timeleft = Remote.timeleft;
                duration = Remote.duration;
                popup = Remote.popup;
                player.repeat = Remote.repeat;
                shuffle = Remote.shuffle;
                cur_index = Remote.cur_index;
                tracks = Remote.tracks;
                frontendready = true;
            }

            Remote.sendHttpRequest = function (urlStr, contentType, requestStr) {
                shared.sendHttpRequest(urlStr, contentType, requestStr);
            }

            Remote.menuModel_sync = function () {// override to prevent sync when not running as WorkerScript
            }

            Remote.sendMenuReady = function () {
                menuReady = true;
            }

            Remote.sendMenuDone = function () {
                menuReady = true;
                menuDone = true;
            }

            Remote.sendNewPlayerid = function (playerid) {
                var _settings;
                _settings = getSettings();
                _settings["playerid"] = playerid;
                setSettings(_settings);
            }

            Remote.sendNewServerAddress = function (server_address) {
                var _settings;
                for (var i = 0; i < shared.serverAddressList.length; i++) {

                    if (server_address === shared.serverAddressList[i]) {
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
