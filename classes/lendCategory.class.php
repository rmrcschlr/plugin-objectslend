<?php

/**
 * Public Class LendCategory
 * Store informations about a lend category
 *
 * PHP version 5
 *
 * Copyright � 2013 M�lissa Djebel
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
class LendCategory {

    const TABLE = 'category';
    const PK = 'category_id';

    private $_fields = array(
        '_category_id' => 'integer',
        '_name' => 'varchar(100)',
        '_is_active' => 'boolean'
    );
    private $_category_id;
    private $_name = '';
    private $_is_active = true;
    private $_objects_nb = 0;
    private $_objects_price_sum = 0;
    // Used to have an url for the image
    private $_categ_image_url = '';

    /**
     * Construit un nouveau statut d'emprunt � partir de la BDD (� partir de son ID) ou vierge
     * 
     * @param int|object $args Peut �tre null, un ID ou une ligne de la BDD
     */
    public function __construct($args = null) {
        global $zdb;

        if (is_int($args)) {
            try {
                $select = $zdb->select(LEND_PREFIX . self::TABLE)
                        ->where(array(self::PK => $args));
                $results = $zdb->execute($select);
                if ($results->count() == 1) {
                    $this->_loadFromRS($results->current());
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

        $this->_category_id = $r->category_id;
        $this->_name = $r->name;
        $this->_is_active = $r->is_active == '1' ? true : false;

        foreach ($extensions as $ext) {
            if (file_exists('categories_pictures/' . $this->_category_id . $ext)) {
                $this->_categ_image_url = 'categories_pictures/' . $this->_category_id . $ext;
                break;
            }
        }
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

            if (!isset($this->_category_id) || $this->_category_id == '') {
                $insert = $zdb->insert(LEND_PREFIX . self::TABLE)
                        ->values($values);
                $add = $zdb->execute($insert);
                if ($add > 0) {
                    $this->_category_id = $zdb->driver->getLastGeneratedValue();
                } else {
                    throw new Exception(_T("CATEGORY.AJOUT ECHEC"));
                }
            } else {
                $update = $zdb->update(LEND_PREFIX . self::TABLE)
                        ->set($values)
                        ->where(array(self::PK => $this->_category_id));
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
     * Renvoi toutes les categories tri�es par le tri indiqu�
     * 
     * @param string $tri Colonne de tri
     * @param string $direction asc ou desc
     * 
     * @return LendCategory[] La liste des statuts tri�s par le tri donn�
     */
    public static function getAllCategories($tri, $direction) {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->order($tri . ' ' . $direction);

            $categs = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $categs[] = new LendCategory($r);
            }
            return $categs;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi toutes les categories actives tri�s par nom avec le nombre
     * d'objets qu'elles contiennent (propri�t� 'objects_nb')
     * 
     * @return LendCategory[] La liste des categories actives tri�es
     */
    public static function getActiveCategories() {
        global $zdb;

        try {
            $select_count = $zdb->select(LEND_PREFIX . LendObject::TABLE)
                    ->columns(array(new Zend\Db\Sql\Predicate\Expression('count(*)')))
                    ->where(array(
                'is_active' => 1,
                new Zend\Db\Sql\Predicate\Expression(PREFIX_DB . LEND_PREFIX . LendObject::TABLE . '.category_id = ' . PREFIX_DB . LEND_PREFIX . self::TABLE . '.' . self::PK)
            ));

            $select_sum = $zdb->select(LEND_PREFIX . LendObject::TABLE)
                    ->columns(array(new Zend\Db\Sql\Predicate\Expression('sum(price)')))
                    ->where(array(
                'is_active' => 1,
                new Zend\Db\Sql\Predicate\Expression(PREFIX_DB . LEND_PREFIX . LendObject::TABLE . '.category_id = ' . PREFIX_DB . LEND_PREFIX . self::TABLE . '.' . self::PK)
            ));

            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('*',
                        'nb' => new Zend\Db\Sql\Predicate\Expression('(' . $zdb->sql->getSqlStringForSqlObject($select_count) . ')'),
                        'sum' => new Zend\Db\Sql\Predicate\Expression('(' . $zdb->sql->getSqlStringForSqlObject($select_sum) . ')'),
                    ))
                    ->where(array('is_active' => 1))
                    ->order('name');

            $categs = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $cat = new LendCategory($r);
                $cat->_objects_nb = $r->nb;
                if (is_numeric($r->sum)) {
                    $cat->_objects_price_sum = $r->sum;
                }
                $categs[] = $cat;
            }
            return $categs;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi toutes les categories actives tri�s par nom avec le nombre
     * d'objet qui correspond � la chaine recherch�e
     * 
     * @param string $search Chaine de recherche
     * @return LendCategory[] La liste des categories actives tri�es
     */
    public static function getActiveCategoriesWithSearchCriteria($search) {
        if (strlen($search) < 1) {
            return self::getActiveCategories();
        }

        global $zdb;

        try {
            $select_count = $zdb->select(LEND_PREFIX . LendObject::TABLE)
                    ->columns(array(new Zend\Db\Sql\Predicate\Expression('count(*)')))
                    ->where(array(
                'is_active' => 1,
                LendObject::writeWhereQuery($search),
                new Zend\Db\Sql\Predicate\Expression(PREFIX_DB . LEND_PREFIX . LendObject::TABLE . '.category_id = ' . PREFIX_DB . LEND_PREFIX . self::TABLE . '.' . self::PK)
            ));

            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->columns(array('*', 'nb' => new Zend\Db\Sql\Predicate\Expression(('(' . $zdb->sql->getSqlStringForSqlObject($select_count) . ')'))))
                    ->where(array('is_active' => 1))
                    ->order('name');

            $categs = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $cat = new LendCategory($r);
                $cat->_objects_nb = $r->nb;
                $categs[] = $cat;
            }
            return $categs;
        } catch (Exception $e) {
            Analog\Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog\Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Supprime une cat�gorie et assigne les objets de cette cat�gorie � "aucune cat�gorie"
     * 
     * @param int $id Id de la cat�gorie � supprimer
     * 
     * @return boolean True en cas de r�ussite, false sinon
     */
    public static function deleteCategory($id) {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . LendObject::TABLE)
                    ->where(array('category_id' => $id));
            $results = $zdb->execute($select);
            if ($results->count() > 0) {
                $values = array();
                $values['category_id'] = new Zend\Db\Sql\Predicate\Expression('NULL');
                $update = $zdb->update(LEND_PREFIX . LendObject::TABLE)
                        ->set($values)
                        ->where(array('category_id' => $id));
                $zdb->execute($update);
            }

            $delete = $zdb->delete(PREFIX_DB . LEND_PREFIX . self::TABLE)
                    ->where(array(self::PK => $id));
            $zdb->execute($delete);
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
            case 'objects_price_sum':
                return number_format($this->$rname, 2, ',', '');
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
