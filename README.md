![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)

# Portfolio AWS – Infrastructure as Code avec Terraform

##  Introduction

Ce projet m’a permis de découvrir concrètement les principaux services AWS à travers un cas d’usage réel et utile : héberger mon propre portfolio.
J’ai choisi de commencer par la console AWS, afin de comprendre chaque service individuellement (S3, CloudFront, ACM, Lambda, API Gateway, DynamoDB).
Cette première approche manuelle m’a aidée à visualiser le fonctionnement global de l’infrastructure et à consolider mes bases sur le cloud public.

Une fois les principes maîtrisés, j’ai refactorisé l’intégralité du projet en Infrastructure as Code (Terraform) pour bénéficier de l’automatisation, de la reproductibilité, du versioning, et de la rigueur d’un workflow professionnel.

Le projet utilise un nom de domaine personnalisé acheté sur OVHCloud, relié à AWS pour le HTTPS.
Cette étape m’a donné l’occasion de comprendre la gestion des zones DNS, les redirections et la validation de certificats SSL avec ACM et CloudFront — une partie qui m’a beaucoup challengée, surtout pour faire fonctionner https://zenabamogne.fr et https://www.zenabamogne.fr en parallèle.

Au-delà d’AWS et Terraform, ce projet m’a aussi permis de :

- créer moi-même le frontend en HTML/CSS,
- expérimenter l’intégration d’un compteur de visites dynamique via une architecture serverless (Lambda + API Gateway + DynamoDB),
- d'approfondir ma compréhension de la sécurité cloud (OAC, chiffrement, IAM, budget).

En résumé, ce projet m’a permis de transformer mes connaissances théoriques en une réalisation concrète, fonctionnelle et personnelle, tout en posant les bases d’une infrastructure moderne et évolutive.

## ⚙️ Stack technique

- **Terraform** (backend S3 + DynamoDB pour state/lock)
- **AWS S3** privé (site statique)
- **AWS CloudFront + ACM** (us-east-1) (CDN + TLS)
- **AWS Lambda + API Gateway + DynamoDB** (compteur de visites serverless)
- **AWS Budget** (alertes coûts)
- **OVH DNS** (nom de domaine personnalisé)

## 📂 Arborescence du projet

```
.
├── Architecture_Decision_Record.md
├── deploy-static-site.json
├── infra
│   ├── backend.tf
│   ├── budget.tf
│   ├── environments/
│   │   └── dev.tfvars
│   ├── lambda/
│   │   ├── build.zip
│   │   └── visit/
│   │       ├── handler.py
│   │       └── tests/
│   │           └── test_handler.py
│   ├── main.tf
│   ├── modules/
│   │   ├── bootstrap-backend/
│   │   ├── static-site/
│   │   └── visit-api/
│   ├── outputs.tf
│   ├── providers.tf
│   ├── public/
│   │   ├── CV_2025_MOGNE_ZENABA.pdf
│   │   ├── index.html
│   │   └── style.css
│   ├── terraform-backend.json
│   ├── variables.tf
│   └── versions.tf
└── README.md
```

J'ai dans un premier temps commencé par une structure simple et monolithique pour comprendre les bases de Terraform.
Les concepts augmentant, j'ai découpé l'architecture en modules distincts afin de bénéficier des avantages suivants :

Avantages de l'approche modulaire :

- Réutilisabilité : Chaque module peut être réutilisé dans différents projets ou environnements
- Séparation des responsabilités : Chaque module a une fonction précise et autonome
Maintenance simplifiée : Les modifications sont isolées et n'affectent pas l'ensemble du système
-Collaboration facilitée : Plusieurs personnes peuvent travailler sur différents modules simultanément sans conflits
-Testabilité : Chaque module peut être testé indépendamment avant intégration

Les différents modules communiquent entre eux via les outputs et variables:

```
# Déclaration d'un output dans un module
output "acm_arn" {
  value = aws_acm_certificate.site_cert.arn
}

# Utilisation dans la configuration racine
module "static_site" {
  source = "./modules/static-site"
  domain_root = var.domain_root
}

# Réutilisation de l'output dans d'autres modules ou outputs
output "certificat_ssl" {
  value = module.static_site.acm_arn
}
```

Cette architecture modulaire permet une gestion évolutive de l'infrastructure et une meilleure organisation du code Terraform, 
tout en facilitant la collaboration et la maintenance à long terme.

## Architecture du projet


![Architecture AWS](Schema/architecture.png)

CloudFront délivre le site depuis **S3 privé via OAC** (pas d'accès public direct au bucket).
L'infrastructure utilise stratégiquement deux régions AWS pour optimiser les performances et respecter les contraintes techniques.

## 🔄 Flux des Requêtes

![Flux des requêtes](Schema/flux_rqt.png)

Parcours d'une requête : 
Le contenu statique est servi via le CDN CloudFront depuis S3, tandis que les données dynamiques du compteur de visites transitent par une API serverless (Lambda + DynamoDB) avant de s'afficher sur la page. Cette architecture assure une performance globale grâce à une séparation claire entre la couche de présentation et le traitement des données.*


##  Workflow Terraform

### Étapes principales

```bash
terraform init           # Initialiser
terraform validate       # Vérifier la syntaxe
terraform fmt -recursive # Mise en forme
terraform plan           # Prévisualiser les changements
terraform apply          # Appliquer les changements
```

### Naming convention

```
<prefix>-<project>-<env>-<type>
```
Exemple : `zenaba-portfolio-dev-tfstate`

##  Gestion du state

- **S3** : stockage centralisé avec versioning + encryption AES256
- **DynamoDB** : table de lock pour éviter les apply concurrents
- **Avantages** : collaboration, rollback, sécurité

## 🌐 Déploiement du site statique

- **Bucket S3 privé** (aucun accès public)
- **CloudFront + OAC** (Origin Access Control) → seul CloudFront accède au bucket
- **Certificat ACM** en us-east-1 pour HTTPS
- **Redirection DNS OVH** (CNAME → CloudFront)

### Commandes utiles :

```bash
aws s3 sync ./public s3://$SITE_BUCKET --delete
aws cloudfront create-invalidation --distribution-id $CF_ID --paths "/*"
```

##  Compteur de visites

- **Lambda** (Python) → incrémente la valeur
- **DynamoDB** → stocke le compteur
- **API Gateway** → expose /visit
- **Frontend** → fetch de l'endpoint → affichage en temps réel

## Résultat ?

Un site hébergé sur AWS accessible à ces adresses :  
- [http://zenabamogne.fr](http://zenabamogne.fr)  
- [www.zenabamogne.fr](https://www.zenabamogne.fr)  
- [https://www.zenabamogne.fr](https://www.zenabamogne.fr)
- [zenabamogne.fr](http://zenabamogne.fr) 

![Site déployé](Schema/site.png)

## Problème rencontré & résolution (ACM/CloudFront)

**Problématique.** L’ajout de l’alias `zenabamogne.fr` dans CloudFront échouait avec comme message d'erreur :
> “The certificate that is attached to your distribution doesn't cover the alternate domain name (CNAME)…”

**Cause racine.**
- Le certificat ACM initial ne couvrait que `www.zenabamogne.fr`.
- La distribution CloudFront n’avait que `www.zenabamogne.fr` en alias.
- Rappel important : **CloudFront exige un certificat ACM en `us-east-1`** couvrant **tous** les noms ajoutés dans `aliases`.

**Correctif mis en place.**
1. Création d’un **nouveau certificat ACM** en `us-east-1` pour **`zenabamogne.fr` + `*.zenabamogne.fr`** (Terraform, provider alias `aws.use1`).
2. Exposition des **CNAMEs de validation** via les outputs Terraform ➜ ajout des CNAMEs dans **OVH DNS** ➜ état **`ISSUED`**.
3. Mise à jour de **CloudFront** :
   - `aliases = ["zenabamogne.fr", "www.zenabamogne.fr"]`
   - `viewer_certificate.acm_certificate_arn = <nouvel ARN ACM>`
4. DNS :
   - `www` ➜ **CNAME** vers la distrib CloudFront
   - **apex** `zenabamogne.fr` ➜ **redirection 301 visible** OVH vers `https://www.zenabamogne.fr` (limitation CNAME sur l’apex).


## 💬 FAQ Technique & Retour d’expérience

### Pourquoi avoir d’abord tout fait via la console AWS ?
Pour comprendre concrètement le rôle de chaque service.
Configurer S3, CloudFront, ACM ou API Gateway à la main m’a permis de visualiser les liens entre eux avant d’automatiser.
Terraform est ensuite venu structurer et fiabiliser tout ce que j’avais appris.

### Pourquoi utiliser Terraform plutôt que CloudFormation ?
Terraform est multi-cloud : il permet de décrire la même infrastructure sur AWS, Azure, GCP ou d’autres services tiers avec un langage unique (HCL).
Dans une démarche d’apprentissage, j’ai préféré utiliser un langage transversal pour renforcer ma compréhension des concepts.

### Comment gérer la sécurité et la performance du site ?
J'ai fait lr choix de servir le site via un bucket S3 privé via CloudFront (OAC) — aucune exposition publique directe.
Le certificat TLS ACM est hébergé en us-east-1, comme requis par CloudFront.
Les fichiers statiques sont mis en cache et compressés, et toutes les requêtes sont redirigées vers HTTPS.
Résultat → Sécurité + performances : HTTPS, cache CDN, compression, latence réduite et chiffrement des données au repos et en transit.

### Quels ont été les principaux défis techniques ?
- La validation ACM avec OVH (CNAMEs et propagation DNS)
- La redirection HTTPS entre zenabamogne.fr et www.zenabamogne.fr
- L’intégration du compteur de visites serverless (Lambda + API Gateway + DynamoDB)

Ces points m’ont obligée à approfondir les notions de DNS, SSL et permissions IAM.

### Comment est géré l'état Terraform et pourquoi cette méthode ?
J’utilise un backend S3 + DynamoDB :
S3 stocke le state de manière versionnée et sécurisée,
DynamoDB gère le verrouillage concurrent (lock) pour éviter les conflits.
Cela garantit la cohérence, la traçabilité et la collaboration sans risque de corruption du state.

##  Améliorations possibles

- Automatisation CI/CD (GitHub Actions → Terraform plan/apply)
- Multi-environnements (dev/staging/prod)
- Monitoring et alertes (CloudWatch + SNS)
- Sécurité avancée (WAF, Secrets Manager)
