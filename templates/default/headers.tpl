<link rel="stylesheet" type="text/css" href="{$galette_base_path}{$lend_tpl_dir}galette_lend.css" media="screen"/>
{if isset($olendsprefs) && $olendsprefs->showFullsize()}
<link rel="stylesheet" type="text/css" href="{$galette_base_path}{$lendc_dir}featherlight-1.7.0/featherlight.min.css" media="screen"/>
<script type="text/javascript" src="{$galette_base_path}{$lendc_dir}featherlight-1.7.0/featherlight.min.js"></script>
{/if}

<link rel="stylesheet" type="text/css" href="{$galette_base_path}{$lend_tpl_dir}tooltipster.css" />
<script type="text/javascript" src="{$galette_base_path}{$lend_tpl_dir}jquery.tooltipster.min.js"></script>
<script type="text/javascript" src="{$galette_base_path}{$lend_tpl_dir}lend.js"></script>
<script>
    $(document).ready(function() {
        $('.tooltip_lend').tooltipster({
                position: 'bottom-right',
                theme : '.tooltipster-lend'
            });
    });
</script>
