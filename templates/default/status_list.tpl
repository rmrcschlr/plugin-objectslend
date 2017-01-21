{if $msg_saved}
    <div id="infobox">
        <h1>{_T string="STATUS LIST.SAVED"}</h1>
    </div>
{/if}
{if $msg_canceled}
    <div id="warningbox">
        <h1>{_T string="STATUS LIST.CANCELED"}</h1>
    </div>
{/if}
{if $msg_deleted}
    <div id="errorbox">
        <h1>{_T string="STATUS LIST.DELETED"}</h1>
    </div>
{/if}
{if $msg_galette_location_needed}
    <div id="errorbox">
        <h1>{_T string="STATUS LIST.GALETTE LOCATION NEEDED"}</h1>
    </div>
{/if}
{if $msg_away_needed}
    <div id="errorbox">
        <h1>{_T string="STATUS LIST.AWAY NEEDED"}</h1>
    </div>
{/if}
<p>
    {$nb_status} {_T string="STATUS LIST.NB RESULT"}
</p>
<table class="listing">
    <thead>
        <tr>
            <th>
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
                    {_T string="STATUS LIST.TEXT"}
                </a>
                {if $tri eq 'status_text' && $direction eq 'asc'} 
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'status_text' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th>
                <a href="?tri=is_home_location&direction={if $tri eq 'is_home_location' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="STATUS LIST.IS GALETTE LOCATION"}
                </a>
                {if $tri eq 'is_home_location' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'is_home_location' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th>
                <a href="?tri=is_active&direction={if $tri eq 'is_active' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="STATUS LIST.IS ACTIVE"}
                </a>
                {if $tri eq 'is_active' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'is_active' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th>
                <a href="?tri=rent_day_number&direction={if $tri eq 'rent_day_number' && $direction eq 'asc'}desc{else}asc{/if}">
                    {_T string="STATUS LIST.RENT DAY NUMBER"}
                </a>
                {if $tri eq 'rent_day_number' && $direction eq 'asc'}
                    <img src="{$template_subdir}images/down.png"/>
                {elseif $tri eq 'rent_day_number' && $direction eq 'desc'}
                    <img src="{$template_subdir}images/up.png"/>
                {/if}
            </th>
            <th>
                {_T string="STATUS LIST.EDIT SHORT"}
            </th>
            <th>
                {_T string="STATUS LIST.DELETE SHORT"}
            </th>
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
                    {if $sttus->is_home_location}
                        <img src="picts/check.png"/>
                    {/if}
                </td>
                <td align="center">
                    {if $sttus->is_active}
                        <img src="picts/check.png"/>
                    {/if}
                </td>
                <td>
                    {$sttus->rent_day_number}
                </td>
                <td align="center">
                    <a href="status_edit.php?status_id={$sttus->status_id}">
                        <img src="picts/edit.png" title="{_T string="STATUS LIST.EDIT"}" border="0"/>
                    </a>
                </td>
                <td align="center">
                    <a href="javascript:void(0)">
                        <img src="picts/delete.png" title="{_T string="STATUS LIST.DELETE"}" border="0" onClick="confirmDelete('{$sttus->status_text}', '{$sttus->status_id}')"/>
                    </a>
                </td>
            </tr>
        {/foreach}
    </tbody>
</table>
<p>
    &nbsp;
</p>
<form action="status_edit.php?status_id=new" method="get">
    <div class="button-container">
        <input type="submit" id="status_create" value="{_T string="STATUS LIST.CREATE"}">
    </div>
</form>
<script>
    function confirmDelete(nom, status_id) {
        var msg = $('<div/>').html('{_T string="STATUS LIST.CONFIRM DELETE"}').text();
        if (confirm(msg + nom + ' ?')) {
            window.location = 'status_delete.php?status_id=' + status_id;
        }
        return false;
    }
</script>
