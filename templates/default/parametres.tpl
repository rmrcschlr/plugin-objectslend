{if $parametres_sauves}
    <div id="infobox">{_T string="PARAMETER LEND.PARAMETERS SAVED"}</div>
{/if}
{if $erreurs}
    <div id="errorbox">
        <h1>{_T string="- ERROR -"}</h1>
        <ul>
            {foreach from=$liste_erreurs item=err}
                <li>{$err}</li>
                {/foreach}
        </ul>
    </div>
{/if}
<form action="parameters.php" method="post">
    <table class="listing">
        <caption class="ui-state-active ui-corner-top">{_T string="PARAMETER LEND.LIST"}</caption>
        <thead>
            <tr>
                <th>{_T string="PARAMETER LEND.CODE"}</th>
                <th>{_T string="PARAMETER LEND.FORMAT"}</th>
                <th>{_T string="PARAMETER LEND.VALUE"}</th>
            </tr>
        </thead>
        <tbody>
            {foreach from=$liste_parametres item=parametre}
                <tr class="{if $parametre@index % 2 eq 0}even{else}odd{/if}">
                    <td width="30%">
                        <b>{$parametre->code}</b>
                        <br/>{_T string="PARAMETER LEND.LABEL {$parametre->code}"}
                        <input type="hidden" name="liste_codes[]" value="{$parametre->code}">
                    </td>
                    <td width="20%">
                        {if $parametre->is_date}
                            {_T string="PARAMETER LEND.DATE"}
                            <input type="hidden" name="format_{$parametre->code}" value="date">
                        {/if}
                        {if $parametre->is_text}
                            {_T string="PARAMETER LEND.TEXT"}
                            <input type="hidden" name="format_{$parametre->code}" value="text">
                        {/if}
                        {if $parametre->is_numeric}
                            {_T string="PARAMETER LEND.NUMERIC"}
                            <input type="hidden" name="format_{$parametre->code}" value="numeric">
                        {/if}
                    </td>
                    <td width="50%">
                        <input type="text" size="50" id="valeur_{$parametre->code}" name="valeur_{$parametre->code}" value="{if $parametre->is_date}{$parametre->value_date}{elseif $parametre->is_text}{$parametre->value_text}{else}{$parametre->value_numeric}{/if}"{if $parametre->isColor()} class="hex"{/if}>
                        <input type="hidden" name="ancienne_valeur_{$parametre->code}" value="{if $parametre->is_date}{$parametre->value_date}{elseif $parametre->is_text}{$parametre->value_text}{else}{$parametre->value_numeric}{/if}">
                    </td>
                </tr>
            {/foreach}
        </tbody>
    </table>
    <div class="button-container">
        <input type="submit" id="parametre" value="{_T string="PARAMETER LEND.SAVE"}">
    </div>
</form>
<script type="text/javascript">
    $('#prefs_tabs').tabs();

    {foreach from=$liste_parametres item=parametre}
        {if $parametre->is_date}
    $('#valeur_{$parametre->code}').datepicker({
        changeMonth: true,
        changeYear: true,
        showOn: 'both',
        buttonImage: '{$template_subdir}images/calendar.png',
        buttonImageOnly: true,
        maxDate: '-0d',
        yearRange: 'c-20'
            });
        {/if}
    {/foreach}

    //for color pickers
    $(function(){
        // hex inputs
        $('input.hex')
                .validHex()
                .keyup(function() {
            $(this).validHex();
    })
                .click(function(){
            $(this).addClass('focus');
            $('#picker').remove();
            $('div.picker-on').removeClass('picker-on');
            $(this).after('<div id="picker"></div>').parent().addClass('picker-on');
            $('#picker').farbtastic(this);
            return false;
    })
                .wrap('<div class="hasPicker"></div>')
                .applyFarbtastic();

        //general app click cleanup
        $('body').click(function() {
            $('div.picker-on').removeClass('picker-on');
            $('#picker').remove();
            $('input.focus, select.focus').removeClass('focus');
    });

    });

    //color pickers setup (sets bg color of inputs)
    $.fn.applyFarbtastic = function() {
        return this.each(function() {
            $('<div/>').farbtastic(this).remove();
    });
    };

    // validation for hex inputs
    $.fn.validHex = function() {

        return this.each(function() {

            var value = $(this).val();
            value = value.replace(/[^#a-fA-F0-9]/g, ''); // non [#a-f0-9]
            if (value.match(/#/g) && value.match(/#/g).length > 1)
                value = value.replace(/#/g, ''); // ##
            if (value.indexOf('#') == -1)
                value = '#' + value; // no #
            if (value.length > 7)
                value = value.substr(0, 7); // too many chars

            $(this).val(value);

    });

    };
</script>
