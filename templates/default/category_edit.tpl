<form action="category_edit.php" method="post" enctype="multipart/form-data">
    <input type="hidden" name="category_id" value="{$category->category_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="CATEGORY EDIT.TITLE"}</legend>
            <div>
                <p>
                    <span class="bline">{_T string="CATEGORY EDIT.NAME"}</span>
                    <input type="text" name="name" size="60" maxlength="100" value="{$category->name}" required>
                </p>
            </div>            
            <div>
                <p>
                    <span class="bline">{_T string="CATEGORY EDIT.IS ACTIVE"}</span>
                    <input type="checkbox" name="is_active" value="true"{if $category->is_active} checked="checked"{/if}>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="CATEGORY EDIT.PICTURE"}</span>
                    <input type="file" name="picture">
                    <br/>
                    <img src="picts/help.png">
                    {_T string="OBJECT EDIT.HELP UPLOAD PICTURE"}
            {if $category->category_id ne ''}
                    <br/>
                    <input type="checkbox" name="del_picture" id="del_picture" value="1"/><span class="labelalign"><label for="del_picture">{_T string="CATEGORY EDIT.DELETE PICTURE"}</label></span><br/>
            {/if}   
                </p>
            </div>
            {if $category->category_id ne ''}
                <div> 
                    <p>
                        <span class="bline">{_T string="CATEGORY EDIT.THUMB"}</span>
                        <img src="picture.php?category_id={$category->category_id}&thumb=1" class="picture" />
                    </p>
                </div>
            {/if}   
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="save" name="save" value="{_T string="CATEGORY EDIT.SAVE"}">
        <input type="submit" id="cancel" name="cancel" value="{_T string="CATEGORY EDIT.CANCEL"}" onclick="document.location = 'categories_list.php?msg=canceled'; return false;">
    </div>
</form>