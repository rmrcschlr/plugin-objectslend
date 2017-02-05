<form action="take_more_objects_away.php" method="post" id="form_take_more_objects_away">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="Objects"}</legend>
            <table class="listing">
                <thead>
                    <tr>
                        {if $olendsprefs->imagesInLists()}
                            <th class="id_row">
                                {_T string="Picture"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_NAME}
                            <th>
                                {_T string="Name"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_SERIAL}
                            <th>
                                {_T string="Serial"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <th>
                                {_T string="Price"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <th>
                                {_T string="Borrow price"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <th>
                                {_T string="Dimensions"}
                            </th>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <th>
                                {_T string="Weight"}
                            </th>
                        {/if}
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$objects item=objt}
                    <tr class="{if $objt@index is odd}even{else}odd{/if}">
                        {if $olendsprefs->imagesInLists()}
                        <td class="center">
                            <img src="picture.php?object_id={$objt->object_id}&amp;rand={$time}&amp;thumb=1"
                                class="picture"
                                width="{$objt->picture->getOptimalThumbWidth()}"
                                height="{$objt->picture->getOptimalThumbHeight()}"
                                alt="{_T string="Object's photo"}"/>
                        </td>
                        {/if}
                        <td>
                            <input type="hidden" name="objects_id[]" value="{$objt->object_id}">
                            <b>{$objt->search_name}</b>
                            {if $lendsprefs.VIEW_DIMENSION}
                                <br/>{$objt->search_description}
                            {/if}
                        </td>
                        {if $lendsprefs.VIEW_SERIAL}
                            <td>
                                {$objt->search_serial_number}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_PRICE}
                            <td class="right">
                                {$objt->price}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_LEND_PRICE}
                            <td class="right">
                                <input type="text" name="rent_price_{$objt->object_id}" value="{$objt->rent_price}" size="10" style="text-align: right">
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_DIMENSION}
                            <td>
                                {$objt->search_dimension}
                            </td>
                        {/if}
                        {if $lendsprefs.VIEW_WEIGHT}
                            <td class="right">
                                {$objt->weight}
                            </td>
                        {/if}
                    </tr>
                {/foreach}
                </tbody>
            </table>
{if $takeorgive eq 'take'}
            <div>
                <p>
                    <span class="bline">{_T string="Member:"}</span>
                    <select name="id_adh" id="id_adh" onchange="validStatus()" style="width: 350px">
                        <option value="null">{_T string="--- Select a member ---"}</option>
                        {foreach from=$members item=mmbr}
                            <option value="{$mmbr->id_adh}"{if $login->id eq $mmbr->id_adh} selected="selected"{/if}>{$mmbr->nom_adh} {$mmbr->prenom_adh}{$mmbr->prenom_adh}{if $mmbr->pseudo_adh != ''} ({$mmbr->pseudo_adh}){/if}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="Status:"}</span>
                    <select name="status" id="status" onchange="validStatus()" style="width: 350px">
                        <option value="null">{_T string="--- Select a status ---"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            {if $lendsprefs.AUTO_GENERATE_CONTRIBUTION}
                <div>
                    <p>
                        <span class="bline">{_T string="Payment type:"}</span>
                        <select name="payment_type" id="payment_type" onchange="validStatus()" style="width: 350px">
                            <option value="null">{_T string="--- Select a payment type ---"}</option>
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
{/if}
{if $takeorgive eq 'give'}
            <div>
                <p>
                    <span class="bline">{_T string="Status:"}</span>
                    <select name="status" id="status">
                        <option value="null">{_T string="--- Select a status ---"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="Comments:"}</span>
                    <textarea name="comments" id="comments" style="font-family: Cantarell,Verdana,sans-serif; font-size: 0.85em; width: 400px; height: 60px;"></textarea>
                    <br/><span id="remaining">200</span>
                    {_T string="remaining characters"}
                </p>
            </div>
{/if}
        </fieldset>
    </div>
    <div class="button-container" id="button_container">
        <input type="submit" id="btnsave" name="yes" value="{if $takeorgive eq 'take'}{_T string="Take away"}{/if}{if $takeorgive eq 'give'}{_T string="Give back"}{/if}">
        <a href="objects_list.php" class="button" id="btncancel">{_T string="Cancel"}</a>
    </div>
</form>

<script>
{if $takeorgive eq 'take'}
    var _init_takeobject_js = function() {
        $('#btnsave').button('disable');

    {if $ajax}
            $('#btnsave').click(ajax_take_more_objects_away);

        {if $olendsprefs->showFullsize()}
            _init_fullimage();
        {/if}
    {/if}

        $('#id_adh, #status, #payment_type').on('change',function() {
            validStatus()
        });
    }

    {if not $ajax}
    $(function () {
        _init_takeobject_js();
    });
    {/if}

    function validStatus() {
        var _disabled = false;
        if ($('#status').val() === 'null') {
            _disabled = true;
        }
        if ($('#id_adh').val() === 'null') {
            _disabled = true;
        }
        if ($('#payment_type').val() === 'null') {
            _disabled = true;
        }

        var _lyes = $('#btnsave');
        if (_disabled) {
            _lyes.button('disable');
        } else {
            _lyes.button('enable');
        }
    }
{/if}
{if $takeorgive eq 'give'}
    var _init_giveobject_js = function() {
        $('#btnsave').button('disable');

    {if $ajax}
            $('#btnsave').click(ajax_take_more_objects_away);

        {if $olendsprefs->showFullsize()}
            _init_fullimage();
        {/if}
    {/if}

        $('#comments').keyup(function() {
            if ($('#comments').val().length > 200) {
                $('#comments').val($('#comments').val().substr(0, 200));
            }
            $('#remaining').text(200 - $('#comments').val().length);
        });

        $('#status').on('change',function() {
            validStatus()
        });
    };

    function validStatus() {
        var _lyes = $('#btnsave');
        if ($('#status').val() === 'null') {
            _lyes.button('disable');
        } else {
            _lyes.button('enable');
        }
    }
{/if}
</script>
