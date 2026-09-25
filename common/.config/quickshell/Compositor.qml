import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root
    readonly property bool isNiri: Quickshell.env("NIRI_SOCKET") !== ""
    property var workspaces: []
    property var windows: []

    function forOutput(name) {
        if (isNiri)
            return workspaces.filter(w => w.output === name).sort((a, b) => a.idx - b.idx);
        return Hyprland.workspaces.values.filter(w => w.monitor && w.monitor.name === name && w.id > 0)
            .sort((a, b) => a.id - b.id);
    }

    function active(workspace) {
        return isNiri ? workspace.is_active : workspace.active;
    }

    function titleForOutput(name) {
        if (!isNiri) {
            const monitor = Hyprland.monitors.values.find(m => m.name === name);
            return monitor && monitor.activeWorkspace && monitor.activeWorkspace.lastIpcObject
                ? (monitor.activeWorkspace.lastIpcObject.lastwindowtitle || "") : "";
        }
        const workspace = workspaces.find(w => w.output === name && w.is_active);
        const window = workspace ? windows.find(w => w.id === workspace.active_window_id) : null;
        return window ? (window.title || "") : "";
    }

    function focus(workspace) {
        if (isNiri)
            Quickshell.execDetached(["python3", Quickshell.shellPath("focus-workspace.py"), String(workspace.id)]);
        else
            workspace.activate();
    }

    Connections {
        target: Hyprland
        enabled: !root.isNiri
        function onRawEvent(event) {
            if (event.name === "activewindow" || event.name === "windowtitle")
                Hyprland.refreshWorkspaces();
        }
    }

    function event(event) {
        if (event.WorkspacesChanged) {
            workspaces = event.WorkspacesChanged.workspaces;
        } else if (event.WorkspaceActivated) {
            const change = event.WorkspaceActivated;
            const target = workspaces.find(w => w.id === change.id);
            workspaces = workspaces.map(w => Object.assign({}, w, {
                is_active: target && w.output === target.output ? w.id === change.id : w.is_active,
                is_focused: change.focused ? w.id === change.id : w.is_focused
            }));
        } else if (event.WorkspaceActiveWindowChanged) {
            const change = event.WorkspaceActiveWindowChanged;
            workspaces = workspaces.map(w => w.id === change.workspace_id
                ? Object.assign({}, w, {active_window_id: change.active_window_id}) : w);
        } else if (event.WindowsChanged) {
            windows = event.WindowsChanged.windows;
        } else if (event.WindowOpenedOrChanged) {
            const window = event.WindowOpenedOrChanged.window;
            windows = windows.filter(w => w.id !== window.id).concat([window]);
        } else if (event.WindowClosed) {
            windows = windows.filter(w => w.id !== event.WindowClosed.id);
        }
    }

    Process {
        id: events
        command: ["niri", "msg", "--json", "event-stream"]
        running: root.isNiri
        stdout: SplitParser {
            onRead: data => {
                try { root.event(JSON.parse(data)); }
                catch (error) { console.warn("niri event:", error); }
            }
        }
        onRunningChanged: if (!running && root.isNiri) reconnect.restart()
    }
    Timer {
        id: reconnect
        interval: 2000
        onTriggered: events.running = true
    }
}
