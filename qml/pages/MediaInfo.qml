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
        var picExts = ["JPG", "JPEG", "GIF", "PNG", "TIF", "TIFF", "BMP", "JP2", "PGF", "HDP", "PSP", "XCF", "RAW",
        "DNG", "BGP", "XMP", "JFIF", "ARW", "BPG", "CR2", "CRW", "DPX", "SVG"]
        var audioExts = ["WAV", "MP3", "AU", "PCM", "APE", "AAC", "WMA", "AA", "AAC", "FLAC", "OGG", "OGA", "WV"]
        var videoExts = [ "WEBM", "MKV", "FLV", "VOB", "OGV", "DRC", "GIF", "GIFV", "MNG", "AVI", "MOV", "QT",
        "WMV", "YUV", "RM", "RMVB", "ASF", "AMV", "MP4", "M4P", "M4V", "MPG", "MP2", "MPEG", "MPE", "MPV",
        "MPG", "MPEG", "M2V", "M4V", "SVI", "3GP", "3G2", "MXF", "ROQ", "NSV", "FLV", "F4V", "F4P", "F4A", "F4B"]

        if (picExts.indexOf(fileExt) > -1) {
            fileType = "image"
            toolCmd = "exiftool"
        } else if (audioExts.indexOf(fileExt) > -1) {
            fileType = "audio"
        } else if (videoExts.indexOf(fileExt) > -1) {
            fileType = "video"
        } else {
            toolCmd = "exiftool"
        }
    }

    function getFileInfo() {
        var exifVerTXT = "Exif Version"
        if (toolCmd === "exiftool") {
            switch(langName.substring(0, 2)) {
                case "nl": // dutch
                toolCmd = toolCmd + " -lang nl "
                exifVerTXT = "Exif versie"
                break
                case "es": // spanish
                toolCmd = toolCmd + " -lang es "
                exifVerTXT = "Versión Exif"
                break
                case "sv": // swedish
                toolCmd = toolCmd + " -lang sv "
                exifVerTXT = "Exif-version"
                break
                case "ru": // russian
                toolCmd = toolCmd + " -lang ru "
                exifVerTXT = "Exif версия"
                break
            }
        } else {
            toolCmd = toolCmd + " --Language=file:///usr/share/mediainfo/Plugins/Language/" + langName.substring(0, 2) + ".csv "
        }

        hasGPSinfo = false
        hasEXIFinfo = false
        var infoText = bar.launch(toolCmd + ' "' + fileName + '"')
        infoText = infoText.split('\n')
        for (var i = 0; i < infoText.length; i++) {
            if (infoText[i].indexOf(": ") > 1) {
                var mediaKey = infoText[i].split(': ')[0].replace(/^\s*/, '').replace(/\s*$/, '')
                var mediaValue = infoText[i].split(': ')[1].replace(/^\s*/, '').replace(/\s*$/, '')
                if (mediaKey.indexOf("GPS ") === 0) {
                    hasGPSinfo = true
                }
                if (mediaKey.indexOf(exifVerTXT) === 0) {
                    hasEXIFinfo = true
                }
                appendList(mediaKey, mediaValue)
            } else {
                // no key : value
                appendList(infoText[i].replace(/^\s*/, '').replace(/\s*$/, ''), "")
            }
        }
    }

    function appendList(mediaKey, mediaValue) {
        listMediaModel.append({
                                 mediaKey:   mediaKey,
                                 mediaValue: mediaValue
                             })
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
            spacing: 0
            width: parent.width - 2 * Theme.paddingSmall
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
            Repeater {
                model: ListModel {
                    id: listMediaModel
                }

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Label {
                        width: parent.width * 0.5
                        text: mediaKey
                        horizontalAlignment: Text.AlignRight
                        color: Theme.primaryColor
                        font.pixelSize: largeScreen ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                        wrapMode: Text.Wrap
                    }
                    Label {
                        width: parent.width * 0.5
                        text: mediaValue
                        color: Theme.highlightColor
                        font.pixelSize: largeScreen ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
