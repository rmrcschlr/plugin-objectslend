<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Give more objects back
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
use GaletteObjectsLend\LendParameter;
use GaletteObjectsLend\LendRent;
use GaletteObjectsLend\LendStatus;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

/*
 * Traitement résultats
 */
if (filter_has_var(INPUT_POST, 'yes')) {
    $objects_ids = filter_input(INPUT_POST, 'objects_id');
    if (filter_has_var(INPUT_POST, 'safe_objects_ids')) {
        $objects_ids = explode(',', filter_input(INPUT_POST, 'safe_objects_ids'));
    }
    foreach ($objects_ids as $o_id) {
        LendRent::closeAllRentsForObject($o_id, filter_input(INPUT_POST, 'comments'));
        $rent = new LendRent();
        $rent->object_id = $o_id;
        $rent->status_id = filter_input(INPUT_POST, 'status');
        $rent->store();
    }

    if (filter_has_var(INPUT_POST, 'mode') && filter_input(INPUT_POST, 'mode') === 'ajax') {
        echo "OK";
        exit;
    } else {
        header('location: objects_list.php?msg=given');
    }
}

$tpl->assign('page_title', _T("BACK OBJECTS.PAGE TITLE"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$objects_ids = filter_has_var(INPUT_GET, 'objects_ids') ? explode(',', filter_input(INPUT_GET, 'objects_ids')) : array();
$ajax = filter_has_var(INPUT_GET, 'mode') ? filter_input(INPUT_GET, 'mode') === 'ajax' : false;

/**
 * Récupération des objets et vérification qu'ils sont bien sortis
 */
$objects = array();
$safe_objects_ids = array();
foreach (LendObject::getMoreObjectsByIds($objects_ids) as $obj) {
    if (!$obj->is_home_location) {
        $objects[] = $obj;
        $safe_objects_ids[] = $obj->object_id;
    }
}

$tpl->assign('objects', $objects);

$tpl->assign('statuses', LendStatus::getActiveHomeStatuses());

/**
 * Paramètres de visibilité des colonnes
 */
$tpl->assign('view_category', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_CATEGORY));
$tpl->assign('view_serial', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_SERIAL));
$tpl->assign('view_thumbnail', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_THUMBNAIL));
$tpl->assign('view_name', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_NAME));
$tpl->assign('view_description', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DESCRIPTION));
$tpl->assign('view_price', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_PRICE));
$tpl->assign('view_dimension', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DIMENSION));
$tpl->assign('view_weight', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_WEIGHT));
$tpl->assign('view_lend_price', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_LEND_PRICE));
$tpl->assign('view_object_thumb', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_OBJECT_THUMB));
$tpl->assign('thumb_max_width', LendParameter::getParameterValue(LendParameter::PARAM_THUMB_MAX_WIDTH));
$tpl->assign('thumb_max_height', LendParameter::getParameterValue(LendParameter::PARAM_THUMB_MAX_HEIGHT));
$tpl->assign('ajax', $ajax);
$tpl->assign('safe_objects_ids', join(',', $safe_objects_ids));

if ($ajax) {
    $tpl->display('give_more_objects_back.tpl', LEND_SMARTY_PREFIX);
} else {
    $content = $tpl->fetch('give_more_objects_back.tpl', LEND_SMARTY_PREFIX);
    $tpl->assign('content', $content);
    //Set path to main Galette's template
    $tpl->template_dir = $orig_template_path;
    $tpl->display('page.tpl', LEND_SMARTY_PREFIX);
}
