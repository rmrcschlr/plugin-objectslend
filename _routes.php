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


//Constants and classes from plugin
require_once $module['root'] . '/_config.inc.php';

$this->get(
    __('/preferences', 'routes'),
    function ($request, $response, $args) use ($module, $module_id) {
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
    function ($request, $response, $args) use ($module, $module_id) {
        $post = $request->getParsedBody();
        $lendsprefs = new Preferences($this->zdb);

        $error_detected = [];
        $success_detected = [];
        if ($lendsprefs->store($pos, $error_detected)) {
            $this->flash->addMessage(
                'success_detected',
                _T("Preferences have been successfully stored!")
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
