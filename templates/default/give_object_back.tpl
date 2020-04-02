{extends file="page.tpl"}
{block name="content"}
<form action="{path_for name="objectslend_do_giveback_lend" data=["action" => $action, "id" => $id ]}" method="post" id="doremove_lend" enctype="multipart/form-data">
{foreach $id as $k=>$v}
    {foreach $objects as $t=>$u}
        {if $u->object_id == $v}
            {if !$name}{$name=$u->name}{else}{assign var="name" value="{$name} / {$u->name}"}{/if}
            {if !$date_begin}{$date_begin=$u->date_begin}{else}{assign var="date_begin" value="{$date_begin} / {$u->date_begin}"}{/if}
            {if !$date_forecast}{$date_forecast=$u->date_forecast}{else}{assign var="date_forecast" value="{$date_forecast} / {$u->date_forecast}"}{/if}
            {if !$comments}{$comments=$u->comments}{else}{assign var="comments" value="{$comments} / {$u->comments}"}{/if}
            <input type="hidden" name="ids[]" value="{$v}">
        {/if}
    {/foreach}
{/foreach}
    <div class="bigtable">
        <fieldset class="galette_form" id="general">
            <legend class="ui-state-active ui-corner-top">{_T string="Object" domain="objectslend"}</legend>
            <div>
                <p>
                    <label for="name">{_T string="Name:" domain="objectslend"}</label>
                    <b>{$name}</b>
                </p>
                <p>
                    <label for="begin_date">{_T string="Begin date:" domain="objectslend"}</label>
                    <b>{$date_begin}</b>
                </p>
                <p>
                    <label for="date_forecast">{_T string="End date" domain="objectslend"}</label>
                    <b>{$date_forecast}</b>
                </p>
                <p>
                    <label for="Comment">{_T string="Comments:" domain="objectslend"}</label>
                    <b>{$comments}</b>
                </p>
            </div>
        </fieldset>
        <fieldset class="galette_form" id="general">
            <legend class="ui-state-active ui-corner-top">{_T string="Return" domain="objectslend"}</legend>
            <div>
                <p>
                    <label for="Comments">{_T string="Return comments" domain="objectslend"}</label>
                    <input type="text" id="comments" name="comments" value="{foreach $id as $k=>$v}{foreach $objects as $t=>$u}{if $u->object_id == $v}{$u->comments} {" - "}{/if}{/foreach}{/foreach} - Return :"  size="80">
                </p>
                <p><b>{_T string="Are you sure you want to proceed?" This can't be undone." domain="objectslend"}</b></p>
                <div class="button-container">
                    <input type="submit" id="delete" value="{_T string="Return" domain="objectslend"}"/>
                        <a href="{$cancel_uri}" class="button" id="btncancel">{_T string="Cancel"}</a>
                </div>
             </div>
        </fieldset>
    </div>
</form>

{/block}
