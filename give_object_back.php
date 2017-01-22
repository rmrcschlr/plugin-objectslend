<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Give an object back
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
use GaletteObjectsLend\Preferences;
use GaletteObjectsLend\LendObjectPicture;
use GaletteObjectsLend\LendRent;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$tpl->assign('page_title', _T("BACK OBJECTS.PAGE TITLE"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

/**
 * Prise de l'objet -> on valide et retourne à la liste
 */
if (filter_has_var(INPUT_POST, 'yes')) {
    $object_id = intval(filter_input(INPUT_POST, 'object_id'));
    LendRent::closeAllRentsForObject($object_id, filter_input(INPUT_POST, 'comments'));
    $rent = new LendRent();
    $rent->object_id = $object_id;
    $rent->status_id = filter_input(INPUT_POST, 'status');
    $rent->store();

    if (filter_has_var(INPUT_POST, 'mode') && filter_input(INPUT_POST, 'mode') === 'ajax') {
        echo "OK";
        exit;
    } else {
        header('location: objects_list.php?msg=given');
    }
}

/**
 * Annulation de rendre l'objet
 */
if (array_key_exists('cancel', $_POST)) {
    header('location: objects_list.php?msg=not_given');
}

$object_id = intval(filter_input(INPUT_GET, 'object_id'));
$ajax = filter_has_var(INPUT_GET, 'mode') ? filter_input(INPUT_GET, 'mode') === 'ajax' : false;

$rents = LendRent::getRentsForObjectId($object_id);
$last_rent = false;
if (count($rents) > 0) {
    $last_rent = $rents[0];
    // Vérification qu'on a les droits pour fermer cette location
    if ($login->id != $last_rent->adherent_id && !$login->isAdmin() && !$login->isStaff()) {
        header('location: objects_list.php?msg=no_right');
    }
}

$object = new LendObject($object_id);
/**
 * Tooltip de la photo
 */
$s = LendObjectPicture::getHeightWidthForObject($object);

$object->tooltip_title = '<center>';
$object->tooltip_title .= '<img src=\'picture.php?quick=1&object_id=' . $object->object_id . '\' width=\'' . $s->width . '\' height=\'' . $s->height . '\'/>';
$object->tooltip_title .= '<br/><b>' . $object->name . '</b>';
if (Preferences::getParameterValue(Preferences::PARAM_VIEW_SERIAL) && strlen($object->serial_number) > 0) {
    $object->tooltip_title .= ' (' . $object->serial_number . ')';
}
$object->tooltip_title .= '<br/>&nbsp;';
if (Preferences::getParameterValue(Preferences::PARAM_VIEW_DESCRIPTION) && strlen($object->description) > 0) {
    $object->tooltip_title .= '<br/>' . $object->description;
}
if (Preferences::getParameterValue(Preferences::PARAM_VIEW_DIMENSION) && strlen($object->dimension) > 0) {
    $object->tooltip_title .= '<br/>' . _T('OBJECTS LIST.DIMENSION') . ' : ' . $object->dimension;
}
if (Preferences::getParameterValue(Preferences::PARAM_VIEW_WEIGHT) && $object->weight_bulk > 0) {
    $object->tooltip_title .= '<br/>' . _T('OBJECTS LIST.WEIGHT') . ' : ' . $object->weight;
}

$tpl->assign('object', $object);
$tpl->assign('statuses', LendStatus::getActiveHomeStatuses());
$tpl->assign('last_rent', $last_rent);
$tpl->assign('today', date('d/m/Y'));
$tpl->assign('ajax', $ajax);
$tpl->assign('view_object_thumb', Preferences::getParameterValue(Preferences::PARAM_VIEW_OBJECT_THUMB));
$tpl->assign('thumb_max_width', Preferences::getParameterValue(Preferences::PARAM_THUMB_MAX_WIDTH));
$tpl->assign('thumb_max_height', Preferences::getParameterValue(Preferences::PARAM_THUMB_MAX_HEIGHT));

if ($ajax) {
    $tpl->display('give_object_back.tpl', LEND_SMARTY_PREFIX);
} else {
    $content = $tpl->fetch('give_object_back.tpl', LEND_SMARTY_PREFIX);
    $tpl->assign('content', $content);
    //Set path to main Galette's template
    $tpl->template_dir = $orig_template_path;
    $tpl->display('page.tpl', LEND_SMARTY_PREFIX);
}
