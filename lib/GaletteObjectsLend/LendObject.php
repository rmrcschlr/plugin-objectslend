<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Public Class LendObject
 * Store informations about an object to lend
 *
 * PHP version 5
 *
 * Copyright © 2013-2016 Mélissa Djebel
 * Copyright © 2017 The Galette Team
 *
 * This file is part of Galette (http://galette.tuxfamily.org).
 *
 * ObjectsLend is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ObjectsLend is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Galette. If not, see <http://www.gnu.org/licenses/>.
 *
 * @category  Plugins
 * @package   ObjectsLend
 *
 * @author    Mélissa Djebel <melissa.djebel@gmx.net>
 * @author    Johan Cwiklinski <johan@x-tnd.be>
 * @copyright 2013-2016 Mélissa Djebel
 * Copyright © 2017 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   0.7
 * @link      http://galette.tuxfamily.org
 * @since     Available since 0.7
 */

namespace GaletteObjectsLend;

use Analog\Analog;
use \Zend\Db\Sql\Predicate;
use Galette\Entity\Adherent;

class LendObject
{

    const TABLE = 'objects';
    const PK = 'object_id';

    private $fields = array(
        'object_id' => 'integer',
        'name' => 'varchar(100)',
        'description' => 'varchar(500)',
        'serial_number' => 'varchar(30)',
        'price' => 'decimal',
        'rent_price' => 'decimal',
        'price_per_day' => 'boolean',
        'dimension' => 'varchar(100)',
        'weight' => 'decimal',
        'is_active' => 'boolean',
        'category_id' => 'int',
        'nb_available' => 'int',
    );
    private $object_id;
    private $name = '';
    private $description = '';
    private $serial_number;
    private $price = 0.0;
    private $rent_price = 0.0;
    private $price_per_day = false;
    private $dimension = '';
    private $weight = 0.0;
    private $is_active = true;
    private $category_id;
    private $nb_available = 1;
    // Nom de la catégorie
    private $category_name = '';
    // Requête sur le dernier statut de l'objet
    private $date_begin;
    private $date_forecast;
    private $date_end;
    private $status_text;
    private $is_home_location;
    // Requête sur l'adhérent associé au statut
    private $nom_adh = '';
    private $prenom_adh = '';
    private $email_adh = '';
    private $id_adh;
    // Propriétés pour la recherche
    private $search_serial_number = '';
    private $search_name = '';
    private $search_description = '';
    private $search_dimension = '';
    // Propriétés pour la taille des images au survol
    private $tooltip_title = '';
    private $object_image_url;
    private $draw_image;

    private $currency = '€';
    private $picture;

    /**
     * Construit un nouvel object d'emprunt à partir de la BDD (à partir de son ID) ou vierge
     *
     * @param int|object $args Peut être null, un ID ou une ligne de la BDD
     */
    public function __construct($args = null, $cloned = false)
    {
        global $zdb;

        if (is_int($args)) {
            try {
                $select = $zdb->select(LEND_PREFIX . self::TABLE)
                        ->where(array(self::PK => $args));
                $results = $zdb->execute($select);
                if ($results->count() == 1) {
                    $this->loadFromRS($results->current());
                }
                if ($cloned) {
                    unset($this->object_id);
                }
            } catch (\Exception $e) {
                Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                        $e->getTraceAsString(),
                    Analog::ERROR
                );
            }
        } elseif (is_object($args)) {
            $this->loadFromRS($args);
        }
    }

    /**
     * Populate object from a resultset row
     *
     * @param ResultSet $r the resultset row
     *
     * @return void
     */
    private function loadFromRS($r)
    {
        global $plugins;

        $this->object_id = $r->object_id;
        $this->search_name = $this->name = self::protectQuote($r->name);
        $this->search_description = $this->description = self::protectQuote($r->description);
        $this->search_serial_number = $this->serial_number = self::protectQuote($r->serial_number);
        $this->price = is_numeric($r->price) ? floatval($r->price) : 0.0;
        $this->rent_price = is_numeric($r->rent_price) ? floatval($r->rent_price) : 0.0;
        $this->price_per_day = $r->price_per_day == '1';
        $this->search_dimension = $this->dimension = self::protectQuote($r->dimension);
        $this->weight = is_numeric($r->weight) ? floatval($r->weight) : 0.0;
        $this->is_active = $r->is_active;
        $this->category_id = $r->category_id;
        $this->nb_available = $r->nb_available;
        $this->category_name = isset($r->category_name) ? $r->category_name : '';

        $this->picture = new ObjectPicture($plugins, (int)$this->object_id);

        //TODO: replace...
        $extensions = array('.png', '.PNG', '.gif', '.GIF', '.jpg', '.JPG', '.jpeg', '.JPEG');
        $this->draw_image = false;
        foreach ($extensions as $ext) {
            if (file_exists(GALETTE_PHOTOS_PATH . 'objectslend/objects/' . $this->object_id . $ext)) {
                //$this->object_image_url = 'objects_pictures/' . $this->object_id . $ext;
                $this->draw_image = true;
                break;
            }
        }
    }

    /**
     * Protège les guillemets et apostrophes en les transformant en caractères qui ne gênent pas en HTML
     *
     * @param string $str Chaîne à transformer
     *
     * @return string Chaîne protégée
     */
    private static function protectQuote($str)
    {
        return str_replace(array('\'', '"'), array(html_entity_decode('&rsquo;'), html_entity_decode('&rdquo;')), $str);
    }

    /**
     * Enregistre l'élément en cours que ce soit en insert ou update
     *
     * @return bool False si l'enregistrement a échoué, true si aucune erreur
     */
    public function store()
    {
        global $zdb;

        try {
            $values = array();

            foreach ($this->fields as $k => $v) {
                $values[$k] = $this->$k;
            }

            if (!isset($this->object_id) || $this->object_id == '') {
                $insert = $zdb->insert(LEND_PREFIX . self::TABLE)
                        ->values($values);
                $add = $zdb->execute($insert);
                if ($add > 0) {
                    $this->object_id = $zdb->driver->getLastGeneratedValue();
                } else {
                    throw new \Exception(_T("OBJECT.AJOUT ECHEC"));
                }
            } else {
                $update = $zdb->update(LEND_PREFIX . self::TABLE)
                        ->set($values)
                        ->where(array(self::PK => $this->object_id));
                $zdb->execute($update);
            }
            return true;
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Supprime logiquement un object (passe son statut IsActive à false)
     *
     * @param int $object_id ID de l'objet à rendre inactif
     *
     * @return boolean Renvoi true quand tout s'est bien déroulé
     */
    public static function setInactiveObject($object_id)
    {
        $o = new self(intval($object_id));
        $o->is_active = false;
        $o->store();
        return true;
    }

    /**
     * Supprime physiquement un objet de la BDD ainsi que son historique d'emprunts
     *
     * @param int $object_id ID de l'objet à supprimer
     *
     * @return boolean Renvoi true quand tout s'est bien déroulé
     */
    public static function removeObject($object_id)
    {
        global $zdb;

        try {
            $delete_history = $zdb->delete(LEND_PREFIX . LendRent::TABLE)
                    ->where(array('object_id' => $object_id));
            $zdb->execute($delete_history);
            $delete_object = $zdb->delete(LEND_PREFIX . self::TABLE)
                    ->where(array(self::PK => $object_id));
            $zdb->execute($delete_object);
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi tous les objets avec leur dernier historique d'emprunt triés par la propriété
     * donnée
     *
     * @param string $tri Nom de propriété surlaquelle faire le tri
     * @param string $direction Sens de tri 'asc' ou 'desc'
     * @param string $search Recherche pour l'objet
     * @param int $category_id Affiche seulement les objets appartenant à la catégorie donnée
     * @param bool $admin_mode Permet d'afficher aussi les objets "supprimés" (= inactifs) si mis à true
     * @param int $page No de la page à afficher (index 1)
     * @param int $rows_per_page Nombre de lignes par page
     * @return LendObject[] Tableau des objets
     */
    public static function getPaginatedObjects($tri, $direction, $search = '', $category_id = null, $admin_mode = false, $page = 0, $rows_per_page = 10)
    {
        global $zdb;

        $objs = array();

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->where(self::writeWhereQuery($admin_mode, $category_id, $search))
                    ->join(PREFIX_DB . LEND_PREFIX . LendCategory::TABLE, PREFIX_DB . LEND_PREFIX . self::TABLE . '.category_id = ' . PREFIX_DB . LEND_PREFIX . LendCategory::TABLE . '.category_id', array('category_name' => 'name'), 'left');

            switch ($tri) {
                case 'name':
                case 'category_name':
                case 'description':
                case 'serial_number':
                case 'price':
                case 'rent_price':
                case 'dimension':
                case 'weight':
                    $select->order($tri . ' ' . $direction);
                    break;
            }

            if ($rows_per_page > 0) {
                $select->limit($rows_per_page);
                $select->offset($page * $rows_per_page);
            }

            $results = $zdb->execute($select);
            foreach ($results as $r) {
                $obj = new self($r);

                self::getStatusForObject($obj);

                $objs[] = $obj;
            }

            switch ($tri) {
                case 'status_text':
                    if ($direction == 'asc') {
                        usort($objs, function ($a, $b) {
                            return strcmp($a->status_text, $b->status_text);
                        });
                    } else {
                        usort($objs, function ($a, $b) {
                            return strcmp($b->status_text, $a->status_text);
                        });
                    }
                    break;
                case 'date_begin':
                    if ($direction == 'asc') {
                        usort($objs, function ($a, $b) {
                            return strcmp($a->date_begin, $b->date_begin);
                        });
                    } else {
                        usort($objs, function ($a, $b) {
                            return strcmp($b->date_begin, $a->date_begin);
                        });
                    }
                    break;
                case 'forecast':
                    if ($direction == 'asc') {
                        usort($objs, function ($a, $b) {
                            return strcmp($a->date_forecast, $b->date_forecast);
                        });
                    } else {
                        usort($objs, function ($a, $b) {
                            return strcmp($b->date_forecast, $a->date_forecast);
                        });
                    }
                    break;
                case 'nom_adh':
                    if ($direction == 'asc') {
                        usort($objs, function ($a, $b) {
                            return strcmp($a->nom_adh, $b->nom_adh);
                        });
                    } else {
                        usort($objs, function ($a, $b) {
                            return strcmp($b->nom_adh, $a->nom_adh);
                        });
                    }
                    break;
            }
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            //throw $e;
        }
        return $objs;
    }

    /**
     * Exécute une requête SQL pour récupérer le statut de location d'un objet, ainsi que l'utilisateur
     * qui loue l'objet.
     * Ne retourne rien.
     *
     * @param LendObject $object L'objet dont on cherche le statut. Est automatiquement modifié.
     */
    public static function getStatusForObject($object)
    {
        global $zdb;

        // Statut
        $select_rent = $zdb->select(LEND_PREFIX . LendRent::TABLE)
                ->join(PREFIX_DB . LEND_PREFIX . LendStatus::TABLE, PREFIX_DB . LEND_PREFIX . LendRent::TABLE . '.status_id = ' . PREFIX_DB . LEND_PREFIX . LendStatus::TABLE . '.status_id')
                ->join(PREFIX_DB . Adherent::TABLE, PREFIX_DB . Adherent::TABLE . '.id_adh = ' . PREFIX_DB . LEND_PREFIX . LendRent::TABLE . '.adherent_id', '*', 'left')
                ->where(array('object_id' => $object->object_id))
                ->limit(1)
                ->offset(0)
                ->order('date_begin desc');

        $results = $zdb->execute($select_rent);
        if ($results->count() == 1) {
            $rent = $results->current();
            $object->date_begin = $rent->date_begin;
            $object->date_forecast = $rent->date_forecast;
            $object->date_end = $rent->date_end;
            $object->status_text = $rent->status_text;
            $object->is_home_location = $rent->is_home_location == '1' ? true : false;
            $object->nom_adh = $rent->nom_adh;
            $object->prenom_adh = $rent->prenom_adh;
            $object->email_adh = $rent->email_adh;
            $object->id_adh = $rent->id_adh;
        }
    }

    /**
     * Renvoi le nombre d'objet correspondant à la catégorie donnée
     *
     * @param int $category_id Affiche seulement les objets appartenant à la catégorie donnée
     * @param string $search Recherche
     * @param bool $admin_mode Permet d'afficher aussi les objets "supprimés" (= inactifs) si mis à true
     * @return int Tableau des objets
     */
    public static function getNbObjects($category_id = null, $search = '', $admin_mode = false)
    {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('nb' => new Predicate\Expression('count(*)')))
                    ->where(self::writeWhereQuery($admin_mode, $category_id, $search));

            $results = $zdb->execute($select);
            return $results->current()->nb;
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Ajoute les clauses or where à une requête existante
     *
     * @param bool $admin_mode Si true cherche tous les objets (is_active = 0/1), si false, cherche uniquement les actifs
     * @param int $category_id Si différent de null, cherche les objets de cette catégorie uniquement
     * @param string $search Cherche uniquement les objets correspondant à la chaine recherchée
     *
     * @return string La clause where à mettre comme recherche
     */
    static function writeWhereQuery($admin_mode, $category_id, $search)
    {
        global $lendsprefs;

        $where = new \Zend\Db\Sql\Where();
        if (!$admin_mode) {
            $where->addPredicate(
                new Predicate\PredicateSet(
                    array(
                        new Predicate\Operator(PREFIX_DB . LEND_PREFIX . self::TABLE . '.is_active', '=', 1)
                    ),
                    Predicate\PredicateSet::OP_AND
                )
            );
        }

        if ($category_id != null && $category_id > 0) {
            $where->addPredicate(
                new Predicate\PredicateSet(
                    array(
                        new Predicate\Operator(
                            PREFIX_DB . LEND_PREFIX . self::TABLE . '.category_id',
                            '=',
                            $category_id
                        )
                    ),
                    Predicate\PredicateSet::OP_AND
                )
            );
        }

        $or_where = array();
        if ($lendsprefs->{Preferences::PARAM_VIEW_SERIAL}) {
            $or_where[] = new Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.serial_number', '%' . $search . '%');
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_NAME}) {
            $or_where[] = new Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.name', '%' . $search . '%');
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_DESCRIPTION}) {
            $or_where[] = new Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.description', '%' . $search . '%');
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_DIMENSION}) {
            $or_where[] = new Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.dimension', '%' . $search . '%');
        }

        if (count($or_where) > 0) {
            $where->addPredicate(new Predicate\PredicateSet($or_where, Predicate\PredicateSet::OP_OR));
        }

        return $where;
    }

    /**
     * Renvoit le nombre total d'objets correspondant à la recherche (si pas de recherche,
     * renvoit juste le nombre total d'objets)
     *
     * @param string $search Chaîne cherchée (peut être vide et renvoit le nombre total d'objets)
     *
     * @return int Nombre d'objets
     */
    public static function getObjectsNumberWithoutCategory($search = '')
    {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('nb' => new Predicate\Expression('count(*)')))
                    ->where(self::writeWhereQuery(false, null, $search));

            $results = $zdb->execute($select);
            return $results->current()->nb;
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoit la somme des prix des objets correspondant a la recherche (si pas de recherche,
     * renvoit juste la somme des prix des objets)
     *
     * @param string $search Chaine cherchee (peut etre vide et renvoit la somme des prix des objets)
     *
     * @return boolean
     */
    public static function getSumPriceObjectsWithoutCategory($search = '')
    {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('sum' => new Predicate\Expression('SUM(price)')))
                    ->where(self::writeWhereQuery(false, null, $search));

            $results = $zdb->execute($select);
            return $results->current()->sum;
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoit tous les objects correspondant aux IDs donnés.
     *
     * @param array $ids Tableau des IDs pour lequels on souhaite avoir les objects
     *
     * @return LendObject[] Tableau des objets correspondant aux IDs
     */
    public static function getMoreObjectsByIds($ids)
    {
        global $zdb;

        $myids = array();
        foreach ($ids as $id) {
            if (is_numeric($id)) {
                $myids[] = $id;
            }
        }

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->where(array(self::PK => $myids));

            $results = array();

            $rows = $zdb->execute($select);
            foreach ($rows as $r) {
                $o = new self($r);

                self::getStatusForObject($o);

                $results[] = $o;
            }

            return $results;
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Global getter method
     *
     * @param string $name name of the property we want to retrive
     *
     * @return false|object the called property
     */
    public function __get($name)
    {
        switch ($name) {
            case 'date_begin_ihm':
                if ($this->date_begin == '' || $this->date_begin == null) {
                    return '';
                }
                $dtb = new \DateTime($this->date_begin);
                return $dtb->format('j M Y');
            case 'date_begin_short':
                if ($this->date_begin == '' || $this->date_begin == null) {
                    return '';
                }
                $dtb = new \DateTime($this->date_begin);
                return $dtb->format('d/m/Y');
            case 'date_end_ihm':
                if ($this->date_end == '' || $this->date_end == null) {
                    return '';
                }
                $dtb = new \DateTime($this->date_end);
                return $dtb->format('j M Y');
            case 'date_forecast_ihm':
                if ($this->date_forecast == '' || $this->date_forecast == null) {
                    return '';
                }
                $dtb = new \DateTime($this->date_forecast);
                return $dtb->format('j M Y');
            case 'date_forecast_short':
                if ($this->date_forecast == '' || $this->date_forecast == null) {
                    return '';
                }
                $dtb = new \DateTime($this->date_forecast);
                return $dtb->format('d/m/Y');
            case 'price':
            case 'rent_price':
                return number_format($this->$name, 2, ',', ' ');
            case 'value_rent_price':
                return $this->rent_price;
            case 'weight_bulk':
                return $this->weight;
            case 'weight':
                return number_format($this->weight, 3, ',', ' ');
            default:
                return $this->$name;
        }
    }

    /**
     * Global setter method
     *
     * @param string $name  name of the property we want to assign a value to
     * @param object $value a relevant value for the property
     *
     * @return void
     */
    public function __set($name, $value)
    {
        $forbidden = ['currency'];
        if (!in_array($name, $forbidden)) {
            $this->$name = $value;
        }
    }

    /**
     * Get currency
     *
     * @return string
     */
    public function getCurrency()
    {
        return $this->currency;
    }
}
