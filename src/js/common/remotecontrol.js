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

var _myPlayerid = "";        //actual playerid
var _preferredPlayerid = ""; // preferred playerid at startup
var _request;                //  
var _server = "";            // server ip address
var _serverport = "";        // server jsonrpc port
var _menuModel;              // QML ListModel for menu
var cmdQueue = [];

// members exposed to qml. values is updated using handleSlimResponse slot
var song = "";
var name = ""
var song = ""
var artist = ""
var album = ""
var meta = ""
var cover = ""
var power = false
var time = 0
var volume = 0
var timeplayed = ""
var timeleft = ""
var duration = 0
var popup = ""
var shuffle = 0
var repeat = 0
var cur_index = 0
var tracks = 0


function setPreferredPlayerid(pid) {
    _preferredPlayerid = pid;
}

function setPlayerid(pid) {
    _myPlayerid = pid;
}

function setServerAddress(adr) {
    _server = adr;
}

function setServerPort(port) {
    _serverport = port;
}

function setMenuModel(model) {
    _menuModel = model;
}

// dispatch messages from qml
WorkerScript.onMessage = function(message) {
    if (message.type === "init") {
        setServerAddress(message.server);
        setPreferredPlayerid(message.playerid);
        setServerPort(message.serverport);
        setMenuModel(message.model);
    }
    else if (message.type === "buttonCommand") {
        addCommandToQueue(message.value);
    }
    else if (message.type === "menuCommand") {
        addCommandToQueue(message.value);
    }
    else if (message.type === "menuMedia") {
        media_go(message.value[0], message.value[1], message.value[2]);
    }
    else if (message.type === "menuModel") {
        setMenuModel(message.value);
    }
    else if (message.type === "httpResponse") {
        handleHttpResponse(message.value);
    }
    else if (message.type === "statusCommand") {
        dispatchCommand();
    }
}


var _lastCmd = 0;
// run this every 200ms to dispatch commands or read status
function dispatchCommand() {
    var now = new Date().getTime();

    if ((now - 1000) > _lastCmd) {
        sendAjax(_createStatusSlimRequest(), false);
        _lastCmd = now;
    }
    else if (_myPlayerid == "") {
        // dont do antything without a playerid
    }
    else if ((now - 100) > _lastCmd) {
        // run cmd queue
        if (cmdQueue.length > 0) {
            var cmd = cmdQueue.shift()
            sendAjax(cmd, true);
            _lastCmd = now;
        }
    }
}


function addCommandToQueue(cmd) {
    cmdQueue.push(cmd);
}

// selection by click.
function media_go(media, action, input) {
    //console.log(JSON.stringify(media, null, 4), action, input);
    if (action in media && media[action] !== "") {

        if (action === "add") {
            popup = "Adding " + media["name"];
        }

        var go = media[action];

        // if exists insert input string into media request
        if (media["input"] !== "") {
            for (var _i = 0; _i < go.length; _i++) {
                if (typeof go[_i] === 'string' && go[_i].indexOf(media["input"]) > 0) {

                    // input overwrites all, tagged input replaces only __TAGGEDINPUT__
                    if (media["input"] === "__INPUT__") {
                        go[_i] = input;
                    }
                    else {
                        go[_i] = go[_i].replace(media["input"], input);
                    }
                    break;
                }
            }
        }

        //console.log("          <-- send timestamp", new Date().toISOString());
        addCommandToQueue(go);
    }
    else if ("playerid" in media) {

        setPlayerid(media["playerid"]);
        sendNewPlayerid( media["playerid"]);
        popup = media["name"];
        menuModel_done(0); // update list
    }
    else if ("serveraddress" in media) {
        setServerAddress(media["serveraddress"]);
        sendNewServerAddress( media["serveraddress"]);
        popup = media["serveraddress"];
    }
}

function sendNewPlayerid(playerid) {
    WorkerScript.sendMessage({ "type": "newPlayerid", "value": playerid});
}

function sendNewServerAddress(serveraddress) {
    WorkerScript.sendMessage({ "type": "newServerAddress", "value": serveraddress});
}

function sendAjax(cmd) {
    var d = new Date();
    var id = d.getSeconds() * 100;
    id += d.getMilliseconds();

    var requestString = JSON.stringify(
                {
                    "id": id,
                    "method": "slim.request",
                    "params": [_myPlayerid, cmd]
                });

    sendHttpRequest(
                "http://" + _server + ":" + _serverport + "/jsonrpc.js",
                "application/json",
                requestString);
}

/* *
 * XMLHttpRequest is very unreliable for some reason. 
 * As a workaround I pass the request to c++ app via QML. 
 * The result from c++ is dispatched to handleHttpResponse via QML
 * */
function sendHttpRequest(urlStr, contentType, requestStr) {
    /*console.log("** ** sendHttpRequest ** **");
    console.log(JSON.stringify(requestStr, null, 4));*/
    WorkerScript.sendMessage({ "type": "sendHttpRequest", "value": [urlStr, contentType, requestStr]});
}

function handleHttpResponse(res) {
    var response = JSON.parse(res);
    /*console.log("** ** handleHttpResponse ** **");
    console.log(JSON.stringify(response, null, 4));*/
    handleSlimResponse(response);
}


function _createStatusSlimRequest() {

    // We need to connect to a player
    if (_myPlayerid === "") {
        return ["players", 0, 100];
    }
    else {
        return ["status", "-", 1, "menu:1"];
    }
}


// callback for the jsonrpc response. updates qml-player info
// using sendSongInfo-signal or update menu using menuModel.
function handleSlimResponse(req_res) {

    // _myPlayerid is missing. We need to connect to a player
    if (_myPlayerid === "") {
        if (req_res["params"][1][0] === "players") {
            for (var players_loop = 0; players_loop < req_res["result"]["count"]; players_loop++) {
                _myPlayerid = req_res["result"]["players_loop"][players_loop]["playerid"];
                if (_myPlayerid === _preferredPlayerid) {
                    break;
                }
            }
        }
    }
    else {
        var request_cmd = req_res["params"][1];

        // Handle status message
        if (request_cmd[0] === "status") {
            if (request_cmd[1] === "-") {

                var stat = req_res["result"];
                var playlist;

                if (("item_loop" in req_res["result"]) && (req_res["result"]["count"] > 0)) {
                    playlist = req_res["result"]["item_loop"][0];
                }
                else {
                    playlist = {};
                }

                name = stat["player_name"];
                song = playlist["track"] || "";
                artist = playlist["artist"] || "";
                album = playlist["album"] || "";
                meta = playlist["remote_title"] || "";
		
                if ("icon-id" in playlist) {
                    cover = _create_image_url(playlist["icon-id"]);
                }
                else if ("icon" in playlist) {
                    cover = _create_image_url(playlist["icon"]);
                }
                else {
                    cover = _create_image_url("");
                }

                power = Boolean(stat["power"] || 0);
                time = Number(stat["time"] || 0);
                volume = stat["mixer volume"] || 0;
                repeat = stat["playlist repeat"] || 0;
                shuffle = stat["playlist shuffle"] || 0;
                duration = Number(stat["duration"] || 1);
                cur_index = Number(stat["playlist_cur_index"] || 0);
                tracks = Number(stat["playlist_tracks"] || 0);

                timeplayed = _format_played_time(time);
                if (duration > time) {
                    timeleft = _format_played_time(duration - time);
                }
                else {
                    timeleft = "";
                }

                sendSongInfo();
            }
            // handle current playlist
            else {
                menuModel_done(_create_menu_model("", req_res["result"], "item_loop", "track", "playlist menu"));
            }

        }
        // handle empty result after a command
        else if (Object.keys(req_res["result"]).length <= 1) {
            menuModel_done(0); // update list
        }
        // handle player-menu
        else if (request_cmd[0] === "players") {
            menuModel_done(_create_menu_model("playerid", req_res["result"], "players_loop", "name", ""));
        }
        //handle main menu.
        else if (request_cmd[0] === "menu") {
            menuModel_done(_create_menu_model("", req_res["result"], "item_loop", "text", (request_cmd.length === 5)?request_cmd[4]:"home"));
        }
        //everything else.
        else {
            menuModel_done(_create_menu_model("", req_res["result"], "item_loop", "text", ""));
        }
    }
}


// return the correct slim-request for given action-type
function _find_menu_item_command(actiontype, menu, loop, item_loop) {
    var _go = "";
    var _nextWindow = "";
    for (var _at = 0; _at < actiontype.length; _at++) {

        var at = actiontype[_at];
        var menu_item = menu[loop][item_loop];

        if ("nextWindow" in menu_item) {
            _nextWindow = menu_item["nextWindow"];
        }
        else if ("radio" in menu_item) {
            // stay in window if menu has radiobuttons
            _nextWindow = "parent";
        }
        else if ("action" in menu_item) {
            if (menu_item["action"] === "none") {
                break; // item have no action. "Empty" item.
            }
        }


        if ("actions" in menu_item &&
                at in menu_item["actions"]) {

            var action = menu_item["actions"][at];

            if (typeof action !== 'string') {

                if ("nextWindow" in action) {
                    _nextWindow = action["nextWindow"];
                }

                if ("cmd" in action) {
                    _go = action["cmd"];
                    if (_go.length === 1) {
                        _go.push(0);
                        _go.push(10000);
                    }
                    else if ([
                                "items",
                                "radios"
                         ].indexOf(_go[_go.length -1]) >= 0) {
                            _go.push(0);
                            _go.push(10000);
                    }
                }
                if ("params" in action) {

                    _go.push.apply(_go, _param_dict_to_tag(action["params"]));
                }
                break; // found it. break for-loop
            }
        }
        else if ("base" in menu) {

            var base_action = menu["base"]["actions"];

            var go_action = "";
            if (at + "Action" in menu_item) {
                go_action = menu_item[at + "Action"];
            }
            else if (at in base_action) {
                go_action = at;
            }

            if (go_action !== "") {
                if ("nextWindow" in base_action[go_action]) {
                    _nextWindow = base_action[go_action]["nextWindow"];
                }

                _go = base_action[go_action]["cmd"].slice(0); // copy
                if (_go.length === 1) {
                    _go.push(0);
                    _go.push(10000);
                }
                else if ([
                         "items",
                         "radios"
                     ].indexOf(_go[_go.length -1]) >= 0) {
                        _go.push(0);
                        _go.push(10000);
                }

                _go.push.apply(_go, _param_dict_to_tag(
                                   base_action[go_action]["params"]
                                   ));

                _go.push.apply(_go, _param_dict_to_tag(
                                   menu_item[base_action[go_action]["itemsParams"]]
                                   ));

                break; // found it. break for-loop
            }
        }
        else {
            //
        }
    }
    return [_go, _nextWindow];
}

// Remove from menu. We cannot display choice menu yet.
var idFilterList =  [
            "randomchoosegenres",
            "opmlappgallery",
            "settingsAlarm",
            "settingsShuffle",
            "settingsRepeat",
            "playerpower"];

// clear and append items to menumodel and return number items added.
function _create_menu_model(cmd, menu, loop, name, nodefilter){
    //console.log(JSON.stringify(menu, null, 4));
    //console.log("--> recv timestamp", new Date().toISOString());

    var _items_counter = 0;

    if (!(loop in menu)) {
        return 0;
    }

    for (var item_loop = 0; item_loop < menu[loop].length; item_loop++) {

        var menu_item = menu[loop][item_loop];

        if (nodefilter !=="") {

            if (("node" in menu_item) && (nodefilter !== menu_item["node"])) {
                continue;
            }
            else if ("id" in menu_item && idFilterList.indexOf(menu_item["id"]) >= 0) {
                continue; // skip unsupported menus
            }
        }

        // used in the media dict.
        var _go = "";
        var _nextWindow = "";
        var _add = "";
        var _play = "";
        var _more = "";
        var _thumb = "";
        var _input = "";

        var _res = [];

        // Find the GO action.
        _res =_find_menu_item_command(["go", "do", "play"], menu, loop, item_loop);

        if (nodefilter === "playlist menu") {
            // We do our own thing in the playlist
            if ( ("params" in menu_item) && ("playlist_index" in menu_item["params"])) {
                _more = _res[0];
                _go = ["playlist", "jump", menu_item["params"]["playlist_index"]];
                _nextWindow = "noaction";
            }
            else {
                _go = _res[0];
            }
        }
        else {
            // Normal menu:

            _go = _res[0];
            _nextWindow = _res[1];

            // Find the ADD action.
            _add =_find_menu_item_command(["add"], menu, loop, item_loop)[0];

            // Find the PLAY action.
            _play =_find_menu_item_command(["play"], menu, loop, item_loop)[0];

            // MORE action
            _more =_find_menu_item_command(["more"], menu, loop, item_loop)[0];

            // If this is a node-header, find the filtered commando
            if (_go === "" && "isANode" in menu_item && menu_item["isANode"]) {
                _go = create_home_menu_request(menu_item["id"]);
            }
        }

        // Find the icon
        if ("window" in menu_item && "icon-id" in menu_item["window"]) {
            _thumb = _create_image_url(menu_item["window"]["icon-id"]);
        }
        else if ("icon-id" in menu_item) {
            _thumb = _create_image_url(menu_item["icon-id"]);
        }
        else if ("icon" in menu_item) {
            _thumb = _create_image_url(menu_item["icon"]);
        }
        else if ("artwork_url" in menu_item) {
            _thumb = _create_image_url(menu_item["artwork_url"]);
        }
        else {
            _thumb = _create_image_url("html/images/newmusic.png");
        }

        // check if input is required:
        if (_go !== "") {
            for (var _goi = 0; _goi < _go.length; _goi++) {

                if (typeof _go[_goi] === 'string' && _go[_goi].indexOf("INPUT__") > 0) {
                    if (_go[_goi].indexOf("__TAGGEDINPUT__") > 0) {
                        _input = "__TAGGEDINPUT__";
                    }
                    else {
                        _input = "__INPUT__";
                    }

                    break;
                }
            }
        }
        //console.log( menu_item[name], ":  GO:", _go, "   ADD:", _add, "   PLAY:", _play, "   MORE:", _more);

        // add menu if the name exists
        if (name in menu_item) {
            // create basic menu item
            var _menu_item = create_menu_item(
                        menu_item[name],
                        _go,
                        _play,
                        _add,
                        _more,
                        _thumb,
                        _nextWindow,
                        _input);

            // if exist add custom command
            if (cmd !== "") {

                _menu_item["media"][cmd] = menu_item[cmd];
                _menu_item["media"]["window"] = "nowPlaying"
            }

            // add item to menumodel
            if (_items_counter === 0) {
                menuModel_clear();
            }

            _items_counter += 1;
            menuModel_append(_items_counter, _menu_item);
        }

    }
    if (nodefilter === "home") {

        // add item to menumodel
        if (_items_counter > 1) {

            _items_counter += 1;
            menuModel_append(
                        _items_counter,
                        create_menu_item(
                                 "Extras",
                                 create_home_menu_request("extras"),
                                 "",
                                 "",
                                 "",
                                 _create_image_url("html/images/plugin.png"),
                                 "",
                                 ""));

            _items_counter += 1;
            menuModel_append(
                        _items_counter,
                        create_menu_item(
                                 "Settings",
                                 create_home_menu_request("settings"),
                                 "",
                                 "",
                                 "",
                                 _create_image_url("html/images/plugin.png"),
                                 "",
                                 ""));

        }
    }
    return _items_counter;
}


// return a menu-item for use in the qml-model
function create_menu_item(name, go, play, add, more, thumb, window, input) {
    return {
        "media": {
            "name": name,
            "go": go,
            "play": play,
            "add": add,
            "more": more,
            "thumb": thumb,
            "window": window,
            "input": input
        }};
}

function create_home_menu_request(filter) {
    if (filter === "") {
        return ['menu', 0, 10000, 'direct:1']
    }
    else {
        return ['menu', 0, 10000, 'direct:1', filter]
    }
}


// return the correct image-url
function _create_image_url(thumb) {
    if (thumb === "") {
        return "http://" + _server + ":" + _serverport + "/music/0/cover.jpg"
    }
    else if (thumb.indexOf("://", 0) > 0) {
        return thumb;
    }
    else if (thumb.indexOf("/", 0) === 0) {
        return "http://" + _server + ":" + _serverport + thumb;
    }
    else if (thumb.indexOf("/", 0) > 0) {
        return "http://" + _server + ":" + _serverport + "/" + thumb;
    }
    else {
        return "http://" + _server + ":" + _serverport + "/music/" + String(thumb || 0) + "/cover.jpg"
    }
}


// wrap dict into string for use in slimrequest
function _param_dict_to_tag(obj) {
  var str = [];
  for(var p in obj)
    if (obj.hasOwnProperty(p)) {
      str.push(p + ":" + obj[p]);
    }
  return str;
}

// format seconds to "%d:%02d"
function _format_played_time(t) {
    return Math.floor(t / 60) + ":" + ("00" + Math.floor(t % 60)).slice(-2)
}

function sendSongInfo() {
    WorkerScript.sendMessage(
                {
                    "type": "updateSongInfo",
                    "song": song,
                    "name": name,
                    "song" : song,
                    "artist": artist,
                    "album": album,
                    "meta": meta,
                    "cover": cover,
                    "power": power,
                    "time": time,
                    "volume": volume,
                    "timeplayed": timeplayed,
                    "timeleft": timeleft,
                    "duration": duration,
                    "popup": popup,
                    "shuffle": shuffle,
                    "repeat": repeat,
                    "cur_index": cur_index,
                    "tracks": tracks
                });
}


function menuModel_clear() {

    _menuModel.clear();
    menuModel_sync();
}

function menuModel_append(itemlength, item) {

    _menuModel.append(item);
    //console.log(itemlength, JSON.stringify(item, null, 4));

    // smooooooth update of the menuModel.
    if (itemlength % 100 === 0) {
        menuModel_sync();
    }

    if (itemlength === 200) {
        // early start for the listview
        sendMenuReady();
    }
}


function menuModel_done(itemlength) {

    if (itemlength > 0) {
        menuModel_sync();
    }
    sendMenuDone();
}

// override to prevent sync when not running as WorkerScript
function menuModel_sync() {
    _menuModel.sync();
}

function sendMenuReady() {
    WorkerScript.sendMessage({"type": "updateMenuReady"});
};

function sendMenuDone() {
    WorkerScript.sendMessage({"type": "updateMenuDone"});
}
