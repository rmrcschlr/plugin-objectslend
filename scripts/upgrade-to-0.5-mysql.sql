--
-- Structure de la table 'galette_lend_categories_pictures'
--

CREATE TABLE IF NOT EXISTS galette_lend_categories_pictures (
  category_id int(11) NOT NULL,
  picture mediumblob NOT NULL,
  format varchar(10) CHARACTER SET utf8 NOT NULL DEFAULT '',
  PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

