<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Edit or create a category
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

$lendsprefs = new Preferences($zdb);

//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$id = null;
if (filter_has_var(INPUT_POST, 'category_id')) {
    $id = (int)$_POST['category_id'];
} elseif (filter_has_var(INPUT_GET, 'category_id')) {
    $id = (int)$_GET['category_id'];
}

if ($id !== null) {
    $category = new LendCategory($id);
    $title = _T("Edit category");
} else {
    $category = new LendCategory();
    $title = _T("New category");
}

/**
 * Store changes
 */
if (filter_has_var(INPUT_POST, 'save')) {
    //$c = new LendCategory(intval(filter_input(INPUT_POST, 'category_id')));
    $category->name = filter_input(INPUT_POST, 'name');
    $category->is_active = filter_input(INPUT_POST, 'is_active') == 'true';
    if ($category->store()) {
        // picture upload
        if (isset($_FILES['picture'])) {
            if ($_FILES['picture']['error'] === UPLOAD_ERR_OK) {
                if ($_FILES['picture']['tmp_name'] !='') {
                    if (is_uploaded_file($_FILES['picture']['tmp_name'])) {
                        $res = $category->picture->store($_FILES['picture']);
                        if ($res < 0) {
                            $error_detected[]
                                = $category->picture->getErrorMessage($res);
                        }
                    }
                }
            } elseif ($_FILES['picture']['error'] !== UPLOAD_ERR_NO_FILE) {
                Analog::log(
                    $category->picture->getPhpErrorMessage($_FILES['picture']['error']),
                    Analog::WARNING
                );
                $error_detected[] = $category->picture->getPhpErrorMessage(
                    $_FILES['picture']['error']
                );
            }
        }

        if (isset($_POST['del_picture'])) {
            if (!$category->picture->delete($category->category_id)) {
                $error_detected[] = _T("Delete failed");
                Analog::log(
                    'Unable to delete picture for member ' . $category->name,
                    Analog::ERROR
                );
            }
        }
    } else {
        $error_detected[] = _T("An error occured while storing the category.");
    }

    if (count($error_detected) == 0) {
        header('Location: categories_list.php?msg=saved');
    }
}

$tpl->assign('page_title', $title);
$tpl->assign('category', $category);
$tpl->assign('lendsprefs', $lendsprefs->getpreferences());
$tpl->assign('olendsprefs', $lendsprefs);
$tpl->assign('time', time());
$tpl->assign('error_detected', $error_detected);

$content = $tpl->fetch('category_edit.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
