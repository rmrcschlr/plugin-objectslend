<form action="admin_picture.php" method="post">
    <div class="button-container">
        <input type="submit" name="save_categories" id="save_categories" value="{_T string="ADMIN PICTURE.SAVE CATEGORIES"}">
        <input type="submit" name="save_objects" id="save_objects" value="{_T string="ADMIN PICTURE.SAVE OBJECTS"}">
        <input type="submit" name="restore_objects" id="restore_objects" value="{_T string="ADMIN PICTURE.RESTORE OBJECTS"}">
    </div>
</form>

{if isset($messages)}
    <ul>
        {foreach from=$messages item=msg}
            <li>
                {$msg}
            </li>
        {/foreach}
    </ul>
{/if}