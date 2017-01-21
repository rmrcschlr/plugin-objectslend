<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Print as PDF all known operations for a pilot.
 * An admin can see operations for an other pilote.
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
define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}

// Import des classes de notre plugin
require_once '_config.inc.php';

function getNotHtmlText($code) {
    return html_entity_decode(_T($code));
}

function cut($str, $length) {
    $l = intval($length / 1.8);
    if (strlen($str) > $l) {
        return substr($str, 0, $l);
    }
    return $str;
}

function addLine($pdf, $code_title, $value, $width) {
    $pdf->Cell($width, 0, '');
    $title = getNotHtmlText($code_title);
    $pdf->SetFont(Galette\IO\Pdf::FONT, 'B', 9);
    $padding = 30;
    $pdf->Cell($padding, 0, cut($title, $padding));

    $pdf->SetFont(Galette\IO\Pdf::FONT, '', 9);
    $wrapped = split("\n", wordwrap($value, 150 - $padding - $width, "\n"));
    $i = 0;
    foreach ($wrapped as $w) {
        if ($i++ > 0) {
            $pdf->Cell($width + $padding, 0, '');
        }
        $pdf->Cell(0, 0, $w);
        $pdf->Ln();
    }
}

$pdf = new LendPDF();

// Set document information
$pdf->SetTitle(getNotHtmlText('OBJECT EDIT.PAGE TITLE'));
$pdf->SetSubject('');
$pdf->SetKeywords('');

// Récupération id
$object_id = filter_has_var(INPUT_GET, 'object_id') ? filter_input(INPUT_GET, 'object_id') : null;
$ids = filter_has_var(INPUT_GET, 'ids') ? split(',', filter_input(INPUT_GET, 'ids')) : array();

if (count($ids) == 0 && is_numeric($object_id)) {
    $ids[] = $object_id;
}

foreach ($ids as $object_id) {
    if (!is_numeric($object_id)) {
        continue;
    }

    $pdf->AddPage('P');

    $name = '';
    if ($object_id != null) {
        $object = new LendObject(intval($object_id));
        LendObject::getStatusForObject($object);
        $size = LendObjectPicture::getHeightWidthForObject($object);

        $width = 1;
        $height = 1;
        if ($object->draw_image && $size->width > 0 && $size->height > 0) {
            $width = 80;
            $height = 80;
            if ($size->width > $size->height) {
                $delta = $size->width / $size->height;
                $height = $height / $delta;
            } else {
                $delta = $size->height / $size->width;
                $width = $width / $delta;
            }
            $pdf->Image($object->object_image_url, 10, 10, $width, $height);
        }

        $name = $object->name;
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_NAME)) {
            addLine($pdf, 'OBJECT EDIT.NAME', $object->name, $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DESCRIPTION)) {
            addLine($pdf, 'OBJECT EDIT.DESCRIPTION', $object->description, $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_CATEGORY)) {
            $categ = new LendCategory(intval($object->category_id));
            addLine($pdf, 'OBJECT EDIT.CATEGORY', $categ->name, $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_SERIAL)) {
            addLine($pdf, 'OBJECT EDIT.SERIAL', $object->serial_number, $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_PRICE)) {
            addLine($pdf, 'OBJECT EDIT.PRICE', $object->price, $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_LEND_PRICE)) {
            addLine($pdf, 'OBJECT EDIT.RENT PRICE', $object->rent_price, $width);
            addLine($pdf, 'OBJECT EDIT.PRICE PER DAY', $object->price_per_day ? '/j' : '', $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DIMENSION)) {
            addLine($pdf, 'OBJECT EDIT.DIMENSION', $object->dimension, $width);
        }
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_WEIGHT)) {
            addLine($pdf, 'OBJECT EDIT.WEIGHT', $object->weight, $width);
        }
        addLine($pdf, 'OBJECT EDIT.IS ACTIVE', $object->is_active ? 'X' : '', $width);
        addLine($pdf, 'OBJECT EDIT.1ST STATUS', $object->status_text, $width);
        addLine($pdf, 'OBJECTS LIST.DATE BEGIN', $object->date_begin_ihm, $width);
        addLine($pdf, 'OBJECTS LIST.ADHERENT', $object->nom_adh . ' ' . $object->prenom_adh, $width);
        if (LendParameter::getParameterValue(LendParameter::PARAM_VIEW_DATE_FORECAST)) {
            addLine($pdf, 'OBJECTS LIST.DATE FORECAST', $object->date_forecast_ihm, $width);
        }

        do {
            $pdf->Ln();
        } while ($pdf->GetY() < $height + 10);

        $rents = LendRent::getRentsForObjectId(intval($object_id));

        $col_begin = 33;
        $col_end = 33;
        $col_status = 30;
        $col_home = 25;
        $col_adh = 30;
        $col_comments = 40;

        $pdf->SetFont(Galette\IO\Pdf::FONT, 'B', 9);
        $pdf->Cell(0, 0, getNotHtmlText('OBJECT EDIT.ALL RENTS'));
        $pdf->Ln();
        $pdf->Cell($col_begin, 0, cut(getNotHtmlText('OBJECT EDIT.DATE BEGIN'), $col_begin), 'B');
        $pdf->Cell($col_end, 0, cut(getNotHtmlText('OBJECT EDIT.DATE FIN'), $col_end), 'B');
        $pdf->Cell($col_status, 0, cut(getNotHtmlText('OBJECT EDIT.STATUS'), $col_status), 'B');
        $pdf->Cell($col_home, 0, cut(getNotHtmlText('OBJECT EDIT.AT HOME'), $col_home), 'B');
        $pdf->Cell($col_adh, 0, cut(getNotHtmlText('OBJECT EDIT.ADH'), $col_adh), 'B');
        $pdf->Cell($col_comments, 0, cut(getNotHtmlText('OBJECT EDIT.COMMENTS'), $col_comments), 'B');
        $pdf->Ln();
        $pdf->SetFont(Galette\IO\Pdf::FONT, '', 9);

        foreach ($rents as $rt) {
            $pdf->Cell($col_begin, 0, cut($rt->date_begin, $col_begin), 'B');
            $pdf->Cell($col_end, 0, cut($rt->date_end, $col_end), 'B');
            $pdf->Cell($col_status, 0, cut($rt->status_text, $col_status), 'B');
            $pdf->Cell($col_home, 0, $rt->is_home_location ? '    X' : '', 'B');
            $pdf->Cell($col_adh, 0, cut($rt->nom_adh . ' ' . $rt->prenom_adh, $col_adh), 'B');
            $pdf->Cell($col_comments, 0, cut($rt->comments, $col_comments), 'B');
            $pdf->Ln();
        }
    }
}

$pdf->Output('object_print_' . date('Ymd-Hi') . '.pdf', 'D');
?>
