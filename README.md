# Replica 44 - Infrastructure as Code (IaC) Holistique & Décentralisée

**Replica 44** est une architecture d'Infrastructure as Code (IaC) modulaire, résiliente et décentralisée. Conçue pour être déployée instantanément sur n'importe quel VPS ou ordinateur hôte (Fedora/Linux, WSL2, macOS), elle orchestre un Pod unifié de 5 conteneurs interconnectés via **Podman Quadlets** sous **systemd**.

---

## 🌟 Caractéristiques Principales

- **Déploiement One-Liner** : Une seule commande bash pour amorcer et démarrer tout le socle sur un serveur vierge.
- **Port d'Entrée & Reverse Proxy HTTPS Unique** : Point d'accès chiffré par défaut (`https://localhost:4000`) avec certificat SSL auto-généré et redirection HTTP (80/4000) vers HTTPS automatique sans interruption.
- **Support Hybride Domaines et Sous-domaines (`SERVER_DOMAIN`)** : Accès au choix par sous-dossiers (`/jellyfin/`, `/transmission/web/`, `/vscode/`) ou par sous-domaines (`jellyfin.votre-domaine.com`, `transmission.votre-domaine.com`, `vscode.votre-domaine.com`).
- **Séparation Stricte & Agnosticisme des Répertoires** :
  - **Dossier Technique (`replica44-infra`)** : Totalement déplaçable n'importe où dans l'espace utilisateur. Auto-détecté sans chemin codé en dur.
  - **Dossier de Données (`REPLICA44_DATA_DIR`)** : Configurables dans le `.env` pour déporter les médias lourds et les configurations sur n'importe quel disque.
- **Accès Administrateur Intégral Open VS Code** : Le conteneur VS Code monte à la fois le code source technique (`/home/coder/project`) et les données/médias (`/home/coder/replica44-data`) avec permissions administrateur complètes (`podman unshare`).
- **Synchronisation Inter-VPS Yggdrasil 1-Clic Sécurisée** :
  - Déverrouillage sécurisé par mot de passe Gateway depuis le Dashboard.
  - Nettoyage et validation automatique du format IPv6 Yggdrasil (support des formats `201:db8::1`, `tcp://200:...:12345`).
  - Déclenchement automatique de la synchronisation `rsync` sans saisie de ligne de commande.
  - Gestion d'erreur et retours visuels (Connexion/Timeout/Hors-ligne).
- **Principe "As a File" & Seeding Continu** : Dépôt automatique `.torrent` dans `/watch`, téléchargement dans `.incomplete` puis passage dans `/completed` pour du streaming Jellyfin et du seeding Transmission simultanés.

---

## 🚀 Démarrage Rapide

### Option A : Installateur One-Liner (VPS Vierge)
```bash
curl -fsSL https://raw.githubusercontent.com/replica44/replica44-infra/main/install.sh | bash
```

### Option B : Déploiement Manuel Local
```bash
# 1. Amorçage de l'instance (.env, secrets, arborescence & certificats SSL)
./bootstrap.sh

# 2. Déploiement des Quadlets systemd
./scripts/deploy_quadlets.sh

# 3. Démarrage du Pod systemd (remplacer 4000 par le port attribué si différent)
systemctl --user start replica44-pod-4000-pod

# 4. Diagnostic de santé
./scripts/healthcheck.sh
```

---

## 🌐 Accès aux Services & URLs

Toutes les interfaces sont centralisées derrière le **Reverse Proxy HTTPS** sur le port principal (ex: `4000`) ou via vos sous-domaines :

- ⚡ **Dashboard Gateway** : `https://localhost:4000/`
- 🎬 **Jellyfin (Streaming)** : `https://localhost:4000/jellyfin/` ou `https://jellyfin.votre-domaine.com:4000/`
- ⚡ **Transmission (Downloads)** : `https://localhost:4000/transmission/web/` ou `https://transmission.votre-domaine.com:4000/`
- 🛠️ **Open VS Code (IDE & Admin)** : `https://localhost:4000/vscode/` ou `https://vscode.votre-domaine.com:4000/`

---

## 📁 Structure du Dépôt

```text
├── install.sh                  # Installateur One-Liner universel
├── bootstrap.sh                # Script d'amorçage principal (Idempotent)
├── reset.sh                    # Réinitialisation config (Conserve tous les médias)
├── uninstall.sh                # Désinstallation complète
├── TUTORIEL_UTILISATEUR.txt    # Guide vulgarisé pas-à-pas pour les débutants
├── .env.example                # Template des variables et secrets
├── scripts/
│   ├── generate_secrets.sh     # Générateur automatique de mots de passe & ports
│   ├── deploy_quadlets.sh      # Instanciation & reload des Quadlets systemd
│   ├── healthcheck.sh          # Outil de diagnostic et santé du Pod
│   ├── check_disk.sh           # Surveillance de l'espace disque (Seuil 80%)
│   ├── watch_transmission.sh   # Traitement automatique "As a File"
│   ├── yggdrasil_info.sh       # Extracteur d'IP IPv6 Yggdrasil
│   └── setup/
│       ├── detect_os.sh        # Détection OS hôte (Fedora, Linux, WSL, macOS)
│       ├── find_free_port_block.sh # Détection de tranches de 10 ports libres
│       ├── install_fedora.sh   # Installation Podman, rsync & activation socket utilisateur
│       ├── setup_dirs.sh       # Arborescence et pré-configurations conteneurs
│       └── setup_ssl.sh        # Générateur TLS/SSL auto-signé & htpasswd
├── configs/
│   ├── systemd/                # Fichiers Quadlet (.pod, .container)
│   ├── gateway/                # Reverse Proxy Nginx (Support WebSocket/Subdomain), HTML & Certificats
│   ├── jellyfin/               # Configuration pré-injectée Jellyfin
│   ├── transmission/           # Configuration pré-injectée Transmission (Seeding illimité)
│   ├── firewall/               # Script nftables dédié (Zero-impact hôte)
│   └── sync/                   # Script rsync d'interconnexion Yggdrasil (Contrôle d'IP & auto-install)
└── docs/                       # Documentation technique approfondie
    └── architecture.md
```

---

## 🛠️ Sécurité & Administration

### 1. Sécurité et Mots de Passe
- Le fichier `.env` génère des mots de passe forts cryptographiquement pour `GATEWAY_PASSWORD`, `VSCODE_PASSWORD` et `TRANSMISSION_PASSWORD`.
- L'authentification HTTP Basic protège la fonction de synchronisation inter-VPS.

### 2. Emplacement Personnalisé des Médias
Éditez la variable `REPLICA44_MEDIA_DIR` et `REPLICA44_DATA_DIR` dans le fichier `.env` pour pointer vers un disque externe ou un dossier dédié.

### 3. Remplacer le Certificat SSL Auto-signé
Remplacez les deux fichiers `replica44.crt` et `replica44.key` dans `~/replica44-data-4000/config/gateway/certs/` par vos propres clés SSL (Let's Encrypt / Certbot).

---

## 📖 Documentation Détaillée

Consultez la [Documentation de l'Architecture Technique](docs/architecture.md) et le [Guide Utilisateur Pas-à-Pas](TUTORIEL_UTILISATEUR.txt).
