<form action="status_edit.php" method="post">
    <input type="hidden" name="status_id" value="{$status->status_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="STATUS EDIT.TITLE"}</legend>
            <div>
                <p>
                    <span class="bline">{_T string="STATUS EDIT.TEXT"}</span>
                    <input type="text" name="text" size="60" maxlength="100" value="{$status->status_text}" required>
                </p>
            </div>
            <div>
                <p>
                    <label for="is_home_location" class="bline tooltip_lend" title="{_T string="STATUS EDIT.HELP GALETTE LOCATION"}">
                        {_T string="STATUS EDIT.IS GALETTE LOCATION"}
                        <img src="picts/help.png"/>
                    </label>
                    <input type="checkbox" name="is_home_location" id="is_home_location" value="true"{if $status->is_home_location} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <label for="is_active" class="bline">{_T string="STATUS EDIT.IS ACTIVE"}</label>
                    <input type="checkbox" name="is_active" id="is_active" value="true"{if $status->is_active} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <label for="is_home_location" class="bline tooltip_lend" title="{_T string="STATUS EDIT.HELP RENT DAY NUMBER"}">
                        {_T string="STATUS EDIT.RENT DAY NUMBER"}
                        <img src="picts/help.png"/>
                    </label>
                    <input type="text" name="rent_day_number" size="5" maxlength="6" value="{$status->rent_day_number}">
                </p>
            </div>
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="btnsave" name="save" value="{_T string="Save"}">
        <a href="status_list.php?msg=canceled" class="button" id="btncancel">{_T string="Cancel"}</a>
    </div>
</form>
