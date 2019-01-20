/*global Sly, YAHOO, window, document */
Sly.util = function(){
    var classSplitToken = '__';
    var Dom = YAHOO.util.Dom;
    var Event = YAHOO.util.Event;
    var CONSTS = {
        AJAXSUCCESS: 'AJAXSUCCESS',
        ALERT: 'ALERT',
        NOT_LOGGED_IN: 'NOT_LOGGED_IN',
        NO_PERMISSION_TO_VIEW: 'NO_PERMISSION_TO_VIEW_PAGE'        
    };
    
    
    
    
    var _getClassValue = function(elem, prefix){
        var val = '';
        var el = Dom.get(elem);
        var classes = el.className.split(' ');
        for (var i = 0; i < classes.length; i++) {
            var curClass = classes[i];
            if (curClass.indexOf(prefix + '-') != -1) {
                var nameVal = curClass.split(prefix + '-');
                val = nameVal[1];
                break;
            }
        }
        return val;
    };
    
    var _replaceClassValue = function(elem, prefix, value){
        var el = Dom.get(elem);
        var classes = el.className.split(' ');

        var replaced = false;
        for (var i = 0; i < classes.length; i++) {
            var curClass = classes[i];
            if (curClass.indexOf(prefix + '-') != -1) {
                Dom.removeClass(elem,curClass);
                Dom.addClass(elem,prefix + '-' + value);
                break;
            }
        }
        if (!replaced) {
            // Just add it
            Dom.addClass(elem,prefix + '-' + value);
        }
        return;
    };
    
    var _getUrlValue = function(elem, prefix){
        var val = '';
        var el = Dom.get(elem);
        if (!el.href) {
            return false;
        }
        var first = el.href.split('?');
        if (first.length > 1) {
            var params = first[1].split('&');
            for (var i = 0; i < params.length; i++) {
                var curParam = params[i];
                if (curParam.indexOf(prefix + '=') != -1) {
                    var nameVal = curParam.split('=');
                    val = nameVal[1];
                    break;
                }
            }
        }
        return val;
    };   
    
    var windowPresets = {
        'mywindow': {
            'scrollbars': 'yes',
            'height': 400
        }, 
        'help': {
            'scrollbars': 'yes',
            'height': 550,
            'width': 740,
            'resizable': 'yes'
        }         
    };
    
    var _simulatedEventFire = function(elem, type){
    

        if (document.createEventObject){
            // dispatch for IE
            var evt = document.createEventObject();
            return elem.fireEvent('on'+type,evt)
        }
        else{
            // dispatch for firefox + others
            var evt = document.createEvent("HTMLEvents");
            evt.initEvent(type, true, true ); // event type,bubbling,cancelable
            return !elem.dispatchEvent(evt);
        }
  
    
    };
    
    var launchPopup = function(elem){
        var classes = elem.className.split(' ');
        var attributes = [];

        var presetIndex = null;
        var winName = null;
        for (var i = 0; i < classes.length; i++) {
            var param = classes[i].split(classSplitToken);
            if (param.length > 1) {
                if (param[0] == 'preset') {
                    presetIndex = param[1];
                } else if (param[0] == 'target') {
                    winName = param[1];
                } else {
                    attributes[param[0]] = param[1];
                }
            }
        }

        var att = null;
        if (presetIndex) {
            for (att in windowPresets[presetIndex]) {
                if (windowPresets[presetIndex].hasOwnProperty(att)) {
                    if (!attributes[att]) {
                        attributes[att] = windowPresets[presetIndex][att];
                    }
                }
            }
        }
        
        att = null;
        var attString = [];
        for (att in attributes) {
            if (attributes.hasOwnProperty(att)) {
                attString[attString.length] = att + "=" + attributes[att];
            }
        }
        if (attributes.height || attributes.width) {
            elem.target = winName;
        }

        if (winName == 'opener') {
            if (window.opener) {
                window.opener.location = elem.href;
                window.opener.focus();
                return;
            } else {
                window.location = elem.href;
            }
        } else if (winName == 'top') {
            top.location.href = elem.href;
            return;
        }
        
        
        var win = window.open(elem.href, winName, attString.join(','));
        win.focus();
        return false;        
    };
    var _firePageTracker = function(name){
        var a = function(){
            try {
                pageTracker._trackPageview( '/dynamic/' + name );           
            } catch (err) {}
        };
        a();
    }

    var _dispatchDynamicEvent = function(e, elem){
        var pN = elem;
        var attributes = null;
        while (pN) {
            var classes = pN.className.split(' ');
            attributes = [];
            for (var i = 0; i < classes.length; i++) {
                var param = classes[i].split(classSplitToken);
                attributes[param[0]] = param[1];
            }
            if (attributes.mod) {
                break;
            }
            pN = pN.parentNode;
        }
        if (!attributes.mod) {
            return true;
        }
        if (elem.nodeName == 'STRONG' && ( elem.parentNode.nodeName == 'A' && Dom.hasClass(elem.parentNode, 'dynamic') ) ) {
            elem = elem.parentNode;
        }        
        var args = {
            'mod': attributes.mod,
            'targetElem': elem,
            'containerElem': pN
        };
        Sly.util.lastTargetElem = elem;
        
       
       
        if (e.type == 'click') {
            Sly.util.dynamicClickEvent.fire('dynamicClickEvent', args);
        } else if (e.type == 'change') {
            Sly.util.dynamicChangeEvent.fire('dynamicChangeEvent', args);
        } else if (e.type == 'submit') {
            Sly.util.dynamicSubmitEvent.fire('dynamicSubmitEvent', args);
        }
        Event.preventDefault(e);
        return false;
    };
    var dispatchLinkClick = function(e, elem){
        //if somebody has a modifier key pressed down, 
        //just follow the link don't do anything fancy unless
        //it is a strict popup - still need to make this work       
        if ((e.shiftKey || e.ctrlKey || e.metaKey) && !Dom.hasClass(elem, 'strict')) {
            return true;
        }
        if (Dom.hasClass(elem, 'popup') || Dom.getAncestorByClassName( elem, 'popup' ) ) {
            if (Dom.getAncestorByClassName(elem, 'popup')) {
                elem =  Dom.getAncestorByClassName( elem, 'popup' );
            }
            launchPopup(elem);
            Event.stopEvent(e);
            return false;
        }

        return true;
    };
    var handleClick = function(e){

        var elem = Event.getTarget(e);
                
        var continueProcessing = true;
        if (Dom.hasClass(elem, 'dynamic') || Dom.hasClass(elem.parentNode, 'dynamic') ) {
	        if (Dom.hasClass(elem.parentNode, 'dynamic')) {                
                elem = elem.parentNode;
            }            
            continueProcessing = Sly.util.dispatchDynamicEvent(e, elem);
        } else if ( Dom.hasClass(elem,'expand') || Dom.hasClass(elem.parentNode,'expand') ) {
            if (Dom.hasClass(elem.parentNode, 'expand')) {                
                elem = elem.parentNode;
            }
            expandItem(e,elem);
        } else if ( ( elem.nodeName == 'A' || Dom.getAncestorByTagName(elem, 'A') ) && continueProcessing) {
            dispatchLinkClick(e, elem);
        } else {
            return true;
        }
    };

    var expandItem = function(e,elem){        
        var contId = Sly.util.getClassValue( elem, 'container' );        
        var className = Sly.util.getClassValue( elem, 'expandClass' );        

        if (!className) {
            className = 'expanded';
        }
        
        var container = Dom.get(contId);

        if (Dom.hasClass(elem, 'noMultiples')) {

            var mod = Dom.getAncestorByClassName( elem, 'mod');
            var allExpands = Dom.getElementsByClassName( 'expand', 'A', mod); 
            
            for (var i = 0; i < allExpands.length; i++) {
                var allExpandsContId = Sly.util.getClassValue( allExpands[i], 'container' );
                if (allExpands[i] != elem) {
                    Dom.removeClass(allExpandsContId, className);
                    Dom.removeClass(allExpands[i], className);
                }
            }            
        }
        
        if (Dom.hasClass(elem, 'hide')) {
            Dom.setStyle(elem, 'display', 'none' );
        } 

        if (container) {

            if (Dom.hasClass(container,className)) {
                Dom.removeClass(container, className);               
                Dom.removeClass(elem,className);        
            } else {
                Dom.addClass(container, className);
                Dom.addClass(elem,className);

            }
        }

        Event.stopEvent(e);

        return false;
    };


    var _initButtons = function(){
        var toolbars = Dom.getElementsByClassName('subHd');
        Event.removeListener(toolbars, 'mouseover', handleButtonMouseOver);
        Event.removeListener(toolbars, 'mouseout', handleButtonMouseOut);
        Event.addListener(toolbars, 'mouseover', handleButtonMouseOver);
        Event.addListener(toolbars, 'mouseout', handleButtonMouseOut);                
    };

    var handleButtonMouseOver = function(e){
        var elem = Event.getTarget(e);
        var continueProcessing = true;        
        if (elem.nodeName == 'LI' || Dom.getAncestorByTagName(elem, 'LI') ) {
            elem = elem.nodeName == 'LI' ? elem : Dom.getAncestorByTagName(elem, 'LI');
            if ( elem.getElementsByTagName('A').length ) {
                Dom.addClass(elem, 'hover');
            }
        }
        
    };
    var handleButtonMouseOut = function(e){
        var elem = Event.getTarget(e);
        var continueProcessing = true;
        
        if (elem.nodeName == 'LI' || Dom.getAncestorByTagName(elem, 'LI')) {
            elem = elem.nodeName == 'LI' ? elem : Dom.getAncestorByTagName(elem, 'LI');
            if ( elem.getElementsByTagName('A').length ) {
                Dom.removeClass(elem, 'hover');
            }
        }

    };    
    
    var _replaceInPlace = function(content, destination){
        if (destination.outerHTML) {
            destination.outerHTML = content;
        } else {
            var tempNode = document.createElement('DIV');
            tempNode.innerHTML = content;
            var toInsert = destination;
            for (var i = tempNode.childNodes.length - 1; i >= 0; i--) {
                toInsert.parentNode.insertBefore(tempNode.childNodes[i].cloneNode(true), toInsert);
                toInsert = toInsert.previousSibling;
            }
            tempNode = null;
            destination.parentNode.removeChild(destination);
        }
    };
    var _mergeElements = function(dest, other){
        var insAfter = dest.lastChild;
        for (var i = other.childNodes.length - 1; i >= 0; i--) {
            dest.appendChild(other.childNodes[i].cloneNode(true));
        }
        other.parentNode.removeChild(other);
    };
        
    var _resetSemanticClasses = function(elems) {
        for (var i = 0; i < elems.length; i++) {
            var elem = elems[i];
            if (i === 0) {
                Dom.addClass(elem, 'first');
            } else {
                Dom.removeClass(elem, 'first');
            }
            if (i == elems.length - 1) {
                Dom.addClass(elem, 'last');
            } else {
                Dom.removeClass(elem, 'last');
            }
            var even = i % 2;
            if (even) {
                Dom.removeClass(elem, 'odd');
                Dom.addClass(elem, 'even');
            } else {
                Dom.removeClass(elem, 'even');
                Dom.addClass(elem, 'odd');
            }
        }
    };
    
    
    var _resetRowClasses = function(tableId, cont){
        if (tableId) {
            var cont = Dom.get(tableId);
        }
        var tbodys = cont.getElementsByTagName('TBODY');
        if (tbodys) {
            var rows = tbodys[0].getElementsByTagName('TR');
            Sly.util.resetSemanticClasses(rows);
        }
    };     
       
    
    
    var _notify = function(notifyType, requestType, note){
      var onload = function(){          
          _notifyFinish(notifyType, requestType, note);
      };      
      Sly.util.getLoader("slyContainer", onload); 
    };
    
    var _notifyFinish = function(notifyType, requestType, note){
        if (notifyType == Sly.util.consts.ALERT 
            || notifyType == Sly.util.consts.NOT_LOGGED_IN 
            || notifyType == Sly.util.consts.NO_PERMISSION_TO_VIEW ) {
            var handleHide = function(){
                this.hide();
            };
            var mySimpleDialog = new YAHOO.widget.SimpleDialog("simpledialog1", {
                width: "450px",
                fixedcenter: true,
                visible: false,
                draggable: true,
                close: true,
                text: unescape(note),
                underlay: 'none',
                modal: true,
                constraintoviewport: true,
                buttons: [{
                    text: "Close",
                    handler: handleHide,
                    isDefault: true
                }]
            });
            mySimpleDialog.setHeader('Warning!'); 
            mySimpleDialog.render(document.body);
            mySimpleDialog.show();
            
        } else {
            consoleLog(requestType + ':' + note);
        }
    };
    var _message = function(type, text){
        var elem = Dom.get('confirmationMessage');
        if (!elem) {
            
            var primary = Dom.get('hd');
            if (!primary) {
                return;
            }
            var newElem = document.createElement('DIV');
            newElem.id = 'confirmationMessage';
            Dom.addClass(newElem, 'mod confirmation');
                           
	        primary.appendChild(newElem); 
                     
            elem = newElem;
        }
        type = type ? type : 'normal';
        if (type == 'normal') {
            elem.innerHTML =  '<div class="content"><div class="bd"><p><span class="icon"></span> '+ text +'</p></div></div>';
        }         
	};
    
    var _handleSystemError = function(error){
        window.alert(error);
    };
    var _loadNonEssentialImages = function(e){
        var load = function(e){
            var imgs = Dom.getElementsByClassName('pli', 'IMG');
            for (var i = 0; i < imgs.length; i++) {
                var newSrc = Sly.util.getClassValue(imgs[i], 'image');
                if (imgs[i].src != newSrc) {
                    imgs[i].src = newSrc;
                }
            }
        };
        window.setTimeout(load, 750);
    }; 
    
    var _getLoader = function(modulesToLoad, callback){
        var loader = new YAHOO.util.YUILoader();            
        //Add the module to YUILoader 
         
        
        loader.addModule({ 
          name: "slyContainer", 
          type: "js", 
          fullpath: Sly.template.containerJsFile, 
          varName: "slyContainer"
        });          
        loader.require(modulesToLoad); //include the new  module 
        loader.onSuccess = callback; 
        loader.insert();        
    };
    
    
    var _ajaxAlert = function(initVars){        
      var onload = function(){          
          _ajaxAlertFinish(initVars);
      };     
      Sly.util.getLoader("slyContainer", onload); 
    };
    
    var _ajaxAlertFinish = function(initVars){
        this.message = initVars.message ? '<div class="alertMessage">'+initVars.message+'</div>' : '';
        
        this.message = this.message.replace( /THISISGONNABEREPLACED/g, '\n');
        
        this.title = initVars.title ? initVars.title : "Warning!";
        this.postmethod = initVars.postMethod ? initVars.postMethod : 'async';
        this.ButtonValues = initVars.buttonValues ? initVars.buttonValues : ['Yes', 'No'];
        this.width = initVars.width ? initVars.width : "600px";
        this.afterShowCallback = function(){};
        if (initVars.afterShowCallback) {
            this.afterShowCallback = function(){   
                var a = Sly.util.getJsContent(initVars.afterShowCallback); 
                if (typeof(a) == 'function') {
                    a();
                }
            };            
        } 
        
        this.containerType = 'normal';
        if (this.width != '600px') {
            this.containerType = 'min';
        }
        
        this.callback = '';
        var handleHide = function(){
            this.hide();
        };
        var onSuccess = function(o){
            var responseObj = YAHOO.lang.JSON.parse(o.responseText);
            if (responseObj.js) {
                var js = Sly.util.getJsContent(responseObj.js);
                if (typeof(js) == 'function') {            
                    js();
                }
            }
        };
        var onFailure = function(o){
            return false;
        };
        var handleConfirm = function(){
            YAHOO.util.Connect.initHeader('Ajax-Request', 'ajaxAlert');
            this.callback.success = onSuccess;
            this.callback.failure = onFailure;
            this.submit();
        };

        var simpleDialog = new YAHOO.widget.SimpleDialog("dialog-"+this.containerType, {
            width: this.width,
            fixedcenter: true,
            visible: false,
            draggable: true,
            close: true,
            text: unescape(this.message),
            underlay: 'none',
            modal: true,
            postmethod: this.postmethod,
            constraintoviewport: true,
            buttons: [{
                text: this.ButtonValues[0],
                handler: handleConfirm,
                isDefault: true
            }, {
                text: this.ButtonValues[1],
                handler: handleHide,                
                isDefault: false
            }]
        });                      
 
        simpleDialog.setHeader(this.title);         
        simpleDialog.render(document.body);
        simpleDialog.showEvent.subscribe(this.afterShowCallback); 
        simpleDialog.show();
        Sly.util.showPanelComplete.fire();
        
        var textWraps = YAHOO.util.Dom.getElementsByClassName('textWrap', null, "dialog-"+this.containerType);
        if (textWraps.length > 0) {
            if (YAHOO.env.ua.gecko) {
                YAHOO.util.Dom.setStyle(textWraps, 'overflow', 'auto');
            }
            var textElems = textWraps[0].getElementsByTagName('INPUT');
            if (textElems.length > 0) {
                textElems[0].focus();
            }
            var textAreas = textWraps[0].getElementsByTagName('TEXTAREA');
            if (textAreas.length > 0) {
                textAreas[0].focus();
            }            
        }
    };
    var _getJsContent = function(content){  
        if (!YAHOO.env.ua.gecko || YAHOO.env.ua.gecko > 1.8 ) {            
            return (Function('var document,top,self,window ,parent,Number,Date,Object,Function,Array,String,Math,RegExp,Image,ActiveXObject; return (' + content + ')'))();
        } else {            
            return eval(content);
        }        
    };
    
    var _getValueFromJsContent = function(content,value){
        var test =  eval("" + content);        
        for (var i = 0; i < test.length; i++) {
            var a = YAHOO.lang.JSON.parse(test[i]); 
            if (a[value]) {
                return a[value];
            }           
        }
        return false;
    };    
    
    var handleOnChangeSubmit = function(e){
        var form = YAHOO.util.Dom.getAncestorByTagName( this, 'FORM');
        if (form) {
            form.submit();
            YAHOO.util.Event.preventDefault(e);
        }        
    };
    
    var _selectOnChangeSubmit = function(id) {
        var cont = YAHOO.util.Dom.get(id);
        if (cont) {
            var sels = cont.getElementsByTagName('SELECT');
            YAHOO.util.Event.addListener( sels, 'change', handleOnChangeSubmit );
        }
    };
    
    var _checkboxOnChangeSubmit = function(id) {
        var cont = YAHOO.util.Dom.get(id);
        if (cont) {
            var inputs = cont.getElementsByTagName('INPUT');
            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == 'checkbox') {
                    YAHOO.util.Event.addListener(inputs[i], 'click', handleOnChangeSubmit);                    
                }
            }
        }
    };    
    
    
    var _positionFooter = function(){
        var ft = Dom.get('ft');
        var doc = Dom.get('doc');
        var bodies = document.getElementsByTagName('BODY');

        if (YAHOO.env.ua.ie && YAHOO.env.ua.ie < 7 ) {
             if (Dom.getDocumentHeight() > Dom.getViewportHeight()) {
                 Dom.setStyle(ft, 'position', 'static');
             } else {
                Dom.setStyle(ft, 'position', 'absolute');
             }
        } else {
            if (bodies[0].offsetHeight != Dom.getDocumentHeight()) {        
                
                if ( !Dom.hasClass(bodies[0], 'g-e')) {
                    Dom.setStyle(ft, 'bottom', (bodies[0].offsetHeight - Dom.getDocumentHeight()) + 'px');
                } else {
                    Dom.setStyle(ft, 'bottom', '0px');
                }
            }        
        }
    };
    var _getEmptyMessage = function(text){       
        text = text ? text : '';
        return '<div class="statusWrap"><p>'+text+'</p></div>';    
    };
    
    return {
        replaceInPlace: function(content, destination){
            _replaceInPlace(content, destination);
        },
        mergeElements: function(dest, other){
            _mergeElements(dest, other);
        },
        init: function(id){
            Event.addListener(id, 'click', handleClick);
            Sly.util.initButtons();
            Sly.util.dynamicRequestSuccess.subscribe(Sly.util.initButtons);
            Event.onContentReady(Dom.get(id).parentNode.id, this.loadNonEssentialImages);
        },
        getClassValue: function(elem, prefix){
            return _getClassValue(elem, prefix);
        },        
        getUrlValue: function(elem, prefix){
            return _getUrlValue(elem, prefix);
        },
        replaceClassValue: function(elem, prefix, value){
            return _replaceClassValue(elem, prefix, value);
        },
        lastTargetElem : null,     
        dynamicRequests: [0],
        dynamicClickEvent: new YAHOO.util.CustomEvent('dynamicClickEvent'),
        dynamicChangeEvent: new YAHOO.util.CustomEvent('dynamicChangeEvent'),
        dynamicSubmitEvent: new YAHOO.util.CustomEvent('dynamicSubmitEvent'),
        dynamicRequest: new YAHOO.util.CustomEvent('dynamicRequest'),
        dynamicRequestSuccess: new YAHOO.util.CustomEvent('dynamicRequestSuccess'),
        tabChangeEvent: new YAHOO.util.CustomEvent('tabChange'),
        dynamicRequestFailure: new YAHOO.util.CustomEvent('dynamicRequestFailure'),
        showPanelComplete: new YAHOO.util.CustomEvent('showPanelComplete'), 
        dispatchDynamicEvent: function(e, elem){
            _dispatchDynamicEvent(e, elem);
        },
        loadNonEssentialImages: function(e){
            _loadNonEssentialImages(e);
        },
        message: function(type, text){
            _message(type, text);
        },
        notify: function(notifyType, requestType, note){
            _notify(notifyType, requestType, note);
        },
        handleSystemError: function(error){
            _handleSystemError(error);
        },
        initButtons: function(){          
            _initButtons();    
        },
        firePageTracker: function(name) {
            _firePageTracker(name);
        },
        consts: CONSTS,
        getJsContent: function(content){
            return _getJsContent(content);
        },
        getValueFromJsContent: function(content, value){
            return _getValueFromJsContent(content,value);
        },        
        ajaxAlert: function(initVars){
            _ajaxAlert(initVars);
        },
        getLoader: function(modulesToLoad, callback){
            _getLoader(modulesToLoad, callback);
        },
        positionFooter:function(){
            _positionFooter();
        },
        resetRowClasses:function (tableId, cont) {
            _resetRowClasses(tableId,cont);
        },
        resetSemanticClasses:function(elems) {
           _resetSemanticClasses(elems);
        },
        selectOnChangeSubmit:function(id) {
           _selectOnChangeSubmit(id);
        },   
        checkboxOnChangeSubmit:function(id) {
           _checkboxOnChangeSubmit(id);
        },        
        getEmptyMessage:function(text) {
           return _getEmptyMessage(text);
        },
        simulatedEventFire: function(elem, type){
            _simulatedEventFire( elem, type);
        }
        
    };
}();

Sly.dynamicModule = function(name){
    this.name = name;

    Sly.util.dynamicClickEvent.subscribe(this.startDynamicAction, this);
    this.performDynamicAction = function(arg, me){
        if (arg.targetElem.nodeName == 'A') {
            this.getDynamicContent(arg, me);
        }
    };
    this.responseSuccess = function(o){
        var responseObj = YAHOO.lang.JSON.parse(o.responseText);
        var destination = o.argument.containerElem;
        var targetElem = o.argument.targetElem;
        o.argument.action = 'pass';

        if (responseObj.error) {
            if (responseObj.error !== 'notify') {
                Sly.util.handleSystemError(responseObj.error);
            } else {
                if (responseObj.js) {       
                    var js = Sly.util.getJsContent(responseObj.js);
                    if (typeof(js) == 'function') {
                        js();
                    }
                }            
            }
            
            Sly.util.dynamicRequestSuccess.fire(o);
        } else {
            if (!YAHOO.util.Dom.hasClass(destination, 'pass')) {
                if (YAHOO.util.Dom.hasClass(destination, 'replaceUp')) {
                    
                    destination = YAHOO.util.Dom.getAncestorByClassName(destination, 'mod__' + o.argument.mod);
                }
               
                if (targetElem == destination || YAHOO.util.Dom.hasClass(destination, 'replace')) {
                    Sly.util.replaceInPlace(responseObj.content, destination);
                    o.argument.action = 'replace';
                } else {
                    destination.innerHTML = responseObj.content;
                    o.argument.action = 'inner';
                }
                if (responseObj.js) {       
                    var js = Sly.util.getJsContent(responseObj.js);
                    if (typeof(js) == 'function') {
                        js();
                    }
                }
            }
            Sly.util.loadNonEssentialImages();
            Sly.util.dynamicRequestSuccess.fire(o);
        }

        if (o.argument.mod) {
            Sly.util.firePageTracker(o.argument.mod);
        }            
        
    };
    this.responseFailure = function(o){
        consoleLog('failure!');
        Sly.util.dynamicRequestFailure.fire('dynamicRequestFailure', o.argument);
    };
};
Sly.dynamicModule.prototype = {
    startDynamicAction: function(type, arg, me){

        if (arg[1].mod == me.name) {
            me.performDynamicAction(arg[1], me);
        }
    },
    getDynamicContent: function(arg){
        var callback = {
            success: this.responseSuccess,
            failure: this.responseFailure,
            argument: {
                containerElem: arg.containerElem,
                targetElem: arg.targetElem,
                mod: arg.mod
            }
        };
        YAHOO.util.Connect.initHeader('Ajax-Request', arg.mod);
        var quest = '';
        if (arg.targetElem.href.indexOf('?') == -1) {
            quest = '?';
        }
        var url = arg.targetElem.href + quest + "&rnd=" + Math.random();
        callback.argument.url = url;
        YAHOO.util.Connect.resetFormState();
        var dynamicRequest = YAHOO.util.Connect.asyncRequest('GET', url, callback, false);
        Sly.util.dynamicRequest.fire(arg.mod, callback.argument);
    }
    
};
Sly.dynamicForm = function(name , specialCase, specialCaseCallback ){
    Sly.dynamicForm.superclass.constructor.call(this, name );
    var handleChange = function(e){
        var elem = YAHOO.util.Event.getTarget(e);
        specialCase = specialCase ? specialCase : null;
        var continueProcessing = true;
        if (YAHOO.util.Dom.hasClass(elem, 'autosave')) {

            if (elem.value != elem.initalValue && elem.value !== specialCase) {
                continueProcessing = Sly.util.dispatchDynamicEvent(e, elem);
            } else if (elem.value === specialCase) {
                specialCaseCallback();                                  
            }
        }
    };
    var handleSubmit = function(e){
        var elem = YAHOO.util.Event.getTarget(e);
        if (elem.nodeName == 'FORM') {
            elem = elem.firstChild;
        }        
        var continueProcessing = true;
        if (this.nodeName == 'FORM') {
            continueProcessing = Sly.util.dispatchDynamicEvent(e, elem);
        }
    };
    this.reattachEvents = function(type, arg, me){
        if (type && (arg[1].mod != me.name)) {
            return false;
        } else if (type) {
            name = me.name;
        } else {
            name = this.name;
        }
        var forms = YAHOO.util.Dom.getElementsByClassName('mod__' + name, 'FORM');
        for (var i = 0; i < forms.length; i++) {
            var form = forms[i];
            var autoInputs = YAHOO.util.Dom.getElementsByClassName('autosave', null, form);
            for (var j = 0; j < autoInputs.length; j++) {
                var input = autoInputs[j];
                input.initalValue = input.value;
            }
            YAHOO.util.Event.removeListener(autoInputs, 'change', handleChange);
            YAHOO.util.Event.addListener(autoInputs, 'change', handleChange);
            YAHOO.util.Event.removeListener(form, 'submit', handleSubmit);
            YAHOO.util.Event.addListener(form, 'submit', handleSubmit);
        }
    };
    this.focusFirstTextInput = function(){
        var forms = YAHOO.util.Dom.getElementsByClassName('mod__' + this.name, 'FORM');
        for (var i = 0; i < forms.length; i++) {
            var form = forms[i];
            var inputs = form.getElementsByTagName('INPUT');
            for (var j = 0; j < inputs.length; j++) {
                var input = inputs[j];
                if (input.type == 'text') {
                    input.focus();
                    return;
                }
            }
        }
    };
    this.reattachEvents();
    Sly.util.dynamicRequestSuccess.subscribe(this.reattachEvents, this);
    Sly.util.dynamicChangeEvent.subscribe(this.startDynamicAction, this);
    Sly.util.dynamicSubmitEvent.subscribe(this.startDynamicAction, this);
    this.performDynamicAction = function(arg, me){
        if (arg.containerElem.nodeName == 'FORM') {
            this.getDynamicContent(arg, me);
        }
    };
};
YAHOO.lang.extend(Sly.dynamicForm, Sly.dynamicModule);
Sly.dynamicForm.prototype.getDynamicContent = function(arg, me){
    var callback = {
        success: this.responseSuccess,
        failure: this.responseFailure,
        argument: {
            containerElem: arg.containerElem,
            targetElem: arg.targetElem,
            mod: arg.mod
        }
    };
    if (YAHOO.util.Dom.hasClass(arg.targetElem, 'jSubmit')) {        
        var inputs = arg.containerElem.getElementsByTagName('INPUT');
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].name == 'jSubmit') {
                inputs[i].value = Sly.util.getClassValue(arg.targetElem, 'jSubmitVal');
                
            }
        }
    }
    
    if (YAHOO.util.Dom.hasClass(arg.targetElem, 'jSubmitHidden')) {        
        var inputs = arg.containerElem.getElementsByTagName('INPUT');
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].name == 'jSubmitHidden') {
                inputs[i].value = Sly.util.getClassValue(arg.targetElem, 'jSubmitHiddenVal');
                
            }
        }
    }    

    
    
    
    if (arg.containerElem.nodeName == 'FORM') {

        YAHOO.util.Connect.setForm(arg.containerElem);
        callback.argument.url = arg.containerElem.action;        
    } else {
        return false;
    }
    var now = new Date();
    var time = now.getTime();
    var previous = Sly.util.dynamicRequests[Sly.util.dynamicRequests.length - 1];
    if ((time - previous) > 500) {
        Sly.util.dynamicRequests[Sly.util.dynamicRequests.length] = time;

        YAHOO.util.Connect.initHeader('Ajax-Request', arg.mod);
        
        var dynamicRequest = YAHOO.util.Connect.asyncRequest('POST', arg.containerElem.action, callback);
        Sly.util.dynamicRequest.fire('dynamicRequest', callback.argument);
    } else {
        consoleLog('cancelledRequest');
        return false;
    }
};
var loadingIndicator = function(){
    var dynamicRequestHandle = function(type, arg, me){

        var loader = document.getElementById('loader');
        if (!loader) {
            loader = document.createElement('DIV');
            loader.id = 'loader';
            document.body.appendChild(loader);
        }

        var container = arg[1].containerElem;
        var parentMod = null;

        var loadingClassName = Sly.util.getClassValue(container, 'loadingClass');

        if (loadingClassName) {
       
            var elems = YAHOO.util.Dom.getElementsByClassName( loadingClassName );
            if ( elems ) {
                container = elems[0];
            }
        }
        
        var width = container.offsetWidth;
        var height = container.offsetHeight;   
        var xy = YAHOO.util.Dom.getXY(container);        
        
        if (YAHOO.util.Dom.hasClass(container, 'mod')) {            
            var parentModWidth = width;            
        } else {
            parentMod = YAHOO.util.Dom.getAncestorByClassName(container, 'mod');            
            var parentModWidth = parentMod.offsetWidth;                
        }
                
        if (YAHOO.util.Dom.hasClass(container, 'mod') || parentMod) {            
            var offset = 8;
            if ( !YAHOO.lang.isUndefined( Sly.template.isInFrame ) ) {
                offset = 0;
            }
            if (width == parentModWidth) {
                width = width - offset*2;
                height = height - offset*2;
                xy[0] = xy[0] + offset;
                xy[1] = xy[1] + offset;
            }
        }
        loader.className = arg[0];
        YAHOO.util.Dom.setStyle(loader, 'width', width + 'px');
        YAHOO.util.Dom.setStyle(loader, 'height', height + 'px');
        YAHOO.util.Dom.setStyle(loader, 'opacity', '0.3');
        YAHOO.util.Dom.setStyle(loader, 'display', 'block');
        YAHOO.util.Dom.setXY(loader, xy);
        
    };
    var dynamicRequestSuccessHandle = function(type, arg, me){
        var loader = document.getElementById('loader');
        if (!loader) {
            return;
        }
        var attributes = {
            opacity: {
                to: 0
            }
        };
        var hideElement = function(){
            var el = this.getEl();
            YAHOO.util.Dom.setStyle(el, 'display', 'none');
        };
        var anim = new YAHOO.util.Anim(loader, attributes, 0.5, YAHOO.util.Easing.easeOut);
        anim.onComplete.subscribe(hideElement);
        anim.animate();

    };
    Sly.util.dynamicRequest.subscribe(dynamicRequestHandle, this);
    Sly.util.dynamicRequestSuccess.subscribe(dynamicRequestSuccessHandle, this);
}();

