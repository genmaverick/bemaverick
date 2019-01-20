module.exports = `
<link rel='stylesheet' id='metaslider-flex-slider-css' href='https://cms.genmaverick.com/wp-content/plugins/ml-slider/assets/sliders/flexslider/flexslider.css?ver=3.8.1' type='text/css' media='all' property='stylesheet'/>
<link rel='stylesheet' id='metaslider-public-css' href='https://cms.genmaverick.com/wp-content/plugins/ml-slider/assets/metaslider/public.css?ver=3.8.1' type='text/css' media='all' property='stylesheet'/>
<script type='text/javascript' src='https://cms.genmaverick.com/wp-includes/js/jquery/jquery.js,qver=1.12.4.pagespeed.jm.pPCPAKkkss.js'></script>
<script type='text/javascript' src='https://cms.genmaverick.com/wp-includes/js/jquery/jquery-migrate.min.js,qver=1.4.1.pagespeed.jm.C2obERNcWh.js'></script>
<script type='text/javascript' src='https://cms.genmaverick.com/wp-content/plugins/ml-slider/assets/sliders/flexslider/jquery.flexslider.min.js?ver=3.8.1'></script>
<script type='text/javascript'>
const init_metaslider = function ($) {
    $('.metaslider > div:first-child > div:first-child').each(function() {
        $(this).addClass('flexslider');
        $(this).flexslider({
            slideshowSpeed: 3000,
            animation: 'fade',
            controlNav: true,
            directionNav: true,
            pauseOnHover: true,
            direction: 'horizontal',
            reverse: false,
            animationSpeed: 600,
            prevText: 'Previous',
            nextText: 'Next',
            fadeFirstSlide: true,
            slideshow: true,
        });
    });
  };
  var timer_metaslider = function () {
    const slider = !window.jQuery
      ? window.setTimeout(timer_metaslider, 100)
      : !jQuery.isReady
        ? window.setTimeout(timer_metaslider, 1)
        : init_metaslider(window.jQuery);
  };
  timer_metaslider();
</script>
<!--<![endif]-->
`;
