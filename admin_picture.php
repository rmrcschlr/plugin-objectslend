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

use GaletteObjectsLend\LendObjectPicture;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$tpl->assign('page_title', _T("ADMIN PICTURE.PAGE TITLE"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

if (filter_has_var(INPUT_POST, 'save_categories') || filter_has_var(INPUT_POST, 'save_objects')) {
    $zip_name = filter_has_var(INPUT_POST, 'save_categories') ? 'categories.zip' : 'objects.zip';
    $zip = new ZipArchive();
    $zip->open($zip_name, ZipArchive::OVERWRITE);
    $dir_name = filter_has_var(INPUT_POST, 'save_categories') ? 'categories_pictures' : 'objects_pictures';
    $dir_pictures = opendir($dir_name);
    while (($file = readdir($dir_pictures)) !== FALSE) {
        if (preg_match('/^[0-9]+$/', pathinfo($file, PATHINFO_FILENAME)) !== FALSE) {
            $zip->addFile($dir_name . '/' . $file, $file);
        }
    }
    $zip->close();
    header('location: ' . $zip_name);
}

if (filter_has_var(INPUT_POST, 'restore_objects')) {
    $p = new LendObjectPicture(-1);
    $tpl->assign('messages', $p->restoreObjectPictures());
}

$content = $tpl->fetch('admin_picture.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
