echo \n========== Initialisation de l’environnement ==========\n
sudo apt update
sudo apt install apache2 libapache2-mpm-itk mysql-client-core-8.0 mysql-server php8.1-cli php-cli php-common php-curl php-gd php-intl php-mbstring php-opcache php-readline php-soap php-xml php-xmlrpc php-zip php-fpm php-ldap php-solr php-redis php-apcu 
mkdir websites && cd websites && mkdir data htdocs && cd htdocs

echo \n========== Ajout d’un MOODLE ==========\n
git clone -b MOODLE_402_STABLE https://github.com/moodle/moodle.git moodleTest --sparse
cd moodleTest

echo \n========== Configuration de l’hôte virtuel ==========\n
echo '<VirtualHost *:80 >
  DocumentRoot /home/ubuntu/websites/htdocs/moodleTest
  ServerName' moodleTest'.local 
  ServerAlias' moodleTest'.behat
  AssignUserId ubuntu ubuntu
  ErrorLog /var/log/apache2/vhost-error-'moodleTest'.log
  <Directory /home/ubuntu/websites/htdocs/'moodleTest' >
	Options FollowSymLinks
	AllowOverride All 
	Require all granted 
  </Directory>
</VirtualHost>' >> /etc/apache2/sites-enabled/dev.conf

echo \n========== Configuration du DNS ==========\n
echo '127.0.0.1       moodleTest.local moodleTest.behat'

echo \n========== Création du fichier config.php ==========\n
echo '<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = "mysqli";
$CFG->dblibrary = "native";
$CFG->dbhost    = "localhost";
$CFG->dbname    = "moodleTest";
// $CFG->behat_dbname = "moodle_behat";
$CFG->dbuser    = "moodle_user";
$CFG->dbpass    = "Password100%";
$CFG->prefix    = "mdl_";
$CFG->phpunit_prefix = "phpu_";
$CFG->behat_prefix = "behat_";
$CFG->behat_wwwroot = "http://moodleTest.behat";
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

echo \n========== Réglages des problèmes de max input var en php ==========\n
find /etc -name "php.ini" -exec sed -i 's/;max_input_vars = 1000/max_input_vars = 5000/' {} \;

echo \n========== Installation de la BDD ==========\n
mysql << EOF

CREATE DATABASE moodleTest;
CREATE USER 'moodle_user'@'localhost' IDENTIFIED BY 'Password100%';
GRANT ALL PRIVILEGES ON moodleTest.* TO 'moodle_user'@'localhost';
exit
EOF

sudo mysql_secure_installation

php admin/cli/install_database.php --agree-license --adminpass=Password100%

