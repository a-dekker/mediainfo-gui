import QtQuick 2.0
import Sailfish.Silica 1.0
import Launcher 1.0
import Settings 1.0
import Nemo.Configuration 1.0

Page {
    id: mediaPage

    property bool largeScreen: screen.width >= 1080
    property string fileName
    property string toolCmd: "mediainfo"
    property string infoText
    property string fileType
    property bool hasGPSinfo: false
    property bool hasEXIFinfo: false
    property string langName: Qt.locale().name

    MySettings {
        id: myset
    }

    App {
        id: bar
    }

    RemorsePopup {
        id: remorse
    }

    function findFileType(fileExt) {
        var picExts = ["JPG", "JPEG", "GIF", "PNG", "TIF", "TIFF", "BMP", "JP2", "PGF", "HDP", "PSP", "XCF", "RAW", "DNG", "BGP", "XMP", "JFIF", "ARW", "BPG", "CR2", "CRW", "DPX", "SVG"]
        var audioExts = ["WAV", "MP3", "AU", "PCM", "APE", "AAC", "WMA", "AA", "AAC", "FLAC", "OGG", "OGA", "WV"]
        if (picExts.indexOf(fileExt) > -1) {
            fileType = "image"
            toolCmd = "exiftool"
        } else if (audioExts.indexOf(fileExt) > -1) {
            fileType = "audio"
        } else {
            fileType = "video"
        }
    }

    function getFileInfo() {
        var exifVerTXT = "Exif Version:"
        if (toolCmd === "exiftool") {
            switch(langName.substring(0, 2)) {
                case "nl": // dutch
                toolCmd = toolCmd + " -lang nl "
                exifVerTXT = "Exif versie"
                break
                case "es": // spanish
                toolCmd = toolCmd + " -lang es "
                exifVerTXT = "Versión Exif:"
                break
                case "ru": // russian
                toolCmd = toolCmd + " -lang ru "
                exifVerTXT = "Exif версия:"
                break
            }
        } else {
            toolCmd = toolCmd + " --Language=file:///usr/share/mediainfo/Plugins/Language/" + langName.substring(0, 2) + ".csv "
        }


        var highLightColor = "white"
        infoText = bar.launch(toolCmd + ' "' + fileName + '"')
        highLightColor = bar.launch(
                    "dconf read /desktop/jolla/theme/color/highlight").replace(
                    /'/g, "").replace(/(\r\n|\n|\r)/gm, "")
        infoText = infoText.replace(/($)/gm, "</font>")
        infoText = infoText.replace("</font></font>", "</font>")
        infoText = infoText.replace(/ *: /gm,
                                    ": <font color=\"" + highLightColor + "\">")
        infoText = infoText.replace(/\n/gm, "<br>")
        // for mediainfo only
        infoText = infoText.replace("General</font><br>", "<h2>General</h2>")
        infoText = infoText.replace(
                    "</font><br></font><br>Video</font></font><br>",
                    "<br><h2>Video</h2>")
        infoText = infoText.replace(
                    "</font><br></font><br>Audio</font></font><br>",
                    "<br><h2>Audio</h2>")
        infoText = infoText.replace(
                    "</font><br></font><br>Image</font></font><br>",
                    "<br><h2>Image</h2>")
        // console.log(infoText)
        if (infoText.indexOf("GPS ") > 1) {
            hasGPSinfo = true
        } else {
            hasGPSinfo = false
        }
        if (infoText.indexOf(exifVerTXT) > 1) {
            hasEXIFinfo = true
        } else {
            hasEXIFinfo = false
        }
    }

    Component.onCompleted: {
        // determine filetype
        var myFileExt = fileName.toUpperCase().split('.').pop()
        findFileType(myFileExt)
        // read preferred tools
        var videoTool = myset.value("video_tool", "mediainfo").toLowerCase()
        if (videoTool !== "exiftool") {
            videoTool = "mediainfo"
        }
        var audioTool = myset.value("audio_tool", "mediainfo").toLowerCase()
        if (audioTool !== "exiftool") {
            audioTool = "mediainfo"
        }
        if (fileType === "audio") {
            toolCmd = audioTool
        }
        if (fileType === "video") {
            toolCmd = videoTool
        }
        getFileInfo()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            visible: hasEXIFinfo
            MenuItem {
                text: qsTr("Phototime to file timestamp")
                onClicked: remorse.execute(qsTr("Setting timestamp"),
                                           function () {
                                               var exiflog = bar.launch('exiftool "-DateTimeOriginal>FileModifyDate" ' + '"' + fileName + '"')
                                               console.log(exiflog)
                                               getFileInfo()
                                           })
            }
            MenuItem {
                text: qsTr("Remove GPS data")
                enabled: hasGPSinfo
                         && fileType === "image" // and exiftool installed
                visible: fileType === "image" // and exiftool installed
                onClicked: remorse.execute(qsTr("Removing location info"),
                                           function () {
                                               var exiflog = bar.launch("exiftool -overwrite_original -gps:all= -xmp:geotag=  " + '"' + fileName + '"')
                                               console.log(exiflog)
                                               getFileInfo()
                                           })
            }
            MenuItem {
                text: qsTr("Remove all EXIF metadata")
                onClicked: remorse.execute(qsTr("Removing all metadata"),
                                           function () {
                                               var exiflog = bar.launch("exiftool -overwrite_original -all= " + '"' + fileName + '"')
                                               console.log(exiflog)
                                               getFileInfo()
                                           })
            }
        }

        VerticalScrollDecorator {
        }

        Column {
            id: col
            spacing: Theme.paddingLarge
            width: parent.width
            PageHeader {
                title: fileName
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: fileType === "image" ? fileName : "image://theme/icon-l-dismiss"
                width: parent.width - (2 * Theme.paddingLarge)
                visible: fileType === "image"
            }
            Label {
                width: parent.width - 40
                x: Theme.paddingLarge
                y: Theme.paddingLarge
                text: infoText
                textFormat: Text.StyledText
                font.pixelSize: largeScreen ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
            }
        }
    }
}
