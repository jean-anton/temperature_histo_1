# Manuel d'Utilisateur - Température Histo

Bienvenue dans Température Histo, une application dédiée à l’analyse météorologique, permettant de comparer les de température prévisions actuelles aux normales climatiques historiques. Elle permet également d’accéder à des informations sur le vent jusqu’à 200 m d’altitude ainsi qu’aux prévisions de précipitations, d'ensoleillement et de couverture nuageuse.

⚠️ Avertissement
Les données présentées sont fournies à titre strictement informatif et peuvent différer des conditions réelles. Les informations affichées ne doivent jamais être utilisées pour la préparation ou la prise de décision concernant des activités aéronautiques avec présence humaine, telles que le parapente, le deltaplane, l’ULM, le kite, la montgolfière ou toute forme d’aviation habitée..
L’auteur de l’application décline toute responsabilité quant aux décisions prises ou aux incidents survenus à la suite de l’utilisation des informations affichées.
---

## 1. Vue d'Ensemble
L'interface est divisée en deux zones principales :
*   **Le Bandeau de Résumé (Haut)** : Affiche la ville sélectionnée, la station climatique de référence, la température actuelle et un résumé de la journée.
*   **La Zone d'Affichage (Centre)** : Présente les données sous forme de graphiques ou de tableaux interactifs.
*   **Le Panneau de Contrôle (Côté ou Bas)** : Permet de configurer tous les paramètres de l'application.

---

## 2. Gestion des Lieux
L'application ne contient aucune ville par défaut. Pour commencer :
1.  Ouvrez le menu et cliquez sur **"Gérer les villes"**.
2.  **Ajout par nom** : Tapez le nom d'une ville et sélectionnez-la dans la liste.
3.  **Ajout par coordonnées** : Saisissez la latitude et la longitude directement.
4.  **Import/Export** : Vous pouvez sauvegarder votre liste de villes ou en importer une au format JSON via les boutons dédiés.

*Note : L'application sélectionne automatiquement la station climatique la plus proche de votre lieu pour garantir la pertinence des comparaisons.*

---

## 3. Modes Temporels
Basculez entre deux échelles de temps :
*   **Journalier** : Pour une vision à long terme (prévisions sur 10-15 jours).
*   **Horaire** : Pour un détail précis heure par heure. Le graphique démarre à "Heure actuelle - 1h" pour voir l'évolution immédiate.

---

## 4. Types d'Affichage
Utilisez le sélecteur dans le panneau de contrôle pour changer de vue :
*   **Graphique** : Affiche les températures prévues superposées aux normales (lignes en pointillés).
*   **Vent** : Visualise la vitesse moyenne du vent et les rafales.
*   **Table Vent** : Présente les conditions de vent par paliers d'altitude (utile pour les activités sensibles au vent).
*   **Comparatif** : Compare simultanément plusieurs modèles météo (ECMWF, GFS, ICON, ARPEGE) sur le même graphique.

---

## 5. Interaction avec les Graphiques
*   **Infobulles (Tooltips)** : Appuyez dans les **2/3 supérieurs** d'un graphique pour ouvrir une infobulle détaillée. Elle affiche les températures exactes, le vent, l'humidité et les icônes météo.
*   **Fermeture** : Pour fermer une infobulle, appuyez dans le **1/3 inférieur** du graphique ou n'importe où en dehors du graphique.
*   **Navigation** : Faites défiler horizontalement pour naviguer dans le temps.

---

## 6. Modèles Météo
Vous pouvez choisir le modèle de calcul :
*   **Best Match** : Le meilleur compromis calculé automatiquement.
*   **ECMWF / GFS** : Modèles globaux de référence.
*   **ARPEGE / AROME** : Modèles haute précision de Météo-France (particulièrement précis pour la France).

---

## 7. Paramètres et Filtres
Dans le panneau de contrôle, vous pouvez :
*   Activer/Désactiver les informations de vent.
*   Afficher le **Vent étendu** (détails par altitude).
*   Filtrer les données pour n'afficher que les rafales dépassant un certain seuil (ex: > 30 km/h) ou les probabilités de précipitations significatives.

---

## 8. Informations Techniques
*   **Version** : Consultez le numéro de version en bas du menu.
*   **Confidentialité** : Cette application respecte votre vie privée. Aucun cookie ni tracker n'est utilisé, et aucune donnée personnelle n'est collectée.
*   **Wasm** : L'indicateur "Wasm: true" confirme que l'application utilise les dernières technologies de performance Web.

---
 
 ## 9. Mentions Légales & Crédits
- **Données Météorologiques** : Fournies par [Open-Meteo.com](https://open-meteo.com/) (Licence CC BY 4.0).
- **Données Climatologiques** : Source : [Deutscher Wetterdienst (DWD)](https://www.dwd.de/). Données de moyennes pluriannuelles (1961-1990) issues du CDC (Climate Data Center).
- **Géolocalisation & Recherche** : Service [Photon](https://photon.komoot.io/) utilisant les données d'© [OpenStreetMap contributors](https://www.openstreetmap.org/copyright) (Licence ODbL).
- **Iconographies** : 
    - Icônes "v3/v4" : Ressources Google LLC (non affilié).
    - Illustration "le-rechauffement-climatique.png" : Créée par [Freepik - Flaticon](https://www.flaticon.com/).
- **Typographies** : Polices Google Fonts (OFL / Apache 2.0).
- **Licence Logicielle** : Cette application est distribuée sous licence MIT.
- **Contact** : [jeananton@gmail.com](mailto:jeananton@gmail.com).

---
*Développé avec soin pour une analyse météo précise et intuitive.*


