=== WP responsive FAQ with category plugin ===
Contributors: wponlinesupport, anoopranawat, pratik-jain
Tags: wponlinesupport, faq, faq list, faq plugin, faqs, jquery ui, wp-faq with category, jquery ui accordion,  faq with accordion, custom post type with accordion, frequently asked questions, wordpress, wordpress faq, WordPress Plugin, shortcodes
Requires at least: 3.5
Tested up to: 4.9.7
Stable tag: trunk
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

A quick, easy way to add an responsive FAQs page. You can use this plugin as a jquery ui accordion.

== Description ==
Many CMS site needs a FAQs section. SP faqs plugin  allows you add, manage and display FAQ on your wordpress website. This plugin is created with custom post type.

View [DEMO](http://wponlinesupport.com/wp-plugin/sp-responsive-wp-faq-with-category-plugin/) | [PRO DEMO and Features](http://wponlinesupport.com/wp-plugin/sp-responsive-wp-faq-with-category-plugin/) for additional information.

Checkout our new plugin - [PowerPack - Need of Every Website](https://wordpress.org/plugins/powerpack-lite/)

Now you can also Fillter OR Display FAQ by category.

Here is the example :
<code>
News
[sp_faq category="category_ID" single_open="true" transition_speed="300"]
sports
[sp_faq category="category_ID" single_open="true" transition_speed="300"]
</code>

To use this FAQ plugin just create a new page and add this FAQ short code 
<code>[sp_faq]</code> 
OR
If you want to display FAQ by category then use this short code 
<code>[sp_faq  category="category_ID"]</code>

= Shortcode parameters are =
* **limit** : [sp_faq limit="10"] (ie Limit the number FAQ's items to be display. By default value is limit="-1" ie all)
* **category** : [sp_faq category="category_ID"] (ie Display FAQ's by category. You can find shortcode under **Faq -> FAQ Category**)
* **single_open** : [sp_faq single_open="true"] (ie Display One FAQ item when click to open. By default value is "true". Values are "true" and "false")
* **transition_speed** : [sp_faq transition_speed="300"] (ie transition speed when user click to open FAQ item )

This faqs plugin add a FAQs page in your wordpress website with accordion.

The faq plugin adds a "FAQ" tab to your admin menu, which allows you to enter FAQ Title and FAQ Description items just as you would regular posts.

we have also used faq accordion function so that user can show/hide FAQ content.

= New Features include: =
* wp-faq with category <code>[sp_faq  category="category_ID"]</code> You can find shortcode under **Faq -> FAQ Category**
* Just create a FAQs page and add short code <code>[sp_faq limit="-1"]</code>
* accordion
* Setting page removed and add shortcode parameters ie  single_open and transition_speed
* Add thumb image for FAQ
* Easy to configure FAQ page
* Smooth FAQ Accordion effect
* Smoothly integrates this paq plugin into any theme
* CSS and JS file for FAQ custmization
* Search Engine Friendly URLs
* Added Text Domain and Domain Path

= PRO FAQ Plugin Features include: =

<code>[sp_faq limit="10"  category="category_ID" design="design-2" grid="2"
 category_name="sports"  single_open="false" transition_speed="300" 
 background_color="#000" font_color="#fff" border_color="#444"]</code>

* Added 15 pre defined designs.
* Visual Composer page builder support.
* WooCommerce Support. You can add product FAQ easily.
* Drag&Drop interface to display FAQ in your desired order.
* Customize any design with shortcode parameters.
* Various shortcode parameter for FAQ like Order, Orderby, Limit, Color, Backgrond color, Border color, Active FAQ color, Display specific FAQ, Exclude some FAQ and many more.
* Plugin setting page with custom css setting.
* Category section with shortcode.
* Display FAQ with category wise.
* Accordion with better animation.
* Custom Colors option as in shortcode parameter.
* Display FAQ's in grid view.
* Display category name.

View [PRO DEMO and Features](http://wponlinesupport.com/wp-plugin/sp-responsive-wp-faq-with-category-plugin/) for additional information.

= Pro Shortcode Parameters are =

* **Limit** : [sp_faq limit="10"] (Limit the number FAQ's items to be display. By default value is limit="20".)
* **Category** : [sp_faq category="category_ID"] (Display FAQ's by category.)
* **Category Name** : [sp_faq category_name="category name"] (Display FAQ's category name. It will display above FAQ.)
* **Design** : [sp_faq design="design-1"] (Select design for faq. We have added 8 colors design ie design-1, design-2, design-3 to design-8.)
* **Single Open** : [sp_faq single_open="true"] (Display One FAQ item when click to open. By default value is "true". Values are "true" and "false".)
* **Transition Speed** : [sp_faq transition_speed="300"] (Transition speed when user click to open FAQ item.)
* **Background Color** : [sp_faq background_color="#000"] (Set background color of FAQ item.)
* **Font Color** : [sp_faq font_color="#fff"] (Set font color of FAQ item.)
* **Border Color** : [sp_faq border_color="#444"] (Set border color of FAQ box.)
* **Heading Font Size** : [sp_faq heading_font_size="20"] (Set font size for FAQ heading.)
* **Active FAQ Background Color** : [sp_faq active_bg_color="#fff"] (Set open FAQ background color.)
* **Icon Color** : [sp_faq icon_color="white"] (Set the icon color. By default value is "black". Options are "black" OR white".)
* **Icon Type** : [sp_faq icon_type="plus"] (Set the icon type. By default value is "arrow". Options are "plus" OR arrtow".)
* **Icon Position** : [sp_faq icon_position="left"] (Set the icon position. By default value is "right". Options are "left" OR right".)
* **Order** : [sp_faq order="DESC"] (Set the FAQ order. Options are "DESC" OR ASC")
* **Orderby** : [sp_faq orderby="post_date"] (Set the FAQ orderby. Default value is 'post_date'. Options are "ID", "title", "post_date", "modified", "rand", "menu_order".)
* **Posts :** [sp_faq posts="1,5,6"] (Display only specific FAQ posts.)
* **Exclude Post :** [sp_faq exclude_post="1,5,6"] (Exclude some FAQ post which you do not want to display.)
* **Exclude Category :** [sp_faq exclude_cat="1,5,6"] (Exclude some FAQ category which you do not want to display.)

**Added New Shortcode to display FAQ's items with categories in the grid view**
<code>[faq-category-grid grid="2" background_color="#f1f1f1" font_color="#000" heading_font_size="20"]</code>

SP FAQ allows you to provide a well-designed and informative FAQ section, which can  decrease the amount of user inquiries on various issues.
With the help of given CSS file for this FAQ plugin you can desgin this FAQ plugin as per your layout.

= Privacy & Policy =
* We have also opt-in e-mail selection , once you download the plugin , so that we can inform you and nurture you about products and its features.

== Installation ==

1. Upload the 'sp-faq' folder to the '/wp-content/plugins/' directory.
2. Activate the sp-faq list plugin through the 'Plugins' menu in WordPress.
3. Add a new page and add this short code <code>[sp_faq limit="-1"]</code>


== Frequently Asked Questions ==

= What templates FAQs are available? =

There is one templates named 'faq.php' which work like same as defult POST TYPE in wordpress.

You can also change the css as per your layout

= Are there shortcodes for FAQs items? =

Yes, Add a new faq page and add this short code <code>[sp_faq limit="-1"]</code>


== Screenshots ==

1. all Faqs
2. Add new Faq
3. preview faq
4. How to add short code
5. Faq with category


== Changelog ==

= 3.2.6 (11, June 2018) =
* [*] Follow some WordPress Detailed Plugin Guidelines.

= 3.2.5 =
* [+] Added "How it work" tab
* [-] Removed Pro design tab

= 3.2.4 =
* Update plugin design page.

= 3.2.3 =
* Fixed some css issues.

= 3.2.2 =
* Fixed some bugs

= 3.2.1 =
* Fixed some bugs
* Added new shortcode for Pro version 

= 3.2 =
* Setting page removed and add shortcode parameters ie  single_open and transition_speed
* Added Text Domain and Domain Path

= 3.1.1 =
* Added Pro Designs and link

= 3.1 =
* Fixed some bugs

= 3.0 =
* Setting page added.
* Fixed some bugs

= 2.2 =
* wp-faq with category

= 2.1 =
* Added jquery UI
* Adds custom post type
* Adds FAQs
* Smooth accordion effect

= 2.0 =
* Adds custom post type
* Adds FAQs
* New css and css file
* Smooth accordion effect

= 1.0 =
* Initial release
* Adds custom post type
* Adds FAQs