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

use Galette\IO\Pdf;
use GaletteObjectsLend\LendObject;
use GaletteObjectsLend\LendCategory;
use GaletteObjectsLend\Preferences;
use GaletteObjectsLend\LendPDF;
use GaletteObjectsLend\ObjectPicture;
use GaletteObjectsLend\LendRent;

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}

// Import des classes de notre plugin
require_once '_config.inc.php';

$lendsprefs = new Preferences($zdb);

/**
 * Cut a string?
 *
 * @param string  $str    Original string
 * @param integer $length Max length
 *
 * @return string
 */
function cut($str, $length)
{
    $l = intval($length / 1.8);
    if (strlen($str) > $l) {
        return substr($str, 0, $l);
    }
    return $str;
}

/**
 * Add a line in the array
 *
 * @param LendPDF $pdf   Pdf instance
 * @param string  $title Line title
 * @param string  $value Line value
 * @param integer $width Cell width
 *
 * @return void
 */
function addCell(LendPDF $pdf, $title, $value, $width)
{
    $pdf->Cell($width, 0, '');
    $pdf->SetFont(Pdf::FONT, 'B', 9);
    $padding = 50;
    $pdf->Cell($padding, 0, cut($title, $padding));

    $pdf->SetFont(Pdf::FONT, '', 9);
    $wrapped = explode("\n", wordwrap($value, 150 - $padding - $width, "\n"));
    $i = 0;
    foreach ($wrapped as $w) {
        if ($i++ > 0) {
            $pdf->Cell($width + $padding, 0, '');
        }
        $pdf->Cell(0, 0, $w);
        $pdf->Ln();
    }
}

$pdf = new LendPDF($preferences);

// Set document information
$pdf->SetTitle(_T("Object card"));
$pdf->SetSubject('');
$pdf->SetKeywords('');

// Récupération id
$object_id = filter_has_var(INPUT_GET, 'object_id') ? filter_input(INPUT_GET, 'object_id') : null;
$ids = filter_has_var(INPUT_GET, 'ids') ? explode(',', filter_input(INPUT_GET, 'ids')) : array();

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
        $object = new LendObject((int)$object_id);
        LendObject::getStatusForObject($object);
        $size = ObjectPicture::getHeightWidthForObject($object);

        $wpic = 0;
        $hpic = 0;
        if ($object->picture->hasPicture()) {
            $pic = $object->picture;
            // Set picture size to max width 30 mm or max height 30 mm
            $ratio = $pic->getOptimalThumbWidth()/$pic->getOptimalThumbHeight();
            if ($ratio < 1) {
                if ($pic->getOptimalThumbHeight() > 16) {
                    $hpic = 30;
                } else {
                    $hpic = $pic->getOptimalThumbHeight();
                }
                $wpic = round($hpic*$ratio);
            } else {
                if ($pic->getOptimalThumbWidth() > 16) {
                    $wpic = 30;
                } else {
                    $wlogo = $pic->getOptimalThumbWidth();
                }
                $hpic = round($wpic/$ratio);
            }

            $pdf->Image($object->picture->getThumbPath(), 10, 10, $wpic, $hpic);
        }

        $name = $object->name;
        if ($lendsprefs->{Preferences::PARAM_VIEW_NAME}) {
            addCell($pdf, _T("Name"), $object->name, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_DESCRIPTION}) {
            addCell($pdf, _T("Description"), $object->description, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_CATEGORY}) {
            $categ = new LendCategory((int)$object->category_id);
            addCell($pdf, _T("Category"), $categ->name, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_SERIAL}) {
            addCell($pdf, _T("Serial number"), $object->serial_number, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_PRICE}) {
            addCell($pdf, _T("Price"), $object->price, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_LEND_PRICE}) {
            addCell(
                $pdf,
                str_replace('%currency', $object->getCurrency(), _T("Borrow price (%currency)")),
                $object->rent_price,
                $wpic
            );
            addCell($pdf, _T("Price per rental day"), $object->price_per_day, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_DIMENSION}) {
            addCell($pdf, _T("Dimensions"), $object->dimension, $wpic);
        }
        if ($lendsprefs->{Preferences::PARAM_VIEW_WEIGHT}) {
            addCell($pdf, _T("Weight"), $object->weight, $wpic);
        }
        addCell($pdf, _T("Active"), $object->is_active ? 'X' : '', $wpic);
        addCell($pdf, _T("Location"), $object->status_text, $wpic);
        addCell($pdf, _T("Since"), $object->date_begin_ihm, $wpic);
        addCell($pdf, _T("Member"), $object->nom_adh . ' ' . $object->prenom_adh, $wpic);
        if ($lendsprefs->{Preferences::PARAM_VIEW_DATE_FORECAST}) {
            addCell($pdf, _T("Return"), $object->date_forecast_ihm, $wpic);
        }

        if ($pdf->GetY() < $hpic) {
            $pdf->SetY($hpic);
        }
        $pdf->Ln();

        $rents = LendRent::getRentsForObjectId((int)$object_id);

        $col_begin = 33;
        $col_end = 33;
        $col_status = 30;
        $col_home = 25;
        $col_adh = 30;
        $col_comments = 40;

        $pdf->SetFont(Pdf::FONT, 'B', 9);
        $pdf->Cell(0, 0, _T("History of object loans"));
        $pdf->Ln();
        $pdf->Cell($col_begin, 0, cut(_T("Begin"), $col_begin), 'B');
        $pdf->Cell($col_end, 0, cut(_T("End"), $col_end), 'B');
        $pdf->Cell($col_status, 0, cut(_T("Status"), $col_status), 'B');
        $pdf->Cell($col_home, 0, cut(_T("On site"), $col_home), 'B');
        $pdf->Cell($col_adh, 0, cut(_T("Member"), $col_adh), 'B');
        $pdf->Cell($col_comments, 0, cut(_T("Comments"), $col_comments), 'B');
        $pdf->Ln();
        $pdf->SetFont(Pdf::FONT, '', 9);

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
