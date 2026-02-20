# Manual de Usuario - AeroClim

Bienvenido a AeroClim, una aplicación dedicada al análisis meteorológico que permite comparar los pronósticos de temperatura actuales con las normales climáticas históricas. También da acceso a información del viento hasta 200m de altitud, además de pronósticos de precipitaciones, sol y nubosidad.

⚠️ Advertencia
Los datos presentados tienen un propósito estrictamente informativo y pueden diferir de las condiciones reales. La información aquí mostrada nunca debe usarse para preparar o tomar decisiones sobre actividades aeronáuticas que involucren presencia humana, como parapente, ala delta, ultraligeros, kitesurf, globos aerostáticos o aviación tripulada.
El autor de la aplicación declina toda responsabilidad por decisiones o incidentes ocurridos derivadas de usar la información mostrada.
---

## 1. Visión General
La interfaz se divide en varias áreas principales:
*   **Barra de Resumen (Superior)**: Muestra la ciudad, estación climática, temperatura actual y dirección del viento a través de la animación (Flecha de ráfagas).
*   **Área de Visualización (Centro)**: Presenta los datos como gráficos o tablas interactivas.
*   **Panel de Control (Lateral o Inferior)**: Permite configurar todos los parámetros.

---

## 2. Gestión de Ubicaciones
La aplicación no incluye ciudades por defecto. Para empezar:
1.  Abra el menú y haga clic en **"Gestionar ciudades"**.
2.  **Añadir por nombre**: Escriba el nombre y selecciónelo de la lista.
3.  **Añadir por coordenadas**: Introduzca la latitud y longitud directamente.
4.  **Establecer ubicación "Inicio"**: En la lista, marque la casilla junto a una ciudad favorita. Aparecerá un botón "Inicio" en el panel.
5.  **Importar/Exportar**: Puede guardar su lista o importarla en formato JSON.

*Nota: La aplicación selecciona la estación climática más cercana automáticamente.*

---

## 3. Modos de Tiempo
Alterne entre tres escalas de tiempo principales:
*   **Diario**: Para pronósticos a largo plazo (10-15 días).
*   **Periodos**: Para ver los pronósticos agrupados por periodos (Noche, Mañana, Tarde, Tarde/Noche).
*   **Por horas**: Para un nivel de detalle hora a hora. 

---

## 4. Tipos de Vista
Cámbielos usando el panel de control:
*   **Gráfico**: Muestra las temperaturas frente a las normales (líneas punteadas).
*   **Viento**: Visualiza velocidades promedio y ráfagas.
*   **Tabla de Viento**: Condiciones por diferentes tramos de altitud de 10m a 200m (mapa de calor por colores).
*   **Comparación**: Compara modelos meteorológicos (ECMWF, GFS, ICON, ARPEGE) a la vez en un gráfico o en tabla interactiva.

---

## 5. Interacción con los Gráficos
*   **Tooltips (Descripciones)**: Toque la zona alta del gráfico/tabla para ver un tooltip. Contiene detalles climáticos y de altitud del viento.
*   **Cierre**: Toque en la zona baja o en un espacio externo al gráfico.
*   **Navegación**: Deslice horizontalmente para retroceder o avanzar en el tiempo (sincronizado entre cabecera y tabla).

---

## 6. Modelos Meteorológicos
Puede elegir el modelo a emplear:
*   **Mejor ajuste**: El algoritmo selecciona el óptimo automáticamente.
*   **ECMWF / GFS**: Modelos globales punteros.
*   **ICON**: Modelo global de Alemania (DWD).
*   **ARPEGE / AROME**: Modelos extremadamente precisos de Météo-France.

---

## 7. Parámetros y Filtros
En el panel puede:
*   Mostrar/Ocultar el viento.
*   Activar el **Viento extendido** (detalles por altitud de 10m a 200m).
*   Filtrar por:
    *   **Ráfagas máx.**: Esconder bajo un límite especificado.
    *   **Precipitaciones**: Esconder bajo probabilidad.
    *   **Temp. aparente mín.**: Filtrar visualmente días gélidos.

---

## 8. Información Técnica
*   **Versión**: Compruebe la información de versión en el panel.
*   **Privacidad**: Sin cookies, rastreadores ni recolecta de datos.
*   **Wasm**: Indica el soporte tecnológico ultrarrápido web.

---

## 9. Legal y Créditos
- **Datos Meteorológicos**: [Open-Meteo.com](https://open-meteo.com/).
- **Datos Climatológicos**: [Deutscher Wetterdienst (DWD)](https://www.dwd.de/).
- **Geolocalización**: Servicio [Photon](https://photon.komoot.io/).
- **Iconografía**: Iconos v4 de Google LLC y Freepik.
- **Licencia**: Licenciado bajo MIT, fuente en GitHub de jean-anton.
