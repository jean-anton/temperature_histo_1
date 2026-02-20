# User Manual - AeroClim

Welcome to AeroClim, an application dedicated to meteorological analysis, allowing you to compare current temperature forecasts to historical climate normals. It also provides access to wind information up to 200m altitude, as well as forecasts for precipitation, sunshine, and cloud cover.

⚠️ Disclaimer
The data presented is provided strictly for informational purposes and may differ from actual conditions. The displayed information must never be used for the preparation or decision-making regarding aeronautical activities involving human presence, such as paragliding, hang gliding, microlights, kitesurfing, hot air ballooning, or any form of manned aviation.
The author of the application declines all responsibility for decisions made or incidents occurring as a result of using the displayed information.
---

## 1. Overview
The interface is divided into several main areas:
*   **Summary Banner (Top)**: Displays the selected city, reference climate station, current temperature, and wind direction via the animated gauge (Gust Arrow Widget).
*   **Display Area (Center)**: Presents data in the form of graphs or interactive tables.
*   **Control Panel (Side or Bottom)**: Allows you to configure all application settings.

---

## 2. Location Management
The application contains no default cities. To begin:
1.  Open the menu and click on **"Manage Cities"**.
2.  **Add by name**: Type a city name and select it from the list.
3.  **Add by coordinates**: Enter the latitude and longitude directly.
4.  **Set "Home" location**: In the list, check the box next to a city to set it as your favorite. A "Home" button will appear in the control panel for quick access.
5.  **Import/Export**: You can save your city list or import one in JSON format via the dedicated buttons.

*Note: The app automatically selects the closest climate station to your location to ensure relevant comparisons.*

---

## 3. Time Modes
Switch between three main time scales:
*   **Daily**: For long-term vision (10-15 day forecasts).
*   **Periods**: To view aggregated forecasts (Night, Morning, Afternoon, Evening) over several days.
*   **Hourly**: For precise hour-by-hour detail. The graph starts at "Current time - 1h" to see immediate changes.

---

## 4. Display Types
Use the selector in the control panel to change views:
*   **Graph**: Displays forecasted temperatures overlaid with normals (dashed lines).
*   **Wind**: Visualizes average wind speed and gusts.
*   **Wind Table**: Shows wind conditions by altitude steps, from 10m up to 200m, with color coding (heatmap) for quick intensity identification.
*   **Comparison**: Compares multiple weather models (ECMWF, GFS, ICON, ARPEGE) simultaneously on the same graph or in a detailed comparative table.

---

## 5. Interacting with Graphs
*   **Tooltips**: Press in the top 2/3 of a graph or table to open a detailed tooltip. It displays exact temperatures, wind by altitude, humidity, weather icons, and additional info.
*   **Closing**: To close a tooltip, press in the bottom 1/3 of the graph or anywhere outside the graph.
*   **Navigation**: Scroll horizontally to navigate through time. The comparative table also supports synchronized header scrolling.

---

## 6. Weather Models
You can choose the calculation model:
*   **Best Match**: The automatically calculated optimal compromise.
*   **ECMWF / GFS**: Core global reference models (including updated ECMWF IFS HRES).
*   **ICON**: German DWD global reference model.
*   **ARPEGE / AROME**: High-precision models from Météo-France (particularly accurate for France).

---

## 7. Settings and Filters
In the control panel, you can:
*   Enable/Disable wind information.
*   Show **Extended Wind** (details by altitude from 10 to 200m).
*   Filter data by:
    *   **Max Gusts**: Hide values below a threshold (e.g. < 30 km/h).
    *   **Precipitation**: Hide low probabilities.
    *   **Min Apparent Temp**: Limit view based on cold levels.

---

## 8. Technical Information
*   **Version**: Check the version number at the bottom of the menu.
*   **Privacy**: This application respects your privacy. No cookies or trackers are used, and no personal data is collected.
*   **Wasm**: The "Wasm" indicator confirms the app uses the latest web performance technologies.

---

## 9. Legal & Credits
- **Meteorological Data**: Provided by [Open-Meteo.com](https://open-meteo.com/) (CC BY 4.0 License).
- **Climate Data**: Source: [Deutscher Wetterdienst (DWD)](https://www.dwd.de/). Long-term average data (1961-1990) from CDC (Climate Data Center).
- **Geolocation & Search**: [Photon](https://photon.komoot.io/) service using data from © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright) (ODbL License).
- **Icons**: 
    - "v4" Icons: Google LLC Assets (unaffiliated).
    - "le-rechauffement-climatique.png" illustration: Created by [Freepik - Flaticon](https://www.flaticon.com/).
- **Typography**: Google Fonts (OFL / Apache 2.0).
- **Software License**: Distributed under MIT license.
- **Source Code**: [GitHub Repository](https://github.com/jean-anton/aeroclim)
