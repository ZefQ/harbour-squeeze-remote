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
TARGET = harbour-squeezeui-remote-ps

CONFIG += sailfishapp

SOURCES += \
    src/shared.cpp \
    src/harbour-squeezeui-remote-ps.cpp

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
    qml/harbour-squeezeui-remote-ps.qml \
    qml/js/common/remotecontrol.js \
    qml/js/common/slimproto.js \
    rpm/harbour-squeezeui-remote-ps.changes.in \
    rpm/harbour-squeezeui-remote-ps.changes.run.in \
    rpm/harbour-squeezeui-remote-ps.spec \
    rpm/harbour-squeezeui-remote-ps.yaml \
    translations/*.ts \
    harbour-squeezeui-remote-ps.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-squeezeui-remote-ps-de.ts

HEADERS += \
    src/shared.h
