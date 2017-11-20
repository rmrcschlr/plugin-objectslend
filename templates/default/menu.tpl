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
    <li{if $PAGENAME eq "categories_list.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}categories_list.php">{_T string="Object categories" domain="objectslend"}</a>
    </li>
    <li{if $PAGENAME eq "category_edit.php"} class="selected"{/if}>
            <a href="category_edit.php">{_T string="Add a category" domain="objectslend"}</a>
    </li>
    <li{if $cur_route eq "objectslend_preferences"} class="selected"{/if}>
        <a href="{path_for name="objectslend_preferences"}">{_T string="Preferences" domain="objectslend"}</a>
    </li>
    <li{if $PAGENAME eq "admin_picture.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}admin_picture.php">{_T string="Pictures administration" domain="objectslend"}</a>
    </li>
    {/if}
</ul>
{/if}
