<h1 class="nojs">
    {_T string="Objects lend" domain="objectslend"}
</h1>
{if $login->isLogged()}
<ul>
   <li{if $PAGENAME eq "objects_list.php" || $PAGENAME eq "take_object.php" || $PAGENAME eq "give_object_back.php"
        || $PAGENAME eq "give_more_objects_back.php" || $PAGENAME eq "take_more_objects_away.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}objects_list.php">
           {_T string="Objects list" domain="objectslend"}
       </a>
   </li>
    {if $login->isAdmin() || $login->isStaff()}
    <li{if $PAGENAME eq "objects_edit.php"} class="selected"{/if}>
            <a href="objects_edit.php">{_T string="Add an object" domain="objectslend"}</a>
    </li>
    <li{if $PAGENAME eq "status_list.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}status_list.php">{_T string="Borrow status" domain="objectslend"}</a>
    </li>
    <li{if $PAGENAME eq "status_edit.php"} class="selected"{/if}>
            <a href="status_edit.php">{_T string="Add a status" domain="objectslend"}</a>
    </li>
    <li{if $cur_route eq "objectslend_categories"} class="selected"{/if}>
        <a href="{path_for name="objectslend_categories"}">{_T string="Object categories" domain="objectslend"}</a>
    </li>
    <li{if $cur_route eq "objectslend_category"} class="selected"{/if}>
            <a href="{path_for name="objectslend_category" data=["action" => {_T string="add" domain="routes"}]}">{_T string="Add a category" domain="objectslend"}</a>
    </li>
    <li{if $cur_route eq "objectslend_preferences"} class="selected"{/if}>
        <a href="{path_for name="objectslend_preferences"}">{_T string="Preferences" domain="objectslend"}</a>
    </li>
    <li{if $cur_route eq "objectslend_adminimages"} class="selected"{/if}>
        <a href="{path_for name="objectslend_adminimages"}">{_T string="Pictures administration" domain="objectslend"}</a>
    </li>
    {/if}
</ul>
{/if}
