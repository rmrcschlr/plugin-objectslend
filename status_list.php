<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Status list
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
 * @copyright 2017 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   0.7
 * @link      http://galette.tuxfamily.org
 * @since     Available since 0.7
 */

use GaletteObjectsLend\LendStatus;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$tpl->assign('page_title', _T("Status list"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$tri = array_key_exists('tri', $_GET) ? $_GET['tri'] : 'status_text';
$direction = array_key_exists('direction', $_GET) ? $_GET['direction'] : 'asc';
if (isset($_GET['msg'])) {
    switch ($_GET['msg']) {
        case 'deleted':
            $success_detected[] = _T("Status has been successfully deleted");
            break;
        case 'saved':
            $success_detected[] = _T("Status has been saved");
            break;
        case 'canceled':
            $warning_detected[] = _T("Status edition has been canceled");
            break;
    }
}

$statuses = LendStatus::getAllStatuses($tri, $direction);
if (count(LendStatus::getActiveHomeStatuses()) == 0) {
    $error_detected[] = _T("You should add at last 1 status 'on site' to ensure the plugin works well!");
}
if (count(LendStatus::getActiveTakeAwayStatuses()) == 0) {
    $error_detected[] = _T("You should add at last 1 status 'object borrowed' to ensure the plugin works well!");
}

$tpl->assign('statuses', $statuses);
$tpl->assign('nb_status', count($statuses));
$tpl->assign('tri', $tri);
$tpl->assign('direction', $direction);
$tpl->assign('success_detected', $success_detected);
$tpl->assign('warning_detected', $warning_detected);
$tpl->assign('error_detected', $error_detected);

$content = $tpl->fetch('status_list.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
