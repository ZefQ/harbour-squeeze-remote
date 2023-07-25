import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    property string thumbnail: ""
    property string fullTitle: ""
    property string _title: fullTitle.split("\n", 2)[0]
    property string _description: fullTitle.split("\n", 2)[1] || ""

    width: parent.width
    contentHeight: Theme.itemSizeMedium

    Row {
        spacing: Theme.paddingMedium
        anchors {
            fill: parent
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }

        Image {
            id: image
            source: thumbnail

            smooth: true
            fillMode: Image.PreserveAspectFit
            cache: true

            sourceSize.width: Theme.iconSizeLarge
            sourceSize.height: Theme.iconSizeLarge
            height: parent.height
            width: height
        }

        Column {
            height: parent.height
            width: parent.width - x - parent.leftPadding

            Label {
                width: parent.width
                truncationMode: TruncationMode.Fade
                text: _title
            }

            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Label.WordWrap
                maximumLineCount: 2
                truncationMode: TruncationMode.Elide
                color: Theme.secondaryColor
                text: _description
                visible: _description
            }
        }
    }
}
