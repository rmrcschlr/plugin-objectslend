{extends file="page.tpl"}
{block name="content"}
{*debug*}
<form action="{path_for name="objectslend_do_take_lend" data=["action" => $action, "id" => $object->object_id]}" method="post" id="form_take_object" enctype="multipart/form-data">
{foreach $id as $k=>$v}
	{foreach $objects as $t=>$u}
		{if $u->object_id == $v}
			{if !$name}
				{$name=$u->name}
			{else}
				{assign var="name" value="{$name} / {$u->name}"}
			{/if}
			{if !$description} {$description=$u->description}{else}{assign var="description" value="{$description} / {$u->description}"}{/if}
			{if !$serial_number} {$serial_number=$u->serial_number}{else}{assign var="serial_number" value="{$serial_number} / {$u->serial_number}"}{/if}

			{if !$price} {$price=$u->price}{else}{assign var="price" value="{$price} / {$u->price}"}{/if}
			{if !$rent_price} {$rent_price=$u->rent_price}{else}{assign var="rent_price" value="{$rent_price} / {$u->rent_price}"}{/if}
			{if !$dimension} {$dimension=$u->dimension}{else}{assign var="dimension" value="{$dimension} / {$u->dimension}"}{/if}
			{if !$weight} {$weight=$u->weight}{else}{assign var="weight" value="{$weight} / {$u->weight}"}{/if}

			<input type="hidden" name="ids[]" value="{$v}">
		{/if}
	{/foreach}
{/foreach}
    <div class="bigtable">
        <fieldset class="galette_form" id="general">
            <legend class="ui-state-active ui-corner-top">{_T string="Object" domain="objectslend"}</legend>
            <div>
                <p>
                    <span class="bline">{_T string="Name:" domain="objectslend"}</span>
					{$name}
                </p>
            </div>
    {if $lendsprefs.VIEW_DESCRIPTION}
            <div>
                <p>
                    <span class="bline">{_T string="Description:" domain="objectslend"}</span>
                    {$description}
                </p>
            </div>
    {/if}
    {if $lendsprefs.VIEW_SERIAL}
            <div>
                <p>
                    <span class="bline">{_T string="Serial number:" domain="objectslend"}</span>
                    {$serial_number}
                </p>
            </div>
    {/if}
    {if $lendsprefs.VIEW_PRICE}
            <div>
                <p>
                    <span class="bline">{_T string="Buy price (%currency):" domain="objectslend" pattern="/%currency/" replace=$object->currency}</span>
                        <input type="hidden" name="price" id="price" value="{$price}">
                    <span id="price_label">{$price}</span>
                </p>
            </div>
        {/if}
	{if $lendsprefs.GIVE_PRICE}
		<div>
			<p>
				<span class="bline">{_T string="Borrow price (%currency):" domain="objectslend" pattern="/%currency/" replace=$object->currency}</span>
				<input type="text" name="rent_price" id="rent_price" value="{$rent_price}" size="5">
			</p>
		</div>
	{else}
		 {if $lendsprefs.VIEW_LEND_PRICE}
            <div>
                <p>
                    <span class="bline">{_T string="Borrow price (%currency):" domain="objectslend" pattern="/%currency/" replace=$object->currency}</span>
                        <input type="hidden" name="rent_price" id="rent_price" value="{$rent_price}">
                    <span id="rent_price_label">{$rent_price}</span>
                </p>
            </div>
        {/if}
	{/if}
    {if $lendsprefs.VIEW_DIMENSION}
            <div>
                <p>
                    <span class="bline">{_T string="Dimensions (cm):" domain="objectslend"}</span>
                    {$dimension}
                </p>
            </div>
    {/if}
    {if $lendsprefs.VIEW_WEIGHT}
            <div>
                <p>
                    <span class="bline">{_T string="Weight (kg):" domain="objectslend"}</span>
                    {$weight}
                </p>
            </div>
    {/if}
    {if $login->isAdmin() || $login->isStaff()}
                <div>
                    <p>
                        <span class="bline">{_T string="Member:" domain="objectslend"}</span>
                        <select name="adherent_id" id="adherent_id">
                            <option value="null">{_T string="--- Select a member ---" domain="objectslend"}</option>
							{foreach $members as $k=>$v}
								<option value="{$k}"{if $transaction->member == $k} selected="selected"{/if}>{$v}</option>
							{/foreach}
                        </select>
                    </p>
                </div>

            {/if}
            <div>
                <p>
                    <span class="bline">{_T string="Status:" domain="objectslend"}</span>
                    <select name="status_id" id="status_id">
                        <option value="null">{_T string="--- Select a status ---" domain="objectslend"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}" data-days="{$sta->rent_day_number}">
                                {$sta->status_text}
                                {if $sta->rent_day_number ne ''}
                                    ({_T string="%days days" domain="objectslend" pattern="/%days/" replace=$sta->rent_day_number})
                                {/if}
                            </option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>

                <p>
					<label for="date_begin">{_T string="Begin date" domain="objectslend"}</label>
					<input type="text" name="date_begin" id="date_begin" maxlength="10" size="10" value="{$date_begin}" required="required"/>

                </p>
            </div>
			 <div>
                <p>
					<label for="date_forecast">{_T string="End date" domain="objectslend"}</label>
					<input type="text" name="date_forecast" id="date_forecast" maxlength="10" size="10" value="{$date_forecast}" required="required"/>
                </p>
            </div>
			 <div>
				<p>
                    <span class="bline">{_T string="Comments:" domain="objectslend"}</span>
                    <input type="text" id="comments" name="comments" value="{$name} : " size="80">
                </p>
            </div>
			{if $lendsprefs.VIEW_PRICE}
				{if $lendsprefs.AUTO_GENERATE_CONTRIBUTION}
					<div>
							{* payment type *}
							{assign var="ptype" value=$contribution->payment_type}
							{include file="forms_types/payment_types.tpl" current=$ptype varname="type_paiement_cotis"}
					</div>
				{/if}
			{/if}

        </fieldset>
    </div>
{if $login->isAdmin() || $login->isStaff()}
	{else}
    <div class="disclaimer center">
        <input type="checkbox" name="agreement" id="agreement" value="1" required="required"/>
        <label for="agreement">{_T string="I have read and I agree with terms and conditions" domain="objectslend"}</label>
        <span class="show_agreement" title="{_T string="Show terms and conditions" domain="objectslend"}"><img src="{$template_subdir}images/icon-down.png" alt="{_T string="Show terms and conditions" domain="objectslend"}"/></span>
        <div id="terms_conditions" class="left">{_T string="The items offered for rent are in good condition and verification rental contradictory to their status is at the time of withdrawal. No claims will be accepted after the release of the object. Writing by the store a list of reservation does not exempt the customer checking his retrait. The payment of rent entitles the purchaser to make normal use of the loaned object. If the object is rendered in a degraded state, the seller reserves the right to collect all or part of the security deposit. In case of deterioration of the rented beyond the standard object, a financial contribution will be required for additional cleaning caused. In case of damage, loss or theft of the rented property, the deposit will not be refunded automatically to 'the company as damages pursuant to Article 1152 of the Civil Code and without that it need for any other judicial or extra-judicial formality. In some other cases not listed above and at the discretion of the seller, the deposit check may also be collected in whole or party." domain="objectslend"}</div>
    </div>
	{/if}
    <div class="button-container" id="button_container">
        <input type="submit" id="btnsave" name="yes" value="{_T string="Take away" domain="objectslend"}">
        <a href="{path_for name="objectslend_objects"}" class="button" id="btncancel">{_T string="Cancel" domain="objectslend"}</a>
    </div>
</form>
{/block}

{block name="javascripts"}
<script type="text/javascript">
    $(function()
		{
		var $nmdt1=$('#date_begin');
		var $nmdt2=$('#date_forecast');
		var $w="";

		if ($nmdt1.length > 0) {
            _collapsibleFieldsets();
            $.datepicker.setDefaults($.datepicker.regional['{$galette_lang}']);
            $('#date_begin').datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: 'button',
                minDate: '-0d',
                dateFormat: "yy-mm-dd",
                buttonText: '<i class="far fa-calendar-alt"></i> <span class="sr-only">{_T string="Select a date"  domain="objectslend" escape="js"}</span>',
                onSelect: function(date) {
					$nmdt1=$('#date_begin').datepicker('getDate') ;
					$nmdt1.setDate($nmdt1.getDate() +1 );
                    $("#date_forecast").datepicker("option", "minDate", $nmdt1);
                }
            });
		}

		if ($nmdt2.length > 0) {
            $('#date_forecast').datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: 'button',
                dateFormat: "yy-mm-dd",
                buttonText: '<i class="far fa-calendar-alt"></i> <span class="sr-only">{_T string="Select a date"  domain="objectslend" escape="js"}</span>',
                minDate: $("#date_forecast").datepicker("getDate")
          });
		}
	});

	$('select').on('change', function() {
		var msg=this.value;
		var res=this.value.split(":");
		if (res[0] === "object") {
			var res1="";
			var res1=res1.concat("\nform_id\t: ",res[1],"\nid_adh\t: ",res[2],"\nsname\t: ",res[3],"\ncateg\t: ",res[4],"\nobject\t: ",res[5]);
			console.log(this.id)
			alert(res1);
		}
	});
</script>
{/block}
