{extends file="page.tpl"}
{block name="content"}
{*debug*}
<div id="lend_content">
    <form id="filtre" method="POST" action='{path_for name="objectslend_filter_objects"}' data=["type" => "list"]}" method="POST" id="filtre">
        <div id="listfilter">
            <label for="filter_str">{_T string='Search:' domain='objectslend'}&nbsp;</label>
            <input type="text" name="filter_str" id="filter_str" value="{$filters->filter_str}" type="search" placeholder="{_T string='Enter a value' domain='objectslend'}"/>&nbsp;
            <label for="field_filter"> {_T string='in:' domain='objectslend'}&nbsp;</label>
            <select name="field_filter" id="field_filter" onchange="form.submit()">
                {html_options options=$field_filter_options selected=$filters->field_filter}
            </select>
{if $login->isAdmin() or $login->isStaff()}
			{_T string='Active:' domain='objectslend'}
			<input type="radio" name="active_filter" id="filter_dc_active" value="{GaletteObjectsLend\Repository\Objects::ALL_OBJECTS}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Objects::ALL_OBJECTS')} checked="checked"{/if}>
			<label for="filter_dc_active" >{_T string='Do not care' domain='objectslend'}</label>
			<input type="radio" name="active_filter" id="filter_yes_active" value="{GaletteObjectsLend\Repository\Objects::ACTIVE_OBJECTS}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Objects::ACTIVE_OBJECTS')} checked="checked"{/if}>
			<label for="filter_yes_active" >{_T string='Yes' domain='objectslend'}</label>
			<input type="radio" name="active_filter" id="filter_no_active" value="{GaletteObjectsLend\Repository\Objects::INACTIVE_OBJECTS}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Objects::INACTIVE_OBJECTS')} checked="checked"{/if}>
			<label for="filter_no_active" >{_T string='No' domain='objectslend'}</label>
{/if}
            <input type="submit" class="inline" value="{_T string='Filter' domain='objectslend'}"/>
            <input name="clear_filter" type="submit" value="{_T string='Clear filter' domain='objectslend'}">
        </div>
        <div class="infoline">
            {$nb_objects} {if $nb_objects gt 1}{_T string='objects' domain='objectslend'}{else}{_T string='object' domain='objectslend'}{/if}
            <div class="fright">
                <label for="nbshow">{_T string='Records per page:' domain='objectslend'}</label>
                <select name="nbshow" id="nbshow">
                    {html_options options=$nbshow_options selected=$numrows}
                </select>
                <noscript> <span>
					<input type="submit" value="{_T string='Change' domain='objectslend'}" />
					</span></noscript>
            </div>
        </div>
    </form>
{if $lendsprefs.VIEW_CATEGORY }
        <section id="categories">
		<header class="ui-state-default ui-state-active">
			{_T string='Categories' domain='objectslend'}
		</header>
		<div>
			<a href="{path_for name="objectslend_objects" data=["option" => 'category' , "value" => 0]}"{if $filters->category_filter eq null} class="active"{/if}>
				<img src="{path_for name="objectslend_photo" data=["type" => "category" , "mode" => "thumbnail" , "id" => 0]}"
					class="picture"
					alt=""/>
				<br/>
				{_T string='All' domain='objectslend'}
			</a>
	{foreach from=$categories item=categ}
		{if $categ->is_active || $categ->category_id eq -1}
			<a href="{path_for name="objectslend_objects" data=["option" => 'category' , "value" => $categ->category_id]}"{if $filters->category_filter eq $categ->category_id} class="active"{/if}>
				<img src="{path_for name="objectslend_photo" data=["type" => "category" , "mode" => "thumbnail" , "id" => $categ->category_id]}"
					class="picture"
					width="{$categ->picture->getOptimalThumbWidth($olendsprefs)}"
					height="{$categ->picture->getOptimalThumbHeight($olendsprefs)}"
					alt=""/>
				<br/>
				{$categ->getName()}
			{if $lendsprefs.VIEW_LIST_PRICE_SUM && $lendsprefs.VIEW_PRICE && ($login->isAdmin() || $login->isStaff())}
				&middot;
				{$categ->objects_price_sum} &euro;
				{if $categ->is_active}
					<span class="use tooltip" title="{_T string='Category is active' domain='objectslend'}">
						<i class="fas fa-thumb-s-up"></i>
						<span class="sr-only">{_T string='Active' domain='objectslend'}</span>
					</span>
				{/if}
			{/if}
			</a>
		{/if}
	{/foreach}
            </div>
        </section>
{/if}

	<form action="{path_for name="objectslend_batch-objectslist"}" method="post" id="objects_list">
		<table class="listing">
			<thead>
				<tr>
{if $login->isAdmin() || $login->isStaff()}
				<th  class="id_row">#</th>
{/if}
{if $olendsprefs->imagesInLists()}
				<th class="id_row">
					{_T string='Picture' domain='objectslend'}
				</th>
{/if}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_NAME"|constant]}">
						{_T string='Name' domain='objectslend'}
{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_NAME')}
	{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
	{else}
						<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
	{/if}
{/if}
					</a>
				</th>
{if $lendsprefs.VIEW_SERIAL}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_SERIAL"|constant]}">
						{_T string='Serial' domain='objectslend'}
	{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_SERIAL')}
		{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png"/>
		{else}
						<img src="{base_url}/{$template_subdir}images/up.png"/>
		{/if}
	{/if}
					</a>
				</th>
{/if}
{if $lendsprefs.VIEW_PRICE}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_PRICE"|constant]}">
						{_T string='Price' domain='objectslend'}
	{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_PRICE')}
		{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
		{else}
						<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
		{/if}
	/if}
					</a>
				</th>
{/if}
{if $lendsprefs.VIEW_LEND_PRICE}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_RENTPRICE"|constant]}">
						{_T string='Borrow price' domain='objectslend'}
	{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_RENTPRICE')}
		{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
								<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
		{else}
								<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
		{/if}
	{/if}
					</a>
				</th>
{/if}
{if $lendsprefs.VIEW_DIMENSION}
				<th>
					{_T string='Dimensions' domain='objectslend'}
				</th>
{/if}
{if $lendsprefs.VIEW_WEIGHT}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_WEIGHT"|constant]}">
						{_T string='Weight' domain='objectslend'}
	{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_WEIGHT')}
		{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
		{else}
						<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
		{/if}
	{/if}
					</a>
				</th>
{/if}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_STATUS"|constant]}">
						{_T string='Status' domain='objectslend'}
{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_STATUS')}
	{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
	{else}
						<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
	{/if}
{/if}
					</a>
				</th>
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_BDATE"|constant]}">
						{_T string='Since' domain='objectslend'}
{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_BDATE')}
	{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
	{else}
						<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
	{/if}
{/if}
					</a>
				</th>
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_MEMBER"|constant]}">
						{_T string='By' domain='objectslend'}
{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_MEMBER')}
	{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
	{else}
						<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
	{/if}
{/if}
					</a>
				</th>
{if $lendsprefs.VIEW_DATE_FORECAST}
				<th>
					<a href="{path_for name="objectslend_objects" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Objects::ORDERBY_FDATE"|constant]}">
						{_T string='Return' domain='objectslend'}
	{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Objects::ORDERBY_FDATE')}
		{if $filters->ordered eq constant('GaletteObjectsLend\Filters\ObjectsList::ORDER_ASC')}
						<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
		{else}
						<img src="{{base_url}/$template_subdir}images/up.png" width="10" height="6" alt=""/>
		{/if}
	{/if}
					</a>

				</th>
{/if}
{if $login->isAdmin() || $login->isStaff()}
				<th class="id_row">
					{_T string='Active' domain='objectslend'}
				</th>
{/if}
				<th class="actions_row">
					{_T string='Actions' domain='objectslend'}
				</th>
				</tr>
			</thead>
		<tbody>
	{foreach from=$objects item=object}

			<tr class="{if $object@index is odd}even{else}odd{/if}">
		{if $login->isAdmin() || $login->isStaff()}
					<td class="center">
						<input type="checkbox" name="object_ids[]" value="{$object->object_id}">
					</td>
		{/if}
		{if $olendsprefs->imagesInLists()}
					<td class="center">
						<img src="{path_for name="objectslend_photo" data=["type" => "object" , "mode" => "thumbnail" , "id" => $object->object_id]}"
							class="picture"
							width="{$object->picture->getOptimalThumbWidth($olendsprefs)}"
							height="{$object->picture->getOptimalThumbHeight($olendsprefs)}"
							alt="{_T string='Object photo' domain='objectslend'}"/>
					</td>
		{/if}
					<td>
						<strong>{$object->displayName($filters)}</strong>
		{if $lendsprefs.VIEW_DESCRIPTION}
						<br/>{$object->displayDescription($filters)}
		{/if}
					</td>
		{if $lendsprefs.VIEW_SERIAL}
					<td>
						{$object->displaySerial($filters)}
					</td>
		{/if}
		{if $lendsprefs.VIEW_PRICE}
					<td class="right nowrap">
						{$object->price}&euro;
					</td>
		{/if}
		{if $lendsprefs.VIEW_LEND_PRICE}
					<td class="right">
						{$object->rent_price}&euro;{if $object->price_per_day}<br/>{_T string='(per day)' domain='objectslend'}{/if}
					</td>
		{/if}
		{if $lendsprefs.VIEW_DIMENSION}
					<td>
						{$object->displayDimension($filters)}
					</td>
		{/if}
		{if $lendsprefs.VIEW_WEIGHT}
					<td>
						{$object->weight}
					</td>
		{/if}
					<td>
		{if $object->status_text}
						{$object->status_text}
		{else}
						-
		{/if}
					</td>
					<td class="center nowrap">
		{if !$object->date_end}
			{if $object->date_begin}
				{if !$object->rent_id or $object->is_home_location}
						-
				{else}
						{$object->date_begin|date_format:_T("Y-m-d")}
				{/if}
			{else}
						-
			{/if}
		{else}
						-
		{/if}
					</td>
					<td>
		{if $object->id_adh}
			{if !$object->rent_id or $object->is_home_location}
						-
			{else}
						<a href="{path_for name="member" data=["id" => $object->id_adh]}">{memberName id=$object->id_adh}</a>
			{/if}
		{else}
						-
		{/if}
					</td>
		{if $lendsprefs.VIEW_DATE_FORECAST}
					<td class="center nowrap">
			{if !$object->date_end}
				{if $object->date_forecast}
						{$object->date_forecast|date_format:_T("Y-m-d")}
				{else}
						-
				{/if}
			{else}
						-
			{/if}
					</td>
		{/if}
					<td class="center {if $object->is_active}use{else}delete{/if}">
						<i class="fas fa-thumbs-{if $object->is_active}up{else}down{/if}" title="{if $object->is_active}{_T string='Object is active' domain='objectslend'}{else}{_T string='Object is inactive' domain='objectslend'}{/if}"></i>
						<span class="sr-only">{_T string='Active' domain='objectslend'}</span>
		{if $object->isActive()}
						<img src="{base_url}/{$template_subdir}images/icon-on.png" alt=""/>
		{/if}
					</td>
					<td class="center nowrap">
		{if !$object->rent_id or $object->is_home_location}
			{if $lendsprefs.ENABLE_MEMBER_RENT_OBJECT || $login->isAdmin() || $login->isStaff()}
						<a class="tooltip action"
							href="{path_for name="objectslend_object" data=["action" => "take_object", "id" => $object->object_id]}"
							title="{_T string='Take object away' domain='objectslend'}">
							<i class="fas fa-cart-arrow-down"></i>
							<span class="sr-only">{_T string='Take away' domain='objectslend'}</span>
						</a>
			{/if}
		{elseif $login->isAdmin() || $login->isStaff() || $login->id == $object->id_adh}
						<a class="tooltip action"
							href="{path_for name="objectslend_object" data=["action" => "give_object_back", "id" => $object->object_id]}"
							title="{_T string='Give object back' domain='objectslend'}">
							<i class="fas fa-sign-in-alt"></i>
							<span class="sr-only">{_T string='Give back' domain='objectslend'}</span>
						</a>
		{/if}

		{if $login->isAdmin() || $login->isStaff()}
						<a class="tooltip action"
							href="{path_for name="objectslend_object" data=["action" => "edit", "id" => $object->object_id]}"
							title="{_T string='Edit the object' domain='objectslend'}">
							<i class="fas fa-edit"></i>
							<span class="sr-only">{_T string='Edit the object' domain='objectslend'}</span>
						</a>
						<a class="tooltip"
							href="{path_for name="objectslend_object_clone" data=["id" => $object->object_id]}"
							title="{_T string='Duplicate object' domain='objectslend'}">
							<i class="fas fa-clone"></i>
							<span class="sr-only">{_T string='Duplicate object' domain='objectslend'}</span>
						</a>
						<a class="tooltip true"
							href="{path_for name="objectslend_show_object_lend" data=["id" => $object->object_id]}"
							title="{_T string='Show object lents' domain='objectslend'}">
							<i class="far fa-file-alt"></i>
							<span class="sr-only">{_T string='Show object' domain='objectslend'}</span>
						</a>
						<a class="tooltip"
							href="{path_for name="objectslend_objects_printobject" data=["id" => $object->object_id]}"
							title="{_T string='Object card in PDF' domain='objectslend'}">
							<i class="fas fa-file-pdf"></i>
							<span class="sr-only">{_T string='Object card in PDF' domain='objectslend'}</span>
						</a>
						<a class="delete tooltip"
							href="{path_for name="objectslend_remove_object" data=["id" => $object->object_id]}"
							title="{_T string='Remove %object from database' domain='objectslend' pattern="/%object/" replace=$object->name}">
							<i class="fas fa-trash"></i>
							<span class="sr-only">{_T string='Remove %object from database' domain='objectslend' pattern="/%object/" replace=$object->name}</span>
						</a>
		{/if}
					</td>

				</tr>
	{foreachelse}
					{* FIXME: calculate colspan *}
					<tr><td colspan="14" class="emptylist">{_T string='No object has been found' domain='objectslend'}</td></tr>
	{/foreach}
			</tbody>
	{if $nb_objects != 0}
			<tfoot>
				<tr>
					<td colspan="14" id="table_footer">
						<ul class="selection_menu">
							<li>{_T string='For the selection:' domain='objectslend'}</li>
							<li>
								<button type="submit" name="print_list" class="tooltip use">
									<i class="fas fa-file-pdf"></i>
									{_T string='Print objects list' domain='objectslend'}
								</button>
							</li>
		{if $login->isAdmin() || $login->isStaff()}
							<li>

								<button type="submit" name="print_objects" class="tooltip use">
									<i class="fas fa-file-pdf"></i>
									{_T string='Print objects cards' domain='objectslend'}
								</button>
							</li>
							<li>
								<button type="submit" name="TakeAway" class="tooltip action">
									<i class="fas fa-cart-arrow-down"></i>
									{_T string='Take away' domain='objectslend'}
								</button>
							</li>
							  <li>
								<button type="submit" name="GiveBack" class="tooltip action">
									<i class="fas fa-sign-in-alt"></i>
									{_T string='Give back' domain='objectslend'}
								</button>
							</li>
							<li>
								 <button type="submit" name="Disable" class="tooltip  delete">
									<i class="fas fa-check-square" ></i>
									{_T string='Disable' domain='objectslend'}
								</button>

							</li>
							 <li>
								 <button type="submit" name="Enable" class="tooltip true">
									<i class="fas fa-check-square" ></i>
									{_T string='Activate' domain='objectslend'}
								</button>

							</li>
							<li>
								<button type="submit" name="Delete" class="tooltip  delete">
									<i class="fas fa-trash" ></i>
									{_T string='Delete' domain='objectslend'}
								</button>
							</li>
		{/if}
						</ul>
					</td>
				</tr>
				<tr>
					<td colspan="14" class="center">
						{_T string='Pages:' domain='objectslend'}<br/>
						<ul class="pages">{$pagination}</ul>
					</td>
				</tr>
			</tfoot>
	{/if}
{/if}
		</table>
    </form>
</div>
{/block}

{block name="javascripts"}
 <script type="text/javascript">
            $(function(){
                $('#nbshow').change(function() {
                    this.form.submit();
                });
            });
</script>
<script type="text/javascript" src="../../webroot/lend.js"></script>
<script type="text/javascript">

{if $nb_objects != 0}
        var _is_checked = true;
        var _bind_check = function(){
            $('#checkall').click(function(){
                $('table.listing :checkbox[name="object_ids[]"]').each(function(){
                    this.checked = _is_checked;
                });
                _is_checked = !_is_checked;
                return false;
            });
            $('#checkinvert').click(function(){
                $('table.listing :checkbox[name="object_ids[]"]').each(function(){
                    this.checked = !$(this).is(':checked');
                });
                return false;
            });
        }

        {* Use of Javascript to draw specific elements that are not relevant is JS is inactive *}
        $(function(){
			$('#table_footer').parent().before('<tr><td id="checkboxes" colspan="4"><span class="fleft"><a href="#" id="checkall">{_T string='(Un)Check all' domain='objectslend'}</a> | <a href="#" id="checkinvert">{_T string='Invert selection'}</a></span></td></tr>');
            _bind_check();


            {* No legend?
            $('#checkboxes').after('<td class="right" colspan="3"><a href="#" id="show_legend">{_T string='Show legend' domain='objectslend'}</a></td>');
            $('#legende h1').remove();
            $('#legende').dialog({
                autoOpen: false,
                modal: true,
                hide: 'fold',
                width: '40%'
            }).dialog('close');

            $('#show_legend').click(function(){
                $('#legende').dialog('open');
                return false;
            });*}
            $('.selection_menu input[type="submit"], .selection_menu input[type="button"]').click(function(){
                if ( this.id == 'delete' ) {
                    //mass removal is handled from 2 steps removal
                    return;
                }
                return _checkselection();
            });
        });

	{if $login->isAdmin() || $login->isStaff()}
				var _checkselection = function() {
					var _checkeds = $('table.listing').find('input[type=checkbox]:checked').length;
					if ( _checkeds == 0 ) {
						var _el = $("
							<div id='pleaseselect' title="{_T string='No object selected' domain='objectslend' escape='js'}">
								{_T string='Please make sure to select at least one object from the list to perform this action.' domain='objectslend' escape='js'}
							</div>
						");
						_el.appendTo('body').dialog({
							modal: true,
							buttons: {
								Ok: function() {
									$(this).dialog( "close" );
								}Glog2
							},
							close: function(event, ui){
								_el.remove();
							}
						});
						return false;
					} else {
						return true;
				}
	{/if}
{/if}



</script>
{/block}
