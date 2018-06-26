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
TARGET = mediainfo-gui

CONFIG += sailfishapp

SOURCES += src/mediainfo-gui.cpp \
    src/osread.cpp \
    src/settings.cpp \
    src/folderlistmodel/qquickfolderlistmodel.cpp \
    src/folderlistmodel/fileinfothread.cpp

icon86.files += icons/86x86/mediainfo-gui.png
icon86.path = /usr/share/icons/hicolor/86x86/apps

icon108.files += icons/108x108/mediainfo-gui.png
icon108.path = /usr/share/icons/hicolor/108x108/apps

icon128.files += icons/128x128/mediainfo-gui.png
icon128.path = /usr/share/icons/hicolor/128x128/apps

icon256.files += icons/256x256/mediainfo-gui.png
icon256.path = /usr/share/icons/hicolor/256x256/apps

INSTALLS += icon86 icon108 icon128 icon256

OTHER_FILES += qml/mediainfo-gui.qml \
    qml/cover/CoverPage.qml \
    rpm/mediainfo-gui.changes.in \
    rpm/mediainfo-gui.spec \
    rpm/mediainfo-gui.yaml \
    mediainfo-gui.desktop \
    qml/pages/About.qml \
    qml/pages/MainPage.qml \
    qml/pages/SettingPage.qml \
    qml/pages/InfoBanner.qml \
    qml/pages/fileman/Main.qml \
    qml/pages/fileman/DirView.qml \
    qml/pages/fileman/DirStack.qml \
    qml/pages/fileman/DirList.qml \
    qml/pages/fileman/DirEntryMenu.qml \
    qml/pages/fileman/DirEntry.qml \
    qml/pages/fileman/OpenDialog.qml \
    qml/pages/MediaInfo.qml

# to disable building translations every time, comment out the
# following CONFIG line
# CONFIG += sailfishapp_i18n


HEADERS += \
    src/osread.h \
    src/settings.h \
    src/fmhelper.hpp \
    src/folderlistmodel/qquickfolderlistmodel.h \
    src/folderlistmodel/fileproperty_p.h \
    src/folderlistmodel/fileinfothread_p.h
