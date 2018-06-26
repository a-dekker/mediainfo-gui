import QtQuick 2.0
import Sailfish.Silica 1.0
import Settings 1.0

Page {
    id: settingsPage

    MySettings {
        id: myset
    }

    objectName: "SettingPage"

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        clip: true

        ScrollDecorator {
        }

        Column {
            id: col
            spacing: isPortrait ? Theme.paddingLarge : Theme.paddingSmall
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Video")
            }
            ComboBox {
                id: videolink
                width: parent.width
                label: qsTr("Using")
                description: qsTr("Preferred tool for video info")
                currentIndex: myset.value("video_tool") === "ExifTool" ? 1 : 0
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("MediaInfo") // 0
                    }
                    MenuItem {
                        text: qsTr("ExifTool") // 1
                    }
                }
                onCurrentItemChanged: {
                    if (videolink.currentIndex === 0) {
                        myset.setValue("video_tool", "MediaInfo")
                    }
                    if (videolink.currentIndex === 1) {
                        myset.setValue("video_tool", "ExifTool")
                    }
                    myset.sync()
                }
            }
            SectionHeader {
                text: qsTr("Audio")
            }
            ComboBox {
                id: audiolink
                width: parent.width
                label: qsTr("Using")
                description: qsTr("Preferred tool for audio info")
                currentIndex: myset.value("audio_tool") === "ExifTool" ? 1 : 0
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("MediaInfo") // 0
                    }
                    MenuItem {
                        text: qsTr("ExifTool") // 1
                    }
                }
                onCurrentItemChanged: {
                    if (audiolink.currentIndex === 0) {
                        myset.setValue("audio_tool", "MediaInfo")
                    }
                    if (audiolink.currentIndex === 1) {
                        myset.setValue("audio_tool", "ExifTool")
                    }
                    myset.sync()
                }
            }
        }
    }
}
