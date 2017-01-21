{* Titre du bloc *}
<h1 class="nojs">
    {_T string="MENU.LEND"}
</h1>
{if $login->isLogged()}
{* Entrées du menu *}
<ul>
   <li{if $PAGENAME eq "objects_list.php" || $PAGENAME eq "objects_edit.php" 
        || $PAGENAME eq "take_object.php" || $PAGENAME eq "give_object_back.php" 
        || $PAGENAME eq "give_more_objects_back.php" || $PAGENAME eq "take_more_objects_away.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}objects_list.php">
           {_T string="MENU.OBJECTS LIST"}
       </a>
   </li>
{if $login->isAdmin() || $login->isStaff()}
   <li{if $PAGENAME eq "status_list.php" || $PAGENAME eq "status_edit.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}status_list.php">
           <img src="{$galette_base_path}{$lend_dir}picts/lock.png" alt="locked"/>
           {_T string="MENU.STATUS LIST"}
       </a>
   </li>
   <li{if $PAGENAME eq "categories_list.php" || $PAGENAME eq "category_edit.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}categories_list.php">
           <img src="{$galette_base_path}{$lend_dir}picts/lock.png" alt="locked"/> 
           {_T string="MENU.CATEGORIES LIST"}
       </a>
   </li>
   <li{if $PAGENAME eq "parameters.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}parameters.php">
           <img src="{$galette_base_path}{$lend_dir}picts/lock.png" alt="locked"/> 
           {_T string="MENU.PARAMETERS"}
       </a>
   </li>
   <li{if $PAGENAME eq "admin_picture.php"} class="selected"{/if}>
       <a href="{$galette_base_path}{$lend_dir}admin_picture.php">
           <img src="{$galette_base_path}{$lend_dir}picts/lock.png" alt="locked"/> 
           {_T string="MENU.ADMIN PICTURE"}
       </a>
   </li>
{/if}
</ul>
{/if}