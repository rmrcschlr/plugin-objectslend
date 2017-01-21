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
                    <label for="is_galette_location" class="bline tooltip" title="{_T string="STATUS EDIT.HELP GALETTE LOCATION"}">{_T string="STATUS EDIT.IS GALETTE LOCATION"}</label>
                    <span class="tip">{_T string="STATUS EDIT.HELP GALETTE LOCATION"}</span>
                    <input type="checkbox" name="is_galette_location" id="is_galette_location" value="true"{if $status->is_galette_location} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="STATUS EDIT.IS ACTIVE"}</span>
                    <input type="checkbox" name="is_active" value="true"{if $status->is_active} checked="checked"{/if}>
                </p>
            </div>
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="save" name="save" value="{_T string="STATUS EDIT.SAVE"}">
        <input type="submit" id="cancel" name="cancel" value="{_T string="STATUS EDIT.CANCEL"}" onclick="document.location = 'status_list.php?msg=canceled'; return false;">
    </div>
</form>