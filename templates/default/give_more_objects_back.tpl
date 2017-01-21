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
                        {if $view_thumbnail}
                            <th>
                                {_T string="BACK OBJECTS.THUMB"}
                            </th>
                        {/if}
                        {if $view_name || $view_description}
                            <th>
                                {if $view_name}
                                    {_T string="BACK OBJECTS.NAME"}
                                {/if}
                                {if $view_name && $view_description}
                                    /
                                {/if}
                                {if $view_description}
                                    {_T string="BACK OBJECTS.DESCRIPTION"}
                                {/if}
                            </th>
                        {/if}
                        {if $view_serial}
                            <th>
                                {_T string="BACK OBJECTS.SERIAL"}
                            </th>
                        {/if}
                        {if $view_price}
                            <th>
                                {_T string="BACK OBJECTS.PRICE"}
                            </th>
                        {/if}
                        {if $view_lend_price}
                            <th>
                                {_T string="BACK OBJECTS.RENT PRICE"}
                            </th>
                        {/if}
                        {if $view_dimension}
                            <th>
                                {_T string="BACK OBJECTS.DIMENSION"}
                            </th>
                        {/if}
                        {if $view_weight}
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
                        {if $view_thumbnail}
                            <td align="center">
                                {if $objt->object_image_url ne ""}
                                    <img src="{$objt->object_image_url}" {if $view_object_thumb}style="max-height: {$thumb_max_height}px; max-width: {$thumb_max_width}px;"{/if}/>
                                {/if}
                            </td>
                        {/if}
                        {if $view_name || $view_description}
                            <td>
                                {if $view_name}
                                    <b>{$objt->search_name}</b>
                                {/if}
                                {if $view_name || $view_description}
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
                                {$objt->price}
                            </td>
                        {/if}
                        {if $view_lend_price}
                            <td align="right">
                                {$objt->rent_price}
                            </td>
                        {/if}
                        {if $view_dimension}
                            <td>
                                {$objt->search_dimension}
                            </td>
                        {/if}
                        {if $view_weight}
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
