<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * ObjectsLend routes
 *
 * PHP version 5
 *
 * Copyright © 2017 The Galette Team
 *
 * This file is part of Galette (http://galette.tuxfamily.org).
 *
 * Galette is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Galette is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Galette. If not, see <http://www.gnu.org/licenses/>.
 *
 * @category Plugins
 * @package  GaletteObjectsLend
 *
 * @author    Johan Cwiklinski <johan@x-tnd.be>
 * @copyright 2017 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   SVN: $Id$
 * @link      http://galette.tuxfamily.org
 * @since     2017-11-19
 */

use Analog\Analog;
use Galette\Entity\ContributionsTypes;
use GaletteObjectsLend\Preferences;
use GaletteObjectsLend\ObjectPicture;
use GaletteObjectsLend\CategoryPicture;

//Constants and classes from plugin
require_once $module['root'] . '/_config.inc.php';

$this->get(
    __('/preferences', 'routes'),
    function ($request, $response) use ($module, $module_id) {
        if ($this->session->objectslend_preferences !== null) {
            $lendsprefs = $this->session->objectslend_preferences;
            $this->session->objectslend_preferences = null;
        } else {
            $lendsprefs = new Preferences($this->zdb);
        }

        $ctypes = new ContributionsTypes($this->zdb);

        $params = [
            'page_title'    => _T('ObjectsLend preferences', 'objectslend'),
            'ctypes'        => $ctypes->getList(),
            'lendsprefs'    => $lendsprefs->getpreferences()
        ];

        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']preferences.tpl',
            $params
        );
        return $response;
    }
)->setName('objectslend_preferences')->add($authenticate);

$this->post(
    __('/preferences', 'routes'),
    function ($request, $response) {
        $post = $request->getParsedBody();
        $lendsprefs = new Preferences($this->zdb);

        $error_detected = [];
        $success_detected = [];
        if ($lendsprefs->store($post, $error_detected)) {
            $this->flash->addMessage(
                'success_detected',
                _T("Preferences have been successfully stored!", "objectslend")
            );
        } else {
            $this->session->objectslend_preferences = $lendsprefs;
            foreach ($error_detected as $error) {
                $this->flash->addMessage(
                    'error_detected',
                    $error
                );
            }
        }

        return $response
            ->withStatus(301)
            ->withHeader(
                'Location',
                $this->router->pathFor('objectslend_preferences')
            );
    }
)->setName('store_objectlend_preferences')->add($authenticate);

$this->get(
    __('/administration', 'objectslend_routes') . __('/images', 'objectslend_routes'),
    function ($request, $response) use ($module, $module_id) {
        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']admin_picture.tpl',
            [
                'page_title' => _T("Pictures administration", "objectslend")
            ]
        );
        return $response;
    }
)->setName('objectslend_adminimages')->add($authenticate);

$this->post(
    __('/administration', 'objectslend_routes') . __('/images', 'objectslend_routes'),
    function ($request, $response, $args) use ($module, $module_id) {
        $post = $request->getParsedBody();
        $success_detected = [];
        $error_detected = [];

        if (isset($post['save_categories']) || isset($post['save_objects'])) {
            $pic_class = isset($post['save_categories']) ? 'CategoryPicture' : 'ObjectPicture';
            $pic_class = '\GaletteObjectsLend\\' . $pic_class;
            $picture = new $pic_class($this->plugins);

            $zip_file = GALETTE_EXPORTS_PATH . 'objectslends/';
            if (!file_exists($zip_file)) {
                if (!mkdir($zip_file, 0755, true)) {
                    Analog::log(
                        'Unable to create backup dir `' . $zip_file . '`.',
                        Analog::ERROR
                    );
                    $error_detected[] = str_replace(
                        '%dir',
                        $zip_file,
                        _T('Unable to create backup directory "%dir"', 'objectslends')
                    );
                } else {
                    Analog::log(
                        'New directory `' . $zip_file . '` has been created',
                        Analog::INFO
                    );
                }
            }

            if (!count($error_detected)) {
                $zip_filename = isset($post['save_categories']) ? 'categories.zip' : 'objects.zip';
                $zip_file .= $zip_filename;

                $zip = new \ZipArchive();

                $ZIP_ERROR = [
                    ZipArchive::ER_EXISTS   => _T('File already exists.', 'objectslends'),
                    ZipArchive::ER_INCONS   => _T('Zip archive inconsistent.', 'objectslends'),
                    ZipArchive::ER_INVAL    => _T('Invalid argument.', 'objectslends'),
                    ZipArchive::ER_MEMORY   => _T('Memory allocation failure.', 'objectslends'),
                    ZipArchive::ER_NOENT    => _T('No such file.', 'objectslends'),
                    ZipArchive::ER_NOZIP    => _T('Not a zip archive.', 'objectslends'),
                    ZipArchive::ER_OPEN     => _T("Can't open file.", "objectslends"),
                    ZipArchive::ER_READ     => _T('Read error.', 'objectslends'),
                    ZipArchive::ER_SEEK     => _T('Seek error.', 'objectslends'),
                ];

                $result_code = $zip->open($zip_file, \ZipArchive::CREATE | \ZipArchive::OVERWRITE);
                if ($result_code !== true) {
                    $error_detected[] = isset($ZIP_ERROR[$result_code]) ?
                        $ZIP_ERROR[$result_code] :
                        _T('Unknown error.', 'objectslends');
                } else {
                    $dir_pictures = opendir($picture->getDir());
                    while (($file = readdir($dir_pictures)) !== false) {
                        if (preg_match('/^[0-9]+$/', pathinfo($file, PATHINFO_FILENAME)) !== false && !is_dir($file)) {
                            $zip->addFile($picture->getDir() . '/' . $file, $file);
                        }
                    }
                    $zip->close();
                    if (file_exists($zip_file)) {
                        header('Content-Type: application/zip');
                        header('Content-Disposition: attachment; filename="' . $zip_filename . '";');
                        header('Pragma: no-cache');
                        readfile($zip_file);
                    } else {
                        Analog::log(
                            'A request has been made to get file named `' .
                            $zip_filename .'` that does not exists.',
                            Analog::WARNING
                        );
                        $error_detected[] = str_replace(
                            '%filename',
                            $zip_filename,
                            _T('File %filename does not exists', 'objectslends')
                        );
                    }
                }
            }
        }

        if (isset($post['restore_objects'])) {
            $p = new ObjectPicture($this->plugins, -1);
            $p->restorePictures($success_detected, $error_detected);
        }

        if (isset($post['restore_categories'])) {
            $p = new CategoryPicture($this->plugins, -1);
            $p->restorePictures($success_detected, $error_detected);
        }

        foreach ($error_detected as $error) {
            $this->flash->addMessage(
                'error_detected',
                $error
            );
        }

        foreach ($success_detected as $success) {
            $this->flash->addMessage(
                'success_detected',
                $success
            );
        }

        return $response
            ->withStatus(301)
            ->withHeader(
                'Location',
                $this->router->pathFor('objectslend_adminimages')
            );
    }
)->setName('objectslend_adminimages_action')->add($authenticate);
