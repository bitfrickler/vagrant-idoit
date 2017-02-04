GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Admin123#';
GRANT ALL PRIVILEGES ON idoit_data.* TO 'idoit'@'localhost' IDENTIFIED BY 'idoit';

-- set password for admin user to Admin123#
UPDATE `idoit_data`.`isys_cats_person_list` SET `isys_cats_person_list__user_pass`='61cc0e405f4b518d264c089ac8b642ef' WHERE `isys_cats_person_list__title`='admin';

-- enable API
UPDATE `idoit_system`.`isys_settings` SET isys_settings__value = '1' where isys_settings__key = 'api.status';

-- set API key
UPDATE `idoit_system`.`isys_mandator` SET isys_mandator__apikey = 'Admin123#';