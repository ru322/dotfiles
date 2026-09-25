import QtQuick
import QtQuick.Controls

Text {
    id: root
    property string tooltip: ""
    signal clicked()
    color: "#cdd6f4"
    font.family: "Noto Sans CJK JP"
    font.pixelSize: 13
    height: 30
    leftPadding: 8
    rightPadding: 8
    verticalAlignment: Text.AlignVCenter
    textFormat: Text.PlainText

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
    ToolTip.visible: mouse.containsMouse && tooltip.length > 0
    ToolTip.text: tooltip
    ToolTip.delay: 400
}
