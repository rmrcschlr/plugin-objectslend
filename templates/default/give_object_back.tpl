<form action="give_object_back.php" method="post">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="GIVE OBJECT BACK.TITLE"}</legend>
            <div>
                <p>
                    <img src="picture.php?object_id={$object->object_id}&thumb=1" class="picture" align="right" />
                    <span class="bline">{_T string="GIVE OBJECT BACK.NAME"}</span>
                    {$object->name}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.DESCRIPTION"}</span>
                    {$object->description}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.SERIAL"}</span>
                    {$object->serial_number}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.PRICE"}</span>
                    {$object->price}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.DIMENSION"}</span>
                    {$object->dimension}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.WEIGHT"}</span>
                    {$object->weight}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.STATUS"}</span>
                    <select name="status" id="status" onchange="validStatus()">
                        <option value="null">{_T string="GIVE OBJECT BACK.SELECT STATUS"}</option>
                        {foreach from=$statuses item=sta}
                            <option value="{$sta->status_id}">{$sta->status_text}</option>
                        {/foreach}
                    </select>
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.TIME"}</span>
                    {_T string="GIVE OBJECT BACK.FROM"}
                    {$last_rent->date_begin_short}
                    {_T string="GIVE OBJECT BACK.TO"}
                    {$today}
                </p>
            </div>
            <div>
                <p>
                    <span class="bline">{_T string="GIVE OBJECT BACK.COMMENTS"}</span>
                    <textarea name="comments" id="comments" onkeyup="countRemainting()" style="font-family: Cantarell,Verdana,sans-serif; font-size: 0.85em; width: 400px; height: 60px;"></textarea>
                    <br/><span id="remaining"></span>
                    {_T string="GIVE OBJECT BACK.REMAINING"}
                </p>
            </div>
        </fieldset>
    </div>
    <div class="button-container">
        <input type="submit" id="yes" name="yes" value="{_T string="GIVE OBJECT BACK.YES"}">
        <input type="submit" id="cancel" name="cancel" value="{_T string="GIVE OBJECT BACK.NO"}" onclick="document.location = 'objects_list.php?msg=canceled{if $object->category_id gt 0}&category_id={$object->category_id}{/if}'; return false;">
    </div>
</form>
<script>
    document.getElementById('yes').style.visibility = 'hidden';
    countRemainting();
    function validStatus() {
    var slct = document.getElementById('status');
    if (slct.options[slct.selectedIndex].value == 'null') {
    document.getElementById('yes').style.visibility = 'hidden';
} else {
document.getElementById('yes').style.visibility = 'visible';
}
}
function countRemainting() {
var txtar = document.getElementById('comments');
var sprem = document.getElementById('remaining');
if (txtar.value.length > 200) {
txtar.value = txtar.value.substr(0, 200);
}
sprem.innerHTML = (200 - txtar.value.length);
}
</script>
