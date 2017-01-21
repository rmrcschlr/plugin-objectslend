<?php

/**
 * Plugin base configuration
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
define('LEND_PREFIX', 'lend_');
define('LEND_SMARTY_PREFIX', 'plugins|lend');

require_once 'classes/lendObject.class.php';
require_once 'classes/lendRent.class.php';
require_once 'classes/lendStatus.class.php';
require_once 'classes/lendPicture.class.php';
require_once 'classes/lendParameter.class.php';
require_once 'classes/lendCategory.class.php';
require_once 'classes/lendPDF.class.php';

?>
