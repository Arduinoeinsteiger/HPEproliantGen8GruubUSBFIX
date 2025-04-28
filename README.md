   ________________________________________________________
  /                                                        \
 |    HPE ProLiant Gen8 Server - GRUB Bootloader Fix       |
 |    ==============================================       |
 |                                                         |
 |    +------------------------------------------------+   |
 |    |                                                |   |
 |    |    ████████████████████████████████████████    |   |
 |    |    ██                                    ██    |   |
 |    |    ██  ████  ████  ████  ████  ████  ██  ██    |   |
 |    |    ██  ████  ████  ████  ████  ████  ██  ██    |   |
 |    |    ██                                    ██    |   |
 |    |    ████████████████████████████████████████    |   |
 |    |                                                |   |
 |    |    [USB]  [SATA]  [NETWORK]  [POWER]          |   |
 |    |                                                |   |
 |    +------------------------------------------------+   |
 |                                                         |
 |    Debian 12 Bootloader Fix für USB/SATA Boot          |
 |                                                         |
 \________________________________________________________/
        \___________________________________/
                 \___________________/
                      \________/
                         \__/
                          ||
                          ||
                          ||
                         \||/
                          \/

# HPE ProLiant Gen8 Server - GRUB Bootloader Fix

Dieses Projekt enthält Skripte und Konfigurationen zur Behebung von Boot-Problemen auf HPE ProLiant Servern, insbesondere für das Booten von SATA-Laufwerken.

## Funktionen

- Automatische Erkennung von SATA-Installationen
- GRUB-Konfigurationsupdate
- Backup-System auf USB
- Debian 12 Kompatibilität

## Installation

Folgen Sie der Anleitung in `grub_integration_guide.txt` für die detaillierte Installationsprozedur.

## Sicherheit

- Alle Skripte müssen mit Root-Rechten ausgeführt werden
- Automatische Backup-Erstellung
- Bestätigungsaufforderung vor Änderungen

## Lizenz

GNU General Public License v3.0
