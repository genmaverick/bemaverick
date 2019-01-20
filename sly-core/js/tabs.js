/*global Sly, YAHOO */
Sly.util.tabs = function(id){    
    this.tabs = [];
    this.id = id;
    this.init(id);

};
Sly.util.tabs.prototype = {

    setTab: function(id) {
        if (!id) {
            return false;
        }
       
        if (this.tabs[id]) {
            for (var j in this.tabs) {
                var elem = YAHOO.util.Dom.get(j);                
                if (j == id) {
                    YAHOO.util.Dom.addClass(elem.parentNode, 'selected');
                    YAHOO.util.Dom.removeClass( this.tabs[j].targetId, 'inactive');
                } else {
                    YAHOO.util.Dom.removeClass(elem.parentNode, 'selected');
                    YAHOO.util.Dom.addClass( this.tabs[j].targetId, 'inactive');
                }
            }
        
        }
        Sly.util.tabChangeEvent.fire(this);
    },
    handleClick : function(e, obj) {               
        YAHOO.util.Event.preventDefault(e);
        obj.setTab(this.id);
    },
    tabSwitch: new YAHOO.util.CustomEvent('tabSwitch'),
    init: function(id){
    
        var cont = YAHOO.util.Dom.get(id);
        var curIndex = null;
        var tabContainers = YAHOO.util.Dom.getElementsByClassName('navHeader','*',cont);
        
        for (var i = 0; i < tabContainers.length; i++) {
            var tabContainer = tabContainers[i];
            var links = tabContainer.getElementsByTagName('A');            
            for (var j = 0; j < links.length; j++) {
                var link = links[j];
                if (link.href.indexOf('#') != -1 ) {
                    targetIdString = link.href.split('#');
                    var navId = YAHOO.util.Dom.generateId(link, id + 'tab');
                    this.tabs[navId] = {
                        targetId:targetIdString[1],
                        navId: navId                       
                    };
                    YAHOO.util.Event.addListener( link, 'click', this.handleClick, this)
                    if (YAHOO.util.Dom.hasClass(link.parentNode,'selected') || j == 0 ) {
                        curIndex = navId;
                    }                    
                }                

            }        
        }

        
        this.setTab(curIndex);
       
    }
    
};
