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

use GaletteObjectsLend\Preferences;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
require_once '_config.inc.php';

$lendsprefs = new Preferences($zdb);

$thumb = isset($_GET['thumb']) && $_GET['thumb'] == '1';
if (!$lendsprefs->showFullsize()) {
    //force thumbnail display from preferences
    $thumb = true;
}
$quick_mode = isset($_GET['quick']) && $_GET['quick'] == '1';

$id = null;
$class = null;

if (isset($_GET['object_id'])) {
    $id = (int)$_GET['object_id'];
    $class = '\GaletteObjectsLend\ObjectPicture';
}
if (isset($_GET['category_id'])) {
    $id = (int)$_GET['category_id'];
    $class = '\GaletteObjectsLend\CategoryPicture';
}

//FIXME: what is quick mode?
if (!$quick_mode && !$login->isLogged()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}

$picture = new $class($plugins, $id);

if ($thumb === true || $quick_mode === true) {
    $picture->displayThumb($lendsprefs);
} else {
    $picture->display();
}
