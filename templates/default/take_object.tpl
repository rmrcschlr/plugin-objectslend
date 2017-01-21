<form action="take_object.php" method="post" id="form_take_object">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    {if $ajax}
        <input type="hidden" name="mode" value="ajax"/>
        <img src="picts/close.png" title="{_T string="AJAX.CLOSE"}" alt="{_T string="AJAX.CLOSE"}" id="button_close"/>
    {/if}
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="TAKE OBJECT.TITLE"}</legend>
            <div>
                <p>
                    {if $object->draw_image}
                        <img src="{$object->object_image_url}" 
                             class="picture tooltip_lend" 
                             align="right" 
                             title="{$object->tooltip_title}" 
                             {if $view_object_thumb}style="max-height: {$thumb_max_height}px; max-width: {$thumb_max_width}px;"{/if}/>
                    {/if}
                    <span class="bline">{_T string="TAKE OBJECT.NAME"}</span>
                    {$object->name}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.DESCRIPTION"}</span>
                    {$object->description}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.SERIAL"}</span>
                    {$object->serial_number}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.PRICE"}</span>
                    {$object->price}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.RENT PRICE"}</span>
                    {if $login->isAdmin() || $login->isStaff()}
                        <input type="text" name="rent_price" id="rent_price" value="{$object->rent_price}" size="10" style="text-align: right">
                    {else}
                        <input type="hidden" name="rent_price" id="rent_price" value="{$object->rent_price}">
                        <span id="rent_price_label">{$object->rent_price}</span>
                    {/if}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.DIMENSION"}</span>
                    {$object->dimension}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.WEIGHT"}</span>
                    {$object->weight}
                </p>
            </div>
            {if $login->isAdmin() || $login->isStaff()}
                <div>
                    <p>
                        <span class="bline">{_T string="TAKE OBJECT.MEMBERS"}</span>
                        <select name="id_adh" id="id_adh" onchange="validStatus()" style="width: 350px">
                            <option value="null">{_T string="TAKE OBJECT.SELECT MEMBER"}</option>
                            {foreach from=$members item=mmbr}
                                <option value="{$mmbr->id_adh}"{if $login->id eq $mmbr->id_adh} selected="selected"{/if}>{$mmbr->nom_adh} {$mmbr->prenom_adh} ({$mmbr->pseudo_adh})</option>
                            {/foreach}
                        </select>
                    </p>
                </div>
            {/if}
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.STATUS"}</span>
                    <select name="status" id="status" onchange="validStatus()" style="width: 350px">
                        <option value="null">{_T string="TAKE OBJECT.SELECT STATUS"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}/{$sta->rent_day_number}">
                                {$sta->status_text}
                                {if $sta->rent_day_number ne ''}
                                    ({$sta->rent_day_number} {_T string="TAKE OBJECT.DAYS"})
                                {/if}
                            </option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="TAKE OBJECT.EXPECTED RETURN"}</span>
                    <input type="text" id="expected_return" name="expected_return" size="8">
                </p>
            </div>
            {if $add_contribution}                
                <div>
                    <p>
                        <span class="bline">{_T string="TAKE OBJECT.PAYMENT TYPE"}</span>
                        <select name="payment_type" id="payment_type" onchange="validStatus()" style="width: 350px">
                            <option value="null">{_T string="TAKE OBJECT.SELECT PAYMENT TYPE"}</option>
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
        <input type="submit" id="lend_yes" class="ui-button ui-widget ui-state-default ui-corner-all" name="yes" value="{_T string="TAKE OBJECT.YES"}" style="visibility: hidden;">
        <input type="submit" id="lend_cancel" class="ui-button ui-widget ui-state-default ui-corner-all" name="cancel" value="{_T string="TAKE OBJECT.NO"}">
    </div>
</form>
<blockquote>
    <small><i>
            {_T string="TAKE OBJECT.RESPONSIBLE FOR"}
        </i></small>
</blockquote>
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
    $('#lend_yes').click(ajax_take_object);
    {else}
    $('#lend_cancel').click(function () {
        document.location = 'objects_list.php?msg=not_taken';
        return false;
    });
    {/if}

    $(function () {
        $('#expected_return').datepicker({
            changeMonth: true,
            changeYear: true,
            showOn: 'both',
            buttonImage: '{$template_subdir}images/calendar.png',
            buttonImageOnly: true,
            minDate: 0,
            selectOtherMonths: true,
            showOtherMonths: false,
            showWeek: true,
        });
    });

    function completeZero(n) {
        return n < 10 ? '0' + n : n;
    }

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

                var id_days = $('#status').val();
                if (id_days === 'null') {
                    return;
                }

                var nb_days = id_days.split('/');
                if (nb_days[1].length === 0) {
                    var text = "{$object->rent_price}";
                    $('#rent_price').val(text);
                    $('#rent_price_label').html(text);
                    return;
                }

                var tomorrow = new Date({$year}, {$month} - 1, {$day} + parseInt(nb_days[1]));
                $('#expected_return').val(completeZero(tomorrow.getDate()) + '/' + completeZero(tomorrow.getMonth() + 1) + '/' + tomorrow.getFullYear());

                if ('1' === '{$object->price_per_day}') {
                    var price_per_day = {$rent_price} * parseInt(nb_days[1]);
                    var text = price_per_day.toFixed(2).replace(".", ",");
                    $('#rent_price').val(text);
                    $('#rent_price_label').html(text);
                }
            }
</script>
