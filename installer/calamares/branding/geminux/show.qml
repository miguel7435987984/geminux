import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: presentation
    color: "#0f141c"
    anchors.fill: parent

    property int currentSlide: 0
    property var slides: [
        {
            title: "Welcome to Geminux OS",
            desc: "A modern, fast, and secure Linux distribution with a refined dark aesthetic and neon cyan accents.",
            tag: "FAST & MODERN"
        },
        {
            title: "Prius Terminal",
            desc: "Built-in high-performance terminal emulator with neon styling, tabs, search, and intuitive shortcuts.",
            tag: "TERMINAL"
        },
        {
            title: "Privacy First with Firefox",
            desc: "Mozilla Firefox pre-configured with enhanced tracking protection and optimized for speed.",
            tag: "SECURITY"
        },
        {
            title: "Minimal GNOME Desktop",
            desc: "Clean desktop environment designed to stay out of your way and maximize your productivity.",
            tag: "DESKTOP"
        }
    ]

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: {
            presentation.currentSlide = (presentation.currentSlide + 1) % presentation.slides.length
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 24
        width: parent.width * 0.85

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 140
            height: 32
            radius: 16
            color: "#00d2ff"
            opacity: 0.15
            border.color: "#00d2ff"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: presentation.slides[presentation.currentSlide].tag
                color: "#00d2ff"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 2
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: presentation.slides[presentation.currentSlide].title
            color: "#ffffff"
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: presentation.slides[presentation.currentSlide].desc
            color: "#94a3b8"
            font.pixelSize: 16
            width: parent.width * 0.8
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.4
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            topPadding: 16

            Repeater {
                model: presentation.slides.length
                Rectangle {
                    width: index === presentation.currentSlide ? 28 : 10
                    height: 8
                    radius: 4
                    color: index === presentation.currentSlide ? "#00d2ff" : "#334155"
                    Behavior on width { NumberAnimation { duration: 250 } }
                    Behavior on color { ColorAnimation { duration: 250 } }
                }
            }
        }
    }
}
