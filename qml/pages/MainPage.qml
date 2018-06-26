import QtQuick 2.0
import Sailfish.Silica 1.0
import Launcher 1.0

Page {
    id: page
    property bool largeScreen: screen.width >= 1080
    signal removeFile(string url)

    Component.onCompleted: {
        mainapp.mediainfoVersion = bar.launch("mediainfo --version")
        mainapp.exifToolVersion = bar.launch("exiftool -ver")
        mainMenuModel.append({
                                 name: qsTr("Browse"),
                                 ident: "browse",
                                 icon: "image://theme/icon-m-folder"
                             })
        mainMenuModel.append({
                                 name: qsTr("Images"),
                                 ident: "image_gallery",
                                 icon: "image://theme/icon-m-image"
                             })
        mainMenuModel.append({
                                 name: qsTr("Videos"),
                                 ident: "video_gallery",
                                 icon: "image://theme/icon-m-video"
                             })
    }

    ListModel {
        id: mainMenuModel
    }

    function parseClickedMainMenu(ident) {
        if (ident === "browse") {
            pageStack.push(Qt.resolvedUrl("fileman/Main.qml"))
        } else if (ident === "image_gallery") {
            var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage")
            imagePicker.selectedContentChanged.connect(function () {
                var filePath = imagePicker.selectedContent.toString().slice(7,imagePicker.selectedContent.length)
                pageStack.push(Qt.resolvedUrl("MediaInfo.qml"),{ fileName: filePath})
            })
        } else if (ident === "video_gallery") {
            var videoPicker = pageStack.push("Sailfish.Pickers.VideoPickerPage")
            videoPicker.selectedContentChanged.connect(function () {
                var filePath = videoPicker.selectedContent.toString().slice(7,videoPicker.selectedContent.length)
                pageStack.push(Qt.resolvedUrl("MediaInfo.qml"),{ fileName: filePath})
            })
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"))
            }
        }

        App {
            id: bar
        }

        PageHeader {
            id: header
            anchors {
                top: parent.top
            }
            title: "MediaInfo-gui"
        }
        Image {
            id: image
            anchors {
                top: header.bottom
            }
            anchors.topMargin: isPortrait ? Theme.paddingLarge : Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            source: "/usr/share/icons/hicolor/256x256/apps/mediainfo-gui.png"
            visible: isPortrait
        }
        Image {
            id: imageLandscape
            anchors {
                top: header.bottom
                left: infotxt.right
            }
            anchors.topMargin: Theme.paddingLarge
            anchors.leftMargin: parent.width / 7
            source: largeScreen ? "/usr/share/icons/hicolor/256x256/apps/mediainfo-gui.png" : "/usr/share/icons/hicolor/128x128/apps/mediainfo-gui.png"
            visible: isLandscape
        }
        Label {
            id: infotxt
            anchors {
                top: isPortrait ? image.bottom : header.bottom
            }
            anchors.topMargin: isPortrait ? Theme.paddingLarge * 2 : (largeScreen ? Theme.paddingLarge * 3 : Theme.paddingLarge)
            horizontalAlignment: isPortrait ? Text.Center : Text.AlignLeft
            x: Theme.paddingLarge
            y: Theme.paddingLarge
            width: isPortrait ? parent.width - Theme.paddingLarge : parent.width / 1.5
            text: qsTr("Select media file (image/audio/video) to acquire extended tag/metadata provided by MediaInfo or ExifTool.")
            wrapMode: Text.Wrap
        }
        Label {
            id: subinfotxt
            anchors {
                top: infotxt.bottom
            }
            anchors.topMargin: Theme.paddingSmall
            horizontalAlignment: isPortrait ? Text.Center : Text.AlignLeft
            x: Theme.paddingLarge
            y: Theme.paddingLarge
            width: isPortrait ? parent.width - Theme.paddingLarge : parent.width / 1.5
            text: qsTr("Includes limited Exif edit options.") + "\n"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            wrapMode: Text.Wrap
        }
        Item {
            id: myItem
            anchors {
                top: subinfotxt.bottom
            }
            height: mainGrid.height
            width: parent.width
            Grid {
                id: mainGrid

                columns: 3

                anchors.horizontalCenter: parent.horizontalCenter
                Repeater {
                    model: mainMenuModel
                    delegate: Component {
                        BackgroundItem {
                            id: gridItem
                            width: Theme.itemSizeHuge
                            height: Theme.itemSizeHuge
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: Theme.paddingSmall
                                color: Theme.rgba(
                                           Theme.highlightBackgroundColor,
                                           Theme.highlightBackgroundOpacity)
                            }
                            Column {
                                anchors.centerIn: parent
                                Image {
                                    id: itemIcon
                                    source: icon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Label {
                                    id: itemLabel
                                    anchors {
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    font.pixelSize: Theme.fontSizeMedium
                                    width: gridItem.width - (2 * Theme.paddingSmall)
                                    horizontalAlignment: "AlignHCenter"
                                     scale: paintedWidth > width ? (width / paintedWidth) : 1
                                    text: name
                                }
                            }

                            onClicked: {
                                parseClickedMainMenu(ident)
                            }
                        }
                    }
                }
            }
        }

        Label {
            id: url_link
            anchors {
                top: myItem.bottom
            }
            anchors.topMargin: isPortrait ? Theme.paddingLarge * 2 : Theme.paddingMedium
            x: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            text: "Homepage <a href=\"http://mediaarea.net/en/MediaInfo\">Mediainfo</a>" + " &amp; " + "<a href=\"http://www.sno.phy.queensu.ca/~phil/exiftool/\">ExifTool</a>"
            onLinkActivated: Qt.openUrlExternally(link)
            linkColor: Theme.highlightColor
        }
    }
}
