<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Take an object
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
use GaletteObjectsLend\LendParameter;
use GaletteObjectsLend\LendObjectPicture;
use GaletteObjectsLend\LendRent;
use GaletteObjectsLend\LendStatus;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}
require_once '_config.inc.php';

$tpl->assign('page_title', _T("TAKE OBJECT.PAGE TITLE"));
//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

/**
 * Prise de l'objet -> on valide et retourne à la liste
 */
if (filter_has_var(INPUT_POST, 'yes')) {
    $object_id = intval(filter_input(INPUT_POST, 'object_id'));
    // Fermeture des anciennes locations de l'objet
    LendRent::closeAllRentsForObject($object_id, '');

    // Ajout d'un nouveau statut "objet loué"
    $rent = new LendRent();
    $rent->object_id = $object_id;
    $rent->status_id = filter_input(INPUT_POST, 'status');
    $rent->date_forecast = null;
    $forecast = filter_input(INPUT_POST, 'expected_return');
    if (strlen($forecast) > 6) {
        list($j, $m, $a) = explode('/', $forecast);
        $rent->date_forecast = $a . '-' . $m . '-' . $j;
    }
    if (filter_has_var(INPUT_POST, 'id_adh') && ($login->isAdmin() || $login->isStaff())) {
        $rent->adherent_id = filter_input(INPUT_POST, 'id_adh');
    } else {
        $rent->adherent_id = $login->id;
    }
    $rent->store();

    // Récupération des informations sur l'objet
    $object = new LendObject($object_id);

    // Récupération du prix de location
    $rentprice = $object->value_rent_price;
    if (filter_has_var(INPUT_POST, 'rent_price') && ($login->isAdmin() || $login->isStaff())) {
        $rentprice = floatval(str_replace(' ', '', str_replace(',', '.', filter_input(input, 'rent_price'))));
    }

    // Ajout d'une contribution
    if ($rentprice > 0 && LendParameter::getParameterValue(LendParameter::PARAM_AUTO_GENERATE_CONTRIBUTION)) {
        $contrib = new Galette\Entity\Contribution();

        $info = str_replace(array('{NAME}', '{DESCRIPTION}', '{SERIAL_NUMBER}', '{PRICE}', '{RENT_PRICE}', '{WEIGHT}', '{DIMENSION}'), array($object->name, $object->description, $object->serial_number, $object->price, $object->rent_price, $object->weight, $object->dimension), LendParameter::getParameterValue(LendParameter::PARAM_GENERATED_CONTRIB_INFO_TEXT));

        $values = array(
            'montant_cotis' => $rentprice,
            \Galette\Entity\ContributionsTypes::PK => LendParameter::getParameterValue(LendParameter::PARAM_GENERATED_CONTRIBUTION_TYPE_ID),
            'date_enreg' => date(_T("Y-m-d")),
            'date_debut_cotis' => date(_T("Y-m-d")),
            'type_paiement_cotis' => intval(filter_input(input_, 'payment_type')),
            'info_cotis' => $info,
            \Galette\Entity\Adherent::PK => $rent->adherent_id,
        );
        $contrib->check($values, array(), array());
        $contrib->store();
    }

    if (filter_has_var(INPUT_POST, 'mode') && filter_input(INPUT_POST, 'mode') === 'ajax') {
        echo "OK";
        exit;
    } else {
        // Redirection sur la liste des objets
        header('location: objects_list.php?msg=taken');
    }
}

/**
 * Annulation de l'emprunt
 */
if (array_key_exists('cancel', $_POST)) {
    header('location: objects_list.php?msg=not_taken');
}

/**
 * Récupération des adhérents actifs
 */
$members = array();
if ($login->isAdmin() || $login->isStaff()) {
    // members
    $m = new Galette\Repository\Members();
    $required_fields = array(
        'id_adh',
        'nom_adh',
        'prenom_adh',
        'pseudo_adh',
    );
    $members = $m->getList(false, $required_fields);
}

// Vérification que l'utilisateur a le droit de prendre l'objet
if (!LendParameter::getParameterValue(LendParameter::PARAM_ENABLE_MEMBER_RENT_OBJECT) && !($login->isAdmin() || $login->isStaff())) {
    header('location: objects_list.php?msg=not_taken');
}

$object_id = filter_has_var(INPUT_GET, 'object_id') ? intval(filter_input(INPUT_GET, 'object_id')) : -1;
$ajax = filter_has_var(INPUT_GET, 'mode') ? filter_input(INPUT_GET, 'mode') === 'ajax' : false;

// Vérification que l'objet est bien dispo
$rents = LendRent::getRentsForObjectId($object_id);
if (count($rents) > 0) {
    $last_rent = $rents[0];
    if (!$last_rent->is_home_location) {
        header('location: objects_list.php?msg=bad_location');
    }
}

$object = new LendObject($object_id);
/**
 * Tooltip de la photo
 */
$s = LendObjectPicture::getHeightWidthForObject($object);

$object->tooltip_title = '<center>';
$object->tooltip_title .= '<img src=\'picture.php?quick=1&object_id=' . $object->object_id . '\' width=\'' . $s->width . '\' height=\'' . $s->height . '\'/>';
$object->tooltip_title .= '<br/><b>' . $object->name . '</b>';
if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_SERIAL) && strlen($object->serial_number) > 0) {
    $object->tooltip_title .= ' (' . $object->serial_number . ')';
}
$object->tooltip_title .= '<br/>&nbsp;';
if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DESCRIPTION) && strlen($object->description) > 0) {
    $object->tooltip_title .= '<br/>' . $object->description;
}
if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DIMENSION) && strlen($object->dimension) > 0) {
    $object->tooltip_title .= '<br/>' . _T('OBJECTS LIST.DIMENSION') . ' : ' . $object->dimension;
}
if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_WEIGHT) && $object->weight_bulk > 0) {
    $object->tooltip_title .= '<br/>' . _T('OBJECTS LIST.WEIGHT') . ' : ' . $object->weight;
}

$tpl->assign('object', $object);
$tpl->assign('statuses', LendStatus::getActiveTakeAwayStatuses());
$tpl->assign('members', $members);
$tpl->assign('add_contribution', LendParameter::getParameterValue(LendParameter::PARAM_AUTO_GENERATE_CONTRIBUTION));
$tpl->assign('view_object_thumb', LendParameter::getParameterValue(LendParameter::PARAM_VIEW_OBJECT_THUMB));
$tpl->assign('thumb_max_width', LendParameter::getParameterValue(LendParameter::PARAM_THUMB_MAX_WIDTH));
$tpl->assign('thumb_max_height', LendParameter::getParameterValue(LendParameter::PARAM_THUMB_MAX_HEIGHT));
$tpl->assign('ajax', $ajax);
$tpl->assign('require_calendar', true);
$tpl->assign('year', date('Y'));
$tpl->assign('month', date('m'));
$tpl->assign('day', date('d'));
$tpl->assign('rent_price', str_replace(array( ',', ' '), array( '.', ''), $object->rent_price));

if ($ajax) {
    $tpl->display('take_object.tpl');
} else {
    $content = $tpl->fetch('take_object.tpl', LEND_SMARTY_PREFIX);
    $tpl->assign('content', $content);
    //Set path to main Galette's template
    $tpl->template_dir = $orig_template_path;
    $tpl->display('page.tpl', LEND_SMARTY_PREFIX);
}
