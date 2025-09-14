Portfolio IaC avec Terraform

General : 
Région principale = eu-west-3
Certificats CloudFront = us-east-1
DNS = OVH (CNAME, pas de migration Route 53 pour l’instant)
Backend = S3 privé (versionning + SSE-S3) + lock DynamoDB
Naming convention <prefix>-<project>-<env>-<type> = zenaba-portfolio-dev-tfstate
Stratégie : importer stateful, recréer stateless, bascule DNS réversible
Raison d’un module séparé bootstrap-backend
Tagging = project=portfolio, Environment=dev

1 : Gestion du state Terraform
Terraform a besoin d’un fichier de state pour comparer l’infra réelle et la configuration. 
-> Ne pas le stocker en local mais dans un bucket S3 privé (versionné, chiffré SSE-S3)
-> Lock : DynamoDB (LockID par requete).
=  Collaboration multi-machines possible / Historique et rollback /Sécurité (chiffrement et accès contrôlé) / Coût minime mais non nul (S3+DynamoDB)

2 : Gestion DNS
Domaine géré chez OVH.
->  Conserver OVH comme DNS, gérer les CNAME manuellement (validation ACM, pointage CloudFront).
= Pas de migration des serveurs DNS → simplicité / maîtrise côté OVH
Pourquoi ne pas migrer la zone vers Route 53 : plus de setup, propagation lente et plus difficile

3 : Stratégie de migration
L’infra existe déjà (site OVH + AWS ACM + CloudFront + DynamoDB + Lambda). Besoin de passer sous Terraform sans perte de données ni coupure visible. Le nom de domaine est déjà acheté et géré chez OVH : il doit être conservé (pas de migration de domaine).
-> Importer les ressources stateful (DynamoDB, Lambda, éventuellement API GW).
-> Recréer les ressources stateless (CloudFront, ACM, S3 site privé).
-> Bascule DNS : mise à jour du CNAME chez OVH pour pointer le domaine existant vers la nouvelle distribution CloudFront.
= Zéro downtime sur les données / Rollback facile via DNS
Probleme :  Double infra temporaire (coût CloudFront minime)
Pourquoi ne pas migrer la zone DNS vers Route 53 : le domaine reste chez OVH (coût déjà payé, pas d’intérêt immédiat à migrer).
Pourquoi ne pas tout importer : trop complexe, risque d’erreurs
Pourquoi ne pas Tout recréer : perte de données sur DDB

4: Sécurité & bonnes pratiques
L’infra héberge un site portfolio public avec compteur de visites (Lambda+DDB).
-> S3 site privé + accès via CloudFront OAC uniquement.
-> TLS v1.2_2021 sur CloudFront.
-> utilisateur Terraform avec AdministratorAccess provisoire, à restreindre ensuite.
= Respect des bonnes pratiques sécurité mais IAM trop permissif au début (mais assumé pour bootstrap)
