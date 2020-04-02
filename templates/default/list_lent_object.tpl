{extends file="page.tpl"}
{block name="content"}
{*debug*}
<form action="{path_for name="objectslend_object_action" data=["action" => $action, "id" => $object->object_id]}" method="post" enctype="multipart/form-data">
    <input type="hidden" name="object_id" value="{$object->object_id}">
    <div class="bigtable">
        <fieldset class="cssform">
            <legend class="ui-state-active ui-corner-top">{_T string="Object" domain="objectslend"}</legend>
            <p>
                <label for="rent_id" class="bline">{_T string="Object ID:" domain="objectslend"}</label>
                <input type="text" name="object_id" id="object_id" maxlength="20" size="20" value="{$object->object_id}">
            </p>
            <p>
                <label for="name" class="bline">{_T string="Name:" domain="objectslend"}</label>
                <input type="text" name="name" id="name" maxlength="20" size="20" value="{$object->name}">
            </p>
            <p>
                <label for="description" class="bline">{_T string="Description:" domain="objectslend"}</label>
                <input type="text" name="description" id="description" maxlength="20" size="20" value="{$object->description}">
            </p>
        </fieldset>
            <table class="listing">
                <thead>
                    <tr><center>
                        <th>{_T string="Id" domain="objectslend"}</th>
                        <th>{_T string="Status" domain="objectslend"}</th>
                        <th>{_T string="Begin date" domain="objectslend"}</th>
                        <th>{_T string="End date" domain="objectslend"}</th>
                        <th>{_T string="Return" domain="objectslend"}</th>
                        <th>{_T string="Name:" domain="objectslend"}</th>
                        <th>{_T string="Comments:" domain="objectslend"}</th>
                    </center></tr>
                </thead>
                <tbody>
{foreach $rents as $rent}
                    <tr>
                    <td><center>{$rent->rent_id}</center></td>
                    <td>{$rent->status_text}</td>
                    <td>{$rent->date_begin|date_format:_T("Y-m-d")}</td>
                    <td>{$rent->date_forecast|date_format:_T("Y-m-d")}</td>
                    <td>{$rent->date_end|date_format:_T("Y-m-d")}</td>
                    <td>{$rent->nom_adh} {$rent->prenom_adh}</td>
                    <td>{$rent->comments}</td>
                    </tr>
{/foreach}
                </tbody>
            </table>
        </fieldset>
    </div>
    <div class="button-container">
        <p>
            <a href="{path_for name="objectslend_objects"}" class="button">
                <i class="fas fa-th-list"></i> {_T string="Return" domain="objectslend"}
            </a>
        </p>
    </div>
</form>
{/block}

