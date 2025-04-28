#!/bin/bash

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logdatei
LOG_FILE="/var/log/update_grub_backup.log"

# Spracheinstellungen
LANGUAGE="de" # Standard: Deutsch

# Texte für Mehrsprachigkeit
declare -A MESSAGES
MESSAGES["de.warning"]="WARNUNG: Dieses Skript wird die GRUB-Konfiguration ändern."
MESSAGES["de.confirm"]="Möchten Sie fortfahren? (j/n)"
MESSAGES["de.abort"]="Abgebrochen."
MESSAGES["de.not_root"]="Fehler: Dieses Skript muss als root ausgeführt werden"
MESSAGES["de.run_as_root"]="Bitte führen Sie das Skript mit sudo aus:"
MESSAGES["de.creating_backup"]="Erstelle Backup der aktuellen GRUB-Konfiguration..."
MESSAGES["de.sata_search"]="Suche nach SATA-Geräten..."
MESSAGES["de.sata_not_found"]="Keine SATA-Geräte gefunden!"
MESSAGES["de.success"]="GRUB-Konfiguration erfolgreich aktualisiert!"
MESSAGES["de.process_done"]="Prozess abgeschlossen!"
MESSAGES["de.backup_location"]="Backup-Verzeichnis:"

MESSAGES["en.warning"]="WARNING: This script will modify the GRUB configuration."
MESSAGES["en.confirm"]="Do you want to continue? (y/n)"
MESSAGES["en.abort"]="Aborted."
MESSAGES["en.not_root"]="Error: This script must be run as root."
MESSAGES["en.run_as_root"]="Please run the script using sudo:"
MESSAGES["en.creating_backup"]="Creating a backup of the current GRUB configuration..."
MESSAGES["en.sata_search"]="Searching for SATA devices..."
MESSAGES["en.sata_not_found"]="No SATA devices found!"
MESSAGES["en.success"]="GRUB configuration successfully updated!"
MESSAGES["en.process_done"]="Process completed!"
MESSAGES["en.backup_location"]="Backup location:"

# Funktion für Ausgaben
print_message() {
    local key="${LANGUAGE}.$1"
    echo -e "${MESSAGES[$key]}"
    echo "${MESSAGES[$key]}" >> "$LOG_FILE"
}

# Überprüfen, ob wir Root-Rechte haben
if [ "$EUID" -ne 0 ]; then
    print_message "not_root"
    print_message "run_as_root"
    echo "sudo ./update_grub_backup.sh" >> "$LOG_FILE"
    exit 1
fi

# Warnung vor Änderungen
print_message "warning"
read -p "$(print_message confirm) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
    print_message "abort"
    exit 1
fi

# Backup erstellen
print_message "creating_backup"
BACKUP_DIR="/boot/grub_backup"
mkdir -p "$BACKUP_DIR"
cp -r /boot/grub "$BACKUP_DIR/grub_$(date +%Y%m%d_%H%M%S)" 2>>"$LOG_FILE"

# Suche nach SATA-Geräten
print_message "sata_search"
SATA_DEVICES=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'sd[a-z][0-9]' | grep -v '/$')
if [ -z "$SATA_DEVICES" ]; then
    print_message "sata_not_found"
    exit 1
fi

echo "$SATA_DEVICES" >> "$LOG_FILE"

# GRUB-Konfiguration aktualisieren
for DEVICE in $(echo "$SATA_DEVICES" | awk '{print $1}'); do
    MOUNT_POINT="/mnt/$DEVICE"
    mkdir -p "$MOUNT_POINT"
    if mount "/dev/$DEVICE" "$MOUNT_POINT" 2>>"$LOG_FILE"; then
        if [ -f "$MOUNT_POINT/etc/debian_version" ]; then
            grub-mkconfig -o /boot/grub/grub.cfg 2>>"$LOG_FILE"
            SATA_INDEX=$(grep -n "menuentry" /boot/grub/grub.cfg | grep -i "sata" | head -1 | cut -d: -f1)
            if [ -n "$SATA_INDEX" ]; then
                grub-set-default "$SATA_INDEX" 2>>"$LOG_FILE"
            else
                grub-set-default 0 2>>"$LOG_FILE"
            fi
            cp /boot/grub/grub.cfg "$BACKUP_DIR/grub.cfg_$(date +%Y%m%d_%H%M%S)" 2>>"$LOG_FILE"
            print_message "success"
            break
        fi
        umount "$MOUNT_POINT" 2>>"$LOG_FILE"
    fi
done

# Aufräumen
print_message "process_done"
print_message "backup_location"
echo "$BACKUP_DIR"