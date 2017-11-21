    <form id="filtre" method="get" action="categories_list.php">
        <div id="listfilter">
            <label for="filter_str">{_T string="Search:"}&nbsp;</label>
            <input type="text" name="filter_str" id="filter_str" value="{$filters->filter_str}" type="search" placeholder="{_T string="Enter a value"}"/>&nbsp;
            {if $login->isAdmin() or $login->isStaff()}
                {_T string="Active:" domain="objectslend"}
                <input type="radio" name="active_filter" id="filter_dc_active" value="{php}echo GaletteObjectsLend\Repository\Categories::ALL_CATEGORIES;{/php}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Categories::ALL_CATEGORIES')} checked="checked"{/if}>
                <label for="filter_dc_active" >{_T string="Don't care"}</label>
                <input type="radio" name="active_filter" id="filter_yes_active" value="{php}echo GaletteObjectsLend\Repository\Categories::ACTIVE_CATEGORIES;{/php}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Categories::ACTIVE_CATEGORIES')} checked="checked"{/if}>
                <label for="filter_yes_active" >{_T string="Yes"}</label>
                <input type="radio" name="active_filter" id="filter_no_active" value="{php}echo GaletteObjectsLend\Repository\Categories::INACTIVE_CATEGORIES;{/php}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Categories::INACTIVE_CATEGORIES')} checked="checked"{/if}>
                <label for="filter_no_active" >{_T string="No"}</label>
            {/if}
            <input type="submit" class="inline" value="{_T string="Filter"}"/>
            <input name="clear_filter" type="submit" value="{_T string="Clear filter"}">
        </div>
    </form>

    <form action="categories_list.php" method="get">
        <table class="infoline">
            <tr>
                <td class="left">{$nb_categories} {if $nb_categories gt 1}{_T string="categories" domain="objectslend"}{else}{_T string="category" domain="objectslend"}{/if}</td>
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

<table class="listing">
    <thead>
        <tr>
            <th class="id_row">&nbsp;</th>
            <th>
                <a href="{$galette_base_path}{$lend_dir}categories_list.php?tri={php}echo GaletteObjectsLend\Repository\Categories::ORDERBY_NAME;{/php}">
                    {_T string="Name" domain="objectslend"}
                    {if $filters->orderby eq constant('GaletteObjectsLend\Repository\Categories::ORDERBY_NAME')}
                        {if $filters->ordered eq constant('GaletteObjectsLend\Filters\CategoriesList::ORDER_ASC')}
                    <img src="{$template_subdir}images/down.png" width="10" height="6" alt=""/>
                        {else}
                    <img src="{$template_subdir}images/up.png" width="10" height="6" alt=""/>
                        {/if}
                    {/if}
                </a>
            </th>
            <th class="id_row">
                {_T string="Active" domain="objectslend"}
            </th>
            <th class="actions_row">
                {_T string="Actions"}
            </th>
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
        {foreach from=$categories item=categ}
            <tr class="{if $categ@index is odd}even{else}odd{/if}">
                <td>
                    {$categ->category_id}
                </td>
                <td>
    {if $olendsprefs->imagesInLists()}
                    <img src="picture.php?category_id={$categ->category_id}&amp;rand={$time}&thumb=1"
                        class="picture"
                        width="{$categ->picture->getOptimalThumbWidth()}"
                        height="{$categ->picture->getOptimalThumbHeight()}"
                        alt=""/>
    {/if}
                    {$categ->name}
                </td>
                <td align="center">
                    {if $categ->is_active}
                        <img src="{$template_subdir}images/icon-on.png" alt="{_T string="Active"}" width="16" height="16"/>
                    {/if}
                </td>
                <td class="center nowrap">
                    <a href="category_edit.php?category_id={$categ->category_id}">
                        <img src="{$template_subdir}images/icon-edit.png" alt="{_T string="[mod]"}" width="16" height="16" title="{_T string="Edit %category" pattern="/%category/" domain="objectslend" replace=$categ->name}"/>
                    </a>
                    <a onclick="return confirm('{_T string="Do you really want to delete this category from the base?" domain="objectslend" escape="js"}')" href="category_delete.php?category_id={$categ->category_id}"><img src="{$template_subdir}images/icon-trash.png" alt="{_T string="[del]"}" width="16" height="16" title="{_T string="Remove %category from database" domain="objectslend" pattern="/%category/" replace=$categ->name}"/></a>
                </td>
            </tr>
        {/foreach}
    </tbody>
</table>
