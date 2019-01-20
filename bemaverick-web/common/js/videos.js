window.MAV = window.MAV || {};
window.MAV.lib = window.MAV.lib || {};
window.MAV.lib.Videos = (function() {
    var isInit = false;

    var permCookieDefaults = {
        domain: "",
        path: "/",
        expires: new Date("January 12, 2025")
    };

    var muted = false;
    var videoPlayers = {};

    var _handleVideoInsert = function(e, obj) {
        var player = $(obj.selector);
        _initVideoPlayer(player);
    };

    var _getPlayerFromVideoElement = function(videoElement) {
        return $(videoElement).closest(".video-player");
    };
    var _getVideoElementFromPlayer = function(player) {
        return player.find("video").get(0);
    };
    var _getVideoFromPlayer = function(player) {
        return player.find("video");
    };

    var _updateTime = function(player) {
        var videoElem = _getVideoElementFromPlayer(player);
        var currentTime = videoElem.currentTime;
        var duration = videoElem.duration;
        if (duration) {
            player.find(".video-player__timeline-elapsed").css({
                width: currentTime / duration * 100 + "%"
            });
        }
    };

    var _handleVideoTimeUpdate = function(e) {
        _updateTime(_getPlayerFromVideoElement(e.currentTarget));
    };

    var _updateStatus = function(player, status) {
        var videoElem = _getVideoElementFromPlayer(player);
        player.attr("data-video-status", status);
    };

    var _handleVideoStatus = function(e) {
        var status = "not-playing";
        if (e.type == "playing") {
            status = "playing";
        }
        _updateStatus(_getPlayerFromVideoElement(e.currentTarget), status);
    };

    var _initVideoPlayer = function(player) {
        var autoplay = player.data("autoplay");
        var video = _getVideoFromPlayer(player);
        var videoElement = _getVideoElementFromPlayer(player);
        videoElement.muted = muted;
        player.attr("data-video-sound", muted ? "off" : "on");
        if (autoplay) {
            var videoElement = video.get(0);
            videoElement.play();
        }

        video.on("timeupdate", _handleVideoTimeUpdate);
        video.on("playing pause ended waiting", _handleVideoStatus);
    };

    var _resizeVideoPlayer = function(player) {
        var videoElement = _getVideoElementFromPlayer(player);
        var height = videoElement.videoHeight;
        var width = videoElement.videoWidth;
        var ratio = width / height * 100;

        //player.css({
        //    width: ratio + "%",
        //    left: (100 - ratio) / 2 + "%"
        // });
        player.addClass("video-initialized");
    };

    var _handleVideoPauseClick = function(e) {
        console.log("_handleVideoPauseClick");
        e.currentTarget.pause();
    };
    var _handleVideoPlayClick = function(e) {
        console.log("_handleVideoPlayClick");
        e.currentTarget.play();
    };

    var _handleLoadedMetadata = function(e, obj) {
        _resizeVideoPlayer($(obj.selector));
    };

    var _handleMuteButtonClick = function(e) {
        var player = $(e.currentTarget).closest(".video-player");
        _toggleMute(player);
    };

    var _toggleMute = function(player) {
        if (muted) {
            muted = false;
        } else {
            muted = true;
        }

        player.attr("data-video-sound", muted ? "off" : "on");
        var videoElem = _getVideoElementFromPlayer(player);
        videoElem.muted = muted;
        var uiCookie = Cookies && Cookies.getJSON("ui");
        uiCookie = uiCookie ? uiCookie : {};
        uiCookie.muted = muted;
        Cookies.set("ui", uiCookie, permCookieDefaults);
    };

    var _init = function() {
        var uiCookie = Cookies && Cookies.getJSON("ui");
        if (uiCookie && uiCookie.muted) {
            muted = true;
        }
    };

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            _init();
            $(window).on("video:inserted", _handleVideoInsert);
            $(window).on("video:loadedmetadata", _handleLoadedMetadata);
            $(document).on("click", '.video-player[data-video-status="playing"] video', _handleVideoPauseClick);
            $(document).on("click", '.video-player[data-video-status="not-playing"] video', _handleVideoPlayClick);
            $(document).on("click", ".video-player .video-player__mute-button", _handleMuteButtonClick);
        }
    };
})();
