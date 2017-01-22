<form action="give_more_objects_back.php" method="post" id="form_give_more_objects_back">
    {if $ajax}
        <input type="hidden" name="mode" value="ajax"/>
        <input type="hidden" name="safe_objects_ids" value="{$safe_objects_ids}"/>
        <img src="picts/close.png" title="{_T string="AJAX.CLOSE"}" alt="{_T string="AJAX.CLOSE"}" id="button_close"/>
    {/if}
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="BACK OBJECTS.TITLE"}</legend>
            <table class="listing">
                <thead>
                    <tr>
                        {if $lendsprefs.VIEW_THUMBNAIL}
                            <th>
                                {_T string="BACK OBJECTS.THUMB"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_NAME || $lendsprefs.VIEW_DESCRIPTION}
                            <th>
                                {if $lendsprefs.VIEW_NAME}
                                    {_T string="BACK OBJECTS.NAME"}
                                {/if}
                                {if $lendsprefs.VIEW_NAME && $lendsprefs.VIEW_DESCRIPTION}
                                    /
                                {/if}
                                {if $lendsprefs.VIEW_DESCRIPTION}
                                    {_T string="BACK OBJECTS.DESCRIPTION"}
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_SERIAL}
                            <th>
                                {_T string="BACK OBJECTS.SERIAL"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <th>
                                {_T string="BACK OBJECTS.PRICE"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <th>
                                {_T string="BACK OBJECTS.RENT PRICE"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <th>
                                {_T string="BACK OBJECTS.DIMENSION"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <th>
                                {_T string="BACK OBJECTS.WEIGHT"}
                            </th>
                        {/if}
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$objects item=objt}
                    <input type="hidden" name="objects_id[]" value="{$objt->object_id}">
                    <tr class="{if $objt@index is odd}even{else}odd{/if}">
                        {if $lendsprefs.VIEW_THUMBNAIL}
                            <td align="center">
                                {if $objt->object_image_url ne ""}
                                    <img src="{$objt->object_image_url}" {if $lendsprefs.VIEW_OBJECT_THUMB}style="max-height: {$lendsprefs.THUMB_MAX_HEIGHT}px; max-width: {$lendsprefs.THUMB_MAX_WIDTH}px;"{/if}/>
                                {/if}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_NAME || $lendsprefs.VIEW_DESCRIPTION}
                            <td>
                                {if $lendsprefs.VIEW_NAME}
                                    <b>{$objt->search_name}</b>
                                {/if}
                                {if $lendsprefs.VIEW_NAME && $lendsprefs.VIEW_DESCRIPTION}
                                    <br/>
                                {/if}
                                {if $lendsprefs.VIEW_DESCRIPTION}
                                    {$objt->search_description}
                                {/if}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_SERIAL}
                            <td>
                                {$objt->search_serial_number}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <td align="right">
                                {$objt->price}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <td align="right">
                                {$objt->rent_price}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <td>
                                {$objt->search_dimension}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <td align="right">
                                {$objt->weight}
                            </td>
                        {/if}
                    </tr>
                {/foreach}
                </tbody>
            </table>
            <div>
                <p>
                    <span class="bline">{_T string="BACK OBJECTS.STATUS"}</span>
                    <select name="status" id="status" onchange="validStatus()">
                        <option value="null">{_T string="BACK OBJECTS.SELECT STATUS"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="BACK OBJECTS.COMMENTS"}</span>
                    <textarea name="comments" id="comments" onkeyup="countRemainting()" style="font-family: Cantarell,Verdana,sans-serif; font-size: 0.85em; width: 400px; height: 60px;"></textarea>
                    <br/><span id="remaining">200</span>
                    {_T string="BACK OBJECTS.REMAINING"}
                </p>
            </div>
        </fieldset>
    </div>
    <div class="button-container" id="button_container">
        <input type="submit" id="lend_yes" name="yes" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="BACK OBJECTS.YES"}" style="visibility: hidden;">
        <input type="submit" id="lend_cancel" name="cancel" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="BACK OBJECTS.NO"}" {*onclick="document.location = 'objects_list.php?msg=not_given'; return false;"*}>
    </div>
</form>

<script>
    {if $ajax}
    $('#button_close').click(function () {
        close_ajax();
        return false;
    });
    $('#lend_cancel').click(function () {
        close_ajax();
        return false;
    });
    $('#lend_yes').click(ajax_give_more_objects_back);
    {else}
    $('#lend_cancel').click(function () {
        document.location = 'objects_list.php?msg=not_given';
        return false;
    });
    {/if}

    $('#status').change(function () {
        if ($('#status').val() === 'null') {
            $('#lend_yes').css({ldelim}"visibility": "hidden"{rdelim});
                    } else {
                        $('#lend_yes').css({ldelim}"visibility": "visible"{rdelim});
                                }
                            });

                            $('#comments').keyup(function () {
                                if ($('#comments').val().length > 200) {
                                    $('#comments').val($('#comments').val().substr(0, 200));
                                }
                                $('#remaining').text(200 - $('#comments').val().length);
                            });
</script>
