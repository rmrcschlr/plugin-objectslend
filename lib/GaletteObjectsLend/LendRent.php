<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Public Class LendRent
 * Store all informations about rent status and time of an object
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
use Galette\Entity\Adherent;
use Galette\Repository\Members;

class LendRent
{

    const TABLE = 'rents';
    const PK = 'rent_id';

    private $_fields = array(
        'rent_id' => 'integer',
        'object_id' => 'integer',
        'date_begin' => 'datetime',
        'date_forecast' => 'datetime',
        'date_end' => 'datetime',
        'status_id' => 'integer',
        'adherent_id' => 'integer',
        'comments' => 'varchar(200)'
    );
    private $_rent_id;
    private $_object_id;
    private $_date_begin;
    private $_date_forecast;
    private $_date_end;
    private $_status_id;
    private $_adherent_id;
    private $_comments = '';
    // Join sur table Status
    private $_status_text;
    private $_is_home_location;
    // Left join sur table adhérents
    private $_nom_adh = '';
    private $_prenom_adh = '';
    private $_pseudo_adh = '';
    private $_email_adh = '';

    /**
     * Construit un nouvel historique d'emprunt à partir de la BDD (à partir de son ID) ou vierge
     *
     * @param int|object $args Peut être null, un ID ou une ligne de la BDD
     */
    public function __construct($args = null)
    {
        global $zdb;

        $this->_date_begin = date('Y-m-d H:i:s');

        if (is_int($args)) {
            try {
                $select = $zdb->select(LEND_PREFIX . self::TABLE)
                        ->where(array(self::PK => $args));
                $result = $zdb->execute($select);
                if ($result->count() == 1) {
                    $this->_loadFromRS($result->current());
                }
            } catch (\Exception $e) {
                Analog::log(
                    'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                        $e->getTraceAsString(),
                    Analog::ERROR
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
    private function _loadFromRS($r)
    {
        $this->_rent_id = $r->rent_id;
        $this->_object_id = $r->object_id;
        $this->_date_begin = $r->date_begin;
        $this->_date_forecast = $r->date_forecast;
        $this->_date_end = $r->date_end;
        $this->_status_id = $r->status_id;
        $this->_adherent_id = $r->adherent_id;
        $this->_comments = $r->comments;
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
            $zdb->connection->beginTransaction();
            $values = array();

            foreach ($this->_fields as $k => $v) {
                $rk = '_' . $k;
                $values[$k] = $this->$rk;
            }

            if (!isset($this->_rent_id) || $this->_rent_id == '') {
                unset($values[self::PK]);
                $insert = $zdb->insert(LEND_PREFIX . self::TABLE)
                        ->values($values);
                $result = $zdb->execute($insert);
                if ($result->count() > 0) {
                    if ( $zdb->isPostgres() ) {
                        $this->_rent_id = $zdb->driver->getLastGeneratedValue(
                            PREFIX_DB . 'lend_rents_id_seq'
                        );
                    } else {
                        $this->_rent_id = $zdb->driver->getLastGeneratedValue();
                    }
                    Analog::log(
                        'Rent #' . $this->_rent_id . ' added.',
                        Analog::DEBUG
                    );
                    $update = $zdb->update(LEND_PREFIX . LendObject::TABLE)
                        ->set([self::PK => $this->_rent_id])
                        ->where([LendObject::PK => $this->_object_id]);
                    $zdb->execute($update);
                    Analog::log(
                        'Rent set for object #' . $this->_object_id,
                        Analog::DEBUG
                    );
                } else {
                    throw new \Exception(_T("Rent has not been added"));
                }
            } else {
                $update = $zdb->update(LEND_PREFIX . self::TABLE)
                        ->set($values)
                        ->where(array(self::PK => $this->_rent_id));
                $zdb->execute($update);
            }
            $zdb->connection->commit();
            return true;
        } catch (\Exception $e) {
            $zdb->connection->rollBack();
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                    $e->getTraceAsString(),
                Analog::ERROR
            );
            return false;
        }
    }

    /**
     * Retourne tous les historiques d'emprunts pour un objet donné trié par date de début
     * les plus récents en 1er.
     *
     * @param integer $object_id ID de l'objet dont on souhaite l'historique d'emprunt
     * @param boolean $only_last Only retrieve last rent (for list display)
     *
     * @return LendRent[] Tableau d'objects emprunts
     */
    public static function getRentsForObjectId($object_id, $only_last = false)
    {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->join(PREFIX_DB . Adherent::TABLE, PREFIX_DB . Adherent::TABLE . '.id_adh = ' . PREFIX_DB . LEND_PREFIX . self::TABLE . '.adherent_id', '*', 'left')
                    ->join(PREFIX_DB . LEND_PREFIX . LendStatus::TABLE, PREFIX_DB . LEND_PREFIX . LendStatus::TABLE . '.status_id = ' . PREFIX_DB . LEND_PREFIX . self::TABLE . '.status_id')
                    ->where(array('object_id' => $object_id))
                    ->order('date_begin desc');

            if ($only_last === true) {
                $select->offset(0)->limit(1);
            }

            $rents = array();
            $rows = $zdb->execute($select);

            foreach ($rows as $r) {
                $rt = new LendRent($r);
                $rt->_status_text = $r->status_text;
                $rt->_is_home_location = $r->is_home_location == '1' ? true : false;
                $rt->_prenom_adh = $r->prenom_adh;
                $rt->_nom_adh = $r->nom_adh;
                $rt->_pseudo_adh = $r->pseudo_adh;
                $rt->_email_adh = $r->email_adh;
                $rents[] = $rt;
            }

            return $rents;
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
     * Ferme tous les emprunts ouverts pour un objet donné avec le commentaire indiqué
     *
     * @param int $object_id ID de l'objet surlequel fermer les emprunts
     * @param string $comments Commentaire à mettre sur les emprunts
     *
     * @return boolean True si OK, False si une erreur SQL est survenue
     */
    public static function closeAllRentsForObject($object_id, $comments)
    {
        global $zdb;

        try {
            $select = $zdb->select(LEND_PREFIX . self::TABLE)
                    ->where(array(
                'object_id' => $object_id,
                'date_end' => null
                    ));
            $rows = $zdb->execute($select);

            foreach ($rows as $r) {
                $rent = new LendRent($r);
                $rent->date_end = date('Y-m-d H:i:s');
                $rent->comments = $comments;
                $rent->store();
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
     * Renvoi une liste de tous les adhérents actifs triés par nom
     *
     * @return \Galette\Entity\Adherent[] Tableau des adhérents actifs triés par nom
     */
    public static function getAllActivesAdherents()
    {
        try {
            $filters = new \Galette\Filters\MembersList();
            $filters->account_status_filter = Members::ACTIVE_ACCOUNT;
            $members = new Members($filters);
            $adherents = $members->getMembersList(
                true,
                null,
                false,
                false,
                false,
                false
            );

            return $adherents;
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
        $rname = '_' . $name;
        if (substr($rname, 0, 3) == '___') {
            return false;
        }
        switch ($name) {
            case 'date_begin':
                $dt = new \DateTime($this->_date_begin);
                return $dt->format('d/m/Y - H:i');
            case 'date_begin_short':
                $dt = new \DateTime($this->_date_begin);
                return $dt->format('d/m/Y');
            case 'date_forecast':
                if ($this->_date_forecast != '') {
                    $dt = new \DateTime($this->_date_forecast);
                    return $dt->format('d/m/Y');
                }
                return '';
            case 'date_end':
                if ($this->_date_end != '') {
                    $dt = new \DateTime($this->_date_end);
                    return $dt->format('d/m/Y - H:i');
                }
                return '';
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
    public function __set($name, $value)
    {
        $rname = '_' . $name;
        switch ($name) {
            case 'adherent_id':
                if ((int)$value > 0) {
                    $this->$rname = (int)$value;
                } else {
                    $this->$rname = null;
                }
                break;
            default:
                $this->$rname = $value;
                break;
        }
    }
}
