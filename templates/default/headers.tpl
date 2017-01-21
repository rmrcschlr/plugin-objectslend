<link rel="stylesheet" type="text/css" href="{$galette_base_path}{$lend_tpl_dir}galette_lend.css" media="screen"/>
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