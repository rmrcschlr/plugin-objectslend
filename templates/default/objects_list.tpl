<div id="lend_content">
    {if $msg_taken}
        <div id="infobox">
            <h1>{_T string="OBJECTS LIST.TAKEN"}</h1>
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
    {if $msg_deleted}
        <div id="errorbox">
            <h1>{_T string="OBJECTS LIST.DELETED"}</h1>
        </div>
    {/if}
    {if $msg_disabled}
        <div id="errorbox">
            <h1>{_T string="OBJECTS LIST.DISABLED"}</h1>
        </div>
    {/if}
    {if $ajax}
        <script>
            $('#infobox').css({ldelim}"position": "fixed", "top": 20, "left": "20%", "width": "60%"{rdelim}).fadeOut(6000, function () {ldelim}
            {rdelim});
                $('#infobox h1').css({ldelim}"background": "#04CC65"{rdelim});
                    $('#warningbox').css({ldelim}"position": "fixed", "top": 20, "left": "20%", "width": "60%"{rdelim}).fadeOut(8000, function () {ldelim}
            {rdelim});
                $('#warningbox h1').css({ldelim}"background": "#FFB619"{rdelim});
                    $('#errorbox').css({ldelim}"position": "fixed", "top": 20, "left": "20%", "width": "60%"{rdelim}).fadeOut(10000, function () {ldelim}
            {rdelim});
                $('#warningbox h1').css({ldelim}"background": "#CC0000"{rdelim});
        </script>
    {/if}

    <form id="filtre" method="post" action="objects_list.php">
        <div id="listfilter">
            <label for="search">{_T string="Search:"}</label>
            <input id="search" name="search" type="text" placeholder="{_T string="Enter a value"}" value="{$search}" size="60">
            <input name="go_search" type="submit" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="Filter"}">
            <input name="reset_search" type="submit" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="Clear filter"}">
        </div>
    </form>

    {if $lendsprefs.VIEW_CATEGORY}
        <div class="bigtable">
            <table class="details">
                <caption class="ui-state-active ui-corner-top">{_T string="Choose a category"}</caption>
                <tr>
        {foreach from=$categories item=categ}
                    <td class="center{if $category_id eq $categ->category_id} cotis-ok{/if}">
                        <a href="?category_id={$categ->category_id}">
                            <img src="picture.php?category_id={$categ->category_id}&amp;rand={$time}&thumb=1"
                                class="picture"
                                width="{$categ->picture->getOptimalThumbWidth()}"
                                height="{$categ->picture->getOptimalThumbHeight()}"
                                alt=""/>
                            <br/>
                            {$categ->name} ({$categ->objects_nb})
                            {if $lendsprefs.VIEW_LIST_PRICE_SUM && $lendsprefs.VIEW_PRICE && ($login->isAdmin() || $login->isStaff())}
                                &middot;
                                {$categ->objects_price_sum} &euro;
                            {/if}
                        </a>
                    </td>
        {/foreach}
                    <td class="center{if $category_id eq 0} cotis-ok{/if}">
                        <a href="?category_id=0">
                            <img src="picture.php?category_id=0&amp;rand={$time}&thumb=1"
                                class="picture"
                                width="128"
                                height="128"
                                alt=""/>
                            <br/>
                            {_T string="All objects"} ({$nb_all_categories})
                            {if $lendsprefs.VIEW_LIST_PRICE_SUM && $lendsprefs.VIEW_PRICE && ($login->isAdmin() || $login->isStaff())}
                                &middot;
                                {$sum_all_categories} &euro;
                            {/if}
                        </a>
                    </td>
                </tr>
            </table>
        </div>
    {/if}

    {if !$lendsprefs.VIEW_CATEGORY || ($lendsprefs.VIEW_CATEGORY && $category_id ne -1)}
        <form action="objects_list.php" method="get">
            <table class="infoline">
                <tr>
                    <td class="left">{$nb_results} {if $nb_results gt 1}{_T string="objects"}{else}{_T string="object"}{/if}</td>
                    <td class="right">{_T string="Records per page:"}
                        <select name="nb_lines" onchange="this.form.submit()">
                            {foreach from=$nb_lines_list item=nb}
                                <option value="{$nb}"{if $nb_lines eq $nb} selected="selected"{/if}>{$nb}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
            </table>
        </form>

        <form action="objects_list.php" method="get" id="objects_list">
            <table class="listing">
                <thead>
                    <tr>
                        {if $login->isAdmin() || $login->isStaff()}
                            <th  class="id_row">&nbsp;</th>
                        {/if}
                        {if $olendsprefs->imagesInLists()}
                            <th class="id_row">
                                {_T string="Picture"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_NAME}
                            <th>
                                {if $lendsprefs.VIEW_NAME}
                                    <a href="?tri=name{$sort_suffix}&direction={if $tri eq 'name' && $direction eq 'asc'}desc{else}asc{/if}">
                                        {_T string="Name"}
                                    </a>
                                    {if $tri eq 'name' && $direction eq 'asc'}
                                        <img src="{$template_subdir}images/down.png"/>
                                    {elseif $tri eq 'name' && $direction eq 'desc'}
                                        <img src="{$template_subdir}images/up.png"/>
                                    {/if}
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_SERIAL}
                            <th>
                                <a href="?tri=serial_number{$sort_suffix}&direction={if $tri eq 'serial_number' && $direction eq 'asc'}desc{else}asc{/if}">
                                    {_T string="Serial"}
                                </a>
                                {if $tri eq 'serial_number' && $direction eq 'asc'} 
                                    <img src="{$template_subdir}images/down.png"/>
                                {elseif $tri eq 'serial_number' && $direction eq 'desc'} 
                                    <img src="{$template_subdir}images/up.png"/>
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <th>
                                <a href="?tri=price{$sort_suffix}&direction={if $tri eq 'price' && $direction eq 'asc'}desc{else}asc{/if}">
                                    {_T string="Price"}
                                </a>
                                {if $tri eq 'price' && $direction eq 'asc'} 
                                    <img src="{$template_subdir}images/down.png"/>
                                {elseif $tri eq 'price' && $direction eq 'desc'} 
                                    <img src="{$template_subdir}images/up.png"/>
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <th>
                                <a href="?tri=rent_price{$sort_suffix}&direction={if $tri eq 'rent_price' && $direction eq 'asc'}desc{else}asc{/if}">
                                    {_T string="Borrow price"}
                                </a>
                                {if $tri eq 'rent_price' && $direction eq 'asc'} 
                                    <img src="{$template_subdir}images/down.png"/>
                                {elseif $tri eq 'rent_price' && $direction eq 'desc'}
                                    <img src="{$template_subdir}images/up.png"/>
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <th>
                                <a href="?tri=dimension{$sort_suffix}&direction={if $tri eq 'dimension' && $direction eq 'asc'}desc{else}asc{/if}">
                                    {_T string="Dimensions"}
                                </a>
                                {if $tri eq 'dimension' && $direction eq 'asc'}
                                    <img src="{$template_subdir}images/down.png"/>
                                {elseif $tri eq 'dimension' && $direction eq 'desc'}
                                    <img src="{$template_subdir}images/up.png"/>
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <th>
                                <a href="?tri=weight{$sort_suffix}&direction={if $tri eq 'weight' && $direction eq 'asc'}desc{else}asc{/if}">
                                    {_T string="Weight"}
                                </a>
                                {if $tri eq 'weight' && $direction eq 'asc'}
                                    <img src="{$template_subdir}images/down.png"/>
                                {elseif $tri eq 'weight' && $direction eq 'desc'}
                                    <img src="{$template_subdir}images/up.png"/>
                                {/if}
                            </th>
                        {/if} 
                        <th>
                            <a href="?tri=status_text{$sort_suffix}&direction={if $tri eq 'status_text' && $direction eq 'asc'}desc{else}asc{/if}">
                                {_T string="Status"}
                            </a>
                            {if $tri eq 'status_text' && $direction eq 'asc'}
                                <img src="{$template_subdir}images/down.png"/>
                            {elseif $tri eq 'status_text' && $direction eq 'desc'}
                                <img src="{$template_subdir}images/up.png"/>
                            {/if}
                        </th>
                        <th>
                            <a href="?tri=date_begin{$sort_suffix}&direction={if $tri eq 'date_begin' && $direction eq 'asc'}desc{else}asc{/if}">
                                {_T string="Since"}
                            </a>
                            {if $tri eq 'date_begin' && $direction eq 'asc'}
                                <img src="{$template_subdir}images/down.png"/>
                            {elseif $tri eq 'date_begin' && $direction eq 'desc'}
                                <img src="{$template_subdir}images/up.png"/>
                            {/if}
                        </th>
                        <th>
                            <a href="?tri=nom_adh{$sort_suffix}&direction={if $tri eq 'nom_adh' && $direction eq 'asc'}desc{else}asc{/if}">
                                {_T string="By"}
                            </a>
                            {if $tri eq 'nom_adh' && $direction eq 'asc'}
                                <img src="{$template_subdir}images/down.png"/>
                            {elseif $tri eq 'nom_adh' && $direction eq 'desc'}
                                <img src="{$template_subdir}images/up.png"/>
                            {/if}
                        </th>
                        {if $lendsprefs.VIEW_DATE_FORECAST}
                            <th>
                                <a href="?tri=forecast{$sort_suffix}&direction={if $tri eq 'forecast' && $direction eq 'asc'}desc{else}asc{/if}">
                                    {_T string="Return"}
                                </a>
                                {if $tri eq 'forecast' && $direction eq 'asc'}
                                    <img src="{$template_subdir}images/down.png"/>
                                {elseif $tri eq 'forecast' && $direction eq 'desc'}
                                    <img src="{$template_subdir}images/up.png"/>
                                {/if}
                            </th>
                        {/if}
                        {if $login->isAdmin() || $login->isStaff()}
                            <th class="id_row">
                                {_T string="Active"}
                            </th>
                        {/if}
                        <th class="action_row">
                            {_T string="Actions"}
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$objects item=objt}
                        <tr class="{if $objt@index is odd}even{else}odd{/if}">
                            {if $login->isAdmin() || $login->isStaff()}
                                <td class="center">
                                    <input type="checkbox" name="object_ids" value="{$objt->object_id}">
                                </td>
                            {/if}
    {if $olendsprefs->imagesInLists()}
                            <td class="center">
                                <img src="picture.php?object_id={$objt->object_id}&amp;rand={$time}&amp;thumb=1"
                                    class="picture"
                                    width="{$objt->picture->getOptimalThumbWidth()}"
                                    height="{$objt->picture->getOptimalThumbHeight()}"
                                    alt="{_T string="Object's photo"}"/>
                            </td>
    {/if}
                            {if $lendsprefs.VIEW_NAME || $lendsprefs.VIEW_DESCRIPTION}
                                <td>
                                    {if $lendsprefs.VIEW_NAME}
                                        <strong>{$objt->search_name}</strong>
                                    {/if}
                                    {if $lendsprefs.VIEW_DESCRIPTION}
                                        {if $lendsprefs.VIEW_NAME}<br/>{/if}{$objt->search_description}
                                    {/if}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_SERIAL}
                                <td>
                                    {$objt->search_serial_number}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_PRICE}
                                <td class="right">
                                    {$objt->price}&euro;
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_LEND_PRICE}
                                <td class="right">
                                    {$objt->rent_price}&euro;
                                    {if $objt->price_per_day}
                                        {_T string="OBJECTS LIST.RENT PRICE PER DAY"}
                                    {/if}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_DIMENSION}
                                <td>
                                    {$objt->search_dimension}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_WEIGHT}
                                <td>
                                    {$objt->weight}
                                </td>
                            {/if}
                            <td>
                                {$objt->status_text}
                            </td>
                            <td class="center">
                                <span style="white-space: nowrap">{$objt->date_begin_ihm}</span>
                            </td>
                            <td>
                                {if $objt->nom_adh ne ''}
                                    <a href="mailto:{$objt->email_adh}">{$objt->nom_adh} {$objt->prenom_adh}</a>
                                {/if}
                            </td>
                            {if $lendsprefs.VIEW_DATE_FORECAST}
                                <td class="center">
                                    <span style="white-space: nowrap">{$objt->date_forecast_ihm}</span>
                                </td>
                            {/if}
                            <td class="center">
                                {if $objt->is_active}
                                    <img src="{$template_subdir}images/icon-on.png" alt="{_T string="Active"}" title="{_T string="Object is active"}"/>
                                {/if}
                            </td>
                            <td class="center nowrap">
                                {if $objt->is_home_location}
                                    {if $lendsprefs.ENABLE_MEMBER_RENT_OBJECT || $login->isAdmin() || $login->isStaff()}
                                        <a id="take_object" href="take_object.php?object_id={$objt->object_id}">
                                            <img src="{$galette_base_path}{$lend_tpl_dir}images/icon-takeaway.png" alt="{_T string="Take away"}" title="{_T string="Take object away"}"/>
                                        </a>
                                    {/if}
                                {elseif $login->isAdmin() || $login->isStaff() || $login->id == $objt->id_adh}
                                        <a id="give_object" href="give_object_back.php?object_id={$objt->object_id}">
                                            <img src="{$galette_base_path}{$lend_tpl_dir}images/icon-giveback.png" alt="{_T string="Give back"}" title="{_T string="Give object back"}"/>
                                        </a>
                                {/if}

    {if $login->isAdmin() || $login->isStaff()}
                                <a href="objects_edit.php?object_id={$objt->object_id}">
                                    <img src="{$template_subdir}images/icon-edit.png" alt="{_T string="[mod]"}" width="16" height="16" title="{_T string="Edit the object"}"/>
                                </a>
                                <a href="objects_edit.php?clone_object_id={$objt->object_id}">
                                    <img src="{$galette_base_path}{$lend_tpl_dir}images/icon-dup.png" title="{_T string="Duplicate object"}"/>
                                </a>
                                <a href="objects_print.php?object_id={$objt->object_id}">
                                    <img src="{$template_subdir}images/icon-pdf.png" title="{_T string="Object card in PDF"}"/>
                                </a>
                            </td>
    {/if}
                        </tr>
                    {foreachelse}
                        {* FIXME: calculate colspan *}
                        <tr><td colspan="10" class="emptylist">{_T string="No object has been found"}</td></tr>
                    {/foreach}
                </tbody>
{if $nb_results != 0}
            <tfoot>
                <tr>
                    <td colspan="7" id="table_footer">
                        <ul class="selection_menu">
                            <li>{_T string="For the selection:"}</li>
                            <li>
                                <input type="hidden" name="actual_page" id="actual_page" value="{$page}">
                                <input type="submit" class="button btnpdf" value="{_T string="Print objects list"}" onclick="return printObjectList('{$tri}', '{$category_id}');">
                            </li>
    {if $login->isAdmin() || $login->isStaff()}
                            <li>
                                <input type="submit" class="button btnpdf" value="{_T string="Print objects cards"}" onclick="return printObjectRecords();">
                            </li>
                            <li>
                                <input type="submit" value="{_T string="Take out"}" id="objects_take_away" class="button">
                            </li>
                            <li>
                                <input type="submit" value="{_T string="Return"}" id="objects_give_back" class="button">
                            </li>
                            <li>
                                <input type="submit" value="{_T string="Disable"}" onclick="return confirmDelete(false);">
                            </li>
                            <li>
                                <input type="submit" id="delete" value="{_T string="Delete"}" onclick="return confirmDelete(true);">
                            </li>
    {/if}
                        </ul>
                    </td>
                </tr>
            </tfoot>
{/if}
            </table>
        <p class="center">{$pagination}</p>
    {/if}
    </form>
<script>
{if $nb_results != 0}
        var _is_checked = true;
        var _bind_check = function(){
            $('#checkall').click(function(){
                $('table.listing :checkbox[name="object_ids"]').each(function(){
                    this.checked = _is_checked;
                });
                _is_checked = !_is_checked;
                return false;
            });
            $('#checkinvert').click(function(){
                $('table.listing :checkbox[name="object_ids"]').each(function(){
                    this.checked = !$(this).is(':checked');
                });
                return false;
            });
        }

        {* Use of Javascript to draw specific elements that are not relevant is JS is inactive *}
        $(function(){
            $('#table_footer').parent().before('<tr><td id="checkboxes" colspan="4"><span class="fleft"><a href="#" id="checkall">{_T string="(Un)Check all"}</a> | <a href="#" id="checkinvert">{_T string="Invert selection"}</a></span></td></tr>');
            _bind_check();
            $('#nbshow').change(function() {
                this.form.submit();
            });
            {* No legend?
            $('#checkboxes').after('<td class="right" colspan="3"><a href="#" id="show_legend">{_T string="Show legend"}</a></td>');
            $('#legende h1').remove();
            $('#legende').dialog({
                autoOpen: false,
                modal: true,
                hide: 'fold',
                width: '40%'
            }).dialog('close');

            $('#show_legend').click(function(){
                $('#legende').dialog('open');
                return false;
            });*}
            $('.selection_menu input[type="submit"], .selection_menu input[type="button"]').click(function(){
                var _checkeds = $('table.listing').find('input[type=checkbox]:checked').length;
                if ( _checkeds == 0 ) {
                    var _el = $('<div id="pleaseselect" title="{_T string="No object selected" escape="js"}">{_T string="Please make sure to select at least one object from the list to perform this action." escape="js"}</div>');
                    _el.appendTo('body').dialog({
                        modal: true,
                        buttons: {
                            Ok: function() {
                                $(this).dialog( "close" );
                            }
                        },
                        close: function(event, ui){
                            _el.remove();
                        }
                    });
                    return false;
                } else {

                    if ( this.id == 'delete' ) {
                        return confirm('{_T string="Do you really want to delete all selected accounts (and related contributions)?" escape="js"}');
                    }
                    return true;
                }
            });


            $('#take_object').on('click', function(e) {
                e.preventDefault();
                var _this = $(this);

                $.ajax({
                    url: _this.attr('href') + '&mode=ajax',
                    type: 'GET',
                    datatype: 'html',
                    {include file="../../../../templates/default/js_loader.tpl"},
                    success: function(res){
                        var _el = $('<div id="lend_window" title="{_T string="Take object" escape="js"}"></div>');
                        _el.appendTo('body').dialog({
                            modal: true,
                            hide: 'fold',
                            width: '60%',
                            height: 450,
                            close: function(event, ui){
                                _el.remove();
                            }
                        }).append(res);

                        $('#lend_window input:submit, #lend_window .button, #lend_window input:reset' ).button({
                            create: function(event, ui) {
                                if ( $(event.target).hasClass('disabled') ) {
                                    $(event.target).button('disable');
                                }
                            }
                        });

                        $('#btncancel').on('click', function(e) {
                            e.preventDefault();
                            $('#lend_window').dialog('close');
                        });

                        _init_takeobject_js();

                    },
                    error: function(){
                        alert("{_T string="An error occured loading 'Take away' display :(" escape="js"}")
                    }
                });
            });

            $('#give_object').on('click', function(e) {
                e.preventDefault();
                var _this = $(this);

                $.ajax({
                    url: _this.attr('href') + '&mode=ajax',
                    type: 'GET',
                    datatype: 'html',
                    {include file="../../../../templates/default/js_loader.tpl"},
                    success: function(res){
                        var _el = $('<div id="lend_window" title="{_T string="Give object" escape="js"}"></div>');
                        _el.appendTo('body').dialog({
                            modal: true,
                            hide: 'fold',
                            width: '60%',
                            height: 450,
                            close: function(event, ui){
                                _el.remove();
                            }
                        }).append(res);

                        $('#lend_window input:submit, #lend_window .button, #lend_window input:reset' ).button({
                            create: function(event, ui) {
                                if ( $(event.target).hasClass('disabled') ) {
                                    $(event.target).button('disable');
                                }
                            }
                        });

                        $('#btncancel').on('click', function(e) {
                            e.preventDefault();
                            $('#lend_window').dialog('close');
                        });

                        _init_giveobject_js();

                    },
                    error: function(){
                        alert("{_T string="An error occured loading 'Give back' display :(" escape="js"}")
                    }
                });
            });
        });
        function printObjectList(tri, category_id) {
            var baseurl = 'objects_list_print.php';

            if ($(':checkbox:checked').length > 0) {
                var objectsIds = '';
                $(':checkbox:checked').each(function () {
                    objectsIds += $(this).val() + ',';
                });
                baseurl += '?ids=' + objectsIds;
            } else {
                baseurl += '?tri=' + tri;
                if (category_id.length > 0 || category_id > 0) {
                    baseurl += '&category_id=' + category_id;
                }
            }

            window.location = baseurl;
            return false;
        }
    {if $login->isAdmin() || $login->isStaff()}
            function confirmDelete(isDelete) {
                var nbSelected = $(':checkbox:checked').length;
                if (!nbSelected) {
                    return false;
                }
                var objectsIds = '';
                $(':checkbox:checked').each(function () {
                    objectsIds += $(this).val() + ',';
                });

                var msg = isDelete ? '{_T string="OBJECTS LIST.CONFIRM DELETE"}' : '{_T string="OBJECTS LIST.CONFIRM DISABLE"}';
                msg = $('<div/>').html(msg).text();
                msg = msg.replace('$0', nbSelected);
                if (nbSelected > 0 && confirm(msg)) {
                    window.location = 'objects_delete.php?' + (isDelete ? 'delete' : 'disable') + '=1&objects_ids=' + objectsIds;
                }
                return false;
            }

            $('#objects_take_away').click(function (e) {
                e.preventDefault();
                var _this = $(this);

                $.ajax({
                    url: 'take_more_objects_away.php?mode=ajax',
                    type: 'GET',
                    data: {
                        objects_ids: get_checked_objets_ids()
                    },
                    datatype: 'html',
                    {include file="../../../../templates/default/js_loader.tpl"},
                    success: function(res){
                        var _el = $('<div id="lend_window" title="{_T string="Take objects" escape="js"}"></div>');
                        _el.appendTo('body').dialog({
                            modal: true,
                            hide: 'fold',
                            width: '60%',
                            height: 450,
                            close: function(event, ui){
                                _el.remove();
                            }
                        }).append(res);

                        $('#lend_window input:submit, #lend_window .button, #lend_window input:reset' ).button({
                            create: function(event, ui) {
                                if ( $(event.target).hasClass('disabled') ) {
                                    $(event.target).button('disable');
                                }
                            }
                        });

                        $('#btncancel').on('click', function(e) {
                            e.preventDefault();
                            $('#lend_window').dialog('close');
                        });

                        _init_takeobject_js();

                    },
                    error: function(){
                        alert("{_T string="An error occured loading 'Take away' display :(" escape="js"}")
                    }
                });
            });

            $('#objects_give_back').click(function (e) {
                e.preventDefault();
                var _this = $(this);

                $.ajax({
                    url: 'give_more_objects_back.php?mode=ajax',
                    type: 'GET',
                    data: {
                        objects_ids: get_checked_objets_ids()
                    },
                    datatype: 'html',
                    {include file="../../../../templates/default/js_loader.tpl"},
                    success: function(res){
                        var _el = $('<div id="lend_window" title="{_T string="Give back objects" escape="js"}"></div>');
                        _el.appendTo('body').dialog({
                            modal: true,
                            hide: 'fold',
                            width: '60%',
                            height: 450,
                            close: function(event, ui){
                                _el.remove();
                            }
                        }).append(res);

                        $('#lend_window input:submit, #lend_window .button, #lend_window input:reset' ).button({
                            create: function(event, ui) {
                                if ( $(event.target).hasClass('disabled') ) {
                                    $(event.target).button('disable');
                                }
                            }
                        });

                        $('#btncancel').on('click', function(e) {
                            e.preventDefault();
                            $('#lend_window').dialog('close');
                        });

                        _init_giveobject_js();

                    },
                    error: function(){
                        alert("{_T string="An error occured loading 'Give back' display :(" escape="js"}")
                    }
                });
            });

            function statusObjects(isAway) {
                if (!$(':checkbox:checked').length) {
                    return false;
                }
                var objectsIds = '';
                $(':checkbox:checked').each(function () {
                    objectsIds += $(this).val() + ',';
                });
                window.location = (isAway ? 'take_more_objects_away' : 'give_more_objects_back') + '.php?objects_ids=' + objectsIds;
                return false;
            }

            function printObjectRecords() {
                var baseurl = 'objects_print.php';

                if ($(':checkbox:checked').length > 0) {
                    var objectsIds = '';
                    $(':checkbox:checked').each(function () {
                        objectsIds += $(this).val() + ',';
                    });
                    baseurl += '?ids=' + objectsIds;

                    window.location = baseurl;
                }
                return false;
            }
    {/if}
{/if}
        </script>
</div>
