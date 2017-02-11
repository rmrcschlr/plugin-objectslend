<link rel="stylesheet" type="text/css" href="{$galette_base_path}{$lend_tpl_dir}galette_lend.css" media="screen"/>
{if isset($olendsprefs) && $olendsprefs->showFullsize()}
<link rel="stylesheet" type="text/css" href="{$galette_base_path}{$lendc_dir}featherlight-1.7.0/featherlight.min.css" media="screen"/>
<script type="text/javascript" src="{$galette_base_path}{$lendc_dir}featherlight-1.7.0/featherlight.min.js"></script>
<script type="text/javascript">
    var _init_fullimage = function() {
        $('.picture').featherlight({
            targetAttr: 'data-fullsrc',
            type: 'image',
            beforeOpen: function(p) {
                var _img = $(p.currentTarget);
                _img.attr('data-fullsrc', _img.attr('src').replace(/&thumb=1/, ''));
            }
        }).css('cursor', 'pointer').attr('title', '{_T string="Click to view fullsize image" escape="js"}');
    }

    $(function(){
        _init_fullimage();
    });
</script>
{/if}
<script type="text/javascript" src="{$galette_base_path}{$lend_tpl_dir}lend.js"></script>
