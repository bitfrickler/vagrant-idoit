-- set remote access via root
-- GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Admin123#';
-- GRANT ALL PRIVILEGES ON idoit_data.* TO 'idoit'@'localhost' IDENTIFIED BY 'idoit';

-- set password for admin user to Admin123#
UPDATE `idoit_data`.`isys_cats_person_list` SET `isys_cats_person_list__user_pass`='61cc0e405f4b518d264c089ac8b642ef' WHERE `isys_cats_person_list__title`='admin';
UPDATE `idoit_system`.`isys_settings` SET `api.status`='1';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Admin123#';
GRANT ALL PRIVILEGES ON idoit_data.* TO 'idoit'@'localhost' IDENTIFIED BY 'idoit';