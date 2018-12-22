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

// global tcp buffer
var tcp_buffer = []


// SEND HELO
function send_helo(macaddr) {

    var request = _create_helo(macaddr);
    return request;
}

// SEND STAT
function send_stat(eventcode, replayGain, played_ms, buffer_fullness_prc) {

    var request = _create_stat(eventcode, replayGain, played_ms, buffer_fullness_prc);
    return request;
}

function on_send_stat(msg, replayGain) {
    // override in qml
    console.log("               ---> msg, replayGain", msg, replayGaine)
}
function on_aude(spdif_enable, dac_enable) {
    // override in qml
    console.log("               ---> spdif_enable, dac_enable", spdif_enable, dac_enable);
}
function  on_audg(dvc, preamp, new_left, new_right) {
    // override in qml
    console.log("               ---> dvc, preamp, new_left, new_right", dvc, preamp, new_left, new_right);
}
function on_playback_start(server_ip, server_port, http_header, startAsPaused, threshold) {
    // override in qml
    console.log("               ---> server_ip, server_port, http_header", server_ip, server_port, http_header);
}
function on_playback_pause(interval) {
    // override in qml
}
function on_playback_resume(delay) {
    // override in qml
}
function on_playback_stop() {
    // override in qml
}

function on_playback_skip_ms(skip_ms) {
    // override in qml
}

// creation of helo request
function _create_helo(macadr) {

    var deviceid = 12;
    var revision = 0;
    var uuid = "0000000000000000";
    var wLanChannelList = 0;
    var bytesReceived = 0;
    var language = 0;

    var buffer = [];
    buffer.push(deviceid);
    buffer.push(revision);  // REVISION
    buffer.push.apply(buffer, macadr.split(":").map(function(x) { return parseInt("0x" + x);}));
    buffer.push.apply(buffer, uuid.split("").map(function(x) { return parseInt("0x" + x); }));
    buffer.push.apply(buffer, _int_to_bytes(wLanChannelList, 2));
    buffer.push.apply(buffer, _int_to_bytes(bytesReceived, 8));
    buffer.push.apply(buffer, _int_to_bytes(language, 2));
    //buffer.push.apply(buffer, _chars_to_bytes("ogg,flc,aif,pcm,mp3,aac"));

    var header = []
    header.push.apply(header, _chars_to_bytes("HELO"));
    header.push.apply(header, _int_to_bytes(buffer.length, 4));

    //console.log("           <--- send HELO");
    return header.concat(buffer);
}

// creation of stat request
function _create_stat(eventcode, replayGain, played_ms, buffer_fullness_prc) {
    var u8_t_num_crlf = 0;          // number of consecutive cr|lf received while parsing headers
    var u8_t_mas_initialized = 0;   // 'm' or 'p'
    var u8_t_mas_mode = 0;          // serdes mode
    var u32_t_rptr = 0x200000;
    var u32_t_wptr = buffer_fullness_prc * u32_t_rptr; //TODO: fix fake buffers
    var u64_t_bytes_received = 0;
    var u16_t_signal_strength = 0xFFFF;
    var u32_t_jiffies = new Date().getTime() & 0xFFFF;
    var u32_t_output_buffer_size = 0x300000;
    var u32_t_output_buffer_fullness = buffer_fullness_prc * u32_t_output_buffer_size;  //TODO: fix fake buffers
    var u32_t_elapsed_seconds = ((played_ms > 0) ? Math.floor(played_ms / 1000):0);
    var u16_t_voltage = 0;
    var u32_t_elapsed_milliseconds = played_ms;
    var u32_t_server_timestamp = replayGain; // 0 exept STMt
    var u16_t_error_code = 0;

    if (eventcode !== "STMt") {
        //console.log("           <--- send stat : ",eventcode, "elapsed", u32_t_elapsed_seconds, "buffer", buffer_fullness_prc);
    }

    var buffer = [];
    buffer.push.apply(buffer, _chars_to_bytes(eventcode));
    buffer.push(u8_t_num_crlf);
    buffer.push(u8_t_mas_initialized);
    buffer.push(u8_t_mas_mode);
    buffer.push.apply(buffer, _int_to_bytes(u32_t_rptr, 4));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_wptr, 4));
    buffer.push.apply(buffer, _int_to_bytes(u64_t_bytes_received, 8));
    buffer.push.apply(buffer, _int_to_bytes(u16_t_signal_strength, 2));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_jiffies, 4));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_output_buffer_size, 4));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_output_buffer_fullness, 4));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_elapsed_seconds, 4));
    buffer.push.apply(buffer, _int_to_bytes(u16_t_voltage, 2));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_elapsed_milliseconds, 4));
    buffer.push.apply(buffer, _int_to_bytes(u32_t_server_timestamp, 4));
    buffer.push.apply(buffer, _int_to_bytes(u16_t_error_code, 2));

    var header = []
    header.push.apply(header, _chars_to_bytes("STAT"));
    header.push.apply(header, _int_to_bytes(buffer.length, 4));

    return header.concat(buffer);
}

function handleTcpResponse (rawtcp) {

    tcp_buffer.push.apply(tcp_buffer, rawtcp);
    var len = 2 + _bytes_to_uint(tcp_buffer.slice(0, 2));

    while ((tcp_buffer.length >= len) && (tcp_buffer.length > 2) && (len > 2)) {

        var response = tcp_buffer.slice(0,len).map(function(x) { return x & 0xFF });
        var head = _bytes_to_chars(response.slice(2,6));

        if (head === "strm") {
            handle_strm(response.slice(6, len));
        }
        else if (head === "aude") {
            handle_aude(response.slice(6, len));
        }
        else if (head === "audg") {
            handle_audg(response.slice(6, len));
        }
        else if (head === "i2cc") {
            handle_i2cc(response.slice(6, len));
        }
        else {
            //console.log("               ---> recv:", head, len, response.length, "WTF?");
        }

        tcp_buffer = tcp_buffer.slice(len);
        len = 2 + _bytes_to_int(tcp_buffer.slice(0, 2));
    }

    if (tcp_buffer.length > 1000) {
        tcp_buffer.length = 0;
    }
}

function handle_strm(resp) {

    //my $frame = pack 'aaaaaaaCCCaCCCNnN', (
    var command = _bytes_to_chars(resp.slice(0,1));
    var autostart = _bytes_to_chars(resp.slice(1,2));
    var formatbyte = resp[2];
    var pcmsamplesize = resp[3];
    var pcmsamplerate = resp[4];
    var pcmchannels = resp[5];
    var pcmendian = resp[6];
    var bufferThreshold = resp[7];
    var s_pdif_auto = resp[8];
    var transitionDuration = resp[9];
    var transitionType = resp[10];
    var flags = resp[11];
    var outputThreshold = resp[12];
    var slaveStreams = resp[13];
    var replayGain = _bytes_to_int(resp.slice(14, 18));
    var server_port = _bytes_to_int(resp.slice(18, 20));
    var server_ip = resp.slice(20, 24);
    var http_header = _bytes_to_chars(resp.slice(24));

    if (command !== "t") {

        //console.log("           ---> recv strm:", command);
    }

    switch (command) {
    case "q":
        on_playback_stop(); //"STMf", 0
        break;

    case "t":
        on_send_stat("STMt", replayGain);
        break;

    case "a":
        on_playback_skip_ms(replayGain);
        break;

    case "p":
        on_playback_pause(replayGain); //"STMp", 0
        break;

    case "u":
        if (replayGain !== 0) {
            on_playback_resume(replayGain - (new Date().getTime() & 0xFFFF));
        }
        else {
            on_playback_resume(0);
        }

        break;

    case "s":
        on_playback_start(
                    server_ip,
                    server_port,
                    http_header,
                    (autostart === "0") || (autostart === "2"),
                    bufferThreshold);
        break;


    default:
        //console.log("               ---> recv strm:", command, "WTF?");
    }
}

function handle_aude(resp) {

    //my $frame = pack 'aaaaaaaCCCaCCCNnN', (
    var spdif_enable = resp[0];
    var dac_enable = resp[1];
    on_aude(spdif_enable, dac_enable);
}

function handle_audg(resp) {
    var old_left = _bytes_to_int(resp.slice(0,4)); // 4 bytes unsigned int
    var old_right = _bytes_to_int(resp.slice(4,8)); // 4 bytes unsigned int
    var dvc = resp[8]; // 1 byte  Digital volume control 0/1
    var preamp = resp[9]; // 1 byte  Preamp (byte 255-0)
    var new_left = _bytes_to_int(resp.slice(10,14)); // 4 bytes 16.16 fixed point
    var new_right=_bytes_to_int(resp.slice(14,18)); // 4 bytes 16.16 fixed point
    var sequence = _bytes_to_int(resp.slice(18,22)); // 4 bytes unsigned int, optional
    on_audg(dvc, preamp, new_left, new_right);
}

function handle_i2cc(resp) {
    //console.log("i2cc", resp);
    on_send_stat("i2cc", 0);
}

function _int_to_bytes(val, bytelen) {
    var arr = new Array(bytelen);
    for (var i = 0; i < bytelen; i++) {
        arr[bytelen - 1 - i] = (val & (0xFF << i * 8)) >> i * 8;
    }
    return arr;
}

function _bytes_to_int(bytes) {
    var newval = 0;
    for(var i = 0; i < bytes.length; i++) {
        newval += parseInt(bytes[i]) << (bytes.length - 1 - i) * 8;
    }
    return newval;
}

function _bytes_to_uint(bytes) {
    return _bytes_to_int(bytes.map(function(x) { return x & 0xFF }));
}

function _chars_to_bytes(bytestr) {
    var chars = [];
    for(var i = 0; i < bytestr.length; i++) {
        chars.push(bytestr.charCodeAt(i));
    }
    return chars;
}

function _bytes_to_chars (bytes) {
    return String.fromCharCode.apply(null, bytes);
}
