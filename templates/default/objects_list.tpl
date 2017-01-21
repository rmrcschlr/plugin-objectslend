{*
    LISTE DES MESSAGES INFORMATIFS
*}
{if $msg_taken}
    <div id="infobox">
        <h1>{_T string="OBJECTS LIST.TAKEN"}</h1>
    </div>
{/if}
{if $msg_not_taken}
    <div id="warningbox">
        <h1>{_T string="OBJECTS LIST.NOT TAKEN"}</h1>
    </div>
{/if}
{if $msg_given}
    <div id="infobox">
        <h1>{_T string="OBJECTS LIST.GIVEN"}</h1>
    </div>
{/if}
{if $msg_not_given}
    <div id="warningbox">
        <h1>{_T string="OBJECTS LIST.NOT GIVEN"}</h1>
    </div>
{/if}
{if $msg_canceled}
    <div id="warningbox">
        <h1>{_T string="OBJECTS LIST.CANCELED"}</h1>
    </div>
{/if}
{if $msg_no_right}
    <div id="errorbox">
        <h1>{_T string="OBJECTS LIST.NO RIGHT"}</h1>
    </div>
{/if}
{if $msg_bad_location}
    <div id="errorbox">
        <h1>{_T string="OBJECTS LIST.BAD LOCATION"}</h1>
    </div>
{/if}
{if $msg_deleted}
    <div id="errorbox">
        <h1>{_T string="OBJECTS LIST.DELETED"}</h1>
    </div>
{/if}
{*
    TABLE DE RECHERCHE
*}
<form id="filtre" method="get" action="objects_list.php">
    <div id="listfilter">
        <label for="filter_str">Rechercher : </label>
        <input id="filter_str" type="text" placeholder="Entrer une valeur" value="" name="filter_str">
        <input class="inline ui-button ui-widget ui-state-default ui-corner-all" type="submit" value="Filtrer" role="button" aria-disabled="false">
        <input class="inline ui-button ui-widget ui-state-default ui-corner-all" type="submit" value="Effacer le filtre" name="clear_filter" role="button" aria-disabled="false">
    </div>
</form>    
{*
    TABLE DES CATEGORIES SI ELLES SONT AFFICHEES
*}
{if $view_category}
<div class="bigtable">
    <table class="details">
        <caption class="ui-state-active ui-corner-top">{_T string="OBJECTS LIST.CHOICE"}</caption>
        <tr>
{foreach from=$categories item=categ}
    {if $categ->objects_nb gt 0}
            <td style="text-align: center !important;{if $category_id eq $categ->category_id} background-color:SpringGreen;{/if}">
                <a href="?category_id={$categ->category_id}">
                    <img src="picture.php?category_id={$categ->category_id}{if $view_category_thumb}&thumb=1{/if}" 
                        border="0" title="{_T string="OBJECTS LIST.CHOOSE THIS"} {$categ->name}">
                <br/>{$categ->name} ({$categ->objects_nb})
            </td>
    {/if}
{/foreach}
            <td style="text-align: center !important;{if $category_id eq 0} background-color:SpringGreen;{/if}">
                <a href="?category_id=0">
                    <img src="picts/all.png" border="0" title="{_T string="OBJECTS LIST.ALL OBJECTS"}">
                <br/>{_T string="OBJECTS LIST.ALL OBJECTS"}
            </td>
        </tr>
    </table>
</div>
{/if}
{*
    TABLE DES OBJETS AVEC LEUR STATUT
*}
{if !$view_category || ($view_category && $category_id ne -1)}
{*
    NOMBRES DE RESULTATS PAR PAGE
*}
<form action="objects_list.php" method="get">
    <input type="hidden" name="category_id" value="{$category_id}">
    <table class="infoline">
        <tr>
            <td class="left">{$nb_results} {_T string="OBJECTS LIST.NB RESULTS"}</td>
            <td class="right">{_T string="OBJECTS LIST.NB LINES"}
                <select name="nb_lines" onchange="this.form.submit()">
                 {foreach from=$nb_lines_list item=nb}
                     <option value="{$nb}"{if $nb_lines eq $nb} selected{/if}>{$nb}</option>
                 {/foreach}
                </select>
            </td>
        </tr>
    </table>
</form>
{*
    TABLE DES OBJETS
*}
<table class="listing">
    <thead>
        <tr>
            {if $view_thumbnail eq '1'}
            <th>{_T string="OBJECTS LIST.THUMB"}</th>
            {/if}
            {if $view_name eq '1'}
            <th><a href="?tri=name{$sort_suffix}&direction={if $tri eq 'name' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.NAME"}</a>{if $tri eq 'name' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'name' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            {if $view_description eq '1'}
            <th><a href="?tri=description{$sort_suffix}&direction={if $tri eq 'description' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.DESCRIPTION"}</a>{if $tri eq 'description' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'description' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            {if $view_serial eq '1'}
            <th><a href="?tri=serial_number{$sort_suffix}&direction={if $tri eq 'serial_number' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.SERIAL"}</a>{if $tri eq 'serial_number' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'serial_number' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            {if $view_price eq '1'}
            <th><a href="?tri=price{$sort_suffix}&direction={if $tri eq 'price' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.PRICE"}</a>{if $tri eq 'price' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'price' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            {if $view_lend_price eq '1'}
            <th><a href="?tri=rent_price{$sort_suffix}&direction={if $tri eq 'rent_price' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.RENT PRICE"}</a>{if $tri eq 'rent_price' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'rent_price' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            {if $view_dimension eq '1'}
            <th><a href="?tri=dimension{$sort_suffix}&direction={if $tri eq 'dimension' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.DIMENSION"}</a>{if $tri eq 'dimension' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'dimension' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            {if $view_weight eq '1'}
            <th><a href="?tri=weight{$sort_suffix}&direction={if $tri eq 'weight' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.WEIGHT"}</a>{if $tri eq 'weight' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'weight' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            {/if}
            <th><a href="?tri=status_text{$sort_suffix}&direction={if $tri eq 'status_text' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.STATUS TEXT"}</a>{if $tri eq 'status_text' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'status_text' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            <th><a href="?tri=date_begin{$sort_suffix}&direction={if $tri eq 'date_begin' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.DATE BEGIN"}</a>{if $tri eq 'date_begin' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'date_begin' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            <th><a href="?tri=nom_adh{$sort_suffix}&direction={if $tri eq 'nom_adh' && $direction eq 'asc'}desc{else}asc{/if}&nb_lines={$nb_lines}">{_T string="OBJECTS LIST.ADHERENT"}</a>{if $tri eq 'nom_adh' && $direction eq 'asc'} <img src="{$template_subdir}images/down.png">{elseif $tri eq 'nom_adh' && $direction eq 'desc'} <img src="{$template_subdir}images/up.png">{/if}</th>
            <th>{_T string="OBJECTS LIST.GALETTE LOCATION"}</th>
            <th>{_T string="OBJECTS LIST.ACTION"}</th>
            {if $login->isAdmin() || $login->isStaff()}
            <th>{_T string="OBJECTS LIST.IS ACTIVE"}</th>
            <th></th>
            {/if}
        </tr>
    </thead>
    <tbody>
        {foreach from=$objects item=objt name=list}
            <tr>
                {if $view_thumbnail eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="center">
                    <img src="picture.php?object_id={$objt->object_id}{if $view_object_thumb}&thumb=1{/if}">
                </td>
                {/if}
                {if $view_name eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    {$objt->name}
                </td>
                {/if}
                {if $view_description eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    {$objt->description}
                </td>
                {/if}
                {if $view_serial eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    {$objt->serial_number}
                </td>
                {/if}
                {if $view_price eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="right">
                    {$objt->price}
                </td>
                {/if}
                {if $view_lend_price eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="right">
                    {$objt->rent_price}
                </td>
                {/if}
                {if $view_dimension eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    {$objt->dimension}
                </td>
                {/if}
                {if $view_weight eq '1'}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="right">
                    {$objt->weight}
                </td>
                {/if}
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    {$objt->status_text}
                </td>
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    <span style="white-space: nowrap">{$objt->date_begin_ihm}</span>
                </td>
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}">
                    {if $objt->nom_adh ne ''}
                        <a href="mailto:{$objt->email_adh}">{$objt->nom_adh} {$objt->prenom_adh}</a>
                    {/if}
                </td>
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="center">
                    {if $objt->is_galette_location}
                        <img src="picts/check.png">
                    {/if}
                </td>
                <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="center">
                    {if $objt->is_galette_location}
                        {if $enable_member_take || $login->isAdmin() || $login->isStaff()}
                        <a href="take_object.php?object_id={$objt->object_id}">
                            <img src="picts/bag.png" alt="{_T string="OBJECTS LIST.TAKE AWAY"}" title="{_T string="OBJECTS LIST.TAKE AWAY"}">
                        </a>
                        {/if}
                    {elseif $login->isAdmin() || $login->isStaff() || $login->id == $objt->id_adh}
                        <a href="give_object_back.php?object_id={$objt->object_id}">
                            <img src="picts/cabinet.png" alt="{_T string="OBJECTS LIST.REPLACE"}" title="{_T string="OBJECTS LIST.REPLACE"}">
                        </a>
                    {/if}
                </td>
                {if $login->isAdmin() || $login->isStaff()}
                    <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" align="center">
                        {if $objt->is_active}
                            <img src="picts/check.png">
                        {/if}
                    </td>
                    <td class="tbl_line_{if $smarty.foreach.list.index is odd}even{else}odd{/if}" width="40">
                        <a href="objects_edit.php?object_id={$objt->object_id}"><img src="picts/edit.png" title="{_T string="OBJECTS LIST.EDIT"}" border="0"></a>
                        <br/><a href="objects_edit.php?clone_object_id={$objt->object_id}"><img src="picts/copy.png" title="{_T string="OBJECTS LIST.COPY"}" border="0"></a>
                        <br/><a href="javascript:void(0)"><img src="picts/delete.png" title="{_T string="OBJECTS LIST.DELETE"}" border="0" onClick="confirmDelete('{$objt->name} {$objt->description}', '{$objt->object_id}')"></a>
                    </td>
                {/if}
            </tr>
        {/foreach}
    </tbody>
</table>
{*
    PAGINATION
*}
<p align="center">{$pagination}</p>
{/if}
{if $login->isAdmin() || $login->isStaff()}
    <p>
        &nbsp;
    </p>
    <form action="objects_edit.php?object_id=new" method="get">
        <div class="button-container">
            <input type="submit" id="object_create" value="{_T string="OBJECTS LIST.CREATE"}">
        </div>
    </form>
    <script>
        function confirmDelete(nom, status_id) {
            if (confirm('{_T string="OBJECTS LIST.CONFIRM DELETE"}' + nom + ' ?')) {
                window.location = 'objects_delete.php?object_id=' + status_id;
            }
            return false;
        }
    </script>
{/if}