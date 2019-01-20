<?php
if ( !function_exists('tatsu_lists') ) {
	function tatsu_lists( $atts, $content ) {
		return '<ul class="tatsu-module tatsu-list">'.do_shortcode( $content ).'</ul>';
	}
	add_shortcode( 'tatsu_lists', 'tatsu_lists' );
	add_shortcode( 'lists', 'tatsu_lists' );
}
if ( !function_exists( 'tatsu_list' ) ) {
	function tatsu_list( $atts, $content ) {
		global $be_themes_data;
		$atts = shortcode_atts( array( 
			'icon' => '',
			'circled' => '',
			'icon_bg' => '', 
			'icon_color' => '',
			'key' => be_uniqid_base36(true),
		), $atts );

		extract( $atts );
		$custom_style_tag = be_generate_css_from_atts( $atts, 'tatsu_list', $key );
		$unique_class_name = 'tatsu-'.$key;
		$output = '';

		if( $icon != 'none' ) { 
		 	if( 1 == $circled ) {
				 $circled = 'circled';
				 $icon_markup  = '<i class="tatsu-icon-list tatsu-icon '.$icon.' '.$circled.'"></i>'; 
		 	} else {
		 		$circled = '';
		 		$icon_markup  = '<i class="tatsu-icon '.$icon.' '.$circled.'"></i>';		
		 	}
		} 
		$output .= '<li class="tatsu-list-content '.$unique_class_name.'">';
		$output .= '<span class="tatsu-list-icon-wrap" >'.$icon_markup.'</span>';
		$output .= '<span class="tatsu-list-inner">'.$content.'</span>'.$custom_style_tag.'</li>';
	//	$output .= $custom_style_tag;
		return $output;
	}
	add_shortcode( 'tatsu_list', 'tatsu_list' );
	add_shortcode( 'list', 'tatsu_list' );
	
}

?>