<div id="lend_content">
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

    {if $view_category}
        <div class="bigtable">
            <table class="details">
                <caption class="ui-state-active ui-corner-top">{_T string="OBJECTS LIST.CHOICE"}</caption>
                <tr>
                    {foreach from=$categories item=categ}
                        {if $categ->objects_nb gt 0}
                            <td style="text-align: center !important;{if $category_id eq $categ->category_id} background-color:SpringGreen;{/if}">
                                <a href="?category_id={$categ->category_id}">
                                    <img src="{$categ->categ_image_url}" {if $view_category_thumb}style="max-height: {$thumb_max_height}px; max-width: {$thumb_max_width}px;"{/if}
                                         border="0" class="tooltip_lend" title="{_T string="OBJECTS LIST.CHOOSE THIS"} <i>''{$categ->name}''</i>"/>
                                    <br/>
                                    {$categ->name} ({$categ->objects_nb})
                                    {if $view_price_sum && $view_price && ($login->isAdmin() || $login->isStaff())}
                                        &middot;
                                        {$categ->objects_price_sum} &euro;
                                    {/if}
                                </a>
                            </td>
                        {/if}
                    {/foreach}
                    <td style="text-align: center !important;{if $category_id eq 0} background-color:SpringGreen;{/if}">
                        <a href="?category_id=0">
                            <img src="picts/all.png" border="0" class="tooltip_lend" title="{_T string="OBJECTS LIST.ALL OBJECTS"}"/>
                            <br/>
                            {_T string="OBJECTS LIST.ALL OBJECTS"} ({$nb_all_categories})
                            {if $view_price_sum && $view_price && ($login->isAdmin() || $login->isStaff())}
                                &middot;
                                {$sum_all_categories} &euro;
                            {/if}
                        </a>
                    </td>
                </tr>
            </table>
        </div>
    {/if}

    {if !$view_category || ($view_category && $category_id ne -1)}
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

        <form action="objects_edit.php?object_id=new" method="get" id="objects_list">
            <table class="listing">
                <thead>
                    <tr>
                        {if $login->isAdmin() || $login->isStaff()}
                            <th>
                            </th>
                        {/if}
                        {if $view_thumbnail}
                            <th>
                                {_T string="Picture"}
                            </th>
                        {/if}
                        {if $view_name || $view_description}
                            <th>
                                {if $view_name}
                                    <a href="?tri=name{$sort_suffix}&direction={if $tri eq 'name' && $direction eq 'asc'}desc{else}asc{/if}">
                                        {_T string="Name"}
                                    </a>
                                    {if $tri eq 'name' && $direction eq 'asc'}
                                        <img src="{$template_subdir}images/down.png"/>
                                    {elseif $tri eq 'name' && $direction eq 'desc'}
                                        <img src="{$template_subdir}images/up.png"/>
                                    {/if}
                                {/if}
                                {if $view_name && $view_description}
                                    /
                                {/if}
                                {if $view_description}
                                    <a href="?tri=description{$sort_suffix}&direction={if $tri eq 'description' && $direction eq 'asc'}desc{else}asc{/if}">
                                        {_T string="Description"}
                                    </a>
                                    {if $tri eq 'description' && $direction eq 'asc'} 
                                        <img src="{$template_subdir}images/down.png"/>
                                    {elseif $tri eq 'description' && $direction eq 'desc'}
                                        <img src="{$template_subdir}images/up.png"/>
                                    {/if}
                                {/if}
                            </th>
                        {/if}
                        {if $view_serial}
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
                        {if $view_price}
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
                        {if $view_lend_price}
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
                        {if $view_dimension}
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
                        {if $view_weight }
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
                        {if $view_date_forecast}
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
                        <th>
                            {_T string="Actions"}
                        </th>
                        {if $login->isAdmin() || $login->isStaff()}
                            <th>
                                {_T string="Active"}
                            </th>
                            <th>
                            </th>
                        {/if}
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$objects item=objt}
                        <tr class="{if $objt@index is odd}even{else}odd{/if}">
                            {if $login->isAdmin() || $login->isStaff()}
                                <td align="center">
                                    <input type="checkbox" name="object_ids" value="{$objt->object_id}">
                                </td>
                            {/if}
                            {if $view_thumbnail eq '1'}
                                <td align="center">
                                    {if $objt->draw_image}
                                        <img src="{$objt->object_image_url}" 
                                             class="tooltip_lend" title="{$objt->tooltip_title}"
                                             {if $view_object_thumb}style="max-height: {$thumb_max_height}px; max-width: {$thumb_max_width}px;"{/if}/>
                                    {/if}
                                </td>
                            {/if}
                            {if $view_name || $view_description}
                                <td>
                                    {if $view_name}
                                        <b>{$objt->search_name}</b>
                                    {/if}
                                    {if $view_name && $view_description}
                                        <br/>
                                    {/if}
                                    {if $view_description}
                                        {$objt->search_description}
                                    {/if} 
                                </td>
                            {/if}
                            {if $view_serial}
                                <td>
                                    {$objt->search_serial_number}
                                </td>
                            {/if}
                            {if $view_price}
                                <td align="right">
                                    {$objt->price}&euro;
                                </td>
                            {/if}
                            {if $view_lend_price eq '1'}
                                <td align="right">
                                    {$objt->rent_price}&euro;
                                    {if $objt->price_per_day}
                                        {_T string="OBJECTS LIST.RENT PRICE PER DAY"}
                                    {/if}
                                </td>
                            {/if}
                            {if $view_dimension}
                                <td>
                                    {$objt->search_dimension}
                                </td>
                            {/if}
                            {if $view_weight eq '1'}
                                <td>
                                    {$objt->weight}
                                </td>
                            {/if}
                            <td>
                                {$objt->status_text}
                            </td>
                            <td align="center">
                                <span style="white-space: nowrap">{$objt->date_begin_ihm}</span>
                            </td>
                            <td>
                                {if $objt->nom_adh ne ''}
                                    <a href="mailto:{$objt->email_adh}">{$objt->nom_adh} {$objt->prenom_adh}</a>
                                {/if}
                            </td>
                            {if $view_date_forecast}
                                <td align="center">
                                    <span style="white-space: nowrap">{$objt->date_forecast_ihm}</span>
                                </td>
                            {/if}
                            <td align="center">
                                {if $objt->is_home_location}
                                    {if $enable_member_take || $login->isAdmin() || $login->isStaff()}
                                        <a onclick="take_object({$objt->object_id});" style="cursor: pointer;" {*href="take_object.php?object_id={$objt->object_id}"*}>
                                            <img src="picts/bag.png" alt="{_T string="OBJECTS LIST.TAKE AWAY"}" class="tooltip_lend" title="{_T string="OBJECTS LIST.TAKE AWAY"}"/>
                                        </a>
                                    {/if}
                                {elseif $login->isAdmin() || $login->isStaff() || $login->id == $objt->id_adh}
                                    <a onclick="give_object_back({$objt->object_id});" style="cursor: pointer;" {*href="give_object_back.php?object_id={$objt->object_id}"*}>
                                        <img src="picts/cabinet.png" alt="{_T string="OBJECTS LIST.REPLACE"}" class="tooltip_lend" title="{_T string="OBJECTS LIST.REPLACE"}">
                                    </a>
                                {/if}
                            </td>
                            {if $login->isAdmin() || $login->isStaff()}
                                <td align="center">
                                    {if $objt->is_active}
                                        <img src="picts/check.png" alt="{_T string="OBJECTS LIST.IS ACTIVE"}" title="{_T string="OBJECTS LIST.IS ACTIVE"}"/>
                                    {/if}
                                </td>
                                <td align="center">
                                    <a href="objects_edit.php?object_id={$objt->object_id}">
                                        <img src="picts/edit.png" class="tooltip_lend" title="{_T string="OBJECTS LIST.EDIT"}" border="0"/>
                                    </a>
                                    <a href="objects_edit.php?clone_object_id={$objt->object_id}">
                                        <img src="picts/copy.png" class="tooltip_lend" title="{_T string="OBJECTS LIST.COPY"}" border="0"/>
                                    </a>
                                    <a href="objects_print.php?object_id={$objt->object_id}">
                                        <img src="picts/pdf24.png" class="tooltip_lend" title="{_T string="OBJECTS LIST.PDF"}" border="0"/>
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
                                <input type="submit" id="objects_print" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECTS LIST.PRINT"}" onclick="return printObjectList('{$tri}', '{$category_id}');">
                            </li>
    {if $login->isAdmin() || $login->isStaff()}
                            <li>
                                <input type="submit" id="objects_record_print" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECTS LIST.SINGLE PRINT"}" onclick="return printObjectRecords();">
                            </li>
                            <li>
                                <input type="submit" id="objects_take_away" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECTS LIST.MORE AWAY"}">
                            </li>
                            <li>
                                <input type="submit" id="objects_give_back" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECTS LIST.GIVE BACK"}">
                            </li>
                            <li>
                                <input type="submit" id="objects_disable" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECTS LIST.DISABLE"}" onclick="return confirmDelete(false);">
                            </li>
                            <li>
                                <input type="submit" id="objects_delete" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECTS LIST.DELETE"}" onclick="return confirmDelete(true);">
                            </li>
    {/if}
                        </ul>
                    </td>
                </tr>
            </tfoot>
{/if}
            </table>
        <p align="center">{$pagination}</p>
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
{/if}

        {* Use of Javascript to draw specific elements that are not relevant is JS is inactive *}
        $(function(){
{if $nb_results != 0}
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
{/if}
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

            $('#objects_take_away').click(function () {
                take_more_objects();
                return false;
            });

            $('#objects_give_back').click(function () {
                give_more_objects_back();
                return false;
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
        </script>
</div>
