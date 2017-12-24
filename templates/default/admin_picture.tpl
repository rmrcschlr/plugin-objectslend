{extends file="page.tpl"}
{block name="content"}
<form action="{path_for name="objectslend_adminimages_action"}" method="post">
    <div class="button-container">
        <input type="submit" name="save_categories" class="button btnsave" value="{_T string="Backup categories pictures" domain="objectslend"}">
        <input type="submit" name="save_objects" class="button btnsave" value="{_T string="Backup objects pictures" domain="objectslend"}">
        <input type="submit" name="restore_objects" class="button btnrefresh" value="{_T string="Restore objects pictures from database" domain="objectslend"}">
        <input type="submit" name="restore_categories" class="button btnrefresh" value="{_T string="Restore categories pictures from database" domain="objectslend"}">
    </div>
</form>
{/block}
