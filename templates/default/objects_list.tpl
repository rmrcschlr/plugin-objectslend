<div id="lend_content">
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

    <form id="filtre" method="get" action="objects_list.php">
        <div id="listfilter">
            <label for="filter_str">{_T string="Search:"}&nbsp;</label>
            <input type="text" name="filter_str" id="filter_str" value="{$filters->filter_str}" type="search" placeholder="{_T string="Enter a value"}"/>&nbsp;
             {_T string="in:"}&nbsp;
            <select name="field_filter" onchange="form.submit()">
                {html_options options=$field_filter_options selected=$filters->field_filter}
            </select>
            {if $login->isAdmin() or $login->isStaff()}
                {_T string="Active:"}
                <input type="radio" name="active_filter" id="filter_dc_active" value="{php}echo GaletteObjectsLend\Repository\Objects::ALL_OBJECTS;{/php}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Objects::ALL_OBJECTS')} checked="checked"{/if}>
                <label for="filter_dc_active" >{_T string="Don't care"}</label>
                <input type="radio" name="active_filter" id="filter_yes_active" value="{php}echo GaletteObjectsLend\Repository\Objects::ACTIVE_OBJECTS;{/php}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Objects::ACTIVE_OBJECTS')} checked="checked"{/if}>
                <label for="filter_yes_active" >{_T string="Yes"}</label>
                <input type="radio" name="active_filter" id="filter_no_active" value="{php}echo GaletteObjectsLend\Repository\Objects::INACTIVE_OBJECTS;{/php}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Objects::INACTIVE_OBJECTS')} checked="checked"{/if}>
                <label for="filter_no_active" >{_T string="No"}</label>
            {/if}
            <input type="submit" class="inline" value="{_T string="Filter"}"/>
            <input name="clear_filter" type="submit" value="{_T string="Clear filter"}">
        </div>
    </form>

    {if $lendsprefs.VIEW_CATEGORY}
        <div class="bigtable">
            <table class="details">
                <caption class="ui-state-active ui-corner-top">{_T string="Choose a category"}</caption>
                <tr>
        {foreach from=$categories item=categ}
                    <td class="center{if $category_id eq $categ->category_id} cotis-ok{/if}">
                        <a href="{$galette_base_path}{$lend_dir}objects_list.php?category_filter={$categ->category_id}">
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
                        <a href="{$galette_base_path}{$lend_dir}objects_list.php?category_filter=all">
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

    <form action="objects_list.php" method="get">
        <table class="infoline">
            <tr>
                <td class="left">{$nb_objects} {if $nb_objects gt 1}{_T string="objects"}{else}{_T string="object"}{/if}</td>
                <td class="right">
                    <label for="nbshow">{_T string="Records per page:"}</label>
                    <select name="nbshow" id="nbshow">
                        {html_options options=$nbshow_options selected=$numrows}
                    </select>
                    <noscript> <span><input type="submit" value="{_T string="Change"}" /></span></noscript>
                </td>
            </tr>
        </table>
    </form>

        <form action="objects_list.php" method="post" id="objects_list">
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
                            <th>
                                <a href="{$galette_base_path}{$lend_dir}objects_list.php?tri={php}echo GaletteObjectsLend\Repository\Objects::ORDERBY_NAME;{/php}">
                                    {_T string="Name"}
                                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_NAME')}
                                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
                                    <img src="{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                                        {else}
                                    <img src="{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                                        {/if}
                                    {/if}
                                </a>
                            </th>
                        {if $lendsprefs.VIEW_SERIAL}
                            <th>
                                <a href="{$galette_base_path}{$lend_dir}objects_list.php?tri={php}echo GaletteObjectsLend\Repository\Objects::ORDERBY_SERIAL;{/php}">
                                    {_T string="Serial"}
                                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_SERIAL')}
                                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
                                            <img src="{$template_subdir}images/down.png"/>
                                        {else}
                                            <img src="{$template_subdir}images/up.png"/>
                                        {/if}
                                    {/if}
                                </a>
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <th>
                                <a href="{$galette_base_path}{$lend_dir}objects_list.php?tri={php}echo GaletteObjectsLend\Repository\Objects::ORDERBY_PRICE;{/php}">
                                    {_T string="Price"}
                                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_PRICE')}
                                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
                                    <img src="{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                                        {else}
                                    <img src="{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                                        {/if}
                                    {/if}
                                </a>
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <th>
                                <a href="{$galette_base_path}{$lend_dir}objects_list.php?tri={php}echo GaletteObjectsLend\Repository\Objects::ORDERBY_RENTPRICE;{/php}">
                                    {_T string="Borrow price"}
                                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_RENTPRICE')}
                                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
                                    <img src="{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                                        {else}
                                    <img src="{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                                        {/if}
                                    {/if}
                                </a>
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <th>
                                {_T string="Dimensions"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <th>
                                <a href="{$galette_base_path}{$lend_dir}objects_list.php?tri={php}echo GaletteObjectsLend\Repository\Objects::ORDERBY_WEIGHT;{/php}">
                                    {_T string="Weight"}
                                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_WEIGHT')}
                                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
                                    <img src="{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                                        {else}
                                    <img src="{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                                        {/if}
                                    {/if}
                                </a>
                            </th>
                        {/if}
                        <th>
                            <a href="{$galette_base_path}{$lend_dir}objects_list.php?tri={php}echo GaletteObjectsLend\Repository\Objects::ORDERBY_STATUS;{/php}">
                                {_T string="Status"}
                                {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_STATUS')}
                                    {if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
                                <img src="{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                                    {else}
                                <img src="{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                                    {/if}
                                {/if}
                            </a>
                        </th>
                        <th>
                            {_T string="Since"}
                        </th>
                        <th>
                            {_T string="By"}
                        </th>
                        {if $lendsprefs.VIEW_DATE_FORECAST}
                            <th>
                                {_T string="Return"}
                            </th>
                        {/if}
                        {if $login->isAdmin() || $login->isStaff()}
                            <th class="id_row">
                                {_T string="Active"}
                            </th>
                        {/if}
                        <th class="actions_row">
                            {_T string="Actions"}
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$objects item=object}
                        <tr class="{if $object@index is odd}even{else}odd{/if}">
                            {if $login->isAdmin() || $login->isStaff()}
                                <td class="center">
                                    <input type="checkbox" name="object_ids[]" value="{$object->object_id}">
                                </td>
                            {/if}
    {if $olendsprefs->imagesInLists()}
                            <td class="center">
                                <img src="picture.php?object_id={$object->object_id}&amp;rand={$time}&amp;thumb=1"
                                    class="picture"
                                    width="{$object->picture->getOptimalThumbWidth()}"
                                    height="{$object->picture->getOptimalThumbHeight()}"
                                    alt="{_T string="Object's photo"}"/>
                            </td>
    {/if}
                            <td>
                                <strong>{$object->search_name}</strong>
                                {if $lendsprefs.VIEW_DESCRIPTION}
                                    <br/>{$object->search_description}
                                {/if}
                            </td>
                            {if $lendsprefs.VIEW_SERIAL}
                                <td>
                                    {$object->search_serial_number}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_PRICE}
                                <td class="right nowrap">
                                    {$object->price}&euro;
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_LEND_PRICE}
                                <td class="right">
                                    {$object->rent_price}&euro;{if $object->price_per_day}<br/>{_T string="(per day)"}{/if}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_DIMENSION}
                                <td>
                                    {$object->search_dimension}
                                </td>
                            {/if}
                            {if $lendsprefs.VIEW_WEIGHT}
                                <td>
                                    {$object->weight}
                                </td>
                            {/if}
                            <td>
                                {assign var=current_rent value=$object->getCurrentRent()}
                                {if $current_rent}{$current_rent->status_text}{/if}
                            </td>
                            <td class="center">
                                {if $current_rent}<span style="white-space: nowrap">{$current_rent->date_begin|date_format:_T("Y-m-d")}</span>{/if}
                            </td>
                            <td>
                                {if $current_rent and $current_rent->nom_adh ne ''}
                                    <a href="mailto:{$current_rent->email_adh}">{$current_rent->nom_adh} {$current_rent->prenom_adh}</a>
                                {/if}
                            </td>
                            {if $lendsprefs.VIEW_DATE_FORECAST}
                                <td class="center">
                                    {if $current_rent}<span style="white-space: nowrap">{$current_rent->date_forecast|date_format:_T("Y-m-d")}</span>{/if}
                                </td>
                            {/if}
                            <td class="center">
                                {if $object->is_active}
                                    <img src="{$template_subdir}images/icon-on.png" alt="{_T string="Active"}" title="{_T string="Object is active"}"/>
                                {/if}
                            </td>
                            <td class="center nowrap">
                                {if !$current_rent or $current_rent->is_home_location}
                                    {if $lendsprefs.ENABLE_MEMBER_RENT_OBJECT || $login->isAdmin() || $login->isStaff()}
                                        <a id="take_object" href="take_object.php?object_id={$object->object_id}">
                                            <img src="{$galette_base_path}{$lend_tpl_dir}images/icon-takeaway.png" alt="{_T string="Take away"}" title="{_T string="Take object away"}"/>
                                        </a>
                                    {/if}
                                {elseif $login->isAdmin() || $login->isStaff() || $login->id == $object->id_adh}
                                        <a id="give_object" href="give_object_back.php?object_id={$object->object_id}">
                                            <img src="{$galette_base_path}{$lend_tpl_dir}images/icon-giveback.png" alt="{_T string="Give back"}" title="{_T string="Give object back"}"/>
                                        </a>
                                {/if}

    {if $login->isAdmin() || $login->isStaff()}
                                <a href="objects_edit.php?object_id={$object->object_id}">
                                    <img src="{$template_subdir}images/icon-edit.png" alt="{_T string="[mod]"}" width="16" height="16" title="{_T string="Edit the object"}"/>
                                </a>
                                <a href="objects_edit.php?clone_object_id={$object->object_id}">
                                    <img src="{$galette_base_path}{$lend_tpl_dir}images/icon-dup.png" title="{_T string="Duplicate object"}"/>
                                </a>
                                <a href="objects_print.php?object_id={$object->object_id}">
                                    <img src="{$template_subdir}images/icon-pdf.png" title="{_T string="Object card in PDF"}"/>
                                </a>
                            </td>
    {/if}
                        </tr>
                    {foreachelse}
                        {* FIXME: calculate colspan *}
                        <tr><td colspan="14" class="emptylist">{_T string="No object has been found"}</td></tr>
                    {/foreach}
                </tbody>
{if $nb_objects != 0}
            <tfoot>
                <tr>
                    <td colspan="14" id="table_footer">
                        <ul class="selection_menu">
                            <li>{_T string="For the selection:"}</li>
                            <li>
                                <input type="submit" name="print_list" class="button btnpdf" value="{_T string="Print objects list"}">
                            </li>
    {if $login->isAdmin() || $login->isStaff()}
                            <li>
                                <input type="submit" name="print_objects" class="button btnpdf" value="{_T string="Print objects cards"}">
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
                <tr>
                    <td colspan="14" class="center">
                        {_T string="Pages:"}<br/>
                        <ul class="pages">{$pagination}</ul>
                    </td>
                </tr>
            </tfoot>
{/if}
            </table>
    </form>
<script>
{if $nb_objects != 0}
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

            $('#print_list').on('click', function(e) {
                e.preventDefault();
            });
        });

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
    {/if}
{/if}
        </script>
</div>
