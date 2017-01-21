<form action="give_object_back.php" method="post" id="form_give_object_back">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    {if $ajax}
        <input type="hidden" name="mode" value="ajax"/>
        <img src="picts/close.png" title="{_T string="AJAX.CLOSE"}" alt="{_T string="AJAX.CLOSE"}" id="button_close"/>
    {/if}
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="GIVE OBJECT BACK.TITLE"}</legend>
            <div>
                <p>
                    {if $object->draw_image}
                        <img src="{$object->object_image_url}" 
                             class="picture tooltip_lend" 
                             align="right" 
                             title="{$object->tooltip_title}" 
                             {if $view_object_thumb}style="max-height: {$thumb_max_height}px; max-width: {$thumb_max_width}px;"{/if}/>
                    {/if}
                    <span class="bline">{_T string="GIVE OBJECT BACK.NAME"}</span>
                    {$object->name}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.DESCRIPTION"}</span>
                    {$object->description}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.SERIAL"}</span>
                    {$object->serial_number}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.PRICE"}</span>
                    {$object->price}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.DIMENSION"}</span>
                    {$object->dimension}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.WEIGHT"}</span>
                    {$object->weight}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.STATUS"}</span>
                    <select name="status" id="status">
                        <option value="null">{_T string="GIVE OBJECT BACK.SELECT STATUS"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.TIME"}</span>
                    {_T string="GIVE OBJECT BACK.FROM"}
                    {$last_rent->date_begin_short}
                    {_T string="GIVE OBJECT BACK.TO"}
                    {$today}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.COMMENTS"}</span>
                    <textarea name="comments" id="comments" style="font-family: Cantarell,Verdana,sans-serif; font-size: 0.85em; width: 400px; height: 60px;"></textarea>
                    <br/><span id="remaining">200</span>
                    {_T string="GIVE OBJECT BACK.REMAINING"}
                </p>
            </div>
        </fieldset>
    </div>
    <div class="button-container" id="button_container">
        <input type="submit" id="lend_yes" name="yes" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="GIVE OBJECT BACK.YES"}" style="visibility: hidden;">
        <input type="submit" id="lend_cancel" name="cancel" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="GIVE OBJECT BACK.NO"}">
    </div>
</form>
<script>
    {if $ajax}
    $('#button_close').click(function() {
        close_ajax();
        return false;
    });
    $('#lend_cancel').click(function() {
        close_ajax();
        return false;
    });
    $('#lend_yes').click(ajax_give_object_back);
    {else}
    $('#lend_cancel').click(function() {
        document.location = 'objects_list.php?msg=not_given';
        return false;
    });
    {/if}

    $('#status').change(function() {
        if ($('#status').val() === 'null') {
            $('#lend_yes').css({ldelim}"visibility": "hidden"{rdelim});
        } else {
            $('#lend_yes').css({ldelim}"visibility": "visible"{rdelim});
        }
    });

    $('#comments').keyup(function() {
        if ($('#comments').val().length > 200) {
            $('#comments').val($('#comments').val().substr(0, 200));
        }
        $('#remaining').text(200 - $('#comments').val().length);
    });
</script>
