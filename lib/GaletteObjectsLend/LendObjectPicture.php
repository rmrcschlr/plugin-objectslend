<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Public Class LendObjectPicture
 * Picture of an object
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

namespace GaletteObjectsLend;

use Analog\Analog;
use Galette\Core\Plugins;

class LendObjectPicture extends \Galette\Core\Picture
{

    protected $tbl_prefix = LEND_PREFIX;
    const PK = 'object_id';

    protected $max_width = 350;
    protected $max_height = 350;

    private $plugins;

    /**
     * Default constructor.
     *
     * @param Plugins $plugins  Plugins
     * @param int     $objectid Object id
     */
    public function __construct(Plugins $plugins, $objectid = '')
    {
        $this->plugins = $plugins;
        $this->store_path = GALETTE_PHOTOS_PATH . 'objectslend/objects/';

        if (!file_exists($this->store_path)) {
            if (!mkdir($this->store_path, 0755, true)) {
                Analog::log(
                    'Unable to create photo dir `' . $this->store_path . '`.',
                    Analog::ERROR
                );
            } else {
                Analog::log(
                    'New directory `' . $this->store_path . '` has been created',
                    Analog::INFO
                );
            }
        } elseif (!is_dir($this->store_path)) {
            Analog::log(
                'Unable to store plugin images, since `' . $this->store_path .
                '` is not a directory.',
                Analog::WARNING
            );
        }

        parent::__construct($objectid);
    }

    /**
     * Gets the default picture to show, anyways
     *
     * @see Logo::getDefaultPicture()
     *
     * @return void
     */
    protected function getDefaultPicture()
    {
        $this->file_path = $this->plugins->getTemplatesPathFromName('Galette Objects Lend') .
            '/images/default.png';
        $this->format = 'png';
        $this->mime = 'image/png';
        $this->has_picture = false;
    }

    /**
     * Affiche la miniature d'une photo d'un avion et la créé si nécessaire
     *
     * @return void
     */
    public function displayThumb()
    {
        $nom_fichier = substr($this->file_path, 0, strlen($this->file_path) - 4);

        // Ano 61 - Quand le fichier fait 0Ko on affiche l'image par défaut
        // Ou que l'image est trop petite (<40x40 pixels)
        $size = getimagesize($this->file_path);
        if (!$size || $size[0] < 40 || $size[1] < 40) {
            $this->getDefaultPicture();
            $this->display();
            return;
        }

        // On récupère la miniature
        $nom_thumb = $nom_fichier . '_th' . '.png';

        // Si la miniature n'existe pas, on la créé
        if (!is_file($nom_thumb)) {
            //$this->createthumb($this->file_path, $nom_thumb, 128, 128);
            //TODO: retrieve from preferences
            $thumb_max_width = 96;
            $thumb_max_height = 96;
            $w = round($this->getOptimalWidth() * $thumb_max_width / $this->max_width);
            $h = round($this->getOptimalHeight() * $thumb_max_height / $this->max_height);
            $this->createRoundThumb($this->file_path, $nom_thumb, $w, $h, 5, 10);
        }
        header('Content-type: ' . $this->mime);
        readfile($nom_thumb);
    }

    /**
     * Créer une miniature d'une image donnée en arrondissant les bords (transparent)
     *
     * @param string $img_src  Nom de l'image source
     * @param string $img_dest Nom de l'image de destination
     * @param int    $w_thumb  Largeur en pixel de la miniature
     * @param int    $h_thumb  Hauteur en pixel de la miniature
     * @param int    $border   Taille de la bordure
     * @param int    $radial   Rayon de la bordure
     *
     * @return void
     */
    private function createRoundThumb($img_src, $img_dest, $w_thumb, $h_thumb, $border = 10, $radial = 24)
    {
        $pic['destNormal']['name'] = $img_src; // nom du fichier normal
        // Récupération des infos de l'image source
        list($pic['src']['info']['width'], $pic['src']['info']['height'], $pic['src']['info']['type'], $pic['src']['info']['attr']) = getimagesize($img_src);

        //On vérifie si le parametre de la hauteur est plus grand que 0
        if ($h_thumb == 0) {
            // si egal a zaro on affecte la hauteur proportionnellement
            $h_thumb = floor($pic['src']['info']['height'] * $w_thumb / $pic['src']['info']['width']);
        }
        switch ($pic['src']['info']['type']) {
            case "1":
                // Création de l'image pour une source gif
                $pic['src']['ress'] = imagecreatefromgif($img_src);
                break;
            case "2":
                // Création de l'image pour une source jpg
                $pic['src']['ress'] = imagecreatefromjpeg($img_src);
                break;
            case "3":
                // Création de l'image pour une source png
                $pic['src']['ress'] = imagecreatefrompng($img_src);
                break;
        }

        // On crée la miniature vide pour l'image Etat Normal
        $pic['destNormal']['ress'] = imagecreatetruecolor($w_thumb, $h_thumb);
        // On crée la miniature Normal
        imagecopyresampled($pic['destNormal']['ress'], $pic['src']['ress'], 0, 0, 0, 0, $w_thumb, $h_thumb, $pic['src']['info']['width'], $pic['src']['info']['height']);

        // On commence à créer le masque pour le contour coin rond
        // On crée le mask vide
        $pic['maskBorder']['ress'] = imagecreate($w_thumb, $h_thumb);
        // affectation de la couleur verte
        $pic['maskBorder']['green'] = imagecolorallocate($pic['maskBorder']['ress'], 0, 255, 0);
        // affectation de la couleur rose
        $pic['maskBorder']['pink'] = imagecolorallocate($pic['maskBorder']['ress'], 255, 0, 255);
        // Ici on trace la zone à mettre en transparence avant le merge entre les 2 images
        // PRINCIPE : 4 cercle situé dans chauque coin avec un rayon de 2 fois la bordure
        // PRINCIPE : 1 forme polygonale de 8 cotés pour peindre de rose la zone restante
        imagefilledellipse($pic['maskBorder']['ress'], $radial, $radial, $radial * 2, $radial * 2, $pic['maskBorder']['pink']); // cercle gauche supérieur
        imagefilledellipse($pic['maskBorder']['ress'], $w_thumb - $radial, $radial, $radial * 2, $radial * 2, $pic['maskBorder']['pink']); // cercle droite supérieur
        imagefilledellipse($pic['maskBorder']['ress'], $radial, $h_thumb - $radial, $radial * 2, $radial * 2, $pic['maskBorder']['pink']); // cercle gauche inférieur
        imagefilledellipse($pic['maskBorder']['ress'], $w_thumb - $radial, $h_thumb - $radial, $radial * 2, $radial * 2, $pic['maskBorder']['pink']); // cercle droit inférieur
        imagefilledpolygon($pic['maskBorder']['ress'], array($radial, 0, 0, $radial, 0, $h_thumb - $radial, $radial, $h_thumb, $w_thumb - $radial, $h_thumb, $w_thumb, $h_thumb - $radial, $w_thumb, $radial, $w_thumb - $radial, 0), 8, $pic['maskBorder']['pink']); // forme géométrique à 8 coter
        imagecolortransparent($pic['maskBorder']['ress'], $pic['maskBorder']['pink']); // Applique la transparence à la couleur rose
        // TRAITEMENT SUR L'IMAGE NORMAL
        // copie du masque au dessus de la miniature avec une transparence (0%)
        imagecopymerge($pic['destNormal']['ress'], $pic['maskBorder']['ress'], 0, 0, 0, 0, $w_thumb, $h_thumb, 100);
        // il faut enlever le vert pour que le fond soit transparent
        if ($radial > 0) {
            // si le radial est de 0 alors ne pas appliquer la transparence parce que le pixel 0,0
            // n'est pas vert ce qui entraine une transparence sur les zones qui on la meme couleur
            // que le pixel 0,0
            // conversion en palette 256 couleur
            //imagetruecolortopalette($pic['destNormal']['ress'], FALSE, 256);
            // affectation de la couleur verte (récupérer au pixel 0,0)
            $pic['destNormal']['green'] = imagecolorat($pic['destNormal']['ress'], 0, 0);
            // Applique la transparence à la couleur verte
            imagecolortransparent($pic['destNormal']['ress'], $pic['destNormal']['green']);
        }
        // On enregistre la miniature avec bordure coin rond
        imagepng($pic['destNormal']['ress'], $img_dest);
        imagedestroy($pic['destNormal']['ress']);
    }

    /**
     * Deletes a picture, from both database and filesystem
     *
     * @param boolean $transaction Whether to use a transaction here or not
     *
     * @return boolean true if image was successfully deleted, false otherwise
     */
    public function delete($transaction = true)
    {
        //find and delete any thumb
        $ext = strlen(pathinfo($this->file_path, PATHINFO_EXTENSION)) + 1;
        $filename = substr($this->file_path, 0, strlen($this->file_path) - $ext);

        $thumb = $filename . '_th.png';

        if (file_exists($thumb)) {
            unlink($thumb);
        }

        return parent::delete($transaction);
    }

    /**
     * Stores an image on the disk and in the database
     *
     * @param object $file the uploaded file
     * @param bool   $ajax not used
     *
     * @return true|false result of the storage process
     */
    public function store($file, $ajax = false)
    {
        $nom_fichier = substr($this->file_path, 0, strlen($this->file_path) - 4);

        $nom_thumb = $nom_fichier . '_th.png';

        if (is_file($nom_thumb)) {
            unlink($nom_thumb);
        }

        return parent::store($file);
    }

    /**
     * Renvoi la taille en pixels d'une image
     *
     * @param LendObject $object Lend object instance
     *
     * @return stdClass Un objet avec 2 propriétés width et height
     */
    public static function getHeightWidthForObject($object)
    {
        $result = new \stdClass();
        $result->width = 0;
        $result->height = 0;

        if ($object->draw_image && file_exists($object->object_image_url)) {
            $size = getimagesize($object->object_image_url);
            $result->width = $size[0];
            $result->height = $size[1];
        }

        return $result;
    }

    /**
     * Restore objects images from database blob
     *
     * @param array $success Success messages
     * @param array $error   Error messages
     *
     * @return void
     */
    public function restoreObjectPictures(&$success, &$error)
    {
        global $zdb;

        try {
            $select_all = $zdb->select($this->tbl_prefix . self::TABLE);
            $results = $zdb->execute($select_all);
            $success[] = str_replace(
                '%count',
                count($results),
                _T("Found %count objects pictures in database")
            );
            foreach ($results as $picture) {
                $path = realpath($this->store_path . $picture->object_id . '.' . $picture->format);
                if (file_exists($path)) {
                    unlink($path);
                    $success[] = str_replace(
                        '%path',
                        $path,
                        _T("Picture '%path' deleted")
                    );
                }

                file_put_contents($path, $picture->picture);
                $success[] = str_replace(
                    '%path',
                    $path,
                    _T("Picture '%path' written")
                );
            }
        } catch (\Exception $e) {
            Analog::log(
                'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                $e->getTraceAsString(),
                Analog::ERROR
            );
            $error[] = _("An error occured :(");
        }
    }
}
