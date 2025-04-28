#!/bin/bash

# Skript zur Aktualisierung der GRUB-Konfiguration für das Hauptsystem auf SATA
# Dieses Skript findet die SATA-Installation und setzt sie als Standard-Boot-Option

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starte GRUB Hauptsystem Konfiguration...${NC}"

# Überprüfen, ob wir Root-Rechte haben
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Fehler: Dieses Skript muss als root ausgeführt werden${NC}"
    echo -e "${YELLOW}Bitte führen Sie das Skript mit sudo aus:${NC}"
    echo -e "sudo ./update_grub_backup.sh"
    exit 1
fi

# Warnung vor Änderungen
echo -e "${YELLOW}WARNUNG:${NC} Dieses Skript wird die GRUB-Konfiguration ändern."
echo -e "${YELLOW}WARNUNG:${NC} Es wird ein Backup erstellt, aber seien Sie vorsichtig."
read -p "Möchten Sie fortfahren? (j/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Jj]$ ]]; then
    echo -e "${RED}Abgebrochen.${NC}"
    exit 1
fi

# Temporäres Verzeichnis erstellen
TEMP_DIR=$(mktemp -d)
BACKUP_DIR="/boot/grub_backup"
mkdir -p "$BACKUP_DIR"

# Backup der aktuellen GRUB-Konfiguration
echo -e "${YELLOW}Erstelle Backup der aktuellen GRUB-Konfiguration...${NC}"
cp -r /boot/grub "$BACKUP_DIR/grub_$(date +%Y%m%d_%H%M%S)"

# Suche nach SATA-Geräten
echo -e "${YELLOW}Suche nach SATA-Geräten...${NC}"
SATA_DEVICES=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'sd[a-z][0-9]' | grep -v '/$')

if [ -z "$SATA_DEVICES" ]; then
    echo -e "${RED}Keine SATA-Geräte gefunden!${NC}"
    exit 1
fi

echo -e "${GREEN}Gefundene SATA-Geräte:${NC}"
echo "$SATA_DEVICES"

# Suche nach Debian-Installationen auf SATA
echo -e "${YELLOW}Suche nach Debian-Installationen...${NC}"
for DEVICE in $(echo "$SATA_DEVICES" | awk '{print $1}'); do
    MOUNT_POINT="/mnt/$DEVICE"
    mkdir -p "$MOUNT_POINT"
    
    if mount "/dev/$DEVICE" "$MOUNT_POINT" 2>/dev/null; then
        if [ -f "$MOUNT_POINT/etc/debian_version" ]; then
            echo -e "${GREEN}Debian-Installation gefunden auf /dev/$DEVICE${NC}"
            
            # GRUB-Konfiguration aktualisieren
            echo -e "${YELLOW}Aktualisiere GRUB-Konfiguration...${NC}"
            grub-mkconfig -o /boot/grub/grub.cfg
            
            # Setze Standard-Boot auf SATA-System
            echo -e "${YELLOW}Setze Standard-Boot auf SATA-System...${NC}"
            # Finde den Index der SATA-Installation in der GRUB-Konfiguration
            SATA_INDEX=$(grep -n "menuentry" /boot/grub/grub.cfg | grep -i "sata" | head -1 | cut -d: -f1)
            if [ -n "$SATA_INDEX" ]; then
                grub-set-default "$SATA_INDEX"
            else
                # Wenn kein spezifischer SATA-Eintrag gefunden wurde, setze den ersten Eintrag
                grub-set-default 0
            fi
            
            # Erstelle Backup der neuen Konfiguration
            cp /boot/grub/grub.cfg "$BACKUP_DIR/grub.cfg_$(date +%Y%m%d_%H%M%S)"
            
            echo -e "${GREEN}GRUB-Konfiguration erfolgreich aktualisiert!${NC}"
            break
        fi
        umount "$MOUNT_POINT"
    fi
done

# Aufräumen
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Prozess abgeschlossen!${NC}"
echo -e "${YELLOW}Hinweis:${NC} Das System wird beim nächsten Neustart von SATA booten."
echo -e "${YELLOW}Backup-Verzeichnis:${NC} $BACKUP_DIR" 