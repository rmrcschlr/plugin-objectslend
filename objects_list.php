<?php

/**
 * Lend objects list
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

use GaletteObjectsLend\LendObject;
use GaletteObjectsLend\LendCategory;
use GaletteObjectsLend\Preferences;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$lendsprefs = new Preferences($zdb);

$tpl->assign('page_title', _T("Managment of the assocation objects"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

/**
 * Valeurs de la session
 */
if (filter_has_var(INPUT_GET, 'category_id')) {
    unset($session[LEND_PREFIX . 'page']);
    $session[LEND_PREFIX . 'category_id'] = filter_input(INPUT_GET, 'category_id');
}

if (filter_has_var(INPUT_GET, 'search')) {
    unset($session[LEND_PREFIX . 'page']);
    $session[LEND_PREFIX . 'search'] = filter_input(INPUT_GET, 'search');
}

if (filter_has_var(INPUT_GET, 'nb_lines') && $session[LEND_PREFIX . 'nb_lines'] != filter_input(INPUT_GET, 'nb_lines')) {
    unset($session[LEND_PREFIX . 'page']);
    $session[LEND_PREFIX . 'nb_lines'] = filter_input(INPUT_GET, 'nb_lines');
}

if (filter_has_var(INPUT_GET, 'tri')) {
    $session[LEND_PREFIX . 'tri'] = filter_input(INPUT_GET, 'tri');
}

if (filter_has_var(INPUT_GET, 'direction')) {
    $session[LEND_PREFIX . 'direction'] = filter_input(INPUT_GET, 'direction');
}

if (filter_has_var(INPUT_GET, 'page')) {
    $session[LEND_PREFIX . 'page'] = filter_input(INPUT_GET, 'page');
}

/*
 * Récupération de la recherche
 */
if (filter_has_var(INPUT_POST, 'go_search')) {
    unset($session[LEND_PREFIX . 'page']);
    $session[LEND_PREFIX . 'search'] = filter_input(INPUT_POST, 'search');
}

if (filter_has_var(INPUT_POST, 'reset_search')) {
    unset($session[LEND_PREFIX . 'page']);
    $session[LEND_PREFIX . 'search'] = '';
}

$category_id = array_key_exists(LEND_PREFIX . 'category_id', $session) ? $session[LEND_PREFIX . 'category_id'] : -1;
$tri = array_key_exists(LEND_PREFIX . 'tri', $session) ? $session[LEND_PREFIX . 'tri'] : 'name';
$direction = array_key_exists(LEND_PREFIX . 'direction', $session) ? $session[LEND_PREFIX . 'direction'] : 'asc';
$page = array_key_exists(LEND_PREFIX . 'page', $session) ? $session[LEND_PREFIX . 'page'] : 1;
$nb_lines = array_key_exists(LEND_PREFIX . 'nb_lines', $session) ? $session[LEND_PREFIX . 'nb_lines'] : $lendsprefs->{Preferences::PARAM_OBJECTS_PER_PAGE_DEFAULT};
$ajax = filter_has_var(INPUT_GET, 'mode') ? filter_input(INPUT_GET, 'mode') === 'ajax' : false;

$search = array_key_exists(LEND_PREFIX . 'search', $session) ? $session[LEND_PREFIX . 'search'] : '';

$nb_lines_list = array();
$param_choices = explode(';', $lendsprefs->{Preferences::PARAM_OBJECTS_PER_PAGE_NUMBER_LIST});
foreach ($param_choices as $choice) {
    if (is_numeric(trim($choice)) && !in_array(intval($choice), $nb_lines_list)) {
        $nb_lines_list[] = intval($choice);
    }
}
sort($nb_lines_list);

$msg_taken = false;
$msg_given = false;
$msg_not_given = false;
$msg_canceled = false;
$msg_no_right = false;
$msg_deleted = false;
$msg_disabled = false;
if (filter_has_var(INPUT_GET, 'msg')) {
    switch (filter_input(INPUT_GET, 'msg')) {
        case 'unavailable':
            $error_detected[] = _T("The object is not available!");
            break;
        case 'taken':
            $msg_taken = true;
            break;
        case 'given':
            $msg_given = true;
            break;
        case 'not_given':
            $msg_not_given = true;
            break;
        case 'canceled':
            $msg_canceled = true;
            break;
        case 'no_right':
            $msg_no_right = true;
            break;
        case 'deleted':
            $msg_deleted = true;
            break;
        case 'disabled':
            $msg_disabled = true;
            break;
    }
}

/**
 * Récupération des objets
 */
$objects = LendObject::getPaginatedObjects($tri, $direction, $search, intval($category_id), $login->isStaff() || $login->isAdmin(), $page - 1, $nb_lines);
$nb_objects = LendObject::getNbObjects($category_id, $search, $login->isStaff() || $login->isAdmin());

$nb_objects_no_category = LendObject::getObjectsNumberWithoutCategory($search);
$sum_objects_no_category = LendObject::getSumPriceObjectsWithoutCategory($search);

/**
 * Mise en forme des résultats
 */
if (strlen($search) > 0) {
    foreach ($objects as $obj) {
        if ($lendsprefs->{Preferences::PARAM_VIEW_SERIAL}) {
            $obj->search_serial_number = preg_replace('/(' . $search . ')/i', '<span class="search">$1</span>', $obj->serial_number);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_NAME}) {
            $obj->search_name = preg_replace('/(' . $search . ')/i', '<span class="search">$1</span>', $obj->name);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_DESCRIPTION}) {
            $obj->search_description = preg_replace('/(' . $search . ')/i', '<span class="search">$1</span>', $obj->description);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_DIMENSION}) {
            $obj->search_dimension = preg_replace('/(' . $search . ')/i', '<span class="search">$1</span>', $obj->dimension);
        }
    }
}

/**
 * Calcul de la pagination
 */
$pagination = Preferences::paginate($page, $nb_objects, $nb_lines, '');

/**
 * Récupération des catégories
 */
$categories = array();
if ($lendsprefs->{Preferences::PARAM_VIEW_CATEGORY}) {
    if (strlen($search) < 1) {
        $categories = LendCategory::getActiveCategories(false);
    } else {
        $categories = LendCategory::getActiveCategoriesWithSearchCriteria($search);
    }
}

$tpl->assign('objects', $objects);
$tpl->assign('tri', $tri);
$tpl->assign('direction', $direction);
$tpl->assign('pagination', $pagination);
$tpl->assign('page', $page);
$tpl->assign('nb_results', $nb_objects);
$tpl->assign('nb_lines', $nb_lines);
$tpl->assign('nb_lines_list', $nb_lines_list);
$tpl->assign('msg_taken', $msg_taken);
$tpl->assign('msg_given', $msg_given);
$tpl->assign('msg_not_given', $msg_not_given);
$tpl->assign('msg_canceled', $msg_canceled);
$tpl->assign('msg_no_right', $msg_no_right);
$tpl->assign('msg_deleted', $msg_deleted);
$tpl->assign('msg_disabled', $msg_disabled);
$tpl->assign('require_calendar', true);
$tpl->assign('require_dialog', true);

$tpl->assign('categories', $categories);
$tpl->assign('nb_all_categories', $nb_objects_no_category);
$tpl->assign('sum_all_categories', number_format($sum_objects_no_category, 2, ',', ''));
$tpl->assign('category_id', $category_id);
$tpl->assign('sort_suffix', $category_id > 0 ? '&category_id=' . $category_id : '');
$tpl->assign('search', $search);

$tpl->assign('lendsprefs', $lendsprefs->getpreferences());
$tpl->assign('olendsprefs', $lendsprefs);
$tpl->assign('ajax', $ajax);
$tpl->assign('time', time());

$tpl->assign('error_detected', $error_detected);

if ($ajax) {
    $tpl->display('objects_list.tpl');
} else {
    $content = $tpl->fetch('objects_list.tpl', LEND_SMARTY_PREFIX);
    $tpl->assign('content', $content);
    //Set path to main Galette's template
    $tpl->template_dir = $orig_template_path;
    $tpl->display('page.tpl', LEND_SMARTY_PREFIX);
}
