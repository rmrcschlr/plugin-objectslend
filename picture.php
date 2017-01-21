<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Display the picture of a plane if it exists
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

$thumb = array_key_exists('thumb', $_GET) && $_GET['thumb'] == '1';
$quick_mode = array_key_exists('quick', $_GET) && $_GET['quick'] == '1';

if ($quick_mode) {
    $photo_path = '';
    $photo_name = '';
    if (array_key_exists('object_id', $_GET)) {
        $photo_path = 'objects_pictures';
        $photo_name = $_GET['object_id'] . ($thumb ? '_th' : '') . '.';
    }

    if (array_key_exists('category_id', $_GET)) {
        $photo_path = 'categories_pictures';
        $photo_name = $_GET['category_id'] . ($thumb ? '_th' : '') . '.';
    }

    if (strlen($photo_name) > 0 && strlen($photo_path) > 0) {
        $dir = opendir($photo_path);
        while (false !== ($entry = readdir($dir))) {
            if (stripos($entry, $photo_name) === 0) {
                $ext = pathinfo($entry, PATHINFO_EXTENSION);
                header("Content-type: image/" . $ext);
                readfile($photo_path . '/' . $entry);
                break;
            }
        }
    }
} else {
    define('GALETTE_BASE_PATH', '../../');
    require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
    require_once '_config.inc.php';

    if (!$login->isLogged()) {
        header('location: ' . GALETTE_BASE_PATH . 'index.php');
        die();
    }

    $thumb = $_GET['thumb'] == '1';

    if (array_key_exists('object_id', $_GET)) {
        $picture = new LendObjectPicture($_GET['object_id']);
    } else if (array_key_exists('category_id', $_GET)) {
        $picture = new LendObjectPicture($_GET['category_id'], true);
    }
    if ($thumb) {
        $picture->displayThumb();
    } else {
        $picture->display();
    }
}
?>
