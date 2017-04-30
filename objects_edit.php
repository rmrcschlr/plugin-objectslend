<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Create or edit an object
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
use GaletteObjectsLend\ObjectPicture;
use GaletteObjectsLend\LendRent;
use GaletteObjectsLend\LendStatus;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';


$lendsprefs = new Preferences($zdb);

//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

// Récupération id
$object_id = null;

if (filter_has_var(INPUT_GET, 'object_id')) {
    $object_id = (int)filter_input(INPUT_GET, 'object_id');
} elseif (filter_has_var(INPUT_POST, 'object_id')) {
    $object_id = (int)filter_input(INPUT_POST, 'object_id');
}

$rents = array();
if ($object_id != null) {
    $object = new LendObject($object_id);
    $rents = LendRent::getRentsForObjectId($object_id);
    $title = _T("Edit an object");
} else {
    if (filter_has_var(INPUT_GET, 'clone_object_id')) {
        $object = new LendObject(intval(filter_input(INPUT_GET, 'clone_object_id')), true);
        $title = _T("Duplicate object");
        $warning_detected[] = _T("You are cloning this object, not editing it!");
    } else {
        $object = new LendObject();
        $title = _T("Create an object");
    }
    $show_status = true;
}

/**
 * Enregistrement des modifications
 */
if (filter_has_var(INPUT_POST, 'save')) {
    // Modification de l'objet
    $object->name = filter_input(INPUT_POST, 'name');
    $object->description = filter_input(INPUT_POST, 'description');
    //TODO: check if category do exits?
    $object->category_id = filter_has_var(INPUT_POST, 'category_id') ? filter_input(INPUT_POST, 'category_id') : null;
    $object->serial_number = filter_input(INPUT_POST, 'serial');
    if (filter_input(INPUT_POST, 'price') != '') {
        //FIXME: better currency format handler
        $object->price = str_replace(' ', '', str_replace(',', '.', filter_input(INPUT_POST, 'price')));
    }
    if (filter_input(INPUT_POST, 'rent_price') != '') {
        //FIXME: better currency format handler
        $object->rent_price = str_replace(' ', '', str_replace(',', '.', filter_input(INPUT_POST, 'rent_price')));
    }
    $object->price_per_day = filter_input(INPUT_POST, 'price_per_day') == 'true';
    $object->dimension = filter_input(INPUT_POST, 'dimension');
    if (filter_input(INPUT_POST, 'weight') != '') {
        //FIXME: better format handler
        $object->weight = str_replace(' ', '', str_replace(',', '.', filter_input(INPUT_POST, 'weight')));
    }
    $object->is_active = filter_input(INPUT_POST, 'is_active') == 'true';

    if ($object->store()) {
        $success_detected[] = _T("Object has been successfully stored!");
    } else {
        $error_detected[] = _T("Something went wrong saving object :(");
    }

    // Enregistrement du 1er statut lors de la création
    if (filter_has_var(INPUT_POST, '1st_status')) {
        $rent = new LendRent();
        $rent->object_id = $object->object_id;
        $rent->status_id = filter_input(INPUT_POST, '1st_status');
        $rent->store();
    }

    // Enregistrement de la photo
    if (isset($_FILES['picture'])) {
        if ($_FILES['picture']['tmp_name'] != '') {
            if (is_uploaded_file($_FILES['picture']['tmp_name'])) {
                $objPicture = new ObjectPicture($plugins, $object->object_id);
                $res = $objPicture->store($_FILES['picture']);
                if ($res < 0) {
                    switch ($res) {
                        case ObjectPicture::INVALID_FILE:
                            $patterns = array('|%s|', '|%t|');
                            $replacements = array(
                                $objPicture->getAllowedExts(),
                                htmlentities($objPicture->getBadChars())
                            );
                            $error_detected[] = preg_replace(
                                $patterns,
                                $replacements,
                                _T("- Filename or extension is incorrect. Only %s files are allowed. File name should not contains any of: %t")
                            );
                            break;
                        case ObjectPicture::FILE_TOO_BIG:
                            $error_detected[] = preg_replace(
                                '|%d|',
                                ObjectPicture::MAX_FILE_SIZE,
                                _T("File is too big. Maximum allowed size is %d")
                            );
                            break;
                        case ObjectPicture::MIME_NOT_ALLOWED:
                            /** FIXME: should be more descriptive */
                            $error_detected[] = _T("Mime-Type not allowed");
                            break;
                        case ObjectPicture::SQL_ERROR:
                        case ObjectPicture::SQL_BLOB_ERROR:
                            $error_detected[] = _T("An SQL error has occured.");
                            break;
                    }
                }
            }
        }
    }

    // Suppression de la photo
    if (filter_has_var(INPUT_POST, 'del_picture') && filter_input(INPUT_POST, 'del_picture') == '1') {
        $pic = new ObjectPicture($plugins, $object->object_id);
        $pic->delete();
    }

    $object_id = $object->object_id;
}

/**
 * Modification du statut
 */
if (filter_has_var(INPUT_POST, 'status')) {
    LendRent::closeAllRentsForObject(intval($object_id), filter_input(INPUT_POST, 'new_comment'));

    $rent = new LendRent();
    $rent->object_id = $object_id;
    $rent->status_id = filter_input(INPUT_POST, 'new_status');
    if (filter_input(INPUT_POST, 'new_adh') != 'null') {
        $rent->adherent_id = filter_input(INPUT_POST, 'new_adh');
    }
    $rent->store();
}

$show_status = false;
$statuses = LendStatus::getActiveStatuses();
$adherents = LendRent::getAllActivesAdherents();

$tpl->assign('page_title', $title);
$tpl->assign('object', $object);
$tpl->assign('rents', $rents);
$tpl->assign('show_status', $show_status);
$tpl->assign('statuses', $statuses);
$tpl->assign('adherents', $adherents);
$tpl->assign('lendsprefs', $lendsprefs->getpreferences());
$tpl->assign('olendsprefs', $lendsprefs);
$tpl->assign('categories', LendCategory::getActiveCategories());
$tpl->assign('time', time());
$tpl->assign('success_detected', $success_detected);
$tpl->assign('error_detected', $error_detected);
$tpl->assign('warning_detected', $warning_detected);

$content = $tpl->fetch('objects_edit.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
