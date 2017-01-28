<form action="status_edit.php" method="post">
    <input type="hidden" name="status_id" value="{$status->status_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="Status"}</legend>
            <div>
                <p>
                    <span class="bline">{_T string="Status:"}</span>
                    <input type="text" name="text" size="60" maxlength="100" value="{$status->status_text}" required="required">
                </p>
            </div>
            <div>
                <p>
                    <label for="is_home_location" class="bline tooltip" title="{_T string="Is object at home or borrowed"}">
                        {_T string="At home:"}
                    </label>
                    <span class="tip">{_T string="Check if the object is available to be borrowed;<br/>uncheck if object is already borrowed and should be given back"}</span>
                    <input type="checkbox" name="is_home_location" id="is_home_location" value="true"{if $status->is_home_location} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <label for="is_active" class="bline">{_T string="Active:"}</label>
                    <input type="checkbox" name="is_active" id="is_active" value="true"{if $status->is_active} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <label for="is_home_location" class="bline tooltip" title="{_T string="Number of days to rent per default"}">
                        {_T string="Days for rent"}
                    </label>
                    <span class="tip">{_T string="Number of days to rent per default"}<br/>{_T string="used to compute return date"}</span>
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
