import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray

ShellRoot {
    id: root
    property var stats: ({cpu: null, memory: null, network: "󰤭", battery: ""})
    readonly property var sink: Pipewire.defaultAudioSink

    Compositor { id: compositor }
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }
    SystemClock { id: clock; precision: SystemClock.Minutes }

    Process {
        id: statsProcess
        command: ["python3", Quickshell.shellPath("stats.py")]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try { root.stats = JSON.parse(data); }
                catch (error) { console.warn("System stats:", error); }
            }
        }
        onRunningChanged: if (!running) restartStats.restart()
    }
    Timer {
        id: restartStats
        interval: 5000
        onTriggered: statsProcess.running = true
    }
    Process {
        id: powerMenu
        command: ["sh", Quickshell.shellPath("power-menu.sh")]
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 30
            exclusiveZone: 30
            color: "#f21e1e2e"

            Row {
                id: workspaces
                anchors.left: parent.left
                Repeater {
                    model: compositor.forOutput(bar.screen.name)
                    BarText {
                        required property var modelData
                        text: compositor.active(modelData) ? "●" : "○"
                        color: compositor.active(modelData) ? "#89b4fa" : "#6c7086"
                        leftPadding: 6
                        rightPadding: 6
                        tooltip: String(modelData.name || modelData.idx || modelData.id)
                        onClicked: compositor.focus(modelData)
                    }
                }
            }

            BarText {
                anchors.centerIn: parent
                // Keep the title centered without colliding with either side.
                width: Math.max(0, Math.min(500, bar.width - 2 * Math.max(workspaces.width, status.width)))
                text: compositor.titleForOutput(bar.screen.name)
                tooltip: text
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Row {
                id: status
                anchors.right: parent.right
                spacing: 4
                BarText {
                    text: !root.sink || !root.sink.audio ? "󰝟 —"
                        : root.sink.audio.muted ? "󰝟 muted"
                        : "󰕾 " + Math.round(root.sink.audio.volume * 100) + "%"
                    tooltip: "クリックでミュート切替"
                    onClicked: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted
                }
                BarText { text: root.stats.network; tooltip: "ネットワーク" }
                BarText { text: " " + (root.stats.cpu === null ? "—" : root.stats.cpu + "%"); tooltip: "CPU使用率" }
                BarText { text: " " + (root.stats.memory === null ? "—" : root.stats.memory + "%"); tooltip: "メモリ使用率" }
                BarText { text: root.stats.battery; visible: text.length > 0; tooltip: "バッテリー" }
                BarText {
                    text: " " + Qt.formatDateTime(clock.date, "yyyy-MM-dd HH:mm")
                    tooltip: Qt.formatDateTime(clock.date, "yyyy年M月d日 dddd")
                    onClicked: calendar.visible = !calendar.visible
                    PopupWindow {
                        id: calendar
                        anchor.window: bar
                        anchor.rect.x: Math.max(0, bar.width - implicitWidth)
                        anchor.rect.y: bar.height
                        implicitWidth: 280
                        implicitHeight: 260
                        color: "#1e1e2e"
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            Text {
                                width: parent.width
                                height: 30
                                color: "#cdd6f4"
                                text: Qt.formatDateTime(clock.date, "yyyy年M月")
                                horizontalAlignment: Text.AlignHCenter
                            }
                            MonthGrid {
                                width: parent.width
                                height: 200
                                month: clock.date.getMonth()
                                year: clock.date.getFullYear()
                                locale: Qt.locale("ja_JP")
                                delegate: Text {
                                    required property var model
                                    text: model.day
                                    color: model.today ? "#89b4fa" : "#cdd6f4"
                                    opacity: model.month === calendarMonth.month ? 1 : 0.3
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                id: calendarMonth
                            }
                        }
                    }
                }
                Row {
                    spacing: 4
                    Repeater {
                        model: SystemTray.items
                        Item {
                            id: trayItem
                            required property var modelData
                            width: 24
                            height: 30
                            Image {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: trayItem.modelData.icon
                            }
                            MouseArea {
                                id: trayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.MiddleButton) trayItem.modelData.secondaryActivate();
                                    else if (mouse.button === Qt.RightButton || trayItem.modelData.onlyMenu) {
                                        if (trayItem.modelData.hasMenu) {
                                            const point = trayItem.mapToItem(bar.contentItem, 0, trayItem.height);
                                            trayItem.modelData.display(bar, point.x, point.y);
                                        }
                                    } else trayItem.modelData.activate();
                                }
                                onWheel: wheel => trayItem.modelData.scroll(wheel.angleDelta.y, false)
                            }
                            ToolTip.visible: trayMouse.containsMouse
                            ToolTip.text: modelData.tooltipTitle || modelData.title
                        }
                    }
                }
                BarText {
                    text: "⏻"
                    color: "#f38ba8"
                    rightPadding: 12
                    tooltip: "電源メニュー"
                    onClicked: if (!powerMenu.running) powerMenu.running = true
                }
            }
        }
    }
}
