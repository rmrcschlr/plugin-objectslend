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
use GaletteObjectsLend\LendCategory;
use GaletteObjectsLend\Repository\Categories;
use GaletteObjectsLend\Filters\CategoriesList;
use GaletteObjectsLend\Repository\Status;
use GaletteObjectsLend\Filters\StatusList;
use GaletteObjectsLend\LendStatus;
use GaletteObjectsLend\LendObject;
use GaletteObjectsLend\Filters\ObjectsList;
use GaletteObjectsLend\Repository\Objects;

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

$this->get(
    __('/category', 'objectslend_routes') . '/{action:' .
    __('edit', 'routes') . '|' . __('add', 'routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $action = $args['action'];
        if ($action === __('edit', 'routes') && !isset($args['id'])) {
            throw new \RuntimeException(
                _T("Category ID cannot be null calling edit route!")
            );
        } elseif ($action === __('add', 'routes') && isset($args['id'])) {
             return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_category', ['action' => __('add', 'routes')])
                );
        }

        if ($this->session->objectslend_category !== null) {
            $category = $this->session->objectslend_category;
            $this->session->objectslend_category = null;
        } else {
            $category = new LendCategory($this->zdb, $this->plugins, isset($args['id']) ? (int)$args['id'] : null);
        }

        if ($category->category_id !== null) {
            $title = _T("Edit category", "objectslend");
        } else {
            $title = _T("New category", "objectslend");
        }

        $params = [
            'page_title'    => $title,
            'category'      => $category,
            'time'          => time(),
            'action'        => $action
        ];

        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']category_edit.tpl',
            $params
        );
        return $response;
    }
)->setName('objectslend_category')->add($authenticate);

$this->post(
    __('/category', 'objectslend_routes') . '/{action:' .
    __('edit', 'routes') . '|' . __('add', 'routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $action = $args['action'];
        $post = $request->getParsedBody();
        $category = new LendCategory($this->zdb, $this->plugins, isset($args['id']) ? (int)$args['id'] : null);
        $error_detected = [];

        /**
        * Store changes
        */
        $category->name = $post['name'];
        $category->is_active = $post['is_active'] == 'true';
        if ($category->store()) {
            // picture upload
            if (isset($_FILES['picture'])) {
                if ($_FILES['picture']['error'] === UPLOAD_ERR_OK) {
                    if ($_FILES['picture']['tmp_name'] !='') {
                        if (is_uploaded_file($_FILES['picture']['tmp_name'])) {
                            $res = $category->picture->store($_FILES['picture']);
                            if ($res < 0) {
                                $error_detected[] = $category->picture->getErrorMessage($res);
                            }
                        }
                    }
                } elseif ($_FILES['picture']['error'] !== UPLOAD_ERR_NO_FILE) {
                    Analog::log(
                        $category->picture->getPhpErrorMessage($_FILES['picture']['error']),
                        Analog::WARNING
                    );
                    $error_detected[] = $category->picture->getPhpErrorMessage(
                        $_FILES['picture']['error']
                    );
                }
            }

            if (isset($post['del_picture'])) {
                if (!$category->picture->delete($category->category_id)) {
                    $error_detected[] = _T("Delete failed", "objectslend");
                    Analog::log(
                        'Unable to delete picture for category ' . $category->name,
                        Analog::ERROR
                    );
                }
            }
        } else {
            $error_detected[] = _T("An error occured while storing the category.", "objectslend");
        }

        if (count($error_detected)) {
            $this->session->objectslend_category = $category;
            foreach ($error_detected as $error) {
                $this->flash->addMessage(
                    'error_detected',
                    $error
                );
            }

            return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_category', $args)
                );
        } else {
            //redirect to categories list
            $this->flash->addMessage(
                'success_detected',
                _T("Category has been saved", "objectslend")
            );

            return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_categories', $args)
                );
        }
    }
)->setName('objectslend_category_action')->add($authenticate);

$this->get(
    '/{type:' . __('category', 'objectslend_routes') .'|' . __('object', 'objectslend_routes') . '}' .
    '/{mode:' . __('photo', 'objectslend_routes') . '|' . __('thumbnail', 'objectslend_routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) {
        $id = isset($args['id']) ? $args['id'] : '';
        $type = $args['type'];
        $class = '\GaletteObjectsLend\\' .
            ($type == __('category', 'objectslend_routes') ? 'CategoryPicture' : 'ObjectPicture');
        $picture = new $class($this->plugins, $id);

        $lendsprefs = new Preferences($this->zdb);
        $thumb = false;
        if (!$lendsprefs->showFullsize() || $args['mode'] == __('thumbnail', 'objectslend_routes')) {
            //force thumbnail display from preferences
            $thumb = true;
        }

        if ($thumb) {
            $picture->displayThumb($lendsprefs);
        } else {
            $picture->display();
        }
    }
)->setName('objectslend_photo');

$this->get(
    __('/categories', 'objectslend_routes') . '[/{option:' . __('page', 'routes') . '|' .
    __('order', 'routes') . '}/{value:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $option = null;
        if (isset($args['option'])) {
            $option = $args['option'];
        }
        $value = null;
        if (isset($args['value'])) {
            $value = $args['value'];
        }

        if (isset($this->session->objectslend_filter_categories)) {
            $filters = $this->session->objectslend_filter_categories;
        } else {
            $filters = new CategoriesList();
        }

        if ($option !== null) {
            switch ($option) {
                case __('page', 'routes'):
                    $filters->current_page = (int)$value;
                    break;
                case __('order', 'routes'):
                    $filters->orderby = $value;
                    break;
            }
        }

        $categories = new Categories($this->zdb, $this->login, $this->plugins, $filters);
        $list = $categories->getCategoriesList(true);

        $this->session->objectslend_filter_categories = $filters;

        //assign pagination variables to the template and add pagination links
        $filters->setSmartyPagination($this->router, $this->view->getSmarty(), false);

        $lendsprefs = new Preferences($this->zdb);
        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']categories_list.tpl',
            array(
                'page_title'            => _T("Categories list", "objectslend"),
                'require_dialog'        => true,
                'categories'            => $list,
                'nb_categories'         => count($list),
                'filters'               => $filters,
                'olendsprefs'           => $lendsprefs,
                'time'                  => time()
            )
        );
        return $response;
    }
)->setName('objectslend_categories')->add($authenticate);

//categories list filtering
$this->post(
    __('/categories', 'objectslend_routes') . __('/filter', 'routes'),
    function ($request, $response) {
        $post = $request->getParsedBody();
        if (isset($this->session->objectslend_filter_categories)) {
            //CAUTION: this one may be simple or advanced, display must change
            $filters = $this->session->objectslend_filter_categories;
        } else {
            $filters = new CategoriesList();
        }

        //reintialize filters
        if (isset($post['clear_filter'])) {
            $filters->reinit();
        } else {
            //string to filter
            if (isset($post['filter_str'])) { //filter search string
                $filters->filter_str = stripslashes(
                    htmlspecialchars($post['filter_str'], ENT_QUOTES)
                );
            }
            //activity to filter
            if (isset($post['active_filter'])) {
                if (is_numeric($post['active_filter'])) {
                    $filters->active_filter = $post['active_filter'];
                }
            }
            //number of rows to show
            if (isset($post['nbshow'])) {
                $filters->show = $post['nbshow'];
            }
        }

        $this->session->objectslend_filter_categories = $filters;

        return $response
            ->withStatus(301)
            ->withHeader('Location', $this->router->pathFor('objectslend_categories'));
    }
)->setName('objectslend_filter_categories')->add($authenticate);

$this->get(
    __('/category', 'objectslend_routes') . __('/remove', 'routes') . '/{id:\d+}',
    function ($request, $response, $args) {
        $category = new LendCategory($this->zdb, $this->plugins, (int)$args['id']);

        $data = [
            'id'            => $args['id'],
            'redirect_uri'  => $this->router->pathFor('objectslend_categories')
        ];

        // display page
        $this->view->render(
            $response,
            'confirm_removal.tpl',
            array(
                'type'          => _T("Category", "objectslend"),
                'mode'          => $request->isXhr() ? 'ajax' : '',
                'page_title'    => sprintf(
                    _T('Remove category %1$s', 'objectslend'),
                    $category->name
                ),
                'form_url'      => $this->router->pathFor(
                    'objectslend_doremove_category',
                    ['id' => $category->category_id]
                ),
                'cancel_uri'    => $this->router->pathFor('objectslend_categories'),
                'data'          => $data
            )
        );
        return $response;
    }
)->setName('objectslend_remove_category')->add($authenticate);

$this->post(
    __('/category', 'objectslend_routes') . __('/remove', 'routes') . '/{id:\d+}',
    function ($request, $response, $args) {
        $post = $request->getParsedBody();
        $ajax = isset($post['ajax']) && $post['ajax'] === 'true';
        $success = false;

        $uri = isset($post['redirect_uri']) ?
            $post['redirect_uri'] :
            $this->router->pathFor('slash');

        if (!isset($post['confirm'])) {
            $this->flash->addMessage(
                'error_detected',
                _T("Removal has not been confirmed!")
            );
        } else {
            $category = new LendCategory($this->zdb, $this->plugins, (int)$args['id']);
            $del = $category->delete();

            if ($del !== true) {
                $error_detected = str_replace(
                    '%category',
                    $category->name,
                    _T("An error occured trying to remove category %category :/")
                );

                $this->flash->addMessage(
                    'error_detected',
                    $error_detected
                );
            } else {
                $success_detected = str_replace(
                    '%category',
                    $category->name,
                    _T("Category %category has been successfully deleted.")
                );

                $this->flash->addMessage(
                    'success_detected',
                    $success_detected
                );

                $success = true;
            }
        }

        if (!$ajax) {
            return $response
                ->withStatus(301)
                ->withHeader('Location', $uri);
        } else {
            return $response->withJson(
                [
                    'success'   => $success
                ]
            );
        }
    }
)->setName('objectslend_doremove_category')->add($authenticate);

$this->get(
    __('/status', 'objectslend_routes') . '/{action:' .
    __('edit', 'routes') . '|' . __('add', 'routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $action = $args['action'];
        if ($action === __('edit', 'routes') && !isset($args['id'])) {
            throw new \RuntimeException(
                _T("Status ID cannot be null calling edit route!")
            );
        } elseif ($action === __('add', 'routes') && isset($args['id'])) {
             return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_status', ['action' => __('add', 'routes')])
                );
        }

        if ($this->session->objectslend_status !== null) {
            $status = $this->session->objectslend_status;
            $this->session->objectslend_status = null;
        } else {
            $status = new LendStatus($this->zdb, isset($args['id']) ? (int)$args['id'] : null);
        }

        if ($status->status_id !== null) {
            $title = str_replace(
                '%status',
                $status->status_text,
                _T("Edit status %status", "objectslend")
            );
        } else {
            $title = _T("New status", "objectslend");
        }

        $params = [
            'page_title'    => $title,
            'status'        => $status,
            'action'        => $action
        ];

        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']status_edit.tpl',
            $params
        );
        return $response;
    }
)->setName('objectslend_status')->add($authenticate);

$this->post(
    __('/status', 'objectslend_routes') . '/{action:' .
    __('edit', 'routes') . '|' . __('add', 'routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $action = $args['action'];
        $post = $request->getParsedBody();
        $status = new LendStatus($this->zdb, isset($args['id']) ? (int)$args['id'] : null);
        $error_detected = [];

        $status->status_text = $post['text'];
        $status->is_home_location = isset($post['is_home_location']);
        $status->is_active = isset($post['is_active']);
        $days = trim($post['rent_day_number']);
        $status->rent_day_number = strlen($days) > 0 ? intval($days) : null;
        if (!$status->store()) {
            $error_detected[] = _T("An error occured while storing the status.", "objectslend");
        }

        if (count($error_detected)) {
            $this->session->objectslend_status = $status;
            foreach ($error_detected as $error) {
                $this->flash->addMessage(
                    'error_detected',
                    $error
                );
            }

            return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_status', $args)
                );
        } else {
            //redirect to categories list
            $this->flash->addMessage(
                'success_detected',
                _T("Status has been saved", "objectslend")
            );

            return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_statuses', $args)
                );
        }
    }
)->setName('objectslend_status_action')->add($authenticate);

$this->get(
    __('/statuses', 'objectslend_routes') . '[/{option:' . __('page', 'routes') . '|' .
    __('order', 'routes') . '}/{value:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $option = null;
        if (isset($args['option'])) {
            $option = $args['option'];
        }
        $value = null;
        if (isset($args['value'])) {
            $value = $args['value'];
        }

        if (isset($this->session->objectslend_filter_statuses)) {
            $filters = $this->session->objectslend_filter_statuses;
        } else {
            $filters = new StatusList();
        }

        if ($option !== null) {
            switch ($option) {
                case __('page', 'routes'):
                    $filters->current_page = (int)$value;
                    break;
                case __('order', 'routes'):
                    $filters->orderby = $value;
                    break;
            }
        }

        $statuses = new Status($this->zdb, $this->login, $filters);
        $list = $statuses->getStatusList(true);

        if (count(LendStatus::getActiveHomeStatuses($this->zdb)) == 0) {
            $this->flash->addMessage(
                'error_detected',
                _T("You should add at last 1 status 'on site' to ensure the plugin works well!", "objectslend")
            );
        }
        if (count(LendStatus::getActiveTakeAwayStatuses($this->zdb)) == 0) {
            $this->flash->addMessage(
                'error_detected',
                _T("You should add at last 1 status 'object borrowed' to ensure the plugin works well!", "objectslend")
            );
        }

        $this->session->objectslend_filter_statuses = $filters;

        //assign pagination variables to the template and add pagination links
        $filters->setSmartyPagination($this->router, $this->view->getSmarty(), false);

        $lendsprefs = new Preferences($this->zdb);
        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']status_list.tpl',
            array(
                'page_title'            => _T("Status list", "objectslend"),
                'require_dialog'        => true,
                'statuses'              => $list,
                'nb_status'             => count($list),
                'olendsprefs'           => $lendsprefs,
                'filters'               => $filters,
                'time'                  => time()
            )
        );
        return $response;
    }
)->setName('objectslend_statuses')->add($authenticate);

//status list filtering
$this->post(
    __('/statuses', 'objectslend_routes') . __('/filter', 'routes'),
    function ($request, $response) {
        $post = $request->getParsedBody();
        if (isset($this->session->objectslend_filter_statuses)) {
            $filters = $this->session->objectslend_filter_statuses;
        } else {
            $filters = new StatusList();
        }

        //reintialize filters
        if (isset($post['clear_filter'])) {
            $filters->reinit();
        } else {
            //string to filter
            if (isset($post['filter_str'])) { //filter search string
                $filters->filter_str = stripslashes(
                    htmlspecialchars($post['filter_str'], ENT_QUOTES)
                );
            }
            //activity to filter
            if (isset($post['active_filter'])) {
                if (is_numeric($post['active_filter'])) {
                    $filters->active_filter = $post['active_filter'];
                }
            }
            //stock to filter
            if (isset($post['stock_filter'])) {
                if (is_numeric($post['stock_filter'])) {
                    $filters->stock_filter = $post['stock_filter'];
                }
            }

            //number of rows to show
            if (isset($post['nbshow'])) {
                $filters->show = $post['nbshow'];
            }
        }

        $this->session->objectslend_filter_statuses = $filters;

        return $response
            ->withStatus(301)
            ->withHeader('Location', $this->router->pathFor('objectslend_statuses'));
    }
)->setName('objectslend_filter_statuses')->add($authenticate);

$this->get(
    __('/status', 'objectslend_routes') . __('/remove', 'routes') . '/{id:\d+}',
    function ($request, $response, $args) {
        $status = new LendStatus($this->zdb, (int)$args['id']);

        $data = [
            'id'            => $args['id'],
            'redirect_uri'  => $this->router->pathFor('objectslend_statuses')
        ];

        // display page
        $this->view->render(
            $response,
            'confirm_removal.tpl',
            array(
                'type'          => _T("Status", "objectslend"),
                'mode'          => $request->isXhr() ? 'ajax' : '',
                'page_title'    => sprintf(
                    _T('Remove status %1$s', 'objectslend'),
                    $status->status_text
                ),
                'form_url'      => $this->router->pathFor(
                    'objectslend_doremove_status',
                    ['id' => $status->status_id]
                ),
                'cancel_uri'    => $this->router->pathFor('objectslend_statuses'),
                'data'          => $data
            )
        );
        return $response;
    }
)->setName('objectslend_remove_status')->add($authenticate);

$this->post(
    __('/status', 'objectslend_routes') . __('/remove', 'routes') . '/{id:\d+}',
    function ($request, $response, $args) {
        $post = $request->getParsedBody();
        $ajax = isset($post['ajax']) && $post['ajax'] === 'true';
        $success = false;

        $uri = isset($post['redirect_uri']) ?
            $post['redirect_uri'] :
            $this->router->pathFor('slash');

        if (!isset($post['confirm'])) {
            $this->flash->addMessage(
                'error_detected',
                _T("Removal has not been confirmed!")
            );
        } else {
            $status = new LendStatus($this->zdb, (int)$args['id']);
            $del = $status->delete();

            if ($del !== true) {
                $error_detected = str_replace(
                    '%status',
                    $status->status_text,
                    _T("An error occured trying to remove status %status :/")
                );

                $this->flash->addMessage(
                    'error_detected',
                    $error_detected
                );
            } else {
                $success_detected = str_replace(
                    '%status',
                    $status->status_text,
                    _T("Status %status has been successfully deleted.")
                );

                $this->flash->addMessage(
                    'success_detected',
                    $success_detected
                );

                $success = true;
            }
        }

        if (!$ajax) {
            return $response
                ->withStatus(301)
                ->withHeader('Location', $uri);
        } else {
            return $response->withJson(
                [
                    'success'   => $success
                ]
            );
        }
    }
)->setName('objectslend_doremove_status')->add($authenticate);

$this->get(
    __('/object', 'objectslend_routes') . '/{action:' .
    __('edit', 'routes') . '|' . __('add', 'routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $action = $args['action'];
        if ($action === __('edit', 'routes') && !isset($args['id'])) {
            throw new \RuntimeException(
                _T("Object ID cannot be null calling edit route!")
            );
        } elseif ($action === __('add', 'routes') && isset($args['id'])) {
             return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_object', ['action' => __('add', 'routes')])
                );
        }

        if ($this->session->objectslend_object !== null) {
            $object = $this->session->objectslend_object;
            $this->session->objectslend_object = null;
        } else {
            $object = new LendObject($this->zdb, $this->plugins, isset($args['id']) ? (int)$args['id'] : null);
        }

        if ($object->object_id !== null) {
            $title = _T("Edit object", "objectslend");
        } else {
            $title = _T("New object", "objectslend");
        }

        $params = [
            'page_title'    => $title,
            'object'        => $object,
            'time'          => time(),
            'action'        => $action
        ];

        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']objects_edit.tpl',
            $params
        );
        return $response;
    }
)->setName('objectslend_object')->add($authenticate);

$this->post(
    __('/object', 'objectslend_routes') . '/{action:' .
    __('edit', 'routes') . '|' . __('add', 'routes') . '}[/{id:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $action = $args['action'];
        $post = $request->getParsedBody();

        $object = new LendObject($this->zdb, $this->plugins, isset($args['id']) ? (int)$args['id'] : null);
        $error_detected = [];

        $object->name = $post['name'];
        $object->description = $post['description'];
        //TODO: check if category do exits?
        $object->category_id = empty($post['category_id']) ? null : $post['category_id'];
        $object->serial_number = $post['serial'];
        if ($post['price'] != '') {
            //FIXME: better currency format handler
            $object->price = str_replace(' ', '', str_replace(',', '.', $post['price']));
        }
        if ($post['rent_price'] != '') {
            //FIXME: better currency format handler
            $object->rent_price = str_replace(' ', '', str_replace(',', '.', $post['rent_price']));
        }
        $object->price_per_day = $post['price_per_day'] == 'true';
        $object->dimension = $post['dimension'];
        if ($post['weight'] != '') {
            //FIXME: better format handler
            $object->weight = str_replace(' ', '', str_replace(',', '.', $post['weight']));
        }
        $object->is_active = $post['is_active'] == 'true';

        if ($object->store()) {
            $success_detected[] = _T("Object has been successfully stored!", "objectslend");
            if (isset($pot['1st_status'])) {
                $rent = new LendRent();
                $rent->object_id = $object->object_id;
                $rent->status_id = $post['1st_status'];
                $rent->store();
            }

            $object_id = $object->object_id;

            /* Modification du statut */
            if ($post['status']) {
                LendRent::closeAllRentsForObject(intval($object_id), $post['new_comment']);

                $rent = new LendRent();
                $rent->object_id = $object_id;
                $rent->status_id = $post['new_status'];
                if (filter_input(INPUT_POST, 'new_adh') != 'null') {
                    $rent->adherent_id = $post['new_adh'];
                }
                $rent->store();
            }
            // picture upload
            if (isset($_FILES['picture'])) {
                if ($_FILES['picture']['error'] === UPLOAD_ERR_OK) {
                    if ($_FILES['picture']['tmp_name'] !='') {
                        if (is_uploaded_file($_FILES['picture']['tmp_name'])) {
                            $res = $object->picture->store($_FILES['picture']);
                            if ($res < 0) {
                                $error_detected[] = $object->picture->getErrorMessage($res);
                            }
                        }
                    }
                } elseif ($_FILES['picture']['error'] !== UPLOAD_ERR_NO_FILE) {
                    Analog::log(
                        $object->picture->getPhpErrorMessage($_FILES['picture']['error']),
                        Analog::WARNING
                    );
                    $error_detected[] = $object->picture->getPhpErrorMessage(
                        $_FILES['picture']['error']
                    );
                }
            }

            if (isset($post['del_picture'])) {
                if (!$object->picture->delete($object->object_id)) {
                    $error_detected[] = _T("Delete failed", "objectslend");
                    Analog::log(
                        'Unable to delete picture for object ' . $object->name,
                        Analog::ERROR
                    );
                }
            }

/*

$show_status = false;
$statuses = LendStatus::getActiveStatuses();
$adherents = LendRent::getAllActivesAdherents();

$tpl->assign('page_title', $title);
$tpl->assign('object', $object);
$tpl->assign('rents', $rents);
$tpl->assign('show_status', $show_status);
$tpl->assign('statuses', $statuses);
$tpl->assign('adherents', $adherents);
$tpl->assign('lendsprefs', $lendsprefs->getpreferences());
$tpl->assign('olendsprefs', $lendsprefs);
$tpl->assign('categories', LendCategory::getActiveCategories());
$tpl->assign('time', time());
$tpl->assign('success_detected', $success_detected);
$tpl->assign('error_detected', $error_detected);
$tpl->assign('warning_detected', $warning_detected);

 */
        } else {
            $error_detected[] = _T("Something went wrong saving object :(", "objectslend");
        }



        if (count($error_detected)) {
            $this->session->objectslend_object = $object;
            foreach ($error_detected as $error) {
                $this->flash->addMessage(
                    'error_detected',
                    $error
                );
            }

            return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_object', $args)
                );
        } else {
            //redirect to objects list
            $this->flash->addMessage(
                'success_detected',
                _T("Object has been saved", "objectslend")
            );

            return $response
                ->withStatus(301)
                ->withHeader(
                    'Location',
                    $this->router->pathFor('objectslend_objects', $args)
                );
        }
    }
)->setName('objectslend_object_action')->add($authenticate);

$this->get(
    __('/objects', 'objectslend_routes') . '[/{option:' . __('page', 'routes') . '|' .
    __('order', 'routes') . '}/{value:\d+}]',
    function ($request, $response, $args) use ($module, $module_id) {
        $option = null;
        if (isset($args['option'])) {
            $option = $args['option'];
        }
        $value = null;
        if (isset($args['value'])) {
            $value = $args['value'];
        }

        if (isset($this->session->objectslend_filter_objects)) {
            $filters = $this->session->objectslend_filter_objects;
        } else {
            $filters = new ObjectsList();
        }

        if ($option !== null) {
            switch ($option) {
                case __('page', 'routes'):
                    $filters->current_page = (int)$value;
                    break;
                case __('order', 'routes'):
                    $filters->orderby = $value;
                    break;
            }
        }

        $lendsprefs = new Preferences($this->zdb);
        $objects = new Objects($this->zdb, $this->plugins, $lendsprefs, $filters);
        $list = $objects->getObjectsList(true);

        $this->session->objectslend_filter_objects = $filters;

        //assign pagination variables to the template and add pagination links
        $filters->setViewCommonsFilters($lendsprefs, $this->view->getSmarty());
        $filters->setSmartyPagination($this->router, $this->view->getSmarty(), false);

        // display page
        $this->view->render(
            $response,
            'file:[' . $module['route'] . ']objects_list.tpl',
            array(
                'page_title'            => _T("Objects list", "objectslend"),
                'require_dialog'        => true,
                'objects'               => $list,
                'nb_objects'            => count($list),
                'filters'               => $filters,
                'olendsprefs'           => $lendsprefs,
                'time'                  => time(),
                'module_id'             => $module_id
            )
        );
        return $response;
    }
)->setName('objectslend_objects')->add($authenticate);

//objects list filtering
$this->post(
    __('/objects', 'objectslend_routes') . __('/filter', 'routes'),
    function ($request, $response) {
        $post = $request->getParsedBody();
        if (isset($this->session->objectslend_filter_objects)) {
            $filters = $this->session->objectslend_filter_objects;
        } else {
            $filters = new ObjectsList();
        }

        //reintialize filters
        if (isset($post['clear_filter'])) {
            $filters->reinit();
        } else {
            //string to filter
            if (isset($post['filter_str'])) { //filter search string
                $filters->filter_str = stripslashes(
                    htmlspecialchars($post['filter_str'], ENT_QUOTES)
                );
            }
            //activity to filter
            if (isset($post['active_filter'])) {
                if (is_numeric($post['active_filter'])) {
                    $filters->active_filter = $post['active_filter'];
                }
            }
            //number of rows to show
            if (isset($post['nbshow'])) {
                $filters->show = $post['nbshow'];
            }
        }

        $this->session->objectslend_filter_objects = $filters;

        return $response
            ->withStatus(301)
            ->withHeader('Location', $this->router->pathFor('objectslend_objects'));
    }
)->setName('objectslend_filter_objects')->add($authenticate);

/*
$this->get(
    __('/category', 'objectslend_routes') . __('/remove', 'routes') . '/{id:\d+}',
    function ($request, $response, $args) {
        $category = new LendCategory($this->zdb, $this->plugins, (int)$args['id']);

        $data = [
            'id'            => $args['id'],
            'redirect_uri'  => $this->router->pathFor('objectslend_categories')
        ];

        // display page
        $this->view->render(
            $response,
            'confirm_removal.tpl',
            array(
                'type'          => _T("Category", "objectslend"),
                'mode'          => $request->isXhr() ? 'ajax' : '',
                'page_title'    => sprintf(
                    _T('Remove category %1$s', 'objectslend'),
                    $category->name
                ),
                'form_url'      => $this->router->pathFor(
                    'objectslend_doremove_category',
                    ['id' => $category->category_id]
                ),
                'cancel_uri'    => $this->router->pathFor('objectslend_categories'),
                'data'          => $data
            )
        );
        return $response;
    }
)->setName('objectslend_remove_category')->add($authenticate);

$this->post(
    __('/category', 'objectslend_routes') . __('/remove', 'routes') . '/{id:\d+}',
    function ($request, $response, $args) {
        $post = $request->getParsedBody();
        $ajax = isset($post['ajax']) && $post['ajax'] === 'true';
        $success = false;

        $uri = isset($post['redirect_uri']) ?
            $post['redirect_uri'] :
            $this->router->pathFor('slash');

        if (!isset($post['confirm'])) {
            $this->flash->addMessage(
                'error_detected',
                _T("Removal has not been confirmed!")
            );
        } else {
            $category = new LendCategory($this->zdb, $this->plugins, (int)$args['id']);
            $del = $category->delete();

            if ($del !== true) {
                $error_detected = str_replace(
                    '%category',
                    $category->name,
                    _T("An error occured trying to remove category %category :/")
                );

                $this->flash->addMessage(
                    'error_detected',
                    $error_detected
                );
            } else {
                $success_detected = str_replace(
                    '%category',
                    $category->name,
                    _T("Category %category has been successfully deleted.")
                );

                $this->flash->addMessage(
                    'success_detected',
                    $success_detected
                );

                $success = true;
            }
        }

        if (!$ajax) {
            return $response
                ->withStatus(301)
                ->withHeader('Location', $uri);
        } else {
            return $response->withJson(
                [
                    'success'   => $success
                ]
            );
        }
    }
)->setName('objectslend_doremove_category')->add($authenticate);


 */
