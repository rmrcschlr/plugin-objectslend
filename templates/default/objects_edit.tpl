{extends file="page.tpl"}
{block name="content"}
<form action="{path_for name="objectslend_object_action" data=["action" => $action, "id" => $object->object_id]}" method="post" enctype="multipart/form-data">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="Object" domain="objectslend"}</legend>
            <div>
                <p>
                    <label for="name" class="bline">{_T string="Name:" domain="objectslend"}</label>
                    <input type="text" name="name" id="name" maxlength="100" size="60" value="{$object->name}" required="required">
                </p>
            </div>
            <div>
                <p>
                    <label for="description" class="bline">{_T string="Description:" domain="objectslend"}</label>
                    <input type="text" name="description" id="description" maxlength="500" size="80" value="{$object->description}" required>
                </p>
            </div>
            {if $lendsprefs.VIEW_CATEGORY}
                <div>
                    <p>
                        <label for="category_id" class="bline">{_T string="Category:" domain="objectslend"}</label>
                        <select name="category_id" id="category_id">
                            <option value="">{_T string="--- Select a category ---" domain="objectslend"}</option>
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
                    <label for="serial" class="bline">{_T string="Serial number:" domain="objectslend"}</label>
                    <input type="text" name="serial" id="serial" maxlength="30" size="20" value="{$object->serial_number}">
                </p>
            </div>
            <div>
                <p>
                    <label for="price" class="bline">{_T string="Price:" domain="objectslend"}</label>
                    <input type="text" name="price" id="price" size="10" style="text-align: right" value="{$object->price}">
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="Borrow price (%currency):" domain="objectslend" pattern="/%currency/" replace=$object->getCurrency()}</span>
                    <input type="text" name="rent_price" size="10" style="text-align: right" value="{$object->rent_price}">
                </p>
            </div>
            <div>
                <p>
                    <label class="bline tooltip" for="price_per_day" title="{_T string="- Checked = the price applies to each rental day <br/> - Unchecked = the price applies once" domain="objectslend"}">
                        {_T string="Price per rental day:" domain="objectslend"}
                    </label>
                    <span class="tip">{_T string="- Checked = the price applies to each rental day <br/> - Unchecked = the price applies once" domain="objectslend"}</span>
                    <input type="checkbox" name="price_per_day" id="price_per_day" value="true"{if $object->price_per_day} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <label for="dimension" class="bline">{_T string="Dimensions (cm):" domain="objectslend"}</label>
                    <input type="text" name="dimension" id="dimension" maxlength="100" size="60" value="{$object->dimension}">
                </p>
            </div>
            <div>
                <p>
                    <label for="weight" class="bline">{_T string="Weight (kg):" domain="objectslend"}</label>
                    <input type="text" name="weight" id="weight" size="10" style="text-align: right" value="{$object->weight}">
                </p>
            </div>
            <div>
                <p>
                    <label class="bline" for="is_active">{_T string="Active:" domain="objectslend"}</label>
                    <input type="checkbox" id="is_active" name="is_active" value="true"{if $object->is_active} checked="checked"{/if}>
                </p>
            </div>
            {if $show_status}
                <div>
                    <p>
                        <label for="1st_status" class="bline">{_T string="Where is the object?" domain="objectslend"}</label>
                        <select name="1st_status" id="1st_status">
                            {foreach from=$statuses item=sta}
                                <option value="{$sta->status_id}"{if $sta->is_home_location} selected="selected"{/if}>{$sta->status_text}{if $sta->is_home_location} (@Galette){/if}</option>
                            {/foreach}
                        </select>
                    </p>
                </div>
            {/if}
        </fieldset>
        <fieldset>
            <legend class="ui-state-active ui-corner-top">{_T string="Object's photo" domain="objectslend"}</legend>
                <p>
                    <div class="exemple">{_T string="The file must be smaller than 2 Mb and its name should not contains whitespace!"}</div>
                    <img src="{if $object->object_id}{path_for name="objectslend_photo" data=["type" => {_T string="object" domain="objectslend_routes"}, "mode" => {_T string="thumbnail" domain="objectslend_routes"}, "id" => $object->object_id]}{else}{path_for name="objectslend_photo" data=["type" => {_T string="object" domain="objectslend_routes"}, "mode" => {_T string="thumbnail" domain="objectslend_routes"}]}{/if}?rand={$time}"
                        class="picture"
                        width="{$object->picture->getOptimalThumbWidth($olendsprefs)}"
                        height="{$object->picture->getOptimalThumbHeight($olendsprefs)}"
                        alt="{_T string="Object photo" domain="objectslend"}"/><br/>
                    <input type="checkbox" name="del_picture" id="del_picture" value="1"/><span class="labelalign"><label for="del_picture">{_T string="Delete image" domain="objectslend"}</label></span><br/>
                    <input type="file" name="picture" id="object_picture">
                </p>
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="btnsave" name="save" value="{_T string="Save"}">
        {if $object->object_id ne ''}
            <a href="objects_edit.php?clone_object_id={$object->object_id}" class="button" id="btnduplicate">
                {_T string="Duplicate" domain="objectslend"}
            </a>
            <a href="objects_print.php?object_id={$object->object_id}" id="btnlabels" class="button">{_T string="Print card"}</a>
        {/if}
        <p>
            <a href="objects_list.php" class="button" id="btnback">
                {_T string="Back to list"}
            </a>
        </p>
    </div>
</form>
{if $object->object_id}
<h3>
    {_T string="History of object loans" domain="objectslend"}
</h3>
<form action="objects_edit.php" method="post">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <table class="listing">
        <thead>
            <tr>
                <th>{_T string="Begin date" domain="objectslend"}</th>
                <th>{_T string="End date" domain="objectslend"}</th>
                <th>{_T string="Status" domain="objectslend"}</th>
                <th>{_T string="At home" domain="objectslend"}</th>
                <th>{_T string="Member" domain="objectslend"}</th>
                <th>{_T string="Comments" domain="objectslend"}</th>
            </tr>
        </thead>
            {if $object->object_id ne ''}
        <tfoot>
                <tr>
                    <th colspan="6" class="center">{_T string="Change status" domain="objectslend"}</th>
                </tr>
                <tr>
                    <th colspan="2">
                        {_T string="Status:" domain="objectslend"}
                    </th>
                    <td colspan="4">
                        <select name="new_status">
                            {foreach from=$statuses item=sta}
                                <option value="{$sta->status_id}"{if $sta->is_home_location} selected="selected"{/if}>{$sta->status_text}{if $sta->is_home_location} (@Galette){/if}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr>
                    <th colspan="2">
                        {_T string="Comment:" domain="objectslend"}
                    </th>
                    <td colspan="4">
                        <input type="text" name="new_comment" maxlength="200" size="60">
                    </td>
                </tr>
                <tr>
                    <th colspan="2">
                        {_T string="Member:" domain="objectslend"}
                    </th>
                    <td colspan="4">
                        <select name="new_adh">
                            <option value="null">{_T string="No member" domain="objectslend"}</option>
                            {foreach from=$adherents item=adh}
                                <option value="{$adh->id}">{$adh->name} {$adh->surname}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
                <tr>
                    <td colspan="6" class="center">
                        <input type="submit" id="status_create" name="status" value="{_T string="Change status" domain="objectslend"}">
                    </td>
                </tr>
        </tfoot>
            {/if}
        <tbody>
            {foreach from=$rents item=rt name=rent}
                <tr>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->date_begin}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->date_end}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->status_text}</td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if} center">
                        {if $rt->is_home_location}
                            <img src="{$template_subdir}images/icon-on.png" alt="{_T string="At home" domain="objectslend"}"/>
                        {/if}
                    </td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">
                        {if $rt->nom_adh ne ''}
                            {if $rt->email_adh ne ''}
                                <a href="mailto:{$rt->email_adh}">{$rt->nom_adh} {$rt->prenom_adh}</a>
                            {else}
                                {$rt->nom_adh} {$rt->prenom_adh}
                            {/if}
                        {else}
                            -
                        {/if}
                    </td>
                    <td class="tbl_line_{if $smarty.foreach.rent.index is odd}even{else}odd{/if}">{$rt->comments}</td>
                </tr>
            {/foreach}
        </tbody>
    </table>
</form>
{/if}
{/block}
