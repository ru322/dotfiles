# Claude Code notification script
# Reads JSON from stdin and shows Windows toast notification via BurntToast

$input_text = [Console]::In.ReadToEnd()

try {
    $json = $input_text | ConvertFrom-Json
} catch {
    exit 0
}

$type = $json.notification_type

if ($type -eq "idle_prompt") {
    $title = "Claude Code"
    $message = "作業が完了しました"
} elseif ($type -eq "permission_prompt") {
    $title = "Claude Code"
    $message = "権限の許可が必要です"
} else {
    exit 0
}

New-BurntToastNotification -Text $title, $message -Silent
