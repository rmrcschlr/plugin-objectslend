<?php

/**
 * Create or edit an object
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

$tpl->assign('page_title', _T("OBJECT EDIT.PAGE TITLE"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;
$saved = false;

// Récupération id
$object_id = filter_has_var(INPUT_GET, 'object_id') ? filter_input(INPUT_GET, 'object_id') : null;

/**
 * Annulation de l'enregistrement, on revient à la liste
 */
if (filter_has_var(INPUT_POST, 'cancel')) {
    header('Location: objects_list.php?msg=canceled');
}

/**
 * Enregistrement des modifications
 */
if (filter_has_var(INPUT_POST, 'save')) {
    // Modification de l'objet
    $obj = new LendObject(intval(filter_input(INPUT_POST, 'object_id')));
    $obj->name = filter_input(INPUT_POST, 'name');
    $obj->description = filter_input(INPUT_POST, 'description');
    $obj->category_id = filter_has_var(INPUT_POST, 'category_id') ? filter_input(INPUT_POST, 'category_id') : null;
    $obj->serial_number = filter_input(INPUT_POST, 'serial');
    if (filter_input(INPUT_POST, 'price') != '') {
        $obj->price = str_replace(' ', '', str_replace(',', '.', filter_input(INPUT_POST, 'price')));
    }
    if (filter_input(INPUT_POST, 'rent_price') != '') {
        $obj->rent_price = str_replace(' ', '', str_replace(',', '.', filter_input(INPUT_POST, 'rent_price')));
    }
    $obj->price_per_day = filter_input(INPUT_POST, 'price_per_day') == 'true';
    $obj->dimension = filter_input(INPUT_POST, 'dimension');
    if (filter_input(INPUT_POST, 'weight') != '') {
        $obj->weight = str_replace(' ', '', str_replace(',', '.', filter_input(INPUT_POST, 'weight')));
    }
    $obj->is_active = filter_input(INPUT_POST, 'is_active') == 'true';
    $obj->store();
    $saved = true;

    // Enregistrement du 1er statut lors de la création
    if (filter_has_var(INPUT_POST, '1st_status')) {
        $rent = new LendRent();
        $rent->object_id = $obj->object_id;
        $rent->status_id = filter_input(INPUT_POST, '1st_status');
        $rent->store();
    }

    // Enregistrement de la photo
    if (isset($_FILES['picture'])) {
        if ($_FILES['picture']['tmp_name'] != '') {
            if (is_uploaded_file($_FILES['picture']['tmp_name'])) {
                $objPicture = new LendObjectPicture($obj->object_id);
                $res = $objPicture->store($_FILES['picture']);
                if ($res < 0) {
                    switch ($res) {
                        case LendObjectPicture::INVALID_FILE:
                            $patterns = array('|%s|', '|%t|');
                            $replacements = array(
                                $objPicture->getAllowedExts(),
                                htmlentities($objPicture->getBadChars())
                            );
                            $error_detected[] = preg_replace(
                                    $patterns, $replacements, _T("- Filename or extension is incorrect. Only %s files are allowed. File name should not contains any of: %t")
                            );
                            break;
                        case LendObjectPicture::FILE_TOO_BIG:
                            $error_detected[] = preg_replace(
                                    '|%d|', LendObjectPicture::MAX_FILE_SIZE, _T("File is too big. Maximum allowed size is %d")
                            );
                            break;
                        case LendObjectPicture::MIME_NOT_ALLOWED:
                            /** FIXME: should be more descriptive */
                            $error_detected[] = _T("Mime-Type not allowed");
                            break;
                        case LendObjectPicture::SQL_ERROR:
                        case LendObjectPicture::SQL_BLOB_ERROR:
                            $error_detected[] = _T("An SQL error has occured.");
                            break;
                    }
                }
            }
        }
    }

    // Suppression de la photo
    if (filter_has_var(INPUT_POST, 'del_picture') && filter_input(INPUT_POST, 'del_picture') == '1') {
        $pic = new LendObjectPicture($obj->object_id);
        $pic->delete();
    }

    $object_id = $obj->object_id;
}

/**
 * Modification du statut 
 */
if (filter_has_var(INPUT_POST, 'status')) {
    $object_id = filter_input(INPUT_POST, 'object_id');

    LendRent::closeAllRentsForObject(intval($object_id), filter_input(INPUT_POST, 'new_comment'));

    $rent = new LendRent();
    $rent->object_id = $object_id;
    $rent->status_id = filter_input(INPUT_POST, 'new_status');
    if (filter_input(INPUT_POST, 'new_adh') != 'null') {
        $rent->adherent_id = filter_input(INPUT_POST, 'new_adh');
    }
    $rent->store();
}

$rents = array();
$show_status = false;
$statuses = LendStatus::getActiveStatuses();
$adherents = LendRent::getAllActivesAdherents();

/**
 * Lecture de l'objet à éditer 
 */
if ($object_id != null) {
    $object = new LendObject(intval($object_id));
    $rents = LendRent::getRentsForObjectId(intval($object_id));
} else {
    if (filter_has_var(INPUT_GET, 'clone_object_id')) {
        $object = new LendObject(intval(filter_input(INPUT_GET, 'clone_object_id')), true);
    } else {
        $object = new LendObject();
    }
    $show_status = true;
}

/**
 * Récupération taille image
 */
$size = LendObjectPicture::getHeightWidthForObject($object);
$tpl->assign('pic_width', $size->width);
$tpl->assign('pic_height', $size->height);

$tpl->assign('object', $object);
$tpl->assign('rents', $rents);
$tpl->assign('saved', $saved);
$tpl->assign('show_status', $show_status);
$tpl->assign('statuses', $statuses);
$tpl->assign('adherents', $adherents);
$tpl->assign('view_category', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_CATEGORY));
$tpl->assign('thumb_max_width', LendParameter::getParameterValue(LendParameter::PARAM_THUMB_MAX_WIDTH));
$tpl->assign('thumb_max_height', LendParameter::getParameterValue(LendParameter::PARAM_THUMB_MAX_HEIGHT));
$tpl->assign('categories', LendCategory::getActiveCategories());
$tpl->assign('msg_clone', filter_has_var(INPUT_GET, 'clone_object_id'));

$content = $tpl->fetch('objects_edit.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
?>
