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

#ifndef SHARED_H
#define SHARED_H

#include <QObject>
#include <QUdpSocket>
#include <QTcpSocket>
#include <QNetworkInterface>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>

class Shared : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString macAddress READ macAddress WRITE setMacAddress NOTIFY macAddressChanged)
    Q_PROPERTY(QList<QString> serverAddressList READ serverAddressList WRITE setServerAddressList NOTIFY serverAddressListChanged)
    Q_PROPERTY(QList<int> serverTcpPortList READ serverTcpPortList WRITE setServerTcpPortList NOTIFY serverTcpPortListChanged)
    Q_PROPERTY(QString settings READ settings WRITE setSettings NOTIFY settingsChanged)
    Q_PROPERTY(bool ready READ ready WRITE setReady NOTIFY readyChanged)
    Q_PROPERTY(QString httpResponse READ httpResponse WRITE setHttpResponse NOTIFY httpResponseChanged)
    Q_PROPERTY(QList<int> tcpResponse READ tcpResponse WRITE setTcpResponse NOTIFY tcpResponseChanged)

public:
    explicit Shared();
    ~Shared();

    // property containing mac address. used as player-id.
    QString macAddress();
    void setMacAddress(QString);
    QString getMacAddress();

    // property containing squeezebox server address.
    QString serverAddress();
    void setServerAddress(QString);
    void getServerAddress();

    // property containing all discovered servers
    QList<QString> serverAddressList();
    void setServerAddressList(QList<QString>);
    void appendServerAddressList(QString);

    // property containing squeezebox server tcp port
    QList<int> serverTcpPortList();
    void setServerTcpPortList(QList<int>);
    void appendServerTcpPortList(int);

    // this property is set when server-address is autodiscovered
    bool ready();
    void setReady(bool);

    // property containing a simple string. qml can use this for settings. (encoded as json).
    QString settings();
    void setSettings(QString);

    // http interface to send and receive rpc from qml.
    void setupHttpClient();

    QString httpResponse();
    void setHttpResponse(QString);

    // Tcp interface to send and receive tcp packages from qml
    void setupTcpClient();

    QList<int> tcpResponse();
    void setTcpResponse(QList<int>);


signals:
    void macAddressChanged(QString);
    void serverAddressListChanged(QList<QString>);
    void serverTcpPortListChanged(QList<int>);
    void readyChanged(bool);
    void settingsChanged(QString);
    void httpResponseChanged(QString);
    void tcpResponseChanged(QList<int>);

public slots:
    // http interface to send and reveive rpc from qml.
    void sendHttpRequest(QString, QString, QString);

    // Tcp interface to send and receive tcp packages from qml
    //void sendTcpRequest(QString);
    void sendTcpRequest(QList<int>);
    void connectTcp(QString, int);
    void disconnectTcp();

    // functions to save/read the settings-property to cache location.
    bool settingsReadFromFile();
    bool settingsWriteToFile();


private slots:
    void httpRequestReplyFinished(QNetworkReply*);
    void readPendingDatagrams();
    void readTcpData();
    void handleTcpError(QAbstractSocket::SocketError);

private:
    void notifyIfReady();

    QString _mac;
    QString _server;
    QList<int> _tcp_port_list;
    QList<QString> _servers_list;
    QString _settings;
    QString _settings_original;
    bool _ready;
    QUdpSocket *_udpSocket;

    QTcpSocket *_tcpSocket;
    QList<int> _tcpResponse;

    QNetworkAccessManager *_manager;

    QString _httpResponse;

};

#endif // SHARED_H
