{if $saved}
    <div id="infobox">
        <h1>{_T string="OBJECT EDIT.SAVED"}</h1>
    </div>
{/if}
{if $msg_clone}
    <div id="warningbox">
        <h1>{_T string="OBJECT EDIT.WILL BE CLONED"}</h1>
    </div>
{/if}
<a href="objects_list.php">
    <img src="picts/back.png" title="{_T string="OBJECT EDIT.BACK"}"/>
    {_T string="OBJECT EDIT.BACK"}
    <br/>&nbsp;
</a>
<form action="objects_edit.php" method="post" enctype="multipart/form-data">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="OBJECT EDIT.TITLE"}</legend>
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.NAME"}</span>
                    <input type="text" name="name" maxlength="100" size="60" value="{$object->name}" required>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.DESCRIPTION"}</span>
                    <input type="text" name="description" maxlength="500" size="80" value="{$object->description}" required>
                </p>
            </div>
            {if $view_category}
                <div>
                    <p>
                        <span class="bline">{_T string="OBJECT EDIT.CATEGORY"}</span>
                        <select name="category_id" style="width: 300px">
                            <option value="">{_T string="OBJECT EDIT.CHOICE CATEGORY"}</option>
                            {foreach from=$categories item=categ}
                                <option value="{$categ->category_id}"{if $object->category_id eq $categ->category_id} selected="selected"{/if}>
                                    {$categ->name}
                                    ({$categ->objects_nb})
                                </option>
                            {/foreach}
                        </select>
                    </p>
                </div>
            {/if}
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.SERIAL"}</span>
                    <input type="text" name="serial" maxlength="30" size="20" value="{$object->serial_number}">
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.PRICE"}</span>
                    <input type="text" name="price" size="10" style="text-align: right" value="{$object->price}">
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.RENT PRICE"}</span>
                    <input type="text" name="rent_price" size="10" style="text-align: right" value="{$object->rent_price}">
                </p>
            </div>
            <div>
                <p>
                    <label class="bline tooltip_lend" for="price_per_day" title="{_T string="OBJECT EDIT.HELP PRICE PER DAY"}">
                        {_T string="OBJECT EDIT.PRICE PER DAY"}
                        <img src="picts/help.png"/>
                    </label>
                    <input type="checkbox" name="price_per_day" id="price_per_day" value="true"{if $object->price_per_day} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.DIMENSION"}</span>
                    <input type="text" name="dimension" maxlength="100" size="60" value="{$object->dimension}">
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="OBJECT EDIT.WEIGHT"}</span>
                    <input type="text" name="weight" size="10" style="text-align: right" value="{$object->weight}">
                </p>
            </div>
            <div>
                <p>
                    <label class="bline" for="is_active">{_T string="OBJECT EDIT.IS ACTIVE"}</label>
                    <input type="checkbox" id="is_active" name="is_active" value="true"{if $object->is_active} checked="checked"{/if}>
                </p>
            </div>
            {if $show_status}
                <div>
                    <p>
                        <span class="bline">{_T string="OBJECT EDIT.1ST STATUS"}</span>
                        <select name="1st_status">
                            {foreach from=$statuses item=sta}
                                <option value="{$sta->status_id}"{if $sta->is_home_location} selected="selected"{/if}>{$sta->status_text}{if $sta->is_home_location} (@Galette){/if}</option>
                            {/foreach}
                        </select>
                    </p>
                </div>
            {/if}
            <div>
                <p>
                    <span class="bline tooltip_lend" title="{_T string="OBJECT EDIT.HELP UPLOAD PICTURE"}">
                        {_T string="OBJECT EDIT.PICTURE"}
                        <img src="picts/help.png"/>
                    </span>
                    <input type="file" name="picture">
                    {if $object->object_id ne ''}
                        <br/>
                        <input type="checkbox" name="del_picture" id="del_picture" value="1"/><span class="labelalign"><label for="del_picture">{_T string="OBJECT EDIT.DELETE PICTURE"}</label></span><br/>
                        {/if}   
                </p>
            </div>
            {if $object->draw_image}
                <div> 
                    <p>
                        <span class="bline">{_T string="OBJECT EDIT.THUMB"}</span>
                        <img src="{$object->object_image_url}" 
                             class="tooltip_lend" 
                             style="max-width: {$thumb_max_width}px; max-height: {$thumb_max_height}px"
                             title="<img src='{$object->object_image_url}' width='{$pic_width}' height='{$pic_height}'/>"/>
                    </p>
                </div>
            {/if}   
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="lend_save" name="save" value="{_T string="OBJECT EDIT.SAVE"}">
        {if $object->object_id ne ''}
            <input type="submit" id="duplicate" name="duplicate" value="{_T string="OBJECT EDIT.DUPLICATE"}" onclick="return confirmClone({$object->object_id});">
            <input type="submit" id="objects_print" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="OBJECT EDIT.PRINT"}" onclick="window.location = 'objects_print.php?object_id={$object->object_id}';
                    return false;">
        {/if}
        <input type="submit" id="lend_cancel" name="cancel" value="{_T string="OBJECT EDIT.CANCEL"}" onclick="document.location = 'objects_list.php?msg=canceled';
                return false;">
    </div>
</form>

<h3>
    {_T string="OBJECT EDIT.ALL RENTS"}
</h3>
<form action="objects_edit.php" method="post">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <table class="listing">
        <thead>
            <tr>
                <th>{_T string="OBJECT EDIT.DATE BEGIN"}</th>
                <th>{_T string="OBJECT EDIT.DATE FIN"}</th>
                <th>{_T string="OBJECT EDIT.STATUS"}</th>
                <th>{_T string="OBJECT EDIT.AT HOME"}</th>
                <th>{_T string="OBJECT EDIT.ADH"}</th>
                <th>{_T string="OBJECT EDIT.COMMENTS"}</th>
            </tr>
        </thead>
        <tbody>
            {if $object->object_id ne ''}
                <tr>
                    <td style="background-color: #CCFECC " colspan="2">
                        {_T string="OBJECT EDIT.NEW STATUS"}                   
                    </td>
                    <td style="background-color: #CCFECC " colspan="4">
                        <select name="new_status">
                            {foreach from=$statuses item=sta}
                                <option value="{$sta->status_id}"{if $sta->is_home_location} selected="selected"{/if}>{$sta->status_text}{if $sta->is_home_location} (@Galette){/if}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr>
                    <td style="background-color: #CCFECC " colspan="2">
                        {_T string="OBJECT EDIT.NEW COMMENT"}
                    </td>
                    <td style="background-color: #CCFECC " colspan="4">
                        <input type="text" name="new_comment" maxlength="200" size="60">
                    </td>
                </tr>
                <tr>
                    <td style="background-color: #CCFECC " colspan="2">
                        {_T string="OBJECT EDIT.NEW ADH"}
                    </td>
                    <td style="background-color: #CCFECC " colspan="4">
                        <select name="new_adh">
                            <option value="null">{_T string="OBJECT EDIT.NO ADH"}</option>
                            {foreach from=$adherents item=adh}
                                <option value="{$adh->id}">{$adh->name} {$adh->surname}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
            {/if}
            {foreach from=$rents item=rt name=rent}
                <tr>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->date_begin}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->date_end}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->status_text}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}" align="center">{if $rt->is_home_location}<img src="picts/check.png"/>{/if}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{if $rt->nom_adh ne ''}<a href="mailto:{$rt->email_adh}">{$rt->nom_adh} {$rt->prenom_adh}</a>{/if}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->comments}</td>                
                </tr>
            {/foreach}
        </tbody>
    </table>
    <p>
    </p>
    <div class="button-container">
        <input type="submit" id="status_create" name="status" value="{_T string="OBJECT EDIT.CHANGE STATUS"}">
    </div>
</form>
<script>
    function confirmClone(object_id) {
        if (confirm('{_T string="OBJECT EDIT.CONFIRM DUPLICATE"}')) {
            window.location = 'objects_edit.php?clone_object_id=' + object_id;
        }
        return false;
    }
</script>