# **Livre Blanc : Projet "Replica 44"**

## **1\. Vision et Philosophie**

**Replica 44** est une architecture d'infrastructure as Code (IaC) holistique, conçue pour déployer des environnements de gestion de médias et de serveurs décentralisés. Le projet repose sur la création de "Pods" conteneurisés, interconnectés via un réseau maillé chiffré de bout en bout (Yggdrasil), et déployables instantanément sur n'importe quel nœud grâce à une approche GitOps stricte.  
La philosophie de Replica 44 s'articule autour de trois piliers :

> * **Résilience par la réplication :** Chaque instance est un clone parfait de l'infrastructure d'origine, récupérable via un simple git pull.  
> * **Automatisation "As a File" :** Les interactions complexes (téléchargements, synchronisation, pare-feu) sont déclenchées par la simple manipulation de fichiers textes ou l'exécution de scripts modulaires.  
> * **Légèreté absolue :** Aucune interface lourde, aucune base de données de synchronisation permanente en RAM. L'intégralité du contrôle s'effectue via un IDE web intégré agissant comme centre de commandement.

## **2\. Déploiement Temporel (Roadmap)**

Le projet Replica 44 se déploie selon une chronologie logique en quatre phases :

### **Phase 1 : Fondation GitOps et Socle Système**

> * Initialisation du dépôt Git hébergeant les configurations Quadlets et les scripts d'installation.  
> * Création des scripts d'amorçage universels (ciblant d'abord Fedora, puis adaptés pour Windows/WSL et macOS).  
> * Mise en place de la gestion des secrets (fichier .env et script de génération de mots de passe aléatoires).  
> * Préparation des arborescences de dossiers sur l'hôte.

### **Phase 2 : Assemblage du Pod Central**

> * Déploiement du fichier .pod définissant l'espace réseau unifié.  
> * Intégration d'Open VS Code Server comme point d'entrée d'administration avec des droits réseau spécifiques.  
> * Intégration des conteneurs de traitement : Transmission (écoute active sur dossier) et Jellyfin (diffusion des médias).

### **Phase 3 : Maillage Réseau et Synchronisation**

> * Déploiement du conteneur Yggdrasil au sein du Pod pour générer le routage IPv6 chiffré.  
> * Écriture des scripts rsync modulaires pour la synchronisation décentralisée à la demande entre les nœuds Replica 44\.

### **Phase 4 : Abstraction et Scalabilité**

> * Automatisation totale : le déploiement d'un nouveau nœud Replica 44 sur un VPS vierge doit s'effectuer en un minimum de temps via une commande d'amorçage unique, incluant la récupération du dépôt et le démarrage des services via systemd.

## **3\. Architecture Technique : Le Pod "Replica 44"**

L'environnement repose sur la technologie Podman en mode rootless. Tous les conteneurs partagent le même espace réseau (*network namespace*) au sein du Pod, ce qui simplifie drastiquement le routage interne et sécurise les flux.

### **Les Composants du Pod**

| Conteneur | Rôle | Spécificités Techniques |
| :---- | :---- | :---- |
| **Open VS Code** | Centre de contrôle (IDE) | Dispose des droits étendus (CAP\_NET\_ADMIN) et monte le socket Podman. Permet l'édition de code, le contrôle du pare-feu (nftables), l'exécution des scripts de synchronisation et la gestion Git depuis un navigateur. |
| **Transmission** | Moteur de téléchargement | Opère "As a File". Surveille le dossier /watch ; lance le téléchargement à l'ajout d'un .torrent, déplace vers /completed et supprime le fichier source. |
| **Jellyfin** | Serveur Multimédia | Isolé en lecture seule sur les dossiers /completed. Indexe et diffuse le contenu sur le réseau. |
| **Yggdrasil** | Bouclier Réseau Maillé | Connecte l'intégralité du Pod au réseau P2P chiffré. Fournit l'IP d'interconnexion (IPv6) pour les commandes de synchronisation inter-VPS. |

### **Arborescence des Dossiers et Fichiers**

L'arborescence doit être stricte, documentée et reproductible.

> * \~/replica44-infra/ (Dépôt Git racine)  
  * .env : Fichier de secrets locaux (généré localement, non suivi par Git).  
  * .env.example : Template des variables requises pour le fonctionnement du Pod.  
  * scripts/  
    * setup/ : Scripts de déploiement (Fedora/Linux, Windows, macOS).  
    * generate\_secrets.sh : Script de génération de mots de passe aléatoires (pour peupler .env si non modifié).  
  * configs/  
    * systemd/ : Fichiers Quadlets (.pod, .container, .network).  
    * firewall/ : Scripts et règles nftables modulaires gérés depuis l'IDE.  
    * sync/ : Scripts rsync pour le transfert vers les autres nœuds.  
  * docs/ : Documentation technique détaillée (Architecture, emplacements, rôles).  
> * \~/replica44-data/ (Volume de données local, **totalement ignoré par Git**)  
  * torrents/watch/ : Dossier de dépôt des fichiers .torrent.  
  * torrents/completed/ : Médias finalisés et scannés par Jellyfin.  
  * ide\_workspace/ : Espace de travail de l'IDE.

## **4\. Directives pour les Agents IA Autonomes (Développement)**

Pour garantir la pérennité, la maintenabilité et l'élégance du projet Replica 44, les agents IA (et humains) chargés de l'écriture du code devront se conformer **strictement** aux règles suivantes :

### **Règle 1 : Contrainte des 100 lignes (Smart & Modular Code)**

> * **Aucun fichier source (script, configuration, Quadlet) ne doit dépasser 100 lignes.**  
> * Si une logique dépasse cette limite, l'agent doit impérativement la scinder en modules réutilisables (ex: un script deploy.sh appelant des sous-scripts comme setup\_network.sh et setup\_volumes.sh).  
> * Cette contrainte force une architecture propre, lisible, et facilite considérablement le débogage.

### **Règle 2 : Agnosticisme Matériel et Système**

> * Les scripts d'amorçage doivent identifier le système hôte.  
> * **Priorité absolue :** L'environnement cible natif et privilégié est **Fedora** (pour son intégration parfaite de Podman et systemd).  
> * **Compatibilité :** Les agents doivent inclure des wrappers ou des instructions pour les environnements macOS et Windows (via WSL2), garantissant que n'importe quelle machine peut devenir un nœud de contrôle ou de stockage.

### **Règle 3 : Documentation Active et Transparente**

> * L'agent IA doit maintenir un fichier README.md exhaustif à la racine du projet, ainsi que des micro-documentations dans chaque sous-dossier (dans le répertoire docs/).  
> * Chaque variable d'environnement, chaque chemin de montage de volume et chaque directive d'un fichier .container doit être explicitée par un commentaire clair et concis dans le code.

### **Règle 4 : Sécurité, Gestion des Secrets et GitOps**

> * **Aucun secret** (mot de passe, clé SSH, configuration réseau spécifique) ne doit être hardcodé dans les fichiers de configuration de moins de 100 lignes ou dans le dépôt Git.  
> * **Le fichier .env est central :** Il doit être placé à la racine du projet (\~/replica44-infra/.env) et strictement ignoré par Git (via .gitignore).  
> * **Génération par défaut :** Un fichier .env.example doit fournir le template. Si un utilisateur déploie le projet sans modifier le .env, un script automatique (generate\_secrets.sh) doit générer des valeurs cryptographiquement sûres pour éviter l'utilisation de mots de passe par défaut vulnérables.