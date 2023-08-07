# Initialisation de l’environnement.
sudo apt update
sudo apt install apache2 libapache2-mpm-itk mysql-client-core-8.0 mysql-server php8.1-cli php-cli php-common php-curl php-gd php-intl php-mbstring php-opcache php-readline php-soap php-xml php-xmlrpc php-zip php-fpm php-ldap php-solr php-redis php-apcu 
mkdir websites && cd websites && mkdir data htdocs && cd htdocs

# Ajout d’un MOODLE.
git clone -b MOODLE_{version}_STABLE https://github.com/moodle/moodle.git $1
cd $1

# Configuration de l’hôte virtuel.
echo '<VirtualHost *:80 >
  DocumentRoot /home/ubuntu/websites/htdocs/$1
  ServerName' $1'.local 
  ServerAlias' $1'.behat
  AssignUserId ubuntu ubuntu
  ErrorLog /var/log/apache2/vhost-error-'$1'.log
  <Directory /home/ubuntu/websites/htdocs/'$1' >
	Options FollowSymLinks
	AllowOverride All 
	Require all granted 
  </Directory>
</VirtualHost>' >> /etc/apache2/sites-enabled/dev.conf

# Configuration du DNS.
echo '127.0.0.1       '$1'.local '$1'.behat'

# Création du fichier config.php
echo '<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = "mysqli";
$CFG->dblibrary = "native";
$CFG->dbhost    = "localhost";
$CFG->dbname    = '$1';
// $CFG->behat_dbname = "moodle_behat";
$CFG->dbuser    = "moodle_user";
$CFG->dbpass    = "Password100%";
$CFG->prefix    = "mdl_";
$CFG->phpunit_prefix = "phpu_";
$CFG->behat_prefix = "behat_";
$CFG->behat_wwwroot = "http://'$1'.behat";
$CFG->dboptions = array (
  "dbpersist" => 0,
  "dbport" => "",
  "dbsocket" => "",
  "dbcollation" => "utf8mb4_unicode_ci",
);

$CFG->wwwroot   = "https://ec2-52-47-151-241.eu-west-3.compute.amazonaws.com";
$CFG->dataroot  = "/home/ubuntu/websites/data/moodleTesting402Data";
$CFG->admin     = "admin";

$CFG->phpunit_dataroot = "/home/martin/websites/data/moodleTesting402_phpunit";
$CFG->behat_dataroot ="/home/martin/websites/data/moodleTesting402_behat";
$CFG->directorypermissions = 02777;

require_once(__DIR__ . "/lib/setup.php");

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!' >> config.php 

# Installation de la BDD.
mysql << EOF

CREATE DATABASE {nameOfTheMoodle};
CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'Password100%';
GRANT ALL PRIVILEGES ON {nameOfTheMoodle}.* TO 'moodle_user'@'localhost';
exit
EOF

sudo mysql_secure_installation

php admin/cli/install_database.php --agree-license --adminpass=Password100%

