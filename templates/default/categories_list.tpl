{extends file="page.tpl"}
{block name="content"}
{*debug*}
<form id="filtre" method="POST" action="{path_for name="objectslend_filter_categories"}">
	<div id="listfilter">
		<label for="filter_str">{_T string="Search:" domain='objectslend'}&nbsp;</label>
		<input type="text" name="filter_str" id="filter_str" value="{$filters->filter_str}" type="search" placeholder="{_T string="Enter a value" domain='objectslend'}"/>&nbsp;
		{_T string="Active:" domain='objectslend'}
		<input type="radio" name="active_filter" id="filter_dc_active" value="{GaletteObjectsLend\Repository\Categories::ALL_CATEGORIES}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Categories::ALL_CATEGORIES')} checked="checked"{/if}>
		<label for="filter_dc_active" >{_T string="Don't care" domain='objectslend'}</label>
		<input type="radio" name="active_filter" id="filter_yes_active" value="{GaletteObjectsLend\Repository\Categories::ACTIVE_CATEGORIES}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Categories::ACTIVE_CATEGORIES')} checked="checked"{/if}>
		<label for="filter_yes_active" >{_T string="Yes" domain='objectslend'}</label>
		<input type="radio" name="active_filter" id="filter_no_active" value="{GaletteObjectsLend\Repository\Categories::INACTIVE_CATEGORIES}"{if $filters->active_filter eq constant('GaletteObjectsLend\Repository\Categories::INACTIVE_CATEGORIES')} checked="checked"{/if}>
		<label for="filter_no_active" >{_T string="No" domain='objectslend'}</label>
		<input type="submit" class="inline" value="{_T string="Filter"}"/>
		<input name="clear_filter" type="submit" value="{_T string="Clear filter" domain='objectslend'}">
	</div>
	<div class="infoline">
		<div class="fright">
			<label for="nbshow">{_T string="Records per page:"  domain='objectslend'}</label>
			<select name="nbshow" id="nbshow">
				{html_options options=$nbshow_options selected=$numrows}
			</select>
			<noscript> <span><input type="submit" value="{_T string="Change" domain='objectslend'}" /></span></noscript>
		</div>
	</div>
</form>
<table class="listing">
	<thead>
		<tr>
			<th class="id_row">&nbsp;</th>
			<th>
				<a href="{path_for name="objectslend_categories" data=["option" => {_T string='order' domain='objectslend'}, "value" => "GaletteObjectsLend\Repository\Categories::ORDERBY_NAME"|constant]}">
					{_T string="Name" domain='objectslend'}
					{if $filters->orderby eq constant('GaletteObjectsLend\Repository\Categories::ORDERBY_NAME')}
						{if $filters->ordered eq constant('GaletteObjectsLend\Filters\CategoriesList::ORDER_ASC')}
					<img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt=""/>
						{else}
					<img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt=""/>
						{/if}
					{/if}
				</a>
			</th>
			<th class="id_row">
				{_T string="Active" domain='objectslend'}
			</th>
			<th class="actions_row">
				{_T string="Actions" domain='objectslend'}
			</th>
		</tr>
	</thead>
	<tbody>
{foreach from=$categories item=categ}
			<tr class="{if $categ@index is odd}even{else}odd{/if}">
				<td>
					{$categ->category_id}
				</td>
				<td>
	{if $olendsprefs->imagesInLists()}

						<img src="{path_for name="objectslend_photo" data=["type" => "category", "mode" => "thumbnail", "id" => $categ->category_id]}"
							class="picture"
							width="{$categ->picture->getOptimalThumbWidth($olendsprefs)}"
							height="{$categ->picture->getOptimalThumbHeight($olendsprefs)}"
							alt=""/>
	{/if}
					{$categ->name}
				</td>
				<td class="center {if $categ->is_active}use{else}delete{/if}">
					<i class="fas fa-thumbs-{if $categ->is_active}up{else}down{/if}"></i>
					<span class="sr-only">{_T string="Active"  domain='objectslend'}</span>
				</td>
	{if $login->isAdmin() || $login->isStaff()}
					<td>
						<a class="tooltip action "
							href="{path_for name="objectslend_category" data=["action" => "edit", "id" => $categ->category_id]}"
							title="{_T string="Edit the Category" domain='objectslend'}">
							<i class="fas fa-edit"></i>
							<span class="sr-only">{_T string="Edit the object" domain='objectslend'}</span>
						</a>

		{if $login->isAdmin()}
							<a class="tooltip remove "
								href="{path_for name="objectslend_remove_category" data=["action" => "remove","id" => $categ->category_id]}"
								title="{_T string="Remove the Category" domain='objectslend' }">
								<i class="fas fa-trash"></i>
								<span class="sr-only">{_T string="Remove the Category" domain='objectslend'}</span>
							</a>
		{/if}
					</td>
	{/if}

			</tr>
{/foreach}
	</tbody>
	<tfoot>
		<tr>
			<td colspan="4" class="center">
				{_T string="Pages:" domain='objectslend'}<br/>
				<ul class="pages">{$pagination}</ul>
			</td>
		</tr>
	</tfoot>
</table>
{/block}

{block name="javascripts"}
<script type="text/javascript">
	$(function(){
		{include file="js_removal.tpl"}
		$('#nbshow').change(function() {
			this.form.submit();
		});
	});
</script>
{/block}
