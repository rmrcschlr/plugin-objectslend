<form action="preferences.php" method="post">
    <div id="prefs_tabs">
        <fieldset class="cssform" id="objectslend">
            <legend class="ui-state-active ui-corner-top">{_T string="Plugin preferences"}</legend>
            <p>
                <span class="bline tooltip" title="{_T string="Allow a member (not staff neither admin) to borrow an object. If set to 'No', only admin and staff members can access the 'Take object' page"}">{_T string="Members can borrow:"}</span>
                <span class="tip">{_T string="Allow a member (not staff neither admin) to borrow an object. If set to 'No', only admin and staff members can access the 'Take object' page"}</span>
                <input type="radio" name="ENABLE_MEMBER_RENT_OBJECT" id="yes_memberborrow" value="1" {if $lendsprefs.ENABLE_MEMBER_RENT_OBJECT eq '1'}checked="checked"{/if}/><label for="yes_memberborrow">{_T string="Yes"}</label>
                <input type="radio" name="ENABLE_MEMBER_RENT_OBJECT" id="no_memberborrow" value="0" {if $lendsprefs.ENABLE_MEMBER_RENT_OBJECT eq '0'}checked="checked"{/if}/><label for="no_memberborrow">{_T string="No"}</label>
            </p>
            <p>
                <label for="max_thumb_height" class="bline">{_T string="Max thumb height (in px)"}</label>
                <input type="text" name="THUMB_MAX_HEIGHT" id="max_thumb_height" value="{$lendsprefs.THUMB_MAX_HEIGHT}"/>
            </p>
            <p>
                <label for="max_thumb_width" class="bline">{_T string="Max thumb width (in px)"}</label>
                <input type="text" name="THUMB_MAX_WIDTH" id="max_thumb_width" value="{$lendsprefs.THUMB_MAX_WIDTH}"/>
            </p>
        </fieldset>
        <fieldset class="cssform" id="objectslendicontribs">
            <legend class="ui-state-active ui-corner-top">{_T string="Contribution related"}</legend>
            <p>
                <span class="bline tooltip" title="{_T string="Automatically generate a contribution for the member of the amount of the rental price of the object"}">{_T string="Generate contribution:"}</span>
                <span class="tip">{_T string="Automatically generate a contribution for the member of the amount of the rental price of the object"}</span>
                <input type="radio" name="AUTO_GENERATE_CONTRIBUTION" id="yes_contrib" value="1" {if $lendsprefs.AUTO_GENERATE_CONTRIBUTION eq '1'}checked="checked"{/if}/><label for="yes_contrib">{_T string="Yes"}</label>
                <input type="radio" name="AUTO_GENERATE_CONTRIBUTION" id="no_contrib" value="0" {if $lendsprefs.AUTO_GENERATE_CONTRIBUTION eq '0'}checked="checked"{/if}/><label for="no_contrib">{_T string="No"}</label>
            </p>
            {* TODO: hide this one if AUTO_GENERATE_CONTRIBUTION is off *}
            <p>
                <label for="contribution_type" class="bline">{_T string="Contribution type:"}</label>
                <select name="GENERATED_CONTRIBUTION_TYPE_ID" id="contribution_type">
                    <option value="0">{_T string="Choose a contribution type"}</option>
    {foreach from=$ctypes item=ctype key=id}
                    <option value="{$id}"{if $lendsprefs.GENERATED_CONTRIBUTION_TYPE_ID eq $id} selected="selected"{/if}>{$ctype}</option>
    {/foreach}
                </select>
            </p>
            {* TODO: hide this one if AUTO_GENERATE_CONTRIBUTION is off *}
            <p>
                <label for="contrib_text" class="bline tooltip" title="{_T string="Comment text to add on generated contribution"}">{_T string="Contribution text:"}</label>
                <span class="tip">{_T string="Comment text to add on generated contribution. Automatically replaced values (put into curly brackets): <br/>- NAME: Name<br/>- DESCRIPTION: Description<br/>- SERIAL_NUMBER: Serial number<br/>- PRICE: Price<br/>- RENT_PRICE: Borrow price<br/>- WEIGHT: Weight<br/>- DIMENSION: Dimensions"}</span>
                <input type="text" size="100" name="GENERATED_CONTRIB_INFO_TEXT" id="contrib_text" value="{$lendsprefs.GENERATED_CONTRIB_INFO_TEXT}"/>
            </p>
        </fieldset>
        <fieldset class="cssform" id="objectslend">
            <legend class="ui-state-active ui-corner-top">{_T string="Display preferences"}</legend>
            <p>
                <span class="bline">{_T string="View category:"}</span>
                <input type="radio" name="VIEW_CATEGORY" id="yes_view_category" value="1" {if $lendsprefs.VIEW_CATEGORY eq '1'}checked="checked"{/if}/><label for="yes_view_category">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_CATEGORY" id="no_view_category" value="0" {if $lendsprefs.VIEW_CATEGORY eq '0'}checked="checked"{/if}/><label for="no_view_category">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline tooltip" title="{_T string="View category pictures as thumb or in fulllsize"}">{_T string="Category thumbs:"}</span>
                <span class="tip">{_T string="View category pictures as thumb or in fulllsize"}</span>
                <input type="radio" name="VIEW_CATEGORY_THUMB" id="yes_view_catthumb" value="1" {if $lendsprefs.VIEW_CATEGORY_THUMB eq '1'}checked="checked"{/if}/><label for="yes_view_catthumb">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_CATEGORY_THUMB" id="no_view_catthumb" value="0" {if $lendsprefs.VIEW_CATEGORY_THUMB eq '0'}checked="checked"{/if}/><label for="no_view_catthumb">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View forecast return date:"}</span>
                <input type="radio" name="VIEW_DATE_FORECAST" id="yes_view_dateforecast" value="1" {if $lendsprefs.VIEW_DATE_FORECAST eq '1'}checked="checked"{/if}/><label for="yes_view_dateforecast">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_DATE_FORECAST" id="no_view_dateforecats" value="0" {if $lendsprefs.VIEW_DATE_FORECAST eq '0'}checked="checked"{/if}/><label for="no_view_dateforecats">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View description"}</span>
                <input type="radio" name="VIEW_DESCRIPTION" id="yes_view_description" value="1" {if $lendsprefs.VIEW_DESCRIPTION eq '1'}checked="checked"{/if}/><label for="yes_view_description">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_DESCRIPTION" id="no_view_description" value="0" {if $lendsprefs.VIEW_DESCRIPTION eq '0'}checked="checked"{/if}/><label for="no_view_description">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View dimensions:"}</span>
                <input type="radio" name="VIEW_DIMENSION" id="yes_view_dimension" value="1" {if $lendsprefs.VIEW_DIMENSION eq '1'}checked="checked"{/if}/><label for="yes_view_dimension">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_DIMENSION" id="no_view_dimension" value="0" {if $lendsprefs.VIEW_DIMENSION eq '0'}checked="checked"{/if}/><label for="no_view_dimension">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View borrow price:"}</span>
                <input type="radio" name="VIEW_LEND_PRICE" id="yes_view_lendprice" value="1" {if $lendsprefs.VIEW_LEND_PRICE eq '1'}checked="checked"{/if}/><label for="yes_view_lendprice">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_LEND_PRICE" id="no_view_lendprice" value="0" {if $lendsprefs.VIEW_LEND_PRICE eq '0'}checked="checked"{/if}/><label for="no_view_lendprice">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline tooltip" title="{_T string="View the objects buy price sum on the list under the category"}">{_T string="View price sum:"}</span>
                <span class="tip">{_T string="View the objects buy price sum on the list under the category"}</span>
                <input type="radio" name="VIEW_LIST_PRICE_SUM" id="yes_view_pricesum" value="1" {if $lendsprefs.VIEW_LIST_PRICE_SUM eq '1'}checked="checked"{/if}/><label for="yes_view_pricesum">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_LIST_PRICE_SUM" id="no_view_pricesum" value="0" {if $lendsprefs.VIEW_LIST_PRICE_SUM eq '0'}checked="checked"{/if}/><label for="no_view_pricesum">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View name:"}</span>
                <input type="radio" name="VIEW_NAME" id="yes_view_name" value="1" {if $lendsprefs.VIEW_NAME eq '1'}checked="checked"{/if}/><label for="yes_view_name">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_NAME" id="no_view_name" value="0" {if $lendsprefs.VIEW_NAME eq '0'}checked="checked"{/if}/><label for="no_view_name">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline tooltip" title="{_T string="View object pictures as thumb or in fulllsize"}">{_T string="Object thumbs:"}</span>
                <span class="tip">{_T string="View object pictures as thumb or in fulllsize"}</span>
                <input type="radio" name="VIEW_OBJECT_THUMB" id="yes_view_objthumb" value="1" {if $lendsprefs.VIEW_OBJECT_THUMB eq '1'}checked="checked"{/if}/><label for="yes_view_objthumb">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_OBJECT_THUMB" id="no_view_objthumb" value="0" {if $lendsprefs.VIEW_OBJECT_THUMB eq '0'}checked="checked"{/if}/><label for="no_view_objthumb">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View buy price:"}</span>
                <input type="radio" name="VIEW_PRICE" id="yes_view_price" value="1" {if $lendsprefs.VIEW_PRICE eq '1'}checked="checked"{/if}/><label for="yes_view_price">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_PRICE" id="no_view_price" value="0" {if $lendsprefs.VIEW_PRICE eq '0'}checked="checked"{/if}/><label for="no_view_price">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View serial number:"}</span>
                <input type="radio" name="VIEW_SERIAL" id="yes_view_serial" value="1" {if $lendsprefs.VIEW_SERIAL eq '1'}checked="checked"{/if}/><label for="yes_view_serial">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_SERIAL" id="no_view_serial" value="0" {if $lendsprefs.VIEW_SERIAL eq '0'}checked="checked"{/if}/><label for="no_view_serial">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View thumnails:"}</span>
                <input type="radio" name="VIEW_THUMBNAIL" id="yes_view_" value="1" {if $lendsprefs.VIEW_THUMBNAIL eq '1'}checked="checked"{/if}/><label for="yes_view_">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_THUMBNAIL" id="no_view_" value="0" {if $lendsprefs.VIEW_THUMBNAIL eq '0'}checked="checked"{/if}/><label for="no_view_">{_T string="No"}</label>
            </p>
            <p>
                <span class="bline">{_T string="View weight"}</span>
                <input type="radio" name="VIEW_WEIGHT" id="yes_view_weight" value="1" {if $lendsprefs.VIEW_WEIGHT eq '1'}checked="checked"{/if}/><label for="yes_view_weight">{_T string="Yes"}</label>
                <input type="radio" name="VIEW_WEIGHT" id="no_view_weight" value="0" {if $lendsprefs.VIEW_WEIGHT eq '0'}checked="checked"{/if}/><label for="no_view_weight">{_T string="No"}</label>
            </p>
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="btnsave" name="saveprefs" value="{_T string="Save"}">
    </div>
</form>
