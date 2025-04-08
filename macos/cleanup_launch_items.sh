#!/usr/bin/env bash

# A script for cleaning up MacOS launch agents
# Why need a script?
# Because APPs always reinstall these agents after update

# TODO
# add launchctl list check
# add ~/Library/StartupItems /Library/StartupItems check

BACKUP_DIR=~/Desktop/LaunchBackup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR/user" "$BACKUP_DIR/system_agents" "$BACKUP_DIR/system_daemons"

echo "🔍 Scanning for launch items..."

declare -a LOCATIONS=(
    "$HOME/Library/LaunchAgents"
    "/Library/LaunchAgents"
    "/Library/LaunchDaemons"
)

declare -a USER_PLISTS=()
declare -a SYSTEM_PLISTS=()

# Gather .plist files
for loc in "${LOCATIONS[@]}"; do
    if [ -d "$loc" ]; then
        for plist in "$loc"/*.plist; do
            [[ -e "$plist" ]] || continue
            if [[ "$plist" == "$HOME"* ]]; then
                USER_PLISTS+=("$plist")
            else
                SYSTEM_PLISTS+=("$plist")
            fi
        done
    fi
done

# Helper function to check if it's Apple-signed
is_apple_signed() {
    codesign -dv "$1" 2>&1 | grep -qi "Apple" && return 0 || return 1
}

# Ask user whether to nuke all non-Apple items
read -p "⚠️  Do you want to automatically disable ALL non-Apple items? [y/N]: " nuke_all

if [[ "$nuke_all" =~ ^[Yy]$ ]]; then
    echo "🧨 Nuking all non-Apple launch items..."

    for plist in "${USER_PLISTS[@]}" "${SYSTEM_PLISTS[@]}"; do
        [[ -e "$plist" ]] || continue
        exec_path=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:0" "$plist" 2>/dev/null)
        [[ -z "$exec_path" ]] && continue

        if is_apple_signed "$exec_path"; then
            echo "✅ Skipping Apple-signed: $(basename "$plist")"
            continue
        fi

        echo "⛔ Disabling: $(basename "$plist")"

        # Unload
        if [[ "$plist" == "$HOME"* ]]; then
            launchctl bootout gui/$(id -u) "$plist" 2>/dev/null
            mv "$plist" "$BACKUP_DIR/user/"
        else
            sudo launchctl bootout system "$plist" 2>/dev/null
            if [[ "$plist" == *"LaunchAgents"* ]]; then
                sudo mv "$plist" "$BACKUP_DIR/system_agents/"
            else
                sudo mv "$plist" "$BACKUP_DIR/system_daemons/"
            fi
        fi
    done

    echo "✅ All non-Apple items disabled and backed up to $BACKUP_DIR"
    exit 0
fi

# Interactive mode
echo ""
echo "🧩 Interactive Mode: Select launch items to disable"
echo ""

index=1
declare -A INDEX_MAP

for plist in "${USER_PLISTS[@]}" "${SYSTEM_PLISTS[@]}"; do
    echo "$index) $(basename "$plist")"
    INDEX_MAP[$index]="$plist"
    ((index++))
done

read -p "Enter numbers (space-separated) of items to disable, or 'a' for all: " selection

if [[ "$selection" == "a" ]]; then
    selection=$(seq 1 $((index - 1)))
fi

for i in $selection; do
    plist="${INDEX_MAP[$i]}"
    [[ -e "$plist" ]] || continue
    echo "⛔ Disabling: $(basename "$plist")"

    if [[ "$plist" == "$HOME"* ]]; then
        launchctl bootout gui/$(id -u) "$plist" 2>/dev/null
        mv "$plist" "$BACKUP_DIR/user/"
    else
        sudo launchctl bootout system "$plist" 2>/dev/null
        if [[ "$plist" == *"LaunchAgents"* ]]; then
            sudo mv "$plist" "$BACKUP_DIR/system_agents/"
        else
            sudo mv "$plist" "$BACKUP_DIR/system_daemons/"
        fi
    fi
done

echo ""
echo "✅ Selected items disabled and backed up to: $BACKUP_DIR"
