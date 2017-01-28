<p>
    {$nb_categories} {if $nb_categories > 1}{_T string="categories"}{else}{_T string="category"}{/if}
</p>
<table class="listing">
    <thead>
        <tr>
            <th class="id_row">
                <a href="?tri=category_id&direction={if $tri eq 'category_id' && $direction eq 'asc'}desc{else}asc{/if}">
                    #
                </a>
                {if $tri eq 'category_id' && $direction eq 'asc'} 
                    <img src="{$template_subdir}images/down.png">
                {elseif $tri eq 'category_id' && $direction eq 'desc'} 
                    <img src="{$template_subdir}images/up.png">
                {/if}
            </th>
            <th>
                <a href="?tri=name&direction={if $tri eq 'name' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="Category"}
                </a>
                {if $tri eq 'name' && $direction eq 'asc'} 
                    <img src="{$template_subdir}images/down.png">
                {elseif $tri eq 'name' && $direction eq 'desc'} 
                    <img src="{$template_subdir}images/up.png">
                {/if}
            </th>
            <th class="id_row">
                <a href="?tri=is_active&direction={if $tri eq 'is_active' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="Active"}
                </a>
                {if $tri eq 'is_active' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png">
                {elseif $tri eq 'is_active' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png">
                {/if}
            </th>
            <th class="actions_row">
                {_T string="Actions"}
            </th>
        </tr>
    </thead>
    <tbody>
        {foreach from=$categories item=categ}
            <tr class="{if $categ@index is odd}even{else}odd{/if}">
                <td>
                    {$categ->category_id}
                </td>
                <td>
                    {if $categ->categ_image_url ne ''}
                        <img src="{$categ->categ_image_url}" {if $lendsprefs.VIEW_CATEGORY_THUMB}style="max-width: {$lendsprefs.THUMB_MAX_WIDTH}px; max-height: {$lendsprefs.THUMB_MAX_HEIGHT}px;"{/if}/>
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
                        <img src="{$template_subdir}images/icon-edit.png" alt="{_T string="[mod]"}" width="16" height="16" title="{_T string="Edit %category" pattern="/%category/" replace=$categ->name}"/>
                    </a>
                    <a onclick="return confirm('{_T string="Do you really want to delete this category from the base?" escape="js"}')" href="category_delete.php?category_id={$categ->category_id}"><img src="{$template_subdir}images/icon-trash.png" alt="{_T string="[del]"}" width="16" height="16" title="{_T string="Remove %category from database" pattern="/%category/" replace=$categ->name}"/></a>
                </td>
            </tr>
        {/foreach}
    </tbody>
</table>
