<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Manage plugin preferences
 *
 * PHP version 5
 *
 * Copyright © 2013 Mélissa Djebel
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
 * @copyright 2013 Mélissa Djebel
 * Copyright © 2017 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   0.7
 * @link      http://galette.tuxfamily.org
 * @since     Available since 0.7
 */

/**
 * Convertit une date du format IHM 'jj/mm/aaaa' vers le format SQL 'aaaa-mm-jj'
 *
 * @param string $str Date au format IHM 'jj/mm/aaaa'
 *
 * @return string Date au format SQL 'aaaa-mm-jj'
 */

use Galette\Entity\ContributionsTypes;
use GaletteObjectsLend\Preferences;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() || !$login->isAdmin()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}

// Import des classes de notre plugin
require_once '_config.inc.php';

$lendsprefs = new Preferences($zdb);

if (isset($_POST['saveprefs'])) {
    unset($_POST['saveprefs']);
    if ($lendsprefs->store($_POST, $error_detected)) {
        $success_detected[] = _T("Preferences have been successfully stored!", "objectslend");
    }
}

$tpl->assign('page_title', _T("ObjectsLend preferences", "objectslend"));

$ctypes = new ContributionsTypes();
$tpl->assign('ctypes', $ctypes->getList());
$tpl->assign('lendsprefs', $lendsprefs->getpreferences());

//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$tpl->assign('error_detected', $error_detected);
$tpl->assign('success_detected', $success_detected);

$content = $tpl->fetch('preferences.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
