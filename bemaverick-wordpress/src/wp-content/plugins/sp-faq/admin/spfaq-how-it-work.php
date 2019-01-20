<?php
/**
 * Pro Designs and Plugins Feed
 *
 * @package WP FAQ
 * @since 1.0.0
 */

// Exit if accessed directly
if ( !defined( 'ABSPATH' ) ) exit;

// Action to add menu
add_action('admin_menu', 'spfaq_register_design_page');

/**
 * Register plugin design page in admin menu
 * 
 * @package WP FAQ
 * @since 1.0.0
 */
function spfaq_register_design_page() {
	add_submenu_page( 'edit.php?post_type='.SP_FAQ_POST_TYPE, __('How it works, our plugins and offers', 'sp-faq'), __('How It Works', 'sp-faq'), 'manage_options', 'spfaq-designs', 'spfaq_designs_page' );
}

/**
 * Function to display plugin design HTML
 * 
 * @package WP FAQ
 * @since 1.0.0
 */
function spfaq_designs_page() {

	$wpos_feed_tabs = spfaq_help_tabs();
	$active_tab 	= isset($_GET['tab']) ? $_GET['tab'] : 'how-it-work';
?>
		
	<div class="wrap spfaq-wrap">

		<h2 class="nav-tab-wrapper">
			<?php
			foreach ($wpos_feed_tabs as $tab_key => $tab_val) {
				$tab_name	= $tab_val['name'];
				$active_cls = ($tab_key == $active_tab) ? 'nav-tab-active' : '';
				$tab_link 	= add_query_arg( array( 'post_type' => SP_FAQ_POST_TYPE, 'page' => 'spfaq-designs', 'tab' => $tab_key), admin_url('edit.php') );
			?>

			<a class="nav-tab <?php echo $active_cls; ?>" href="<?php echo $tab_link; ?>"><?php echo $tab_name; ?></a>

			<?php } ?>
		</h2>
		
		<div class="spfaq-tab-cnt-wrp">
		<?php
			if( isset($active_tab) && $active_tab == 'how-it-work' ) {
				spfaq_howitwork_page();
			}
			else if( isset($active_tab) && $active_tab == 'plugins-feed' ) {
				echo spfaq_get_plugin_design( 'plugins-feed' );
			} else {
				echo spfaq_get_plugin_design( 'offers-feed' );
			}
		?>
		</div><!-- end .spfaq-tab-cnt-wrp -->

	</div><!-- end .spfaq-wrap -->

<?php
}

/**
 * Gets the plugin design part feed
 *
 * @package WP FAQ
 * @since 1.0.0
 */
function spfaq_get_plugin_design( $feed_type = '' ) {
	
	$active_tab = isset($_GET['tab']) ? $_GET['tab'] : '';
	
	// If tab is not set then return
	if( empty($active_tab) ) {
		return false;
	}

	// Taking some variables
	$wpos_feed_tabs = spfaq_help_tabs();
	$transient_key 	= isset($wpos_feed_tabs[$active_tab]['transient_key']) 	? $wpos_feed_tabs[$active_tab]['transient_key'] 	: 'spfaq_' . $active_tab;
	$url 			= isset($wpos_feed_tabs[$active_tab]['url']) 			? $wpos_feed_tabs[$active_tab]['url'] 				: '';
	$transient_time = isset($wpos_feed_tabs[$active_tab]['transient_time']) ? $wpos_feed_tabs[$active_tab]['transient_time'] 	: 172800;
	$cache 			= get_transient( $transient_key );
	
	if ( false === $cache ) {
		
		$feed 			= wp_remote_get( esc_url_raw( $url ), array( 'timeout' => 120, 'sslverify' => false ) );
		$response_code 	= wp_remote_retrieve_response_code( $feed );
		
		if ( ! is_wp_error( $feed ) && $response_code == 200 ) {
			if ( isset( $feed['body'] ) && strlen( $feed['body'] ) > 0 ) {
				$cache = wp_remote_retrieve_body( $feed );
				set_transient( $transient_key, $cache, $transient_time );
			}
		} else {
			$cache = '<div class="error"><p>' . __( 'There was an error retrieving the data from the server. Please try again later.', 'sp-faq' ) . '</div>';
		}
	}
	return $cache;	
}

/**
 * Function to get plugin feed tabs
 *
 * @package WP FAQ
 * @since 1.0.0
 */
function spfaq_help_tabs() {
	$wpos_feed_tabs = array(
						'how-it-work' 	=> array(
													'name' => __('How It Works', 'sp-faq'),
												),
						'plugins-feed' 	=> array(
													'name' 				=> __('Our Plugins', 'sp-faq'),
													'url'				=> 'http://wponlinesupport.com/plugin-data-api/plugins-data.php',
													'transient_key'		=> 'wpos_plugins_feed',
													'transient_time'	=> 172800
												),
						'offers-feed' 	=> array(
													'name'				=> __('Hire Us', 'sp-faq'),
													'url'				=> 'http://wponlinesupport.com/plugin-data-api/wpos-offers.php',
													'transient_key'		=> 'wpos_offers_feed',
													'transient_time'	=> 86400,
												)
					);
	return $wpos_feed_tabs;
}

/**
 * Function to get 'How It Works' HTML
 *
 * @package WP FAQ
 * @since 1.0.0
 */
function spfaq_howitwork_page() { ?>
	
	<style type="text/css">
		.wpos-pro-box .hndle{background-color:#0073AA; color:#fff;}
		.wpos-pro-box .postbox{background:#dbf0fa none repeat scroll 0 0; border:1px solid #0073aa; color:#191e23;}
		.postbox-container .wpos-list li:before{font-family: dashicons; content: "\f139"; font-size:20px; color: #0073aa; vertical-align: middle;}
		.spfaq-wrap .wpos-button-full{display:block; text-align:center; box-shadow:none; border-radius:0;}
		.spfaq-shortcode-preview{background-color: #e7e7e7; font-weight: bold; padding: 2px 5px; display: inline-block; margin:0 0 2px 0;}
	</style>

	<div class="post-box-container">
		<div id="poststuff">
			<div id="post-body" class="metabox-holder columns-2">
			
				<!--How it workd HTML -->
				<div id="post-body-content">
					<div class="metabox-holder">
						<div class="meta-box-sortables ui-sortable">
							<div class="postbox">
								
								<h3 class="hndle">
									<span><?php _e( 'How It Works - Display and shortcode', 'sp-faq' ); ?></span>
								</h3>
								
								<div class="inside">
									<table class="form-table">
										<tbody>
											<tr>
												<th>
													<label><?php _e('Geeting Started with FAQ', 'sp-faq'); ?>:</label>
												</th>
												<td>
													<ul>
														<li><?php _e('Step-1. Go to "FAQ --> Add New".', 'sp-faq'); ?></li>
														<li><?php _e('Step-2. Add Title, Description and featured image', 'sp-faq'); ?></li>
														<li><?php _e('Step-3. Display multiple FAQs, create categories under "FAQ --> category" and create categories.', 'sp-faq'); ?></li>
														<li><?php _e('Step-4. Assign FAQ post to respective categories and use the category shortcode under "FAQ --> category"', 'sp-faq'); ?></li>
													</ul>
												</td>
											</tr>

											<tr>
												<th>
													<label><?php _e('How Shortcode Works', 'sp-faq'); ?>:</label>
												</th>
												<td>
													<ul>
														<li><?php _e('Step-1. Create a page like FAQ OR add the shortcode in any page.', 'sp-faq'); ?></li>
														<li><?php _e('Step-2. Put below shortcode as per your need.', 'sp-faq'); ?></li>
													</ul>
												</td>
											</tr>

											<tr>
												<th>
													<label><?php _e('All Shortcodes', 'sp-faq'); ?>:</label>
												</th>
												<td>
													<span class="spfaq-shortcode-preview">[sp_faq]</span> – <?php _e('Logo Showcase Slider Shortcode', 'sp-faq'); ?>
												</td>
											</tr>						
												
											<tr>
												<th>
													<label><?php _e('Need Support?', 'sp-faq'); ?></label>
												</th>
												<td>
													<p><?php _e('Check plugin document for shortcode parameters and demo for designs.', 'sp-faq'); ?></p> <br/>
													<a class="button button-primary" href="https://www.wponlinesupport.com/plugins-documentation/document-wp-responsive-faq-with-category-plugin/" target="_blank"><?php _e('Documentation', 'sp-faq'); ?></a>									
													<a class="button button-primary" href="http://demo.wponlinesupport.com/sp-faq/" target="_blank"><?php _e('Demo for Designs', 'sp-faq'); ?></a>
												</td>
											</tr>
										</tbody>
									</table>
								</div><!-- .inside -->
							</div><!-- #general -->
						</div><!-- .meta-box-sortables ui-sortable -->
					</div><!-- .metabox-holder -->
				</div><!-- #post-body-content -->
				
				<!--Upgrad to Pro HTML -->
				<div id="postbox-container-1" class="postbox-container">
					<div class="metabox-holder wpos-pro-box">
						<div class="meta-box-sortables ui-sortable">
							<div class="postbox">
									
								<h3 class="hndle">
									<span><?php _e( 'Upgrate to Pro', 'sp-faq' ); ?></span>
								</h3>
								<div class="inside">										
									<ul class="wpos-list">
										<li>15+ predefined design and Custom Colors option as in shortcode parameter.</li>
										<li>FAQ with accordion</li>
										<li>FAQ with categories grid</li>
										<li>Visual Composer support.</li>
										<li>Custom ordering with drag and drop</li>	
										<li>WooCommerce FAQ support. Now you can add Product FAQ to WooCommerce Product page easily.</li>
										<li>Various shortcode parameter for FAQ like Order, Orderby, Limit, Color, Backgrond color, Border color, Active FAQ color, Display specific FAQ, Exclude some FAQ and many more.</li>
										<li>Remain open FAQ on page load</li>
										<li>Custom CSS option</li>
										<li>Fully responsive</li>
										<li>100% Multi language</li>
									</ul>
									<a class="button button-primary wpos-button-full" href="https://www.wponlinesupport.com/wp-plugin/sp-responsive-wp-faq-with-category-plugin/" target="_blank"><?php _e('Go Premium ', 'sp-faq'); ?></a>	
									<p><a class="button button-primary wpos-button-full" href="http://demo.wponlinesupport.com/prodemo/pro-faq-plugin-demo/" target="_blank"><?php _e('View PRO Demo ', 'sp-faq'); ?></a>			</p>								
								</div><!-- .inside -->
							</div><!-- #general -->
						</div><!-- .meta-box-sortables ui-sortable -->
					</div><!-- .metabox-holder -->

					<!-- Help to improve this plugin! -->
					<div class="metabox-holder">
						<div class="meta-box-sortables ui-sortable">
							<div class="postbox">
									<h3 class="hndle">
										<span><?php _e( 'Help to improve this plugin!', 'sp-faq' ); ?></span>
									</h3>									
									<div class="inside">										
										<p>Enjoyed this plugin? You can help by rate this plugin <a href="https://wordpress.org/support/plugin/sp-faq/reviews/" target="_blank">5 stars!</a></p>
									</div><!-- .inside -->
							</div><!-- #general -->
						</div><!-- .meta-box-sortables ui-sortable -->
					</div><!-- .metabox-holder -->
				</div><!-- #post-container-1 -->

			</div><!-- #post-body -->
		</div><!-- #poststuff -->
	</div><!-- #post-box-container -->
<?php }