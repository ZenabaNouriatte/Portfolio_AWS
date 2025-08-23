# 🌐 Portfolio AWS - Déploiement Serverless avec S3 + CloudFront + Lambda + DynamoDB

## Contexte du projet

### Pourquoi ce projet ?

J'ai découvert le **AWS Resume Challenge** — un excellent projet pour apprendre AWS de manière pratique. Cependant, étant actuellement concentrée sur la fin du tronc commun à l'école 42, j'ai adapté l'approche :

- **Objectif immédiat** : Migrer mon portfolio HTML existant (GitHub Pages → AWS)
- **Objectif à long terme** : Acquérir des compétences AWS pratiques pour **ft_transcendence** (projet final 42)
- **Approche** : Démarche progressive et scalable, en utilisant le Free Tier AWS

## Architecture

```
Internet
    ↓
OVH DNS (zenabamogne.fr)
    ↓
AWS CloudFront (CDN + HTTPS)
    ↓
AWS S3 (Static Website Hosting)
    ↓
AWS Lambda + DynamoDB (Visitor Counter)
```

## Technologies utilisées

- **Frontend** : HTML/CSS/JavaScript
- **Hébergement** : AWS S3 (Static Website Hosting)
- **CDN & SSL** : AWS CloudFront + ACM (Certificate Manager)
- **DNS** : OVH (Registrar + DNS Zone)
- **Backend** : AWS Lambda (Python) + DynamoDB
- **Testing local** : Docker + Nginx

## Étapes de mise en œuvre

### Étape 1 : Validation locale avec Docker
```bash
# Test de l'architecture locale
docker run -d -p 80:80 -v $(pwd):/usr/share/nginx/html nginx
```

**Pourquoi cette étape ?**
- Validation du rendu avant déploiement
- Test de la configuration Nginx
- Démarche DevOps : tester localement d'abord

### Étape 2 : Configuration S3
1. **Création du bucket** avec le nom de domaine final
2. **Configuration Static Website Hosting**
3. **Politique de bucket** pour l'accès public aux fichiers

### Étape 3 : Implémentation du compteur de visites

#### Backend (AWS Lambda + DynamoDB)
- **Table DynamoDB** : `VisitorCounter` avec une clé `id`
- **Fonction Lambda** : En python : Incrémente le compteur à chaque visite


#### Frontend (JavaScript)
```javascript
// Appel AJAX vers la Lambda Function URL
fetch('https://your-lambda-url.amazonaws.com/')
    .then(response => response.json())
    .then(data => {
        document.getElementById('visitor-count').textContent = data.visits;
    })
    .catch(error => console.log('Error:', error));
```

### Étape 4 : Nom de domaine personnalisé

**Pourquoi changer de GitHub Pages vers un domaine personnalisé ?**

| Critère | GitHub Pages | AWS + Domaine personnalisé |
|---------|--------------|---------------------------|
| URL | `username.github.io` | `zenabamogne.fr` |
| HTTPS | ✅ Automatique | ✅ Via ACM |
| SEO | ❌ Moins optimisé | ✅ Meilleur référencement |
| Scalabilité | ❌ Limitée | ✅ Services AWS extensibles |
| Performance mondiale | ❌ Une région | ✅ CDN CloudFront |

**Choix du registrar** : OVH
- Prix compétitif
- Interface française
- Bonne réputation

### Étape 5 : HTTPS avec CloudFront + ACM

#### Configuration CloudFront
1. **Création de la distribution** avec S3 comme origine
2. **Configuration SSL/TLS** avec certificat ACM
3. **Optimisation** : Compression, cache policies

#### Certificat SSL gratuit (ACM)
1. **Demande de certificat** pour `zenabamogne.fr` et `www.zenabamogne.fr`
2. **Validation DNS** : Ajout des enregistrements CNAME dans OVH
3. **Validation automatique** en quelques minutes

### Étape 6 : Configuration DNS (OVH)
```
Type: A
Nom: @
Valeur: [CloudFront Distribution Domain]

Type: CNAME
Nom: www
Valeur: zenabamogne.fr
```

## Défis rencontrés et solutions

### Problème 1 : Erreur CORS en local
**Symptôme** : La fonction Lambda n'était pas appelable depuis `localhost`

**Solution** : Configuration CORS sur la Lambda Function URL
```python
'headers': {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET',
    'Content-Type': 'application/json'
}
```

### Problème 2 : Accès ACM bloqué
**Symptôme** : Service ACM inaccessible malgré un compte vérifié

**Solution** : 
- Ouverture d'un ticket support AWS
- Résolution : Restrictions injustifiées levées par le support
- **Apprentissage** : Importance du support AWS pour les nouveaux comptes

### Problème 3 : Propagation DNS
**Symptôme** : Site inaccessible après configuration

**Solution** :
- Vérification de la configuration CloudFront
- Attente de la propagation DNS (24-48h max)
- Test avec différents DNS resolver

## Considérations de sécurité

### Sécurité actuelle
- **HTTPS partout** via CloudFront + ACM
- **Fonction Lambda** : Lecture seule, pas de données sensibles
- **CORS configuré** : Accepte uniquement les requêtes GET

### Améliorations possibles
- **API Gateway** avec throttling et authentification
- **WAF** (Web Application Firewall) sur CloudFront
- **Monitoring** avec CloudWatch pour détecter les anomalies

## Contrôle des coûts

### Free Tier utilisé
- **S3** : 5 GB de stockage + 20 000 requêtes GET
- **CloudFront** : 50 GB de transfert + 2 millions de requêtes
- **Lambda** : 1 million d'exécutions + 400 000 GB-secondes
- **DynamoDB** : 25 GB de stockage + 25 RCU/WCU

### Alertes configurées
- **Billing Alert** : Notification si dépassement de 5$ par mois
- **S3 Bucket** : Monitoring des requêtes

## Résultats

### Performance
- ✅ **HTTPS natif** avec certificat SSL gratuit
- ✅ **Performance mondiale** via CloudFront CDN
- ✅ **Scalabilité** : Architecture serverless ready
- ✅ **SEO optimisé** avec nom de domaine personnalisé

### Compétences acquises
- **Infrastructure AWS** : S3, CloudFront, ACM, Route 53
- **Serverless** : Lambda, DynamoDB
- **DNS Management** : Configuration et propagation
- **DevOps** : Testing local, déploiement cloud

## Prochaines étapes

### Phase 2 : Infrastructure as Code
- **Migration vers Terraform** : Automatisation du déploiement
- **CI/CD Pipeline** : GitHub Actions pour les mises à jour
- **Tests automatisés** : Validation du compteur de visites

### Phase 3 : Monitoring avancé
- **CloudWatch Dashboard** : Métriques en temps réel
- **X-Ray Tracing** : Analyse des performances Lambda
- **Logs analysis** : Détection des patterns d'usage

## 🔗 Ressources utiles

- [AWS Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Distribution Configuration](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.html)
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)

---

## Notes personnelles

Cette approche progressive m'a permis de :
- **Comprendre les bases** AWS sans me disperser
- **Appliquer immédiatement** les concepts appris
- **Préparer le terrain** pour ft_transcendence avec des services AWS
- **Construire un portfolio** technique démontrant mes compétences cloud

Le projet reste **évolutif** et servira de base pour des architectures plus complexes par la suite.

---

# **Objectif atteint** : Portfolio professionnel hébergé sur AWS avec architecture scalable et sécurisée !
