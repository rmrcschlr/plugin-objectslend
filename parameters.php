<?php

/**
 * Display all parameters of the Plugin and allow the Admin to edit
 * the values of the parameters
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

/**
 * Convertit une date du format IHM 'jj/mm/aaaa' vers le format SQL 'aaaa-mm-jj'
 * 
 * @param string $str Date au format IHM 'jj/mm/aaaa'
 * 
 * @return string Date au format SQL 'aaaa-mm-jj'
 */
function dateIHMtoSQL($str) {
    if (strlen($str) < 5) {
        return '';
    }
    $dt = date_create_from_format('d/m/Y', $str);
    return $dt->format('Y-m-d');
}

/**
 * Convertit une date du format SQL 'aaaa-mm-jj' vers le format IHM 'jj/mm/aaaa'
 * 
 * @param string $str Date au format SQL 'aaaa-mm-jj'
 * 
 * @return string Date au format IHM 'jj/mm/aaaa'
 */
function dateSQLtoIHM($str) {
    list($annee, $mois, $jour) = explode('-', $str);
    return $jour . '/' . $mois . '/' . $annee;
}

define('GALETTE_BASE_PATH', '../../');
require_once GALETTE_BASE_PATH . 'includes/galette.inc.php';
if (!$login->isLogged() || !$login->isAdmin()) {
    header('location: ' . GALETTE_BASE_PATH . 'index.php');
    die();
}

// Import des classes de notre plugin
require_once '_config.inc.php';

global $zdb;

/**
 * Sauvegarde des paramètres envoyés
 */
$erreurs = false;
$parametres_sauves = false;
$liste_erreurs = array();
if (filter_has_var(INPUT_POST, 'liste_codes')) {
    $parametres_sauves = true;
    $liste_codes = filter_input(INPUT_POST, 'liste_codes', FILTER_SANITIZE_STRING, FILTER_REQUIRE_ARRAY);
    foreach ($liste_codes as $code_param) {
        if (filter_input(INPUT_POST, 'valeur_' . $code_param) != filter_input(INPUT_POST, 'ancienne_valeur_' . $code_param)) {
            try {
                $values = array(
                    'is_date' => filter_input(INPUT_POST, 'format_' . $code_param) == 'date' ? true : false,
                    'value_date' => filter_input(INPUT_POST, 'format_' . $code_param) == 'date' ? dateIHMtoSQL(filter_input(INPUT_POST, 'valeur_' . $code_param)) : new Zend\Db\Sql\Predicate\Expression('NULL'),
                    'is_text' => filter_input(INPUT_POST, 'format_' . $code_param) == 'text' ? true : false,
                    'value_text' => filter_input(INPUT_POST, 'format_' . $code_param) == 'text' ? filter_input(INPUT_POST, 'valeur_' . $code_param) : new Zend\Db\Sql\Predicate\Expression('NULL'),
                    'is_numeric' => filter_input(INPUT_POST, 'format_' . $code_param) == 'numeric' ? true : false,
                    'value_numeric' => filter_input(INPUT_POST, 'format_' . $code_param) == 'numeric' ? filter_input(INPUT_POST, 'valeur_' . $code_param) : new Zend\Db\Sql\Predicate\Expression('NULL'),
                    'date_modification' => date('Y-m-d H:i:s')
                );
                $update = $zdb->update(LEND_PREFIX . LendParameter::TABLE)
                        ->set($values)
                        ->where(array(LendParameter::PK => $code_param));
                $zdb->execute($update);
            } catch (Exception $e) {
                $liste_erreurs[] = 'Sauvegarde du paramètre ' . $code_param . ' échouée.';
                $erreurs = true;
                Analog\Analog::log(
                        'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
                        $e->getTraceAsString(), Analog\Analog::ERROR
                );
            }
        }
    }
}

/**
 * Lecture de tous les paramètres en base pour leur affichage à l'écran
 */
$parametres = array();
try {
    $select = $zdb->select(LEND_PREFIX . LendParameter::TABLE)
            ->order(LendParameter::PK);
    $rows = $zdb->execute($select);

    foreach ($rows as $r) {
        $param = new LendParameter($r);
        if ($param->is_date) {
            $param->value_date = dateSQLtoIHM($param->value_date);
        }

        $parametres[] = $param;
    }
} catch (Exception $e) {
    Analog\Analog::log(
            'Something went wrong :\'( | ' . $e->getMessage() . "\n" .
            $e->getTraceAsString(), Analog\Analog::ERROR
    );
}

/**
 * Le traitement est terminé, on affiche le template
 */
$tpl->assign('page_title', _T("PARAMETER LEND.PAGE TITLE"));

//Set the path to the current plugin's templates,
//but backup main Galette's template path before
$orig_template_path = $tpl->template_dir;
$tpl->template_dir = 'templates/' . $preferences->pref_theme;

$tpl->assign('liste_parametres', $parametres);
$tpl->assign('parametres_sauves', $parametres_sauves);
$tpl->assign('erreurs', $erreurs);
$tpl->assign('liste_erreurs', $liste_erreurs);
$tpl->assign('require_calendar', true);
$tpl->assign('color_picker', true);
$tpl->assign('require_tabs', true);

$content = $tpl->fetch('parametres.tpl', LEND_SMARTY_PREFIX);
$tpl->assign('content', $content);
//Set path to main Galette's template
$tpl->template_dir = $orig_template_path;
$tpl->display('page.tpl', LEND_SMARTY_PREFIX);
?>
