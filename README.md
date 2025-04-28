# HPE ProLiant Gen8 Server - GRUB Bootloader Fix

Bilder sind Hier https://github.com/Arduinoeinsteiger/HPEproliantGen8GruubUSBFIX/wiki

## 🚀 Einfache Installation - Schritt für Schritt

### Was Sie brauchen:
- Einen USB-Stick (mindestens 8GB)
- Debian 12 Installationsmedium
- HPE ProLiant Server

### 📋 Installationsanleitung für Anfänger

#### 1. Backup-System auf USB erstellen
1. Stecken Sie den USB-Stick in Ihren Computer
2. Starten Sie den Debian 12 Installer
3. Folgen Sie den Anweisungen auf dem Bildschirm
4. Wählen Sie den USB-Stick als Installationsziel
5. Warten Sie, bis die Installation abgeschlossen ist

#### 2. Hauptsystem auf SATA installieren
1. Starten Sie den Debian 12 Installer erneut
2. Wählen Sie die interne SATA-Platte als Ziel
3. Wichtig: Wählen Sie "Ohne Bootloader installieren"
4. Warten Sie, bis die Installation abgeschlossen ist

#### 3. GRUB-Konfiguration
1. Starten Sie den Server vom USB-Stick
2. Öffnen Sie das Terminal (Tastenkombination: Strg+Alt+T)
3. Kopieren Sie diesen Befehl und drücken Sie Enter:
   ```bash
   sudo ./update_grub_backup.sh
   ```
4. Geben Sie Ihr Passwort ein, wenn Sie dazu aufgefordert werden
5. Bestätigen Sie die Warnung mit 'j'
6. Warten Sie, bis der Vorgang abgeschlossen ist

### 🔍 Was passiert?
- Das Skript erstellt automatisch Backups
- Es findet die SATA-Installation
- Es richtet die Boot-Umleitung ein
- Nach dem Neustart bootet der Server von SATA

### ⚠️ Wichtige Hinweise
- Alle Schritte sind sicher und können rückgängig gemacht werden
- Es werden automatisch Backups erstellt
- Bei Problemen können Sie immer vom USB-Stick booten

### ❓ Hilfe benötigt?
- Schauen Sie in die detaillierte Anleitung: `grub_integration_guide.txt`
- Bei Fragen können Sie ein Issue auf GitHub erstellen

## Lizenz

GNU General Public License v3.0
