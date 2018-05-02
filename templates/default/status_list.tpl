{extends file="page.tpl"}
{block name="content"}
    <form id="filtre" method="POST" action="{path_for name="objectslend_filter_statuses"}">
        <div id="listfilter">
            <label for="filter_str">{_T string="Search:"}&nbsp;</label>
            <input type="text" name="filter_str" id="filter_str" value="{$filters->filter_str}" type="search" placeholder="{_T string="Enter a value"}"/>&nbsp;
            {_T string="Active:" domain="objectslend"}
            <input type="radio" name="active_filter" id="filter_dc_active" value="{GaletteObjectsLend\Repository\Status::ALL}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Status::ALL')} checked="checked"{/if}>
            <label for="filter_dc_active" >{_T string="Don't care"}</label>
            <input type="radio" name="active_filter" id="filter_yes_active" value="{GaletteObjectsLend\Repository\Status::ACTIVE}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Status::ACTIVE')} checked="checked"{/if}>
            <label for="filter_yes_active" >{_T string="Yes"}</label>
            <input type="radio" name="active_filter" id="filter_no_active" value="{GaletteObjectsLend\Repository\Status::INACTIVE}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Status::INACTIVE')} checked="checked"{/if}>
            <label for="filter_no_active" >{_T string="No"}</label>
            {_T string="In stock:" domain="objectslend"}
            <input type="radio" name="stock_filter" id="filter_dc_stock" value="{GaletteObjectsLend\Repository\Status::DC_STOCK}"{if $filters->stock_filter eq constant('GaletteObjectsLend\Repository\Status::DC_STOCK')} checked="checked"{/if}>
            <label for="filter_dc_stock" >{_T string="Don't care"}</label>
            <input type="radio" name="stock_filter" id="filter_yes_stock" value="{GaletteObjectsLend\Repository\Status::IN_STOCK}"{if $filters->stock_filter eq constant('GaletteObjectsLend\Repository\Status::IN_STOCK')} checked="checked"{/if}>
            <label for="filter_yes_stock" >{_T string="Yes"}</label>
            <input type="radio" name="stock_filter" id="filter_no_stock" value="{GaletteObjectsLend\Repository\Status::OUT_STOCK}"{if $filters->stock_filter eq constant('GaletteObjectsLend\Repository\Status::OUT_STOCK')} checked="checked"{/if}>
            <label for="filter_no_stock" >{_T string="No"}</label>
            <input type="submit" class="inline" value="{_T string="Filter"}"/>
            <input name="clear_filter" type="submit" value="{_T string="Clear filter"}">
        </div>
        <div class="infoline">
            {$nb_status} {_T string="status" domain="objectslend"}
            <div class="fright">
                <label for="nbshow">{_T string="Records per page:"}</label>
                <select name="nbshow" id="nbshow">
                    {html_options options=$nbshow_options selected=$numrows}
                </select>
                <noscript> <span><input type="submit" value="{_T string="Change"}" /></span></noscript>
            </div>
        </div>
    </form>
<table class="listing">
    <thead>
        <tr>
            <th class="id_row">
                <a href="{path_for name="objectslend_statuses" data=["option" => {_T string='order' domain="routes"}, "value" => "GaletteObjectsLend\Repository\Status::ORDERBY_ID"|constant]}">
                    #
                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Status::ORDERBY_ID')}
                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\StatusList::ORDER_ASC')}
                    <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                        {else}
                    <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                        {/if}
                    {/if}
                </a>
            </th>
            <th>
                <a href="{path_for name="objectslend_statuses" data=["option" => {_T string='order' domain="routes"}, "value" => "GaletteObjectsLend\Repository\Status::ORDERBY_NAME"|constant]}">
                    {_T string="Status" domain="objectslend"}
                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Status::ORDERBY_NAME')}
                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\StatusList::ORDER_ASC')}
                    <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                        {else}
                    <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                        {/if}
                    {/if}
                </a>
            </th>
            <th class="id_row">
                <a href="{path_for name="objectslend_statuses" data=["option" => {_T string='order' domain="routes"}, "value" => "GaletteObjectsLend\Repository\Status::ORDERBY_ACTIVE"|constant]}">
                    {_T string="Active" domain="objectslend"}
                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Status::ORDERBY_ACTIVE')}
                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\StatusList::ORDER_ASC')}
                    <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                        {else}
                    <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                        {/if}
                    {/if}
                </a>
            </th>
            <th class="id_row">
                <a href="{path_for name="objectslend_statuses" data=["option" => {_T string='order' domain="routes"}, "value" => "GaletteObjectsLend\Repository\Status::ORDERBY_STOCK"|constant]}">
                    {_T string="Stock" domain="objectslend"}
                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Status::ORDERBY_STOCK')}
                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\StatusList::ORDER_ASC')}
                    <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                        {else}
                    <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                        {/if}
                    {/if}
                </a>
            </th>
            <th class="id_row">
                <a href="{path_for name="objectslend_statuses" data=["option" => {_T string='order' domain="routes"}, "value" => "GaletteObjectsLend\Repository\Status::ORDERBY_RENTDAYS"|constant]}">
                    {_T string="Days for rent" domain="objectslend"}
                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Status::ORDERBY_RENTDAYS')}
                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\StatusList::ORDER_ASC')}
                    <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                        {else}
                    <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                        {/if}
                    {/if}
                </a>
            </th>
            <th class="actions_row">{_T string="Actions"}</th>
        </tr>
    </thead>
    <tfoot>
        <tr>
            <td colspan="4" class="center">
                {_T string="Pages:"}<br/>
                <ul class="pages">{$pagination}</ul>
            </td>
        </tr>
    </tfoot>
    <tbody>
        {foreach from=$statuses item=sttus}
            <tr class="{if $sttus@index is odd}even{else}odd{/if}">
                <td>
                    {$sttus->status_id}
                </td>
                <td>
                    {$sttus->status_text}
                </td>
                <td align="center">
                    {if $sttus->is_active}
                        <img src="{base_url}/{$template_subdir}images/icon-on.png" alt="{_T string="Active" domain="objectslend"}" width="16" height="16"/>
                    {else}
                        <img src="{base_url}/{$template_subdir}images/icon-off.png" alt="{_T string="Inactive" domain="objectslend"}" width="16" height="16"/>
                    {/if}
                </td>
                <td align="center">
                    {if $sttus->is_home_location}
                        <img src="{base_url}/{$template_subdir}images/icon-on.png" alt="{_T string="In stock" domain="objectslend"}" width="16" height="16"/>
                    {else}
                        <img src="{base_url}/{$template_subdir}images/icon-off.png" alt="{_T string="Not in stock" domain="objectslend"}" width="16" height="16"/>
                    {/if}
                </td>
                <td>
                    {if $sttus->rent_day_number}
                        {_T string="%days days" domain="objectslend" pattern="/%days/" replace=$sttus->rent_day_number}
                    {else}
                        -
                    {/if}
                </td>
                <td class="center nowrap">
                    <a href="{path_for name="objectslend_status" data=["action" => {_T string="edit" domain="routes"}, "id" => $sttus->status_id]}">
                        <img src="{base_url}/{$template_subdir}images/icon-edit.png" alt="{_T string="[mod]"}" width="16" height="16" title="{_T string="Edit %status" domain="objectslend" pattern="/%status/" replace=$sttus->status_text}"/>
                    </a>
                    <a class="delete" href="{path_for name="objectslend_remove_status" data=["id" => $sttus->status_id]}"><img src="{base_url}/{$template_subdir}images/icon-trash.png" alt="{_T string="[del]"}" width="16" height="16" title="{_T string="Remove %status from database" domain="objectslend" pattern="/%status/" replace=$sttus->status_text}"/></a>
                </td>
            </tr>
        {foreachelse}
            <tr><td colspan="6" class="emptylist">{_T string="No status has been found" domain="objectslend"}</td></tr>
        {/foreach}
    </tbody>
</table>
{/block}

{block name="javascripts"}
    <script type="text/javascript">
        $(function(){
            {include file="js_removal.tpl"}
            $('#nbshow').change(function() {
                this.form.submit();
            });
        });
    </script>
{/block}
