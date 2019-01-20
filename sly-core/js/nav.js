Sly.util.nav = function(){
    var isShown = false;
    var hider = null;
    var shower = null;
    var Dom = YAHOO.util.Dom;
    var Event = YAHOO.util.Event;    

    var finishHide = function(item){      
        Dom.removeClass(item, 'visible');
        Dom.removeClass(Dom.getAncestorByClassName(item, 'visible' ), 'visible');        
        shower = null;
        isShown = null;
    };
    
    var finishShow = function(item){
        var menuId = Sly.util.getClassValue(item, 'menu');
        var xY = Dom.getXY(item);
        xY[1] = xY[1] + item.offsetHeight;
        var menu = Dom.get(menuId + 'Menu');
        Event.removeListener(menu, 'mouseout', hideMe);
        Event.removeListener(menu, 'mouseover', showMe);
        Event.addListener(menu, 'mouseout', hideMe);
        Event.addListener(menu, 'mouseover', showMe);
        Dom.addClass(menu, 'visible');
        Dom.setXY(menu, xY);
        Dom.addClass(item, 'visible');
        isShown = menu;
        hider = null;
    };
    
    var showMe = function(e){
        window.clearTimeout(hider);
        hider = null;
    };
    
    var hideMe = function(e){
        var menu = this;
        
        if (Dom.hasClass(this, 'visible')) {
            return false;
        }
        hider = window.setTimeout(function(){
            finishHide(menu);
        }, 300);
        window.clearTimeout(shower);
    };
    
    var showMenu = function(e){
        var el = this;
        var menuId = Sly.util.getClassValue(this, 'menu');
        if (!menuId) {
            return;
        }
        var menu = Dom.get(menuId + 'Menu');
        var time = 400;
        if (!isShown || menu != isShown) {
            if (isShown) {
                finishHide(isShown);
                time = 0;
            }
            shower = window.setTimeout(function(){
                finishShow(el);
            }, time);
        }
        window.clearTimeout(hider);
    };
    
    var hideMenu = function(e){
        var menuId = Sly.util.getClassValue(this, 'menu');
        if (!menuId) {
            return;
        }
        var menu = Dom.get(menuId + 'Menu');
        hider = window.setTimeout(function(){
            finishHide(menu);
        }, 400);
        window.clearTimeout(shower);
    };
    
    var _init = function(id){
        container = Dom.get(id);
        if (!container) {
            return;
        }
        var menuItems = Dom.getElementsByClassName('menuDrop', 'LI', container);
        Event.addListener(menuItems, 'mouseover', showMenu);
        Event.addListener(menuItems, 'mouseout', hideMenu);
    };
    
    return {
        init: function(id){
            _init(id);
        }
        
    };
}();
