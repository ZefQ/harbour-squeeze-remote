# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-squeeze-remote

CONFIG += sailfishapp

SOURCES += \
    src/shared.cpp \
    src/harbour-squeeze-remote.cpp

HEADERS += \
    src/shared.h

DISTFILES += \
    qml/common/base/PlayerRemoteBase.qml \
    qml/common/AudioPlayerJavascript.qml \
    qml/common/PlayerRemoteJavascript.qml \
    qml/common/PlayerRemotePython.qml \
    qml/common/PlayerRemoteWorkerscript.qml \
    qml/sailfishos/cover/CoverPage.qml \
    qml/sailfishos/pages/LibraryPage.qml \
    qml/sailfishos/pages/PlayerPage.qml \
    qml/sailfishos/pages/PlaylistPage.qml \
    qml/sailfishos/pages/SettingsPage.qml \
    qml/sailfishos/pages/StartupPage.qml \
    qml/harbour-squeeze-remote.qml \
    qml/js/common/remotecontrol.js \
    qml/js/common/slimproto.js \
    rpm/harbour-squeeze-remote.changes.in \
    rpm/harbour-squeeze-remote.spec \
    rpm/harbour-squeeze-remote.yaml \
    translations/*.ts \
    harbour-squeeze-remote.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

js.path = /usr/share/harbour-squeeze-remote/js
js.files = js/*

INSTALLS += js

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-squeeze-remote-cs.ts \
                translations/harbour-squeeze-remote-de.ts \
                translations/harbour-squeeze-remote-es.ts \
                translations/harbour-squeeze-remote-nl.ts \
                translations/harbour-squeeze-remote-pl.ts \
                translations/harbour-squeeze-remote-zh_CN.ts                