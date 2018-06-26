import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    property bool largeScreen: screen.width >= 1080
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        VerticalScrollDecorator {
        }

        Column {
            id: col
            spacing: isPortrait ? Theme.paddingLarge : Theme.paddingMedium
            width: parent.width
            PageHeader {
                title: qsTr("About")
            }
            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                visible: isPortrait || largeScreen
            }
            InfoLabel {
                text: "mediainfo-gui"
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                    source: largeScreen ? "/usr/share/icons/hicolor/256x256/apps/mediainfo-gui.png" : "/usr/share/icons/hicolor/86x86/apps/mediainfo-gui.png"
            }
            Label {
                font.pixelSize: largeScreen ? Theme.fontSizeLarge : Theme.fontSizeMedium
                text: qsTr("Version") + " " + version
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
            }
            Label {
                text: qsTr("Mediainfo-gui is a graphical user interface for MediaInfo and ExifTool")
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                horizontalAlignment: Text.Center
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
            }
            Label {
                text: qsTr("-thanks to llelectronics for the file browser-")
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                horizontalAlignment: Text.Center
                color: Theme.secondaryColor
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
            }
            Label {
                text: mainapp.exifToolVersion
                      === "" ? qsTr("ExifTool not found. Using ")+ mainapp.mediainfoVersion.replace(
                                   "\n",
                                   "") : qsTr("Using ")+ mainapp.mediainfoVersion.replace(
                                   /(\r\n|\n|\r)/gm,
                                   "") + qsTr(" and ExifTool ") + mainapp.exifToolVersion
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                horizontalAlignment: Text.Center
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
            }
            SectionHeader {
                text: qsTr("Author")
                visible: isPortrait || screen.width > 1080
            }
            Separator {
                color: Theme.primaryColor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                visible: isPortrait || screen.width > 1080
            }

            Label {
                text: "© Arno Dekker 2014-2018"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
