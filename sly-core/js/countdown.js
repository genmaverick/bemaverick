YUI.add( "sly-countdown", function( Y ) {
    Y.namespace( 'Countdown' );
    var isInit = false;
    var timer;
    var startCountdown = function( obj ) {
        var targetTime = Y.Util.getClassValue( $(obj), 'cdTargetTime' );
        var serverLoadTime = Y.Util.getClassValue( $(obj), 'cdLoadTime' );
        var browserLoadTime = Math.round( new Date().getTime() / 1000 );
        var browserTimeCorrection = browserLoadTime - serverLoadTime; // calibrate to server to avoid weirdness based on local machine time
        this.timer = Y.later( 1000, this, updateCountdown, [ obj, targetTime, browserTimeCorrection ], true );
    }
    var updateCountdown = function( obj, targetTime, browserTimeCorrection ) {
        var currentBrowserTime = getCorrectedBrowserUnixTime( browserTimeCorrection );
        var timeRemaining = targetTime - currentBrowserTime;
        if ( timeRemaining == 0 ) {
            // done
            this.timer.cancel();
        }
        var daysRemaining = getWholeUnits( timeRemaining / ( 3600 * 24 ) );
        var hoursRemaining = getWholeUnits( ( timeRemaining - ( daysRemaining * ( 3600 * 24 ) ) ) / 3600 );
        var minutesRemaining = getWholeUnits( ( timeRemaining - ( daysRemaining * ( 3600 * 24 ) ) - ( hoursRemaining * 3600 ) ) / 60 );
        var secondsRemaining = ( timeRemaining - ( daysRemaining * ( 3600 * 24 ) ) - ( hoursRemaining * 3600 ) - ( minutesRemaining * 60 ) );
        obj.all( 'span' ).each( function( s ) {
            if ( s.hasClass( "days" ) ) {
                updateTimeChunk( s, daysRemaining, false );
            } else if ( s.hasClass( "hours" ) ) {
                updateTimeChunk( s, hoursRemaining, false );
            } else if ( s.hasClass( "minutes" ) ) {
                updateTimeChunk( s, minutesRemaining, true );
            } else if ( s.hasClass( "seconds" ) ) {
                updateTimeChunk( s, secondsRemaining, true );
            }
        } );
    }
    var getWholeUnits = function( x ) {
        if ( x < 0 ) {
            return Math.ceil( x );
        }
        return Math.floor( x );
    }
    var updateTimeChunk = function( chunk, time, forceDoubleDigits ) {
        time = Math.abs( time );
        if ( forceDoubleDigits && time.toString().length <= 1 ) {
            time = "0" + time;
        }
        chunk.setContent( time );
    }
    var getBrowserUnixTime = function() {
        return Math.round( new Date().getTime() / 1000 );
    }
    var getCorrectedBrowserUnixTime = function( browserTimeCorrection ) {
        return getBrowserUnixTime() - browserTimeCorrection;
    }
    Y.Countdown = {
        init: function() {
            if ( isInit ) {
                return;
            }
            isInit = true;
        },
        startCountdown: function( obj ) {
            startCountdown( obj );
        },
        startCountdowns: function( objs ) {
            objs.each( function( obj ) {
                startCountdown( obj );
            } );
        },
        updateCountdown: function( obj ) {
            updateCountdown( obj );
        }
    }
}, '0.1', {
    requires: [ 'node' ],
    optional: []
} );
