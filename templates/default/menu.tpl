{* Titre du bloc *}
<h1 class="nojs">
    {_T string="Borrow"}
</h1>
{if $login->isLogged()}
{* Entrées du menu *}
<ul>
   <li{if $PAGENAME eq "objects_list.php" || $PAGENAME eq "take_object.php" || $PAGENAME eq "give_object_back.php"
        || $PAGENAME eq "give_more_objects_back.php" || $PAGENAME eq "take_more_objects_away.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}objects_list.php">
           {_T string="Objects list"}
       </a>
   </li>
    {if $login->isAdmin() || $login->isStaff()}
    <li{if $PAGENAME eq "objects_edit.php"} class="selected"{/if}>
            <a href="objects_edit.php">{_T string="Create a new object"}</a>
    </li>
    <li{if $PAGENAME eq "status_list.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}status_list.php">{_T string="Borrow status"}</a>
    </li>
    <li{if $PAGENAME eq "status_edit.php"} class="selected"{/if}>
            <a href="status_edit.php">{_T string="Create a new status"}</a>
    </li>
    <li{if $PAGENAME eq "categories_list.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}categories_list.php">{_T string="Object categories"}</a>
    </li>
    <li{if $PAGENAME eq "category_edit.php"} class="selected"{/if}>
            <a href="category_edit.php">{_T string="Create a new category"}</a>
    </li>
    <li{if $PAGENAME eq "preferences.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}preferences.php">{_T string="Preferences"}</a>
    </li>
    <li{if $PAGENAME eq "admin_picture.php"} class="selected"{/if}>
        <a href="{$galette_base_path}{$lend_dir}admin_picture.php">{_T string="Picture admin"}</a>
    </li>
    {/if}
</ul>
{/if}
