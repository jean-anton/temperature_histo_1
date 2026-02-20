# Benutzer-Handbuch - AeroClim

Willkommen bei AeroClim, einer Wetter-Analyse-App, die aktuelle Temperaturvorhersagen mit historischen Klimanormalen vergleicht. Zudem erhalten Sie detaillierte Windinfos bis auf 200m Höhe, sowie Niederschlags- und Wolkenvorhersagen.

⚠️ Warnung
Die Daten dienen rein zu Informationszwecken und können von der Realität abweichen. Sie dürfen niemals für die Entscheidungsfindung in luftfahrtbezogenen Aktivitäten (z. B. Gleitschirmfliegen, Heißluftballon, alle Formen personenbesetzter Luftfahrt) genutzt werden. Der Autor übernimmt keine Haftung.
---

## 1. Übersicht
Die Benutzeroberfläche:
*   **Das Summary-Banner (Oben)**: Stadt, Klimastation, aktuelle Temperatur & animierte Windrichtung (Böen-Pfeil).
*   **Das Anzeigefenster (Mitte)**: Zeigt interaktive Grafiken oder Ansichten.
*   **Das Kontrollpanel (Seite/Unten)**: Bietet alle Einstellungen.

---

## 2. Städtemanagement
Fügen Sie zuerst Städte hinzu:
1.  Menü öffnen » **"Städte verwalten"**.
2.  **Mit Namen**: Stadt eingeben und wählen.
3.  **Mit Koordinaten**: Längen-/Breitengrad eintragen.
4.  **Home-Standort**: Mit Häkchen den Home-Standort setzen. Ein "Home" Button taucht in den Einstellungen auf.
5.  **Import/Export**: Sichern oder als JSON einspielen.

*Hinweis: Die App sucht automatisch die passende Basis-Klimastation.*

---

## 3. Zeitraum-Modus
*   **Täglich**: Für die Vorhersage der kommenden 10-15 Tage.
*   **Zeiträume**: Fasst Vorhersagen per Zeitintervall (Nacht, Morgen, Nachmittag, Abend) zusammen.
*   **Stündlich**: Das exakteste Maß für stündliche Details.

---

## 4. Ansichtstypen
*   **Grafik**: Temperaturen im Vergleich zur Normalen (gestrichelte Linie).
*   **Wind**: Mittlerer Wind und Böen.
*   **Wind-Tabelle**: Höhenabhängige Windstärken (10-200m) visuell per Heatmap dargestellt.
*   **Vergleich**: Mehrere Wettermodelle (ECMWF, GFS, ICON, ARPEGE) miteinander in Grafik oder Tabelle vergleichen.

---

## 5. Grafiken bedienen
*   **Tooltips**: Das obere Drittel anklicken, um genaue Infos und Wetter-Icons (bzw. Höhenwinde) einzublenden.
*   **Schließen**: Auf das untere Drittel tippen.
*   **Scrollen**: Horizontales Scrollen bewegt die Zeitachse. Vergleichende Tabellen scrollen synchron.

---

## 6. Wettermodelle
*   **Beste Übereinstimmung**: Optimiere Zusammenführung automatisch.
*   **ECMWF / GFS**: Globale Referenzmodelle.
*   **ICON**: Hochaufgelöstes Modell des DWD.
*   **ARPEGE / AROME**: Spezialisierte Modelle von Météo-France (besonders gut für FR/Nachbarländer).

---

## 7. Einstellungen & Filter
*   Wind anzeigen/ausblenden.
*   **Erweiterte Wind-Infos** aktivieren (10-200m).
*   Spezielle Filter: Böen < Schwellenwert ausblenden, Niederschläge unter X% Wahrscheinlichkeit ausblenden, "Gefühlte Temp. Min." für harte Winter fokussieren.

---

## 8. Privatsphäre & Technik
*   **Version**: Anzeige ganz unten bei den Parametern.
*   Keine Tracker, Cookies oder Sammlungen persönlicher Infos.
*   **Wasm**: AeroClim nutzt neuste Webtechnologien für bestmögliche Performance.

---

## 9. Daten & Lizenzen
- **Wetterdaten**: [Open-Meteo.com](https://open-meteo.com/).
- **Klimadaten**: [CDC/DWD](https://www.dwd.de/).
- **Geolokalisierung**: [Photon](https://photon.komoot.io/).
- **Icons**: Google LLC v4.
- **Quellcode**: [GitHub](https://github.com/jean-anton/aeroclim) via MIT-Lizenz.
