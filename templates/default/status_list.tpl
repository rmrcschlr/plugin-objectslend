<table class="infoline">
    <tr>
        <td class="left">{$nb_status} {_T string="status" domain="objectslend"}</td>
    </tr>
</table>
<table class="listing">
    <thead>
        <tr>
            <th class="id_row">
                <a href="?tri=status_id&direction={if $tri eq 'status_id' && $direction eq 'asc'}desc{else}asc{/if}">
                    #
                </a>
                {if $tri eq 'status_id' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'status_id' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th>
                <a href="?tri=status_text&direction={if $tri eq 'status_text' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="Status" domain="objectslend"}
                </a>
                {if $tri eq 'status_text' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'status_text' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th class="id_row">
                <a href="?tri=is_active&direction={if $tri eq 'is_active' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="Active" domain="objectslend"}
                </a>
                {if $tri eq 'is_active' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'is_active' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th class="id_row">
                <a href="?tri=is_home_location&direction={if $tri eq 'is_home_location' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="Stock" domain="objectslend"}
                </a>
                {if $tri eq 'is_home_location' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'is_home_location' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>

            <th class="id_row">
                <a href="?tri=rent_day_number&direction={if $tri eq 'rent_day_number' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="Days for rent" domain="objectslend"}
                </a>
                {if $tri eq 'rent_day_number' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'rent_day_number' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th class="actions_row">{_T string="Actions"}</th>
        </tr>
    </thead>
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
                        <img src="{$template_subdir}images/icon-on.png" alt="{_T string="Active" domain="objectslend"}" width="16" height="16"/>
                    {else}
                        <img src="{$template_subdir}images/icon-off.png" alt="{_T string="Inactive" domain="objectslend"}" width="16" height="16"/>
                    {/if}
                </td>
                <td align="center">
                    {if $sttus->is_home_location}
                        <img src="{$template_subdir}images/icon-on.png" alt="{_T string="In stock domain="objectslend""}" width="16" height="16"/>
                    {else}
                        <img src="{$template_subdir}images/icon-off.png" alt="{_T string="Not in stock" domain="objectslend"}" width="16" height="16"/>
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
                    <a href="status_edit.php?status_id={$sttus->status_id}">
                        <img src="{$template_subdir}images/icon-edit.png" alt="{_T string="[mod]"}" width="16" height="16" title="{_T string="Edit %status" domain="objectslend" pattern="/%status/" replace=$sttus->status_text}"/>
                    </a>
                    <a onclick="return confirm('{_T string="Do you really want to delete this status from the base?" domain="objectslend" escape="js"}')" href="status_delete.php?status_id={$sttus->status_id}"><img src="{$template_subdir}images/icon-trash.png" alt="{_T string="[del]"}" width="16" height="16" title="{_T string="Remove %status from database" domain="objectslend" pattern="/%status/" replace=$sttus->status_text}"/></a>
                </td>
            </tr>
        {/foreach}
    </tbody>
</table>
