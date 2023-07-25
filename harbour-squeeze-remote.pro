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

RESOURCES += \
    resources.qrc

DISTFILES += \
    qml/**/*.qml

OTHER_FILES += \
    rpm/harbour-squeeze-remote.changes.in \
    rpm/harbour-squeeze-remote.spec \
    rpm/harbour-squeeze-remote.yaml \
    harbour-squeeze-remote.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-squeeze-remote-cs.ts \
                translations/harbour-squeeze-remote-de.ts \
                translations/harbour-squeeze-remote-es.ts \
                translations/harbour-squeeze-remote-nl.ts \
                translations/harbour-squeeze-remote-pl.ts \
                translations/harbour-squeeze-remote-zh_CN.ts

