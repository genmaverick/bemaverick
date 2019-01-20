window.MAV = window.MAV || {};
window.MAV.lib = window.MAV.lib || {};
window.MAV.lib.Comments = (function() {
  var site = null;
  var isInit = false;
  var $ = null;
  var hasTwilio = false;
  var twilioClient = null;
  var apiToken = null;
  var commentApiDomain = null; // TODO: load from config
  var svgLoader =
    '<svg width="20" height="20" viewBox="0 0 45 45" xmlns="http://www.w3.org/2000/svg" stroke="#00a8b0"> <g fill="none" fill-rule="evenodd" transform="translate(1 1)" stroke-width="2"> <circle cx="22" cy="22" r="6" stroke-opacity="0"> <animate attributeName="r" begin="1.5s" dur="3s" values="6;22" calcMode="linear" repeatCount="indefinite" /> <animate attributeName="stroke-opacity" begin="1.5s" dur="3s" values="1;0" calcMode="linear" repeatCount="indefinite" /> <animate attributeName="stroke-width" begin="1.5s" dur="3s" values="2;0" calcMode="linear" repeatCount="indefinite" /> </circle> <circle cx="22" cy="22" r="6" stroke-opacity="0"> <animate attributeName="r" begin="3s" dur="3s" values="6;22" calcMode="linear" repeatCount="indefinite" /> <animate attributeName="stroke-opacity" begin="3s" dur="3s" values="1;0" calcMode="linear" repeatCount="indefinite" /> <animate attributeName="stroke-width" begin="3s" dur="3s" values="2;0" calcMode="linear" repeatCount="indefinite" /> </circle> <circle cx="22" cy="22" r="8"> <animate attributeName="r" begin="0s" dur="1.5s" values="6;1;2;3;4;5;6" calcMode="linear" repeatCount="indefinite" /> </circle> </g></svg>';

  var _setLoading = function(loading) {
    var input = $(".comments__form form input");
    var button = $(".comments__form form button");
    if (loading) {
      $(input)
        .prop("disabled", true)
        .css("font-style", "italic");
      $(button)
        .prop("disabled", true)
        .css("color", "#666666");
      $(".commentLoader").html(svgLoader);
    } else {
      $(input)
        .prop("disabled", false)
        .css("font-style", "normal");
      $(button)
        .prop("disabled", false)
        .css("color", "#00a8b0");
      $(".commentLoader").html("");
    }
  };

  var _appendComment = function(comment) {
    var body = comment.body;
    var author = comment.meta.user.username;
    var mentions = comment.meta.mentions;
    // TODO: convert mentions to links in body
    for (var i = 0; i < mentions.length; i++) {
      var user = mentions[i];
      body = body.replace(user.username, '<a href="/users/' + user.userId + '">' + user.username + "</a>");
    }
    var commentsContainer = $(".comments");
    if (commentsContainer.length) {
      commentsContainer.append('<div class="one-comment"><a>' + author + "</a>" + body + "</div>").scrollTop(commentsContainer[0].scrollHeight);
    }
  };

  var _createComment = function(body, parentType, parentId) {
    _setLoading(true);
    var options = {
      async: true,
      crossDomain: true,
      url: commentApiDomain,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: apiToken
        // "Cache-Control": "no-cache"
      },
      contentType: "application/json",
      data: JSON.stringify({
        body: body,
        parentType: parentType,
        parentId: parentId
      })
    };

    $.ajax(options)
      .done(function(response) {
        _setLoading(false);
        _appendComment(response);
        var input = $(".comments__form form input");
        $(input).val("");
      })
      .fail(function(error) {
        _setLoading(false);
        window.alert("Error: Could not post comment");
      });
  };

  var _initCommentForm = function() {
    $(".comments__form form").on("submit", function(e) {
      e.preventDefault();
      var commentBody = e.target.commentBody.value;
      if (commentBody) {
        // send comment to api
        _createComment(commentBody, parentType, parentId);
      }
      return false;
    });
  };

  var _loadConfig = function() {
    var container = $("[data-comments-api-key]");
    apiToken = container.attr("data-comments-api-key");
    commentApiDomain = container.attr("data-comments-api-url");
    parentId = container.attr("data-comments-parentId");
    parentType = container.attr("data-comments-parentType");
  };

  var _scrollHeight = function() {
    var container = $(".comments");
    if (container.length) {
      container.scrollTop(container[0].scrollHeight);
    }
  };

  var _init = function() {
    _loadConfig();
    _scrollHeight();
    _initCommentForm();
  };

  return {
    init: function(initSite, jquery) {
      if (isInit) {
        return;
      }
      isInit = true;
      $ = jquery;
      site = initSite;
      $(document).on("site:insert", _init);
    }
  };
})();
