
#!/bin/bash

# date du jour
backupdate=$(date +%Y-%m-%d)

#répertoire de backup
dirbackup=/backup/backup-$backupdate

# création du répertoire de backup
/bin/mkdir $dirbackup

# tar -cjf /destination/fichier.tar.bz2 /source1 /source2 /sourceN
# créé une archive bz2
# sauvegarde de /home
/bin/tar -cjf $dirbackup/home-$backupdate.tar.bz2 /home

# sauvegarde mysql
/usr/bin/mysqldump --user=xxxx --password=xxxx --all-databases | /usr/bin/gzip > $dirbackup/mysqldump-$backupdate.sql.gz

#importation des ID de connexion sur aws
aws configure import --csv file://credentials.csv

#creation du bucket 
aws s3api create-bucket --bucket bucketdearnaud --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1

# copie des fichier de backup 
aws s3 cp home-$backupdate.tar.bz2 s3://bucketdearnaud/backup

aws s3 cp mysqldump-$backupdate.sql.gz s3://bucketdearnaud/backup

#mise en place du cycle de vie des fichiers pour les supprimer au bout de 7 jours
aws s3api put-bucket-lifecycle-configuration  \
--bucket bucketdearnaud  \
--lifecycle-configuration file://lifecycle.json