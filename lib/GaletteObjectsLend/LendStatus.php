<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Public Class LendStatus
 * Store informations about a lend status
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

class LendStatus
{

    const TABLE = 'status';
    const PK = 'status_id';

    private $_fields = array(
        '_status_id' => 'integer',
        '_status_text' => 'varchar(100)',
        '_is_home_location' => 'boolean',
        '_is_active' => 'boolean',
        '_rent_day_number' => 'int'
    );
    private $_status_id;
    private $_status_text = '';
    private $_is_home_location = false;
    private $_is_active = true;
    private $_rent_day_number = null;

    /**
     * Construit un nouveau statut d'emprunt à partir de la BDD (à partir de son ID) ou vierge
     * 
     * @param int|object $args Peut être null, un ID ou une ligne de la BDD
     */
    public function __construct($args = null) {
        global $zdb;

        if (is_int($args)) {
            try {
                $select = $zdb->select(LEND_PREFIX . self::TABLE)
                        ->where(self::PK . ' = ' . $args);
                $result = $zdb->execute($select);
                if ($result->count() == 1) {
                    $this->_loadFromRS($result->current());
                }
            } catch (\Exception $e) {
                Analog::log(
                        'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                        $e->getTraceAsString(), Analog::ERROR
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
        $this->_status_id = $r->status_id;
        $this->_status_text = $r->status_text;
        $this->_is_home_location = $r->is_home_location == '1' ? true : false;
        $this->_is_active = $r->is_active == '1' ? true : false;
        $this->_rent_day_number = $r->rent_day_number;
    }

    /**
     * Enregistre l'élément en cours que ce soit en insert ou update
     * 
     * @return bool False si l'enregistrement a échoué, true si aucune erreur
     */
    public function store() {
        global $zdb;

        try {
            $values = array();

            foreach ($this->_fields as $k => $v) {
                $values[substr($k, 1)] = $this->$k;
            }

            if (!isset($this->_status_id) || $this->_status_id == '') {
                $insert = $zdb->insert(LEND_PREFIX . self::TABLE)
                        ->values($values);
                $add = $zdb->execute($insert);
                if ($add > 0) {
                    $this->_status_id = $zdb->driver->getLastGeneratedValue();
                } else {
                    throw new \Exception(_T("STATUS.AJOUT ECHEC"));
                }
            } else {
                $update = $zdb->update(LEND_PREFIX . self::TABLE)
                        ->set($values)
                        ->where(array(self::PK => $this->_status_id));
                $zdb->execute($update);
            }
            return true;
        } catch (\Exception $e) {
            Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi tous les statuts triés par le tri indiqué
     * 
     * @param string $tri Colonne de tri
     * @param string $direction asc ou desc
     * 
     * @return LendStatus[] La liste des statuts triés par le tri donné
     */
    public static function getAllStatuses($tri, $direction) {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->order($tri . ' ' . $direction);

            $status = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $status[] = new LendStatus($r);
            }
            return $status;
        } catch (\Exception $e) {
            Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi tous les statuts actifs triés par nom
     * 
     * @return LendStatus[] La liste des statuts actifs triés
     */
    public static function getActiveStatuses() {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->where(array('is_active' => 1))
                    ->order('status_text');

            $status = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $status[] = new LendStatus($r);
            }
            return $status;
        } catch (\Exception $e) {
            Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi tous les statuts actifs considéré comme empruntés triés par nom
     * 
     * @return LendStatus[] La liste des statuts actifs triés
     */
    public static function getActiveTakeAwayStatuses() {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->where(array('is_active' => 1, 'is_home_location' => 0))
                    ->order('status_text');

            $status = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $status[] = new LendStatus($r);
            }
            return $status;
        } catch (\Exception $e) {
            Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Renvoi tous les statuts actifs considéré comme à la maison triés par nom
     * 
     * @return LendStatus[] La liste des statuts actifs triés
     */
    public static function getActiveHomeStatuses() {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->where(array('is_active' => 1, 'is_home_location' => 1))
                    ->order('status_text');

            $status = array();
            $result = $zdb->execute($select);
            foreach ($result as $r) {
                $status[] = new LendStatus($r);
            }
            return $status;
        } catch (\Exception $e) {
            Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Supprime un statut
     * 
     * @param int $id Id du statut à supprimer
     * 
     * @return boolean True en cas de réussite, false sinon
     */
    public static function deleteStatus($id) {
        global $zdb;

        try {
            $delete = $zdb->delete(LEND_PREFIX . self::TABLE)
                    ->where(array(self::PK => $id));
            $zdb->execute($delete);
            return true;
        } catch (\Exception $e) {
            Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(), Analog::ERROR
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
