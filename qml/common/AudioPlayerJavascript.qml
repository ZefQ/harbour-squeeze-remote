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
  Local audioplayer using QtMultimedia.
  This is a temporary solution. Known issues:
    - No access to audiobuffers. Cannot skip-ahed when syncing with other players.
    - No access to audiobuffer size. We have to fake the audiobuffer.
    - We have to pass a URL to the audioplayer. This is a problem
      when trying to stream from Spotify etc.
    - bufferProgress do not work on Windows?
  */

import QtQuick 2.0
import QtMultimedia 5.0
import "../../js/common/slimproto.js" as Slimproto

Rectangle {
    property bool started: false

    Connections {
        target: shared
        onTcpResponseChanged: Slimproto.handleTcpResponse(shared.tcpResponse)
    }

    Timer {
        id: delayed
        interval: 0; running: false; repeat: false
        property var callbackfunc: function () {}

        function exec(delay, callback) {
            if (!running) {
                delayed.interval = delay;
                delayed.callbackfunc = callback;
                delayed.start();
            }
            else {
                //console.log("Delayed timer already running");
            }
        }

        onTriggered: {
            callbackfunc();
        }
    }

    function send_stat(eventcode, replayGain) {

        shared.sendTcpRequest(Slimproto.send_stat(eventcode, replayGain, audio.position, audio.bufferProgress));
    }

    function start() {

        if (started) {
            return;
        }

        started = true;

        Slimproto.on_send_stat = function (msg, rg) {
            send_stat(msg, rg);
        }

        Slimproto.on_playback_resume = function (delay) {
            if (delay !== 0) {
                //console.log("DELAYED RESUME", delay);
                delayed.exec(delay, function () {audio.play();});
            }
            else {
                audio.play();

            }
            send_stat("STMr", 0);
        }

        Slimproto.on_playback_stop = function () {
            audio.isPaused = false;
            audio.stop();
            send_stat("STMf", 0);
        }

        Slimproto.on_playback_pause = function (interval) {
            audio.isPaused = true;
            audio.pause();

            if (interval !==0) {
                //console.log("DELAYED PAUSE/RESUME", interval);
                delayed.exec(interval, function () {audio.play();});
            }
            else {
                send_stat("STMp", 0);
            }
        }

        Slimproto.on_playback_skip_ms = function (skip_ms) {
            if (audio.seekable) {
                audio.seek(skip_ms);
                //console.log("player skip (by seek):", skip_ms);
            }
            else {
                console.log("player cannot skip (by seek):", skip_ms);
                if (skip_ms > 3000) {
                    audio.stop();
                    send_stat("STMf", 0);
                    audio.play();
                    send_stat("STMs", 0);
                    console.log("attempt to reconnect");
                }
            }
        }

        Slimproto.on_playback_start = function (server_ip, server_port, http_header, startAsPaused, threshold) {

            var src = "http://";
            var url = http_header.split(" ")[1];

            if (server_ip[0] === 0) {
                src += player.backendServerAddress;
            }
            else {
                src += server_ip.join(".");
            }
            src += (":" + server_port);

            if (url[0] === "/") {
                src += url;
            }
            else {
                src += ("/" + url);
            }

            //console.log(src);

            audio.stop();
            send_stat("STMf", 0);

            //console.log("on_playback_start startAsPaused", startAsPaused);


            if (startAsPaused) {
                audio.isPaused = true;
                audio.isBufferReady = false;
            }

            audio.source = "";
            audio.source = src;

            send_stat("STMc", 0);

            if (!startAsPaused) {
                audio.play();
            }
        }

        Slimproto.on_audg = function (dvc, preamp, new_left, new_right) {
            var volm = Math.min(new_left, new_right) / 0x10000;
            audio.volume = volm;
        }

        //console.log(player.backendServerAddress, player.serverTcpPort);
        shared.connectTcp(player.backendServerAddress, player.serverTcpPort);
        shared.sendTcpRequest(Slimproto.send_helo(shared.macAddress));
    }

    function close() {
        if (started) {
            shared.disconnectTcp();
            started = false;
        }
    }


    MediaPlayer {
        id: audio
        property bool isPaused: false
        property bool isReadyForNext: false
        property bool isBufferReady: true

        autoLoad : true


        onPlaying: {
            isReadyForNext = false;
            if (isPaused) {
                isPaused = false;
            }
            else {
                send_stat("STMs", 0);
            }
        }

        onStopped: {
            //send_stat("STMf", 0);
            send_stat("STMd", 0); //TODO FIX THIS.
        }

        onPositionChanged: {
            if ( (playbackState === Audio.PlayingState) && ((duration - position) <= 10) && !isReadyForNext) {
                isReadyForNext = true;
                //send_stat("STMd", 0); //TODO FIX THIS.
            }
            else {
                send_stat("STMt", 0);
            }

        }

        /*onPlaybackStateChanged: {
            console.log("playbackState", playbackState);
            if (playbackState === Audio.Buffered) {
                if (!isBufferReady) {
                    isBufferReady = true;
                    send_stat("STMl", 0);
                }
            }
        }*/

        onBufferProgressChanged: {

            if (!isBufferReady) {
                if (bufferProgress === 1) {
                    isBufferReady = true;
                    send_stat("STMl", 0);
                }
            }
        }
    }
}
