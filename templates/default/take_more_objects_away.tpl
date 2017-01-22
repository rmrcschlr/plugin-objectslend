<form action="take_more_objects_away.php" method="post" id="form_take_more_objects_away">
    {if $ajax}
        <input type="hidden" name="mode" value="ajax"/>
        <input type="hidden" name="safe_objects_ids" value="{$safe_objects_ids}"/>
        <img src="picts/close.png" title="{_T string="AJAX.CLOSE"}" alt="{_T string="AJAX.CLOSE"}" id="button_close"/>
    {/if}
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="TAKE OBJECTS.TITLE"}</legend>
            <table class="listing">
                <thead>
                    <tr>
                        {if $lendsprefs.VIEW_THUMBNAIL}
                            <th>
                                {_T string="TAKE OBJECTS.THUMB"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_NAME || $lendsprefs.VIEW_DESCRIPTION}
                            <th>
                                {if $lendsprefs.VIEW_NAME}
                                    {_T string="TAKE OBJECTS.NAME"}
                                {/if}
                                {if $lendsprefs.VIEW_NAME && $lendsprefs.VIEW_DESCRIPTION}
                                    /
                                {/if}
                                {if $lendsprefs.VIEW_DESCRIPTION}
                                    {_T string="TAKE OBJECTS.DESCRIPTION"}
                                {/if}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_SERIAL}
                            <th>
                                {_T string="TAKE OBJECTS.SERIAL"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <th>
                                {_T string="TAKE OBJECTS.PRICE"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <th>
                                {_T string="TAKE OBJECTS.RENT PRICE"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <th>
                                {_T string="TAKE OBJECTS.DIMENSION"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <th>
                                {_T string="TAKE OBJECTS.WEIGHT"}
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
                                {if $lendsprefs.VIEW_DIMENSION}
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
                                <input type="text" name="rent_price_{$objt->object_id}" value="{$objt->rent_price}" size="10" style="text-align: right">
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
                    <span class="bline">{_T string="TAKE OBJECTS.MEMBERS"}</span>
                    <select name="id_adh" id="id_adh" onchange="validStatus()" style="width: 350px">
                        <option value="null">{_T string="TAKE OBJECTS.SELECT MEMBER"}</option>
                        {foreach from=$members item=mmbr}
                            <option value="{$mmbr->id_adh}"{if $login->id eq $mmbr->id_adh} selected="selected"{/if}>{$mmbr->nom_adh} {$mmbr->prenom_adh} ({$mmbr->pseudo_adh})</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECTS.STATUS"}</span>
                    <select name="status" id="status" onchange="validStatus()" style="width: 350px">
                        <option value="null">{_T string="TAKE OBJECTS.SELECT STATUS"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            {if $lendsprefs.AUTO_GENERATE_CONTRIBUTION}
                <div>
                    <p>
                        <span class="bline">{_T string="TAKE OBJECTS.PAYMENT TYPE"}</span>
                        <select name="payment_type" id="payment_type" onchange="validStatus()" style="width: 350px">
                            <option value="null">{_T string="TAKE OBJECTS.SELECT PAYMENT TYPE"}</option>
                            <option value="{php}echo Galette\Entity\Contribution::PAYMENT_CASH;{/php}">{_T string="Cash"}</option>
                            <option value="{php}echo Galette\Entity\Contribution::PAYMENT_CREDITCARD;{/php}">{_T string="Credit card"}</option>
                            <option value="{php}echo Galette\Entity\Contribution::PAYMENT_CHECK;{/php}">{_T string="Check"}</option>
                            <option value="{php}echo Galette\Entity\Contribution::PAYMENT_TRANSFER;{/php}">{_T string="Transfer"}</option>
                            <option value="{php}echo Galette\Entity\Contribution::PAYMENT_PAYPAL;{/php}">{_T string="Paypal"}</option>
                            <option value="{php}echo Galette\Entity\Contribution::PAYMENT_OTHER;{/php}">{_T string="Other"}</option>
                        </select>
                    </p>
                </div>
            {/if}
        </fieldset>
    </div>
    <div class="button-container" id="button_container">
        <input type="submit" id="lend_yes" name="yes" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="TAKE OBJECTS.YES"}" style="visibility: hidden;">
        <input type="submit" id="lend_cancel" name="cancel" class="ui-button ui-widget ui-state-default ui-corner-all" value="{_T string="TAKE OBJECTS.NO"}" {*onclick="document.location = 'objects_list.php?msg=not_taken'; return false;"*}>
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
    $('#lend_yes').click(ajax_take_more_objects_away);
    {else}
    $('#lend_cancel').click(function () {
        document.location = 'objects_list.php?msg=not_taken';
        return false;
    });
    {/if}

    function validStatus() {
        var visibility = 'visible';
        if ($('#status').val() === 'null') {
            visibility = 'hidden';
        }
        if ($('#id_adh').val() === 'null') {
            visibility = 'hidden';
        }
        if ($('#payment_type').val() === 'null') {
            visibility = 'hidden';
        }
        $('#lend_yes').css({ldelim}"visibility": visibility{rdelim});
            }
</script>
