<?php
/*
Plugin Name: WP FAQ
Plugin URL: http://wponlinesupport.com
Description: A simple FAQ plugin created with WordPress custom post type.
Text Domain: sp-faq
Domain Path: /languages/
Version: 3.2.6
Author: WP Online Support
Author URI: http://wponlinesupport.com
Contributors: WP Online Support
*/

if( !defined( 'SP_FAQ_VERSION' ) ) {
	define( 'SP_FAQ_VERSION', '3.2.6' ); // Version of plugin
}
if( !defined( 'SP_FAQ_DIR' ) ) {
	define( 'SP_FAQ_DIR', dirname( __FILE__ ) ); // Plugin dir
}
if( !defined( 'SP_FAQ_POST_TYPE' ) ) {
	define( 'SP_FAQ_POST_TYPE', 'sp_faq' ); // Plugin post type
}

/**
 * Function to load text domain
 * 
 * @package WP FAQ
 * @since 3.2.5
 */ 
add_action('plugins_loaded', 'sp_faq_load_textdomain');
function sp_faq_load_textdomain() {
	load_plugin_textdomain( 'sp-faq', false, dirname( plugin_basename(__FILE__) ) . '/languages/' );
} 

/**
 * Activation Hook
 * 
 * Register plugin activation hook.
 * 
 * @package WP FAQ
 * @since 3.2.5
 */
register_activation_hook( __FILE__, 'install_premium_version_faq' );

/**
 * Plugin Setup (On Activation)
 * 
 * Does the initial setup,
 * 
 * @package WP FAQ
 * @since 3.2.5
 */
function install_premium_version_faq(){
	if( is_plugin_active('wp-faq-pro/faq.php') ){
     add_action('update_option_active_plugins', 'deactivate_premium_version_faq');
    }
}

/**
 * Deactivate pro plugin
 * 
 * @package WP FAQ
 * @since 3.2.5
 */
function deactivate_premium_version_faq(){
   deactivate_plugins('wp-faq-pro/faq.php',true);
}

// Action to add admin notice
add_action( 'admin_notices', 'rpfs_admin_notice_faq' );

/**
 * Admin notice
 * 
 * @package WP FAQ
 * @since 3.2.5
 */
function rpfs_admin_notice_faq() {
	
	global $pagenow;

    // If PRO plugin is active and free plugin exist
    $dir                = WP_PLUGIN_DIR . '/wp-faq-pro/faq.php';
    $notice_link        = add_query_arg( array('message' => 'sp-faq-plugin-notice'), admin_url('plugins.php') );
    $notice_transient   = get_transient( 'sp_faq_install_notice' );

    if ( $notice_transient == false &&  $pagenow == 'plugins.php' && file_exists($dir) && current_user_can( 'install_plugins' ) ) {
        echo '<div class="updated notice" style="position:relative;">
                <p>
                    <strong>'.sprintf( __('Thank you for activating %s', 'sp-faq'), 'WP FAQ').'</strong>.<br/>
                    '.sprintf( __('It looks like you had PRO version %s of this plugin activated. To avoid conflicts the extra version has been deactivated and we recommend you delete it.', 'sp-faq'), '<strong>(<em>WP FAQ PRO</em>)</strong>' ).'
                </p>
                <a href="'.esc_url( $notice_link ).'" class="notice-dismiss" style="text-decoration:none;"></a>
            </div>';      
    }
}

function sp_faq_setup_post_types() {
	$festivals_labels =  apply_filters( 'sp_faq_labels', array(
		'name'                 => _x('FAQs', 'sp-faq'),
		'singular_name'        => _x('FAQ', 'sp-faq'),
		'add_new'              => _x('Add New', 'sp-faq'),
		'add_new_item'        => __('Add New FAQ', 'sp-faq'),
		'edit_item'           => __('Edit FAQ', 'sp-faq'),
		'new_item'            => __('New FAQ', 'sp-faq'),
		'all_items'           => __('All FAQ', 'sp-faq'),
		'view_item'           => __('View FAQ', 'sp-faq'),
		'search_items'        => __('Search FAQ', 'sp-faq'),
		'not_found'           => __('No FAQ found', 'sp-faq'),
		'not_found_in_trash'  => __('No FAQ found in Trash', 'sp-faq'),
		'parent_item_colon'   => '',
		'menu_name'           => __('FAQ', 'sp-faq'),
		'exclude_from_search' => true
	) );
	$faq_args = array(
		'labels' 			=> $festivals_labels,
		'public' 			=> true,
		'publicly_queryable'=> true,
		'show_ui' 			=> true,
		'show_in_menu' 		=> true,
		'query_var' 		=> true,
		'capability_type' 	=> 'post',
		'has_archive' 		=> true,
		'hierarchical' 		=> false,
		'menu_icon'   => 'dashicons-info',
		'supports' => array('title','editor','thumbnail','excerpt')
	);
	register_post_type( 'sp_faq', apply_filters( 'sp_faq_post_type_args', $faq_args ) );
}
add_action('init', 'sp_faq_setup_post_types');

/*
 * Add [sp_faq limit="-1"] shortcode
 *
 */
function sp_faq_shortcode( $atts, $content = null ) {
	extract(shortcode_atts(array(
		"limit" => '',
		"category" => '',
		"single_open"   => '',
		"transition_speed" => '',
	), $atts));
	// Define limit
	if( $limit ) { 
		$posts_per_page = $limit; 
	} else {
		$posts_per_page = '-1';
	}
	// Define limit
	if( $category ) { 
		$cat = $category; 
	} else {
		$cat = '';
	}
	
	if( $single_open != ''  ) { 
		$faqsingleOpen = $single_open; 
	} else {
		$faqsingleOpen = 'true';
	}
	
	if( $transition_speed != '' ) { 
		$faqtransitionSpeed = $transition_speed; 
	} else {
		$faqtransitionSpeed = '300';
	}
	
	ob_start();
	// Create the Query
	
	$post_type 		= 'sp_faq';
	$orderby 		= 'post_date';
	$order 			= 'DESC';
				 
        $args = array ( 
            'post_type'      => $post_type, 
            'orderby'        => $orderby, 
            'order'          => $order,
            'posts_per_page' => $posts_per_page,           
            );
	if($cat != ""){
            	$args['tax_query'] = array( array( 'taxonomy' => 'faq_cat', 'field' => 'term_id', 'terms' => $cat) );
            }        
      $query = new WP_Query($args);
	//Get post type count
	$post_count = $query->post_count;
	$i = 1;
	// Displays Custom post info
	if( $post_count > 0) :
	?>
	<div class="faq-accordion" data-accordion-group>	
	
	<?php while ($query->have_posts()) : $query->the_post();
		?>			  
      <div data-accordion class="faq-main">
        <div data-control class="faq-title"><h4> <?php the_title(); ?></h4></div>
        <div data-content>
         <?php
          if ( function_exists('has_post_thumbnail') && has_post_thumbnail() ) { 
		  
            the_post_thumbnail('thumbnail'); 
          }
          ?>
        <div class="faq-content"><?php the_content(); ?></div>
        </div>
      </div>
	<?php
	$i++;
	endwhile; ?>
	</div>
	<?php	endif;
	// Reset query to prevent conflicts
	wp_reset_query();
	?>
	    <script type="text/javascript">
      jQuery(document).ready(function() {
        jQuery('.faq-accordion [data-accordion]').accordionfaq({
		 singleOpen: <?php echo $faqsingleOpen; ?>,
		 transitionEasing: 'ease',
          transitionSpeed: <?php echo $faqtransitionSpeed; ?>
		});        
      });
    </script>
	<?php
	return ob_get_clean();
}
add_shortcode("sp_faq", "sp_faq_shortcode");

/* Register Taxonomy */
add_action( 'init', 'free_sp_faq_taxonomies');
function free_sp_faq_taxonomies() {
    $labels = array(
        'name'              => _x( 'Category', 'sp-faq' ),
        'singular_name'     => _x( 'Category', 'sp-faq' ),
        'search_items'      => __( 'Search Category', 'sp-faq' ),
        'all_items'         => __( 'All Category', 'sp-faq' ),
        'parent_item'       => __( 'Parent Category', 'sp-faq' ),
        'parent_item_colon' => __( 'Parent Category' , 'sp-faq' ),
        'edit_item'         => __( 'Edit Category', 'sp-faq' ),
        'update_item'       => __( 'Update Category', 'sp-faq' ),
        'add_new_item'      => __( 'Add New Category', 'sp-faq' ),
        'new_item_name'     => __( 'New Category Name', 'sp-faq' ),
        'menu_name'         => __( 'FAQ Category', 'sp-faq' ),
    );

    $args = array(
        'hierarchical'      => true,
        'labels'            => $labels,
        'show_ui'           => true,
        'show_admin_column' => true,
        'query_var'         => true,
        'rewrite'           => array( 'slug' => 'faq_cat' ),
    );

    register_taxonomy( 'faq_cat', array( 'sp_faq' ), $args );
}


add_action( 'wp_enqueue_scripts','style_css_script_free' );
function style_css_script_free() {
    wp_enqueue_style( 'accordioncssfree',  plugin_dir_url( __FILE__ ). 'css/jquery.accordion.css', array(), SP_FAQ_VERSION );
    wp_enqueue_script( 'accordionjsfree', plugin_dir_url( __FILE__ ) . 'js/jquery.accordion.js', array( 'jquery' ), SP_FAQ_VERSION );
}

// How it work file, Load admin files
if ( is_admin() || ( defined( 'WP_CLI' ) && WP_CLI ) ) {
    require_once( SP_FAQ_DIR . '/admin/spfaq-how-it-work.php' );
}

// Admin Class File
require_once( SP_FAQ_DIR . '/admin/class-spfaq-admin.php' );

/* Plugin Wpos Analytics Data Starts */
function wpos_analytics_anl36_load() {

    require_once dirname( __FILE__ ) . '/wpos-analytics/wpos-analytics.php';

    $wpos_analytics =  wpos_anylc_init_module( array(
                            'id'            => 36,
                            'file'          => plugin_basename( __FILE__ ),
                            'name'          => 'WP responsive FAQ with category plugin',
                            'slug'          => 'wp-responsive-faq-with-category-plugin',
                            'type'          => 'plugin',
                            'menu'          => 'edit.php?post_type=sp_faq',
                            'text_domain'   => 'sp-faq',
                            'offers'        => array(
                                                    'trial_premium' => array(
                                                        'image'	=> 'http://analytics.wponlinesupport.com/?anylc_img=36',
                                                        'link'	=> 'https://www.wponlinesupport.com/plugins-plus-themes-powerpack-combo-offer/?ref=blogeditor'
                                                    ),
                                                ),
                        ));

    return $wpos_analytics;
}

// Init Analytics
wpos_analytics_anl36_load();
/* Plugin Wpos Analytics Data Ends */