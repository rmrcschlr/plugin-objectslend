<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Categories list
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

use GaletteObjectsLend\LendCategory;
use GaletteObjectsLend\Preferences;
use GaletteObjectsLend\Repository\Categories;
use GaletteObjectsLend\Filters\CategoriesList;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$lendsprefs = new Preferences($zdb);

if (isset($session['filters']['objectslend_categories'])) {
    $filters = unserialize($session['filters']['objectslend_categories']);
} else {
    $filters = new CategoriesList();
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

$categories = new Categories($zdb, $filters);
$list = $categories->getCategoriesList(true);


if (isset($_GET['msg'])) {
    switch ($_GET['msg']) {
        case 'deleted':
            $success_detected[] = _T("Category has been successfully deleted");
            break;
        case 'notdeleted':
            $error_detected[] = _T("Category has not been deleted :(");
            break;
        case 'saved':
            $success_detected[] = _T("Category has been saved");
            break;
        case 'canceled':
            $warning_detected[] = _T("Category edition has been canceled");
            break;
    }
}

//store current filters in session
$session['filters']['objectslend_categories'] = serialize($filters);

//assign pagination variables to the template and add pagination links
$filters->setSmartyPagination($tpl, false);

$tpl->assign('page_title', _T("Categories list"));

$tpl->assign('categories', $list);
$tpl->assign('nb_categories', count($list));
$tpl->assign('filters', $filters);
$tpl->assign('success_detected', $success_detected);
$tpl->assign('warning_detected', $warning_detected);
$tpl->assign('error_detected', $error_detected);
$tpl->assign('lendsprefs', $lendsprefs->getpreferences());
$tpl->assign('olendsprefs', $lendsprefs);
$tpl->assign('time', time());

//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$content = $tpl->fetch('categories_list.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
