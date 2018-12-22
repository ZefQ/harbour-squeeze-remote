#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
// from here copied
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include "shared.h"


int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-squeezeui-remote-ps.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    //return SailfishApp::main(argc, argv);
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    Shared *shared = new Shared();
    view->rootContext()->setContextProperty("shared", shared);
    // qDebug() << view->filePath();
    QString x = app->applicationDirPath();
    view->setSource(QUrl::fromLocalFile("/usr/share/harbour-squeezeui-remote-ps/qml/harbour-squeezeui-remote-ps.qml"));
    // view->setSource(QUrl("qrc:///src/qml/harbour-squeezeui-remote.qml"));

    view->showFullScreen();

    int returncode = app->exec();
    shared->settingsWriteToFile(); // write settings if changed since last read
    delete shared;
    return returncode;

}
