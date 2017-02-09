--
-- Structure de la table 'galette_lend_categories_pictures'
--

CREATE TABLE IF NOT EXISTS galette_lend_categories_pictures (
  category_id int(11) NOT NULL,
  picture mediumblob NOT NULL,
  format varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT '',
  PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

-- Add fullsize parameter
insert into galette_lend_parameters
(code, is_date, is_text, is_numeric, nb_digits, value_numeric, date_creation, date_modification)
values
('VIEW_FULLSIZE', 0, 0, 1, 0, 1, NOW(), NOW());

DELETE FROM galette_lend_parameters WHERE code='VIEW_CATEGORY_THUMB';
DELETE FROM galette_lend_parameters WHERE code='VIEW_OBJECT_THUMB';
DELETE FROM galette_lend_parameters WHERE code='OBJECTS_PER_PAGE_NUMBER_LIST';
DELETE FROM galette_lend_parameters WHERE code='OBJECTS_PER_PAGE_DEFAULT';
DELETE FROM galette_lend_parameters WHERE code='VIEW_NAME';

ALTER TABLE galette_lend_rents DROP FOREIGN KEY FK_rent_adherent_1;
ALTER TABLE galette_lend_rents ADD CONSTRAINT FK_rent_adherent_1 FOREIGN KEY (adherent_id) REFERENCES galette_adherents (id_adh) ON DELETE CASCADE ON UPDATE CASCADE;
