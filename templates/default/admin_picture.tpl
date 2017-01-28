<form action="admin_picture.php" method="post">
    <div class="button-container">
        <input type="submit" name="save_categories" class="button btnsave" value="{_T string="Backup categories pictures"}">
        <input type="submit" name="save_objects" class="button btnsave" value="{_T string="Backup objects pictures"}">
        <input type="submit" name="restore_objects" class="button btnrefresh" value="{_T string="Restore objects pictures from database"}">
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
