<?php

/**
 * Public Class LendObject
 * Store informations about an object to lend
 *
 * PHP version 5
 *
 * Copyright © 2013 M�lissa Djebel
 *
 * This file is part of Galette (http://galette.tuxfamily.org).
 *
 * Plugin ObjectsLend is distributed in the hope that it will be useful,
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
 * @author    M�lissa Djebel <melissa.djebel@gmx.net>
 * @copyright 2013 M�lissa Djebel
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   0.7
 * @link      http://galette.tuxfamily.org
 * @since     Available since 0.7
 */
class LendObject {

    const TABLE = 'objects';
    const PK = 'object_id';

    private $_fields = array(
        '_object_id' => 'integer',
        '_name' => 'varchar(100)',
        '_description' => 'varchar(500)',
        '_serial_number' => 'varchar(30)',
        '_price' => 'decimal',
        '_rent_price' => 'decimal',
        '_price_per_day' => 'boolean',
        '_dimension' => 'varchar(100)',
        '_weight' => 'decimal',
        '_is_active' => 'boolean',
        '_category_id' => 'int',
        '_nb_available' => 'int',
    );
    private $_object_id;
    private $_name = '';
    private $_description = '';
    private $_serial_number;
    private $_price = 0.0;
    private $_rent_price = 0.0;
    private $_price_per_day = false;
    private $_dimension = '';
    private $_weight = 0.0;
    private $_is_active = true;
    private $_category_id;
    private $_nb_available = 1;
    // Nom de la cat�gorie
    private $_category_name = '';
    // Requ�te sur le dernier statut de l'objet
    private $_date_begin;
    private $_date_forecast;
    private $_date_end;
    private $_status_text;
    private $_is_home_location;
    // Requ�te sur l'adh�rent associ� au statut
    private $_nom_adh = '';
    private $_prenom_adh = '';
    private $_email_adh = '';
    private $_id_adh;
    // Propri�t�s pour la recherche
    private $_search_serial_number = '';
    private $_search_name = '';
    private $_search_description = '';
    private $_search_dimension = '';
    // Propri�t�s pour la taille des images au survol
    private $_tooltip_title = '';
    private $_object_image_url;
    private $_draw_image;

    /**
     * Construit un nouvel object d'emprunt � partir de la BDD (� partir de son ID) ou vierge
     * 
     * @param int|object $args Peut �tre null, un ID ou une ligne de la BDD
     */
    public function __construct($args = null, $cloned = false) {
        global $zdb;

        if (is_int($args)) {
            try {
                $select = $zdb->select(LEND_PREFIX . self::TABLE)
                        ->where(array(self::PK => $args));
                $results = $zdb->execute($select);
                if ($results->count() == 1) {
                    $this->_loadFromRS($results->current());
                }
                if ($cloned) {
                    unset($this->_object_id);
                }
            } catch (Exception $e) {
                Analog\Analog::log(
                        'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                        $e->getTraceAsString(), Analog\Analog::ERROR
                );
            }
        } else if (is_object($args)) {
            $this->_loadFromRS($args);
        }
    }

    /**
     * Populate object from a resultset row
     *
     * @param ResultSet $r the resultset row
     *
     * @return void
     */
    private function _loadFromRS($r) {
        $extensions = array('.png', '.PNG', '.gif', '.GIF', '.jpg', '.JPG', '.jpeg', '.JPEG');

        $this->_object_id = $r->object_id;
        $this->_search_name = $this->_name = self::protectQuote($r->name);
        $this->_search_description = $this->_description = self::protectQuote($r->description);
        $this->_search_serial_number = $this->_serial_number = self::protectQuote($r->serial_number);
        $this->_price = is_numeric($r->price) ? floatval($r->price) : 0.0;
        $this->_rent_price = is_numeric($r->rent_price) ? floatval($r->rent_price) : 0.0;
        $this->_price_per_day = $r->price_per_day == '1';
        $this->_search_dimension = $this->_dimension = self::protectQuote($r->dimension);
        $this->_weight = is_numeric($r->weight) ? floatval($r->weight) : 0.0;
        $this->_is_active = $r->is_active;
        $this->_category_id = $r->category_id;
        $this->_nb_available = $r->nb_available;
        $this->_category_name = isset($r->category_name) ? $r->category_name : '';

        $this->_draw_image = false;
        foreach ($extensions as $ext) {
            if (file_exists('objects_pictures/' . $this->_object_id . $ext)) {
                $this->_object_image_url = 'objects_pictures/' . $this->_object_id . $ext;
                $this->_draw_image = true;
                break;
            }
        }
    }

    /**
     * Prot�ge les guillemets et apostrophes en les transformant en caract�res qui ne g�nent pas en HTML
     * 
     * @param string $str Cha�ne � transform�e
     * 
     * @return string Cha�ne prot�g�e
     */
    private static function protectQuote($str) {
        return str_replace(array('\'', '"'), array(html_entity_decode('&rsquo;'), html_entity_decode('&rdquo;')), $str);
    }

    /**
     * Enregistre l'�l�ment en cours que ce soit en insert ou update
     * 
     * @return bool False si l'enregistrement a �chou�, true si aucune erreur
     */
    public function store() {
        global $zdb;

        try {
            $values = array();

            foreach ($this->_fields as $k => $v) {
                $values[substr($k, 1)] = $this->$k;
            }

            if (!isset($this->_object_id) || $this->_object_id == '') {
                $insert = $zdb->insert(LEND_PREFIX . self::TABLE)
                        ->values($values);
                $add = $zdb->execute($insert);
                if ($add > 0) {
                    $this->_object_id = $zdb->driver->getLastGeneratedValue();
                } else {
                    throw new Exception(_T("OBJECT.AJOUT ECHEC"));
                }
            } else {
                $update = $zdb->update(LEND_PREFIX . self::TABLE)
                        ->set($values)
                        ->where(array(self::PK => $this->_object_id));
                $zdb->execute($update);
            }
            return true;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Supprime logiquement un object (passe son statut IsActive � false)
     * 
     * @param int $object_id ID de l'objet � rendre inactif
     * 
     * @return boolean Renvoi true quand tout s'est bien d�roul�
     */
    public static function setInactiveObject($object_id) {
        $o = new LendObject(intval($object_id));
        $o->is_active = false;
        $o->store();
        return true;
    }

    /**
     * Supprime physiquement un objet de la BDD ainsi que son historique d'emprunts
     * 
     * @param int $object_id ID de l'objet � supprimer
     * 
     * @return boolean Renvoi true quand tout s'est bien d�roul�
     */
    public static function removeObject($object_id) {
        global $zdb;

        try {
            $delete_history = $zdb->delete(LEND_PREFIX . LendRent::TABLE)
                    ->where(array('object_id' => $object_id));
            $zdb->execute($delete_history);
            $delete_object = $zdb->delete(LEND_PREFIX . self::TABLE)
                    ->where(array(self::PK => $object_id));
            $zdb->execute($delete_object);
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi tous les objets avec leur dernier historique d'emprunt tri�s par la propri�t� 
     * donn�e
     * 
     * @param string $tri Nom de propri�t� surlaquelle faire le tri
     * @param string $direction Sens de tri 'asc' ou 'desc'
     * @param string $search Recherche pour l'objet
     * @param int $category_id Affiche seulement les objets appartenant � la cat�gorie donn�e
     * @param bool $admin_mode Permet d'afficher aussi les objets "supprim�s" (= inactifs) si mis � true
     * @param int $page N� de la page � afficher (index 1)
     * @param int $rows_per_page Nombre de lignes par page
     * @return LendObject[] Tableau des objets
     */
    public static function getPaginatedObjects($tri, $direction, $search = '', $category_id = null, $admin_mode = false, $page = 0, $rows_per_page = 10) {
        global $zdb;

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

            $objs = array();
            $results = $zdb->execute($select);
            foreach ($results as $r) {
                $obj = new LendObject($r);

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

            return $objs;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Ex�cute une requ�te SQL pour r�cup�rer le statut de location d'un objet, ainsi que l'utilisateur
     * qui loue l'objet.
     * Ne retourne rien.
     * 
     * @param LendObject $object L'objet dont on cherche le statut. Est automatiquement modifi�.
     */
    public static function getStatusForObject($object) {
        global $zdb;

        // Statut
        $select_rent = $zdb->select(LEND_PREFIX . LendRent::TABLE)
                ->join(PREFIX_DB . LEND_PREFIX . LendStatus::TABLE, PREFIX_DB . LEND_PREFIX . LendRent::TABLE . '.status_id = ' . PREFIX_DB . LEND_PREFIX . LendStatus::TABLE . '.status_id')
                ->join(PREFIX_DB . Galette\Entity\Adherent::TABLE, PREFIX_DB . Galette\Entity\Adherent::TABLE . '.id_adh = ' . PREFIX_DB . LEND_PREFIX . LendRent::TABLE . '.adherent_id', '*', 'left')
                ->where(array('object_id' => $object->object_id))
                ->limit(1)
                ->offset(0)
                ->order('date_begin desc');

        $results = $zdb->execute($select_rent);
        if ($results->count() == 1) {
            $rent = $results->current();
            $object->_date_begin = $rent->date_begin;
            $object->_date_forecast = $rent->date_forecast;
            $object->_date_end = $rent->date_end;
            $object->_status_text = $rent->status_text;
            $object->_is_home_location = $rent->is_home_location == '1' ? true : false;
            $object->_nom_adh = $rent->nom_adh;
            $object->_prenom_adh = $rent->prenom_adh;
            $object->_email_adh = $rent->email_adh;
            $object->_id_adh = $rent->id_adh;
        }
    }

    /**
     * Renvoi le nombre d'objet correspondant � la cat�gorie donn�e
     * 
     * @param int $category_id Affiche seulement les objets appartenant � la cat�gorie donn�e
     * @param string $search Recherche
     * @param bool $admin_mode Permet d'afficher aussi les objets "supprim�s" (= inactifs) si mis � true
     * @return int Tableau des objets
     */
    public static function getNbObjects($category_id = null, $search = '', $admin_mode = false) {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('nb' => new Zend\Db\Sql\Predicate\Expression('count(*)')))
                    ->where(self::writeWhereQuery($admin_mode, $category_id, $search));

            $results = $zdb->execute($select);
            return $results->current()->nb;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Ajoute les clauses or where � une requ�te existante
     * 
     * @param bool $admin_mode Si true cherche tous les objets (is_active = 0/1), si false, cherche uniquement les actifs
     * @param int $category_id Si différent de null, cherche les objets de cette catégorie uniquement
     * @param string $search Cherche uniquement les objets correspondant à la chaine recherchée
     * 
     * @return string La clause where � mettre comme recherche
     */
    static function writeWhereQuery($admin_mode, $category_id, $search) {
        $where = new Zend\Db\Sql\Where();
        if (!$admin_mode) {
            $where->addPredicate(new Zend\Db\Sql\Predicate\PredicateSet(array(new Zend\Db\Sql\Predicate\Operator(PREFIX_DB . LEND_PREFIX . self::TABLE . '.is_active', '=', 1)), Zend\Db\Sql\Predicate\PredicateSet::OP_AND));
        }

        if ($category_id != null && $category_id > 0) {
            $where->addPredicate(new Zend\Db\Sql\Predicate\PredicateSet(array(new Zend\Db\Sql\Predicate\Operator(PREFIX_DB . LEND_PREFIX . self::TABLE . '.category_id', '=', $category_id)), Zend\Db\Sql\Predicate\PredicateSet::OP_AND));
        }

        $or_where = array();
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_SERIAL)) {
            $or_where[] = new Zend\Db\Sql\Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.serial_number', '%' . $search . '%');
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_NAME)) {
            $or_where[] = new Zend\Db\Sql\Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.name', '%' . $search . '%');
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DESCRIPTION)) {
            $or_where[] = new Zend\Db\Sql\Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.description', '%' . $search . '%');
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DIMENSION)) {
            $or_where[] = new Zend\Db\Sql\Predicate\Like(PREFIX_DB . LEND_PREFIX . self::TABLE . '.dimension', '%' . $search . '%');
        }

        if (count($or_where) > 0) {
            $where->addPredicate(new Zend\Db\Sql\Predicate\PredicateSet($or_where, Zend\Db\Sql\Predicate\PredicateSet::OP_OR));
        }

        return $where;
    }

    /**
     * Renvoit le nombre total d'objets correspondant � la recherche (si pas de recherche,
     * renvoit juste le nombre total d'objets)
     * 
     * @param string $search Cha�ne cherch�e (peut �tre vide et renvoit le nombre total d'objets)
     * 
     * @return int Nombre d'objets
     */
    public static function getObjectsNumberWithoutCategory($search = '') {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('nb' => new Zend\Db\Sql\Predicate\Expression('count(*)')))
                    ->where(self::writeWhereQuery(false, null, $search));

            $results = $zdb->execute($select);
            return $results->current()->nb;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
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
    public static function getSumPriceObjectsWithoutCategory($search = '') {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('sum' => new Zend\Db\Sql\Predicate\Expression('SUM(price)')))
                    ->where(self::writeWhereQuery(false, null, $search));

            $results = $zdb->execute($select);
            return $results->current()->sum;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoit tous les objects correspondant aux IDs donn�s.
     * 
     * @param array $ids Tableau des IDs pour lequels on souhaite avoir les objects
     * 
     * @return LendObject[] Tableau des objets correspondant aux IDs
     */
    public static function getMoreObjectsByIds($ids) {
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
                $o = new LendObject($r);

                self::getStatusForObject($o);

                $results[] = $o;
            }

            return $results;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
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
    public function __get($name) {
        $rname = '_' . $name;
        if (substr($rname, 0, 3) == '___') {
            return false;
        }
        switch ($name) {
            case 'date_begin_ihm':
                if ($this->_date_begin == '' || $this->_date_begin == null) {
                    return '';
                }
                $dtb = new DateTime($this->_date_begin);
                return $dtb->format('j M Y');
            case 'date_begin_short':
                if ($this->_date_begin == '' || $this->_date_begin == null) {
                    return '';
                }
                $dtb = new DateTime($this->_date_begin);
                return $dtb->format('d/m/Y');
            case 'date_end_ihm':
                if ($this->_date_end == '' || $this->_date_end == null) {
                    return '';
                }
                $dtb = new DateTime($this->_date_end);
                return $dtb->format('j M Y');
            case 'date_forecast_ihm':
                if ($this->_date_forecast == '' || $this->_date_forecast == null) {
                    return '';
                }
                $dtb = new DateTime($this->_date_forecast);
                return $dtb->format('j M Y');
            case 'date_forecast_short':
                if ($this->_date_forecast == '' || $this->_date_forecast == null) {
                    return '';
                }
                $dtb = new DateTime($this->_date_forecast);
                return $dtb->format('d/m/Y');
            case 'name':
                return str_replace('\'', '’', $this->_name);
            case 'description':
                return str_replace('\'', '’', $this->_description);
            case 'price':
                return number_format($this->_price, 2, ',', ' ');
            case 'rent_price':
                return number_format($this->_rent_price, 2, ',', ' ');
            case 'value_rent_price':
                return $this->_rent_price;
            case 'weight_bulk':
                return $this->_weight;
            case 'weight':
                return number_format($this->_weight, 3, ',', ' ');
            default:
                return $this->$rname;
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
    public function __set($name, $value) {
        $rname = '_' . $name;
        $this->$rname = $value;
    }

}
