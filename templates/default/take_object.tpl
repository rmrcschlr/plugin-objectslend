<form action="take_object.php" method="post">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="TAKE OBJECT.TITLE"}</legend>
            <div>
                <p>
                    <img src="picture.php?object_id={$object->object_id}&thumb=1" class="picture" align="right" />
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
                    <input type="text" name="rent_price" value="{$object->rent_price}" size="10" style="text-align: right">
{else}
                    {$object->rent_price}
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
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
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
    <div class="button-container">
        <input type="submit" id="yes" name="yes" value="{_T string="TAKE OBJECT.YES"}">
        <input type="submit" id="cancel" name="cancel" value="{_T string="TAKE OBJECT.NO"}" onclick="document.location = 'objects_list.php?msg=canceled{if $object->category_id gt 0}&category_id={$object->category_id}{/if}'; return false;">
    </div>
</form>
<blockquote>
    <small><i>
    {_T string="TAKE OBJECT.RESPONSIBLE FOR"}
    </i></small>
</blockquote >
<script>
    document.getElementById('yes').style.visibility = 'hidden';
    function validStatus() {
    var slctStatus = document.getElementById('status');
    var slctIdAdh = document.getElementById('id_adh');
    var slctPayTyp = document.getElementById('payment_type');    
    var visibility = 'visible';    
    if (slctStatus.options[slctStatus.selectedIndex].value == 'null') {
        visibility = 'hidden';
    }
    if (slctIdAdh != null && slctIdAdh.options[slctIdAdh.selectedIndex].value == 'null') {
        visibility = 'hidden';
    }
    if (slctPayTyp != null && slctPayTyp.options[slctPayTyp.selectedIndex].value == 'null') {
        visibility = 'hidden';
    }
    document.getElementById('yes').style.visibility = visibility;    
}
</script>
