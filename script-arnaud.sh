
#!/bin/bash

# date du jour
backupdate=$(date +%Y-%m-%d)

#répertoire de backup
dirbackup=/backup/backup-$backupdate

#nom du bucket
bucket="nomdubucket"

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
aws s3 mb s3://$bucket --region eu-west-3

# copie des fichier de backup 
aws s3 cp $dirbackup/home-$backupdate.tar.bz2 s3://$bucket

aws s3 cp $dirbackup/mysqldump-$backupdate.sql.gz s3://$bucket

#mise en place du cycle de vie des fichiers pour les supprimer au bout de 7 jours
aws s3api put-bucket-lifecycle-configuration --bucket $bucket --lifecycle-configuration file://lifecycle.json