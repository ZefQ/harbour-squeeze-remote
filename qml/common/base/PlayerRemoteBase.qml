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

Rectangle {
    id: player

    //TODO: rename to remote

    // internal
    property bool frontendready: false          // TODO: rename to remoteReady
    property bool backendready: false

    property string backendPlayerid: ""         // TODO: rename to audioPlayerid
    property string backendServerAddress: ""    // TODO: rename to serverAddress. For remote and audioPlayer
    property string backendServerPort: "9000"   // TODO: rename to serverHttpPort. For remote
    property int serverTcpPort: 3483

    property bool enableAudioPlayer: false

    // player:
    property string name: ""
    property string song: ""
    property string artist: ""
    property string album: ""
    property string meta: ""
    property string cover: ""
    property bool power: false
    property double time: 0
    property double volume: 0
    property string timeplayed: ""
    property string timeleft: ""
    property double duration: 1


    // playlist:
    property int shuffle: 0
    property int repeat: 0
    property int cur_index: 0 // place in the playlist
    property int tracks: 0 // number of tracks in playlist

    property string popup: ""

    property ListModel menuModel: ListModel {} // Qt.createQmlObject("import QtQuick 2.0; ListModel { }", player, "list1")
    property bool menuReady: false
    property bool menuDone: false

    property var frontend; // this is the javascript or python frontend

    function initFrontend() {
        frontend.init();
    }

    //TODO: maybe change to QSettings?
    // function to load / save settings as string in backend.
    // using json.
    function getSettings() {
        var _settings = {};
        try { _settings = JSON.parse(shared.settings); } catch(err) {}
        if (Array.isArray(_settings)) { _settings = {}; }
        return _settings;
    }

    function setSettings(newSettings) {
        shared.settings = JSON.stringify(newSettings);
    }

    function saveSettings() {
        shared.settingsWriteToFile();
    }

    // button functions
    //TODO: move slimrequest to remote script.
    function button_power(toggle) { frontend.cmdAjax(['power', toggle]) }
    function button_shuffle(toggle) { frontend.cmdAjax(['playlist','shuffle', toggle]) }
    function button_repeat(toggle) { frontend.cmdAjax(['playlist','repeat', toggle]) }
    function button_jump_rew() { frontend.cmdAjax(['button', 'jump_rew']) }
    function button_jump_fwd() { frontend.cmdAjax(['button', 'jump_fwd']) }
    function button_pause() { frontend.cmdAjax(["pause"]) }
    function button_play() { frontend.cmdAjax(["play"]) }
    function slider_time(t) { frontend.cmdAjax(['time', t]) }
    function slider_volume(v) { frontend.cmdAjax(['mixer', 'volume', v]) }

    function media_servers() {

        player.menuModel.clear();
        for (var i = 0; i < shared.serverAddressList.length; i++) {
            player.menuModel.append({
                                        "media": {
                                            "name": shared.serverAddressList[i],
                                            "serveraddress": shared.serverAddressList[i],
                                            "thumb": "",
                                            "input": "",
                                            "window": "parent"
                                        }});
        }
    }

    // listview functions
    function media_go(o, action, input) { frontend.media_go(o, action || "go", input); return o; }

    function setMenuModel(mm) { frontend.setMenuModel(mm); }

    //TODO: move slimrequest to frontend
    function get_media_menu_home() {
        var o = {"name": "Home", "go": ['menu', 0, 10000, 'direct:1'], "window": "", "input":"" };
        return media_go(o, "go", "");
    }
    function get_media_menu_settings() {
        var o = {"name": "Select player", "go": ['players', 0, 10000], "window": "", "input":"" };
        return media_go(o, "go", "");
    }
    function get_media_menu_playlist() {
        var o = {"name": "Current playlist", "go": ["status", 0, 10000, "menu:1"], "window": "", "input":"" };
        return media_go(o, "go", "");
    }

    Component.onCompleted: {

        // parse configfile:
        var _settings = getSettings();

        if ("enable_audio_player" in _settings) {
            enableAudioPlayer = _settings["enable_audio_player"];
        }

        if ("playerid" in _settings) {
            backendPlayerid = _settings["playerid"];
        }
        else {
            backendPlayerid = Qt.binding(function() { return shared.macAddress });
        }

        if ("server_address" in _settings) {
            backendServerAddress = _settings["server_address"];
        }
        else {
            backendServerAddress = Qt.binding(function() { return (shared.serverAddressList[0] || ""); });
        }

        if ("server_http_port" in _settings) {
            backendServerPort = _settings["server_http_port"];
        }

        if ("server_tcp_port" in _settings) {
            serverTcpPort = parseInt(_settings["server_tcp_port"]);
        }
        else {
            var defaultServerTcpPortValue = serverTcpPort;
            serverTcpPort = Qt.binding(function() { return (shared.serverTcpPortList[0] || defaultServerTcpPortValue); });
        }

        // connect or wait for autodiscover?
        if ((backendServerPort != "") && (backendServerAddress != "")) {
            backendready = true;
        }
        else {
            backendready = Qt.binding(function() { return shared.ready; });
        }
    }
}
