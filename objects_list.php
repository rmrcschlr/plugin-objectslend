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
use GaletteObjectsLend\Repository\Objects;
use GaletteObjectsLend\Filters\ObjectsList;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$lendsprefs = new Preferences($zdb);


if (isset($session['filters']['objectslend_objects'])) {
    $filters = unserialize($session['filters']['objectslend_objects']);
} else {
    $filters = new ObjectsList();
}

$ajax = (isset($_GET['mode']) && $_GET['mode'] === 'ajax');

if (isset($_POST['print_list'])
    || isset($_POST['print_objects'])
) {
    if (isset($_POST['object_ids'])) {
        $filters->selected = $_POST['object_ids'];
        $session['filters']['objectslend_print_objects'] = serialize($filters);

        if (isset($_POST['print_list'])) {
            $qstring = 'objects_list_print.php';
        } elseif (isset($_POST['print_objects'])) {
            $qstring = 'objects_print.php';
        }
        header('location: '.$qstring);
        die();
    } else {
        $error_detected[]
            = _T("No object was selected, please check at least one name.");
    }
}

// Simple filters
if (isset($_GET['page'])) {
    $filters->current_page = (int)$_GET['page'];
}

if (isset($_GET['clear_filter'])) {
    $filters->reinit();
} else {
    //string to filter
    if (isset($_GET['filter_str'])) { //filter search string
        $filters->filter_str = stripslashes(
            htmlspecialchars($_GET['filter_str'], ENT_QUOTES)
        );
    }

    //field to filter
    if (isset($_GET['field_filter'])) {
        if (is_numeric($_GET['field_filter'])) {
            $filters->field_filter = $_GET['field_filter'];
        }
    }

    //category to filter
    if (isset($_GET['category_filter'])) {
        if (is_numeric($_GET['category_filter'])) {
            $filters->category_filter = $_GET['category_filter'];
        } elseif ($_GET['category_filter'] == 'none') {
            $filters->category_filter = 'none';
        }
    }

    //activity to filter
    if (isset($_GET['active_filter'])) {
        if (is_numeric($_GET['active_filter'])) {
            $filters->active_filter = $_GET['active_filter'];
        }
    }
}

//numbers of rows to display
if (isset($_GET['nbshow']) && is_numeric($_GET['nbshow'])) {
    $filters->show = $_GET['nbshow'];
}

// Sorting
if (isset($_GET['tri'])) {
    $filters->orderby = $_GET['tri'];
}

if (!$login->isAdmin() && !$login->isStaff()) {
    $filters->active_filter = false;
}

$objects = new Objects($zdb, $lendsprefs, $filters);
$list = $objects->getObjectsList(true);

$msg_no_right = false;
if (filter_has_var(INPUT_GET, 'msg')) {
    switch (filter_input(INPUT_GET, 'msg')) {
        case 'unavailable':
            $error_detected[] = _T("The object is not available!");
            break;
        case 'taken':
            $success_detected[] = _T("Object has been took");
            break;
        case 'given':
            $success_detected[] = _T("Object has been returned!");
            break;
        case 'not_given':
            $warning_detected[] = _T("Object has not been returned! Don't forget it!");
            break;
        case 'canceled':
            $warning_detected[] = _T("Action has been canceled!");
            break;
        case 'no_right':
            $error_detected[] = _T("You can't return an object that you don't borrow!");
            break;
        case 'deleted':
            $success_detected[] = _T("Objects have been disabled!");
            break;
        case 'disabled':
            $success_detected[] = _T("Objects have been disabled!");
            break;
    }
}

$categories = $objects->getCategoriesList();

//store current filters in session
$session['filters']['objectslend_objects'] = serialize($filters);

//assign pagination variables to the template and add pagination links
$filters->setSmartyPagination($tpl, false);

$tpl->assign('page_title', _T("Objects managment"));

//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$tpl->assign('objects', $list);
$tpl->assign('nb_objects', $objects->getCount());
$tpl->assign('filters', $filters);
$tpl->assign('lendsprefs', $lendsprefs->getpreferences());
$tpl->assign('olendsprefs', $lendsprefs);
$tpl->assign('require_calendar', true);
$tpl->assign('require_dialog', true);
$tpl->assign('ajax', $ajax);
$tpl->assign('time', time());

$tpl->assign('error_detected', $error_detected);
$tpl->assign('success_detected', $success_detected);
$tpl->assign('warning_detected', $warning_detected);

$tpl->assign('msg_no_right', $msg_no_right);
$tpl->assign('categories', $categories);

$filters->setTplCommonsFilters($lendsprefs, $tpl);

if ($ajax) {
    $tpl->display('objects_list.tpl');
} else {
    $content = $tpl->fetch('objects_list.tpl', LEND_SMARTY_PREFIX);
    $tpl->assign('content', $content);
    //Set path to main Galette's template
    $tpl->template_dir = $orig_template_path;
    $tpl->display('page.tpl', LEND_SMARTY_PREFIX);
}
