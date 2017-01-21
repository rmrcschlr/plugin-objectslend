<?php

/**
 * Delete an object
 *
 * PHP version 5
 *
 * Copyright © 2013 Mélissa Djebel
 *
 * This file is part of Galette (http://galette.tuxfamily.org).
 *
 * Plugin ObjectsLend is distributed in the hope that it will be useful,
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
 * @copyright 2013 Mélissa Djebel
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   0.7
 * @link      http://galette.tuxfamily.org
 * @since     Available since 0.7
 */
define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() && !($login->isAdmin() || $login->isStaff())) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$to_delete = array_key_exists('delete', $_GET) ? $_GET['delete'] == '1' : false;
$to_disable = array_key_exists('disable', $_GET) ? $_GET['disable'] == '1' : false;

if (array_key_exists('objects_ids', $_GET)) {
    $ids = split(',', $_GET['objects_ids']);
    foreach ($ids as $obj_id) {
        if (is_numeric($obj_id)) {
            if ($to_disable) {
                LendObject::setInactiveObject($obj_id);
            }

            if ($to_delete) {
                LendObject::removeObject($obj_id);
            }
        }
    }
}

header('Location: objects_list.php?msg=' . ($to_delete ? 'deleted' : '') . ($to_disable ? 'disabled' : ''));
?>
