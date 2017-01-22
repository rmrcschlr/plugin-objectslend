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

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$tpl->assign('page_title', _T("CATEGORIES LIST.PAGE TITLE"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$tri = filter_has_var(INPUT_GET, 'tri') ? filter_input(INPUT_GET, 'tri') : 'name';
$direction = filter_has_var(INPUT_GET, 'direction') ? filter_input(INPUT_GET, 'direction') : 'asc';
$saved = filter_has_var(INPUT_GET, 'msg') && filter_input(INPUT_GET, 'msg') == 'saved';
$canceled = filter_has_var(INPUT_GET, 'msg') && filter_input(INPUT_GET, 'msg') == 'canceled';
$deleted = filter_has_var(INPUT_GET, 'msg') && filter_input(INPUT_GET, 'msg') == 'deleted';

$categories = LendCategory::getAllCategories($tri, $direction);

$tpl->assign('categories', $categories);
$tpl->assign('nb_categories', count($categories));
$tpl->assign('tri', $tri);
$tpl->assign('direction', $direction);
$tpl->assign('msg_saved', $saved);
$tpl->assign('msg_canceled', $canceled);
$tpl->assign('msg_deleted', $deleted);
$tpl->assign('view_category_thumb', Preferences::getParameterValue(Preferences::PARAM_VIEW_CATEGORY_THUMB));
$tpl->assign('thumb_max_width', Preferences::getParameterValue(Preferences::PARAM_THUMB_MAX_WIDTH));
$tpl->assign('thumb_max_height', Preferences::getParameterValue(Preferences::PARAM_THUMB_MAX_HEIGHT));

$content = $tpl->fetch('categories_list.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
