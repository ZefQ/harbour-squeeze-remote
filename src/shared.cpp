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

#include "shared.h"
#include <QStandardPaths>
#include <QFile>
#include <QDir>

Shared::Shared() {
    _mac = "";
    _server = "";
    _tcp_port_list.clear();
    _servers_list.clear();
    _ready = false;
    _settings = "";

    //sync fetching data
    setMacAddress(getMacAddress());

    settingsReadFromFile();

    // async fetching data
    getServerAddress();

    // init http client
    setupHttpClient();

    // init tcp client
    setupTcpClient();
}

Shared::~Shared() {
    disconnectTcp();
}

// Property: ready

void Shared::setReady(bool ready) {
    if (ready != _ready) {
        _ready = ready;

        emit readyChanged(ready);
    }
}

bool Shared::ready() {
    return _ready;
}

void Shared::notifyIfReady() {
    // notify that we are ready to serve
    if (!_ready && (_servers_list.length() > 0) && (_tcp_port_list.length() > 0) && (_mac  != "")) {
        setReady(true);
    }

}


// Property: settings

void Shared::setSettings(QString newSettings) {
    if (newSettings != _settings) {
        _settings = newSettings;
        emit settingsChanged(newSettings);
    }
}

QString Shared::settings() {
    return _settings;
}


// Property: macAddress

void Shared::setMacAddress(QString mac) {
    if (mac != _mac) {
        _mac = mac;
        emit macAddressChanged(mac);
    }
    notifyIfReady();
}

QString Shared::macAddress() {
    return _mac;
}


QString Shared::getMacAddress() {
    // Return MAC-addr as string
    foreach(QNetworkInterface netInterface, QNetworkInterface::allInterfaces()) {
        if (!(netInterface.flags() & QNetworkInterface::IsLoopBack)) {
            if (netInterface.flags() & QNetworkInterface::IsRunning) {
                return netInterface.hardwareAddress();
            }
        }
    }
    return QString();
}


bool Shared::settingsReadFromFile() {
    QDir cache_dir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));

    QFile configFile(cache_dir.absoluteFilePath("squeezeui.json"));

    if (!configFile.exists()) {
        return false;
    }
    else if (!configFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return false;
    }

    QString configData(QString::fromUtf8(configFile.readAll()));
    configFile.close();
    setSettings(configData);
    _settings_original = configData;
    return true;
}

bool Shared::settingsWriteToFile() {

    if (_settings_original == settings()) {
        return false;
    }

    QDir cache_dir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));

    if (!cache_dir.exists()) {
        if (!cache_dir.mkpath(cache_dir.absolutePath())) {
            return false;
        }
    }

    QFile configFile(cache_dir.absoluteFilePath("squeezeui.json"));

    if (!configFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        return false;
    }

    configFile.write(_settings.toUtf8());
    configFile.close();
    return true;
}


// Property: serverAddressList

void Shared::setServerAddressList(QList<QString> servers) {
    if (servers != _servers_list) {
        _servers_list = servers;
        emit serverAddressListChanged(servers);
    }
}

QList<QString> Shared::serverAddressList() {
    return _servers_list;
}

void Shared::appendServerAddressList(QString server) {
    _servers_list.append(server);
    emit serverAddressListChanged(_servers_list);
}

// Property serverTcpPort

void Shared::setServerTcpPortList(QList<int> tcpPortList) {
    if (_tcp_port_list != tcpPortList) {
        _tcp_port_list = tcpPortList;
        emit serverTcpPortListChanged(tcpPortList);
    }
}

QList<int> Shared::serverTcpPortList() {
    return _tcp_port_list;
}

void Shared::appendServerTcpPortList(int port) {
    _tcp_port_list.append(port);
    emit serverTcpPortListChanged(_tcp_port_list);
}


void Shared::getServerAddress() {
    // discover squeezebox server on the network
    _udpSocket = new QUdpSocket(this);

    connect(_udpSocket, SIGNAL(readyRead()),
            this, SLOT(readPendingDatagrams()));

    QByteArray datagram("e");
    _udpSocket->writeDatagram(datagram.data(), datagram.size(),
                                  QHostAddress::Broadcast, 3483);
}

void Shared::readPendingDatagrams() {
    // listen to respons from squeezebox server. if response: add ip to serveraddr.
    while (_udpSocket->hasPendingDatagrams()) {
            QByteArray datagram;
            datagram.resize(_udpSocket->pendingDatagramSize());
            QHostAddress sender;
            quint16 senderPort;

            _udpSocket->readDatagram(datagram.data(), datagram.size(),
                                    &sender, &senderPort);

            if (datagram.indexOf("E",0) == 0) {
                appendServerAddressList(sender.toString());
                appendServerTcpPortList(senderPort);
                notifyIfReady();
                break;
            }
        }
}

// Property: httpResponse

void Shared::setHttpResponse(QString response) {
    _httpResponse = response;
    emit httpResponseChanged(response);
}

QString Shared::httpResponse() {
    return _httpResponse;
}

void Shared::setupHttpClient() {

    _manager = new QNetworkAccessManager(this);
    connect(_manager, SIGNAL(finished(QNetworkReply*)),
        this, SLOT(httpRequestReplyFinished(QNetworkReply*)));
}

void Shared::sendHttpRequest(QString url, QString contentType, QString post) {

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, contentType);

    _manager->post(request, post.toUtf8());
}


void Shared::httpRequestReplyFinished(QNetworkReply* reply) {
    QString encodedAnswer = QString::fromUtf8(reply->readAll());
    setHttpResponse(encodedAnswer);
}

// Property tcpResponse

void Shared::setTcpResponse(QList<int> data) {
    _tcpResponse = data;
    emit tcpResponseChanged(data);
    //qDebug() << "setTcpResponse: < "  << data << " >";

}

QList<int> Shared::tcpResponse() {
    return _tcpResponse;
}

void Shared::setupTcpClient() {
    _tcpSocket = new QTcpSocket(this);

    connect(_tcpSocket, SIGNAL(readyRead()), this, SLOT(readTcpData()));
    connect(_tcpSocket, SIGNAL(error(QAbstractSocket::SocketError)),
            this, SLOT(handleTcpError(QAbstractSocket::SocketError)));
}

void Shared::readTcpData() {
    while (_tcpSocket->bytesAvailable() > 0) {
        QByteArray rawdata;
        rawdata.resize(_tcpSocket->bytesAvailable());
        _tcpSocket->read(rawdata.data(), rawdata.size());

        //qDebug() << "tcp recv: " << rawdata.length();

        QList<int> response;

        for (int i = 0; i < rawdata.length(); i++) {
            response.append(rawdata[i]);
        }

        setTcpResponse(response);
    }
}

void Shared::sendTcpRequest(QList<int> request) {
    //qDebug() << "tcp write: " << request.length();

    QByteArray buffer;
    buffer.resize(request.length());
    for (int i = 0; i < request.length(); i++) {
        buffer[i] = request[i] & 0xFF;
    }

    _tcpSocket->write(buffer);
}

void Shared::connectTcp(QString ipaddress, int port) {
    if (!_tcpSocket->isOpen()) {
        _tcpSocket->abort(); // reconnect if already open
        _tcpSocket->connectToHost(ipaddress, port);
        qDebug() << "tcp connecting to" << ipaddress << ":" << port;
    }
}

void Shared::disconnectTcp() {
    if (_tcpSocket->isOpen()) {
        _tcpSocket->close();
        qDebug() << "tcp close";
    }
}

void Shared::handleTcpError(QAbstractSocket::SocketError socketError) {
    switch (socketError) {

    case QAbstractSocket::RemoteHostClosedError:
        break;

    case QAbstractSocket::HostNotFoundError:
        qDebug() << ("The host was not found. Please check the "
                                    "host name and port settings.");
        break;

    case QAbstractSocket::ConnectionRefusedError:
        qDebug() << ("The connection was refused by the peer. "
                                    "Make sure the fortune server is running, "
                                    "and check that the host name and port "
                                    "settings are correct.");
        break;

    default:
        qDebug() << _tcpSocket->errorString();
    }
}
