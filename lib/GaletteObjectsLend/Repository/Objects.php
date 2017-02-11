<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Objects list
 *
 * PHP version 5
 *
 * Copyright © 2017 The Galette Team
 *
 * This file is part of Galette (http://galette.tuxfamily.org).
 *
 * Galette is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Galette is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Galette. If not, see <http://www.gnu.org/licenses/>.
 *
 * @category  Repository
 * @package   Galette
 *
 * @author    Johan Cwiklinski <johan@x-tnd.be>
 * @copyright 2017 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @link      http://galette.tuxfamily.org
 * @since     2017-02-10
 */

namespace GaletteObjectsLend\Repository;

use Galette\Entity\DynamicFields;

use Analog\Analog;
use Galette\Core\Db;
use Zend\Db\Sql\Expression;
use Galette\Repository\Repository;
use GaletteObjectsLend\Filters\ObjectsList;
use GaletteObjectsLend\Preferences;
use GaletteObjectsLend\LendObject;
use GaletteObjectsLend\LendCategory;
use GaletteObjectsLend\LendRent;
use GaletteObjectsLend\LendStatus;

/**
 * Objects list
 *
 * @name Objects
 * @category  Repository
 * @package   GaletteObjectsLend
 *
 * @author    Johan Cwiklinski <johan@x-tnd.be>
 * @copyright 2017 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @link      http://galette.tuxfamily.org
 */
class Objects
{
    const TABLE = LendObject::TABLE;
    const PK = LendObject::PK;

    const ALL_OBJECTS = 0;
    const ACTIVE_OBJECTS = 1;
    const INACTIVE_OBJECTS = 2;

    const FILTER_NAME = 0;
    const FILTER_SERIAL = 1;
    const FILTER_DIM = 2;
    const FILTER_ID = 3;

    const ORDERBY_NAME = 0;
    const ORDERBY_SERIAL = 1;
    const ORDERBY_PRICE = 2;
    const ORDERBY_RENTPRICE = 3;
    const ORDERBY_WEIGHT = 4;
    const ORDERBY_STATUS = 5;

    private $filters = false;
    private $count = null;
    private $errors = array();
    private $prefs;

    /**
     * Default constructor
     *
     * @param Db          $zdb     Database instance
     * @param Preferences $lprefs  Lends preferences instance
     * @param ObjectsList $filters Filtering
     */
    public function __construct(Db $zdb, Preferences $lprefs, ObjectsList $filters = null)
    {
        $this->zdb = $zdb;
        $this->prefs = $lprefs;

        if ($filters === null) {
            $this->filters = new ObjectsList();
        } else {
            $this->filters = $filters;
        }
    }


    /**
     * Get members list
     *
     * @param boolean $as_objects return the results as an array of
     *                               Object object.
     * @param array   $fields     field(s) name(s) to get. Should be a string or
     *                               an array. If null, all fields will be
     *                               returned
     * @param boolean $count      true if we want to count members
     * @param boolean $limit      true if we want records pagination
     *
     * @return LendObject[]|ResultSet
     */
    public function getObjectsList(
        $as_objects = false,
        $fields = null,
        $count = true,
        $limit = true,
        $all_rents = false
    ) {
        try {
            $select = $this->buildSelect($fields, false, $count);

            //add limits to retrieve only relevant rows
            if ($limit === true) {
                $this->filters->setLimit($select);
            }

            $rows = $this->zdb->execute($select);
            $this->filters->query = $this->zdb->query_string;

            $objects = array();
            if ($as_objects) {
                foreach ($rows as $row) {
                    $deps = ['last_rent' => true];
                    if ($all_rents === true) {
                        $deps['rents'] = true;
                    }
                    $objects[] = new LendObject($row, false, $deps);
                }
            } else {
                $objects = $rows;
            }
            return $objects;
        } catch (\Exception $e) {
            Analog::log(
                'Cannot list objects | ' . $e->getMessage(),
                Analog::WARNING
            );
        }
    }

    /**
     * Remove specified objects
     *
     * @param integer|array $ids Objects identifiers to delete
     *
     * @return boolean
     */
    public function removeObjects($ids)
    {
        /*global $zdb, $hist;

        $list = array();
        if ( is_numeric($ids) ) {
            //we've got only one identifier
            $list[] = $ids;
        } else {
            $list = $ids;
        }

        if ( is_array($list) ) {
            try {
                $zdb->connection->beginTransaction();

                //Retrieve some informations
                $select = $zdb->select(self::TABLE);
                $select->columns(
                    array(self::PK, 'nom_adh', 'prenom_adh')
                )->where->in(self::PK, $list);

                $results = $zdb->execute($select);

                $infos = null;
                foreach ($results as $member ) {
                    $str_adh = $member->id_adh . ' (' . $member->nom_adh . ' ' .
                        $member->prenom_adh . ')';
                    $infos .=  $str_adh . "\n";

                    $p = new Picture($member->id_adh);
                    if ( $p->hasPicture() ) {
                        if ( !$p->delete(false) ) {
                            Analog::log(
                                'Unable to delete picture for member ' . $str_adh,
                                Analog::ERROR
                            );
                            throw new \Exception(
                                'Unable to delete picture for member ' .
                                $str_adh
                            );
                        } else {
                            $hist->add(
                                _T("Member Picture deleted"),
                                $str_adh
                            );
                        }
                    }
                }

                //delete contributions
                $del_qry = $zdb->delete(Contribution::TABLE);
                $del_qry->where->in(
                    self::PK, $list
                );
                $del = $zdb->execute($del_qry);

                //delete transactions
                $del_qry = $zdb->delete(Transaction::TABLE);
                $del_qry->where->in(self::PK, $list);
                $del = $zdb->execute($del_qry);

                //delete groups membership/mamagmentship
                $del = Groups::removeMemberFromGroups((int)$member->id_adh);

                //delete reminders
                $del_qry = $zdb->delete(Reminder::TABLE);
                $del_qry->where->in(
                    'reminder_dest', $list
                );
                $del = $zdb->execute($del_qry);

                //delete members
                $del_qry = $zdb->delete(self::TABLE);
                $del_qry->where->in(
                    self::PK, $list
                );
                $del = $zdb->execute($del_qry);

                //commit all changes
                $zdb->connection->commit();

                //add an history entry
                $hist->add(
                    _T("Delete members cards, transactions and dues"),
                    $infos
                );

                return true;
            } catch (\Exception $e) {
                $zdb->connection->rollBack();
                if ( $e instanceof \Zend_Db_Statement_Exception
                    && $e->getCode() == 23000
                ) {
                    Analog::log(
                        'Member still have existing dependencies in the ' .
                        'database, maybe a mailing or some content from a ' .
                        'plugin. Please remove dependencies before trying ' .
                        'to remove him.',
                        Analog::ERROR
                    );
                    $this->errors[] = _T("Cannot remove a member who still have dependencies (mailings, ...)");
                } else {
                    Analog::log(
                        'Unable to delete selected member(s) |' .
                        $e->getMessage(),
                        Analog::ERROR
                    );
                }
                return false;
            }
        } else {
            //not numeric and not an array: incorrect.
            Analog::log(
                'Asking to remove members, but without providing an array or a single numeric value.',
                Analog::WARNING
            );
            return false;
        }*/
    }

    /**
     * Get Objects list
     *
     * @param boolean $as_objects return the results as an array of
     *                            Object object.
     * @param array   $fields     field(s) name(s) to get. Should be a string or
     *                            an array. If null, all fields will be
     *                            returned
     *
     * @return LendObject[]|ResultSet
     */
    public function getList($as_objects = false, $fields = null)
    {
        return $this->getObjectsList(
            $as_objects,
            $fields,
            false,
            false,
            false,
            false
        );
    }

    /**
     * Builds the SELECT statement
     *
     * @param array $fields fields list to retrieve
     * @param bool  $photos true if we want to get only members with photos
     *                      Default to false, only relevant for SHOW_PUBLIC_LIST
     * @param bool  $count  true if we want to count members, defaults to false
     *
     * @return Select SELECT statement
     */
    private function buildSelect($fields, $photos, $count = false)
    {
        global $zdb, $login;

        try {
            $fieldsList = ( $fields != null )
                            ? (( !is_array($fields) || count($fields) < 1 ) ? (array)'*'
                            : $fields) : (array)'*';

            $select = $zdb->select(LEND_PREFIX . self::TABLE, 'o');
            $select->columns($fieldsList);

            $select->quantifier('DISTINCT');

            $select->join(
                array('c' => PREFIX_DB . LEND_PREFIX . LendCategory::TABLE),
                'o.' . LendCategory::PK . '=c.' . LendCategory::PK,
                array(),
                $select::JOIN_LEFT
            );

            $select->join(
                array('r' => PREFIX_DB . LEND_PREFIX . LendRent::TABLE),
                'o.' . LendObject::PK . '=r.' . LendObject::PK,
                array(),
                $select::JOIN_LEFT
            );

            $select->join(
                array('s' => PREFIX_DB . LEND_PREFIX . LendStatus::TABLE),
                'r.' . LendStatus::PK . '=s.' . LendStatus::PK,
                array(LendStatus::PK, 'status_text'),
                $select::JOIN_LEFT
            );

            if ($this->filters !== false) {
                $this->buildWhereClause($select);
            }
            $select->order($this->buildOrderClause($fields));

            if ($count) {
                $this->proceedCount($select);
            }

            return $select;
        } catch (\Exception $e) {
            Analog::log(
                'Cannot build SELECT clause for members | ' . $e->getMessage(),
                Analog::WARNING
            );
            return false;
        }
    }

    /**
     * Count members from the query
     *
     * @param Select $select Original select
     *
     * @return void
     */
    private function proceedCount($select)
    {
        global $zdb;

        try {
            $countSelect = clone $select;
            $countSelect->reset($countSelect::COLUMNS);
            $countSelect->reset($countSelect::ORDER);
            $countSelect->reset($countSelect::HAVING);
            $countSelect->columns(
                array(
                    'count' => new Expression('count(DISTINCT o.' . self::PK . ')')
                )
            );

            $have = $select->having;
            if ($have->count() > 0) {
                foreach ($have->getPredicates() as $h) {
                    $countSelect->where($h);
                }
            }

            $results = $zdb->execute($countSelect);

            $this->count = $results->current()->count;
            if (isset($this->filters) && $this->count > 0) {
                $this->filters->setCounter($this->count);
            }
        } catch (\Exception $e) {
            Analog::log(
                'Cannot count objects | ' . $e->getMessage(),
                Analog::WARNING
            );
            return false;
        }
    }

    /**
     * Builds the order clause
     *
     * @param array $fields Fields list to ensure ORDER clause
     *                      references selected fields. Optionnal.
     *
     * @return string SQL ORDER clause
     */
    private function buildOrderClause($fields = null)
    {
        $order = array();
        switch ($this->filters->orderby) {
            case self::ORDERBY_NAME:
                if ($this->canOrderBy('name', $fields)) {
                    $order[] = 'name ' . $this->filters->getDirection();
                }
                break;
            case self::ORDERBY_SERIAL:
                if ($this->canOrderBy('serial_number', $fields)) {
                    $order[] = 'serial_number ' . $this->filters->getDirection();
                }
                break;
            case self::ORDERBY_PRICE:
                if ($this->canOrderBy('price', $fields)) {
                    $order[] = 'price ' . $this->filters->getDirection();
                }
                break;
            case self::ORDERBY_RENTPRICE:
                if ($this->canOrderBy('rent_price', $fields)) {
                    $order[] = 'rent_price ' . $this->filters->getDirection();
                }
                break;
            case self::ORDERBY_WEIGHT:
                if ($this->canOrderBy('weight', $fields)) {
                    $order[] = 'weight ' . $this->filters->getDirection();
                }
                break;
            case self::ORDERBY_STATUS:
                if ($this->canOrderBy('status_text', $fields)) {
                    $order[] = 'status_text ' . $this->filters->getDirection();
                }
                break;
        }

        return $order;
    }

    /**
     * Builds where clause, for filtering on simple list mode
     *
     * @param Select $select Original select
     *
     * @return string SQL WHERE clause
     */
    private function buildWhereClause($select)
    {
        global $login;

        try {
            if (is_array($this->filters->selected) && count($this->filters->selected) > 0) {
                $select->where->in('o.' . self::PK, $this->filters->selected);
            }

            if ($this->filters->active_filter == self::ACTIVE_OBJECTS) {
                $select->where('o.is_active = true');
            }
            if ($this->filters->active_filter == self::INACTIVE_OBJECTS) {
                $select->where('o.is_active = false');
            }

            if ($this->filters->category_filter != 'all' && $this->filters->category_filter !== null) {
                $select->where('o.' . LendCategory::PK . '=' . $this->filters->category_filter);
            }

            if ($this->filters->filter_str != '') {
                $token = $this->zdb->platform->quoteValue(
                    '%' . strtolower($this->filters->filter_str) . '%'
                );

                switch ($this->filters->field_filter) {
                    case self::FILTER_NAME:
                        if (TYPE_DB === 'pgsql') {
                            $sep = " || ' ' || ";
                            $pre = '';
                            $post = '';
                        } else {
                            $sep = ', " ", ';
                            $pre = 'CONCAT(';
                            $post=')';
                        }

                        if ($this->prefs->getPreferences()['VIEW_DESCRIPTION']) {
                            $select->where(
                                '(' .
                                $pre . 'LOWER(o.name)' . $sep .
                                'LOWER(o.description)' . $post  . ' LIKE ' .
                                $token . ')'
                            );
                        } else {
                            $select->where(
                                'o.name LIKE ' . $token
                            );
                        }
                        break;
                    case self::FILTER_SERIAL:
                        $select->where(
                            'LOWER(serial_number) LIKE ' .
                            $token
                        );
                        break;
                    case self::FILTER_DIM:
                        $select->where(
                            'LOWER(dimension) LIKE ' .
                            $token
                        );
                        break;
                    case self::FILTER_ID:
                        $select->where->equalTo('o.' . LendObject::PK, $this->filters->filter_str);
                        break;
                }
            }
        } catch (\Exception $e) {
            Analog::log(
                __METHOD__ . ' | ' . $e->getMessage(),
                Analog::WARNING
            );
        }
    }

    /**
     * Is field allowed to order? it shoulsd be present in
     * provided fields list (those that are SELECT'ed).
     *
     * @param string $field_name Field name to order by
     * @param array  $fields     SELECTE'ed fields
     *
     * @return boolean
     */
    private function canOrderBy($field_name, $fields)
    {
        if (!is_array($fields)) {
            return true;
        } elseif (in_array($field_name, $fields)) {
            return true;
        } else {
            Analog::log(
                'Trying to order by ' . $field_name  . ' while it is not in ' .
                'selected fields.',
                Analog::WARNING
            );
            return false;
        }
    }

    /**
     * Get count for current query
     *
     * @return int
     */
    public function getCount()
    {
        return $this->count;
    }

    /**
     * Get registered errors
     *
     * @return array
     */
    public function getErrors()
    {
        return $this->errors;
    }
}
