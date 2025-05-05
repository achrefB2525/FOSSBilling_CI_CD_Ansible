#!/bin/bash

# Variables
OS="xUbuntu_22.04"
CRIO_VERSION="1.28"

# Créer le dossier pour les clés
sudo mkdir -p /etc/apt/keyrings

# Ajouter les dépôts avec signature explicite
echo "deb [signed-by=/etc/apt/keyrings/crio.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/crio-stable.list

echo "deb [signed-by=/etc/apt/keyrings/crio.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/crio-version.list

# Télécharger les nouvelles clés GPG
curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/$OS/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/crio.gpg

curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/crio-version.gpg

# Ajouter la clé principale de Kubic
curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubic.gpg

