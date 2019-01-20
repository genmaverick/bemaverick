!(function() {
  var scrollable = true;
  var initFileSelectors = function() {
    var fileInputs = document.querySelectorAll('input[type="file"]');
    for (var input of fileInputs) {
      input.addEventListener("change", function(e) {
        var target = e.currentTarget;
        target.classList.toggle("has-file", target.value);
      });
    }
  };

  var setHiddenTypeahead = function(input) {
    var container = input.closest(".auto-complete");
    if (!container.length) {
      return;
    }
    var hiddenInput = container.find("input.hidden");
    var data = input.getSelectedItemData();

    var action = input.attr("data-auto-complete-action");

    if (action == "search") {
      if (data) {
        hiddenInput.val(data.id);
      } else {
        hiddenInput.val("");
      }
    } else if (action == "insert") {
      hiddenInput.val("");
      input.val("");
      insertIntoDataTable(data);
    }
  };
  var initTypeAheads = function() {
    var autocompleteContainers = $(".auto-complete");
    autocompleteContainers.each(function(index, container) {
      container = $(container);
      var input = container.find("input.form-control.text");
      var options = {
        url: function(phrase) {
          return input.attr("data-auto-complete-url") + "?query=" + phrase;
        },
        getValue: "searchText",
        list: {
          maxNumberOfElements: 20,
          match: {
            enabled: true
          },
          onChooseEvent: function(e) {
            setHiddenTypeahead(input);
          }
        }
      };

      input.easyAutocomplete(options);
      input.on("blur", function(e) {
        var target = $(e.currentTarget);
        if (target.length && !target.val()) {
          setHiddenTypeahead(target);
        }
      });
    });
  };

  var insertIntoDataTable = function(data) {
    console.log("data", data);
    if (!data || !data.id || !data.type) {
      return;
    }
    var table = $(".table-responsive table");
    if (table.find("." + data.type + "-" + data.id).length && false) {
      return;
    }
    var rows = table.find("thead tr");

    var statusToClassName = {
      published: "label-primary",
      hidden: "label-danger",
      active: "label-primary"
    };

    if (rows.length) {
      var html = '<tr class="' + data.type + "-" + data.id + '">';
      var row = $(rows[0]);
      var columns = row.find("th");
      columns.each(function(index, column) {
        column = $(column);
        var content = "";
        if (column.hasClass("id")) {
          content =
            data.id +
            '<input type="hidden" name="' +
            data.type +
            'Ids[]" value="' +
            data.id +
            '">';
        } else if (column.hasClass("status") && data.status) {
          var labelClass = statusToClassName[data.status]
            ? statusToClassName[data.status]
            : "label-default";
          content =
            '<span class="label ' +
            labelClass +
            '">' +
            ucFirst(data.status) +
            "</span>";
        } else if (column.hasClass("title") && data.title) {
          content = data.title;
        } else if (
          column.hasClass("createdTimestamp") &&
          data.createdTimestamp
        ) {
          content = data.createdTimestamp;
        } else if (column.hasClass("username") && data.username) {
          content = data.username;
        } else if (column.hasClass("userName") && data.userName) {
          content = data.userName;
        } else if (column.hasClass("profileImage") && data.profileImageUrl) {
          content =
            '<a href="' +
            data.profileImageUrl +
            '" target="_blank"><img src="' +
            data.profileImageUrl +
            '" width="100" height="100" /></a>';
        } else if (column.hasClass("mainImage") && data.mainImageUrl) {
          content =
            '<a href="' +
            data.originalImageUrl +
            '" target="_blank"><img src="' +
            data.mainImageUrl +
            '" width="60" height="108" /></a>';
        } else if (
          column.hasClass("videoThumbnail") &&
          data.videoThumbnailUrl
        ) {
          content =
            '<img src="' +
            data.videoThumbnailUrl +
            '" width="60" height="108" />';
        } else if (column.hasClass("tableRowDelete")) {
          content = '<div class="delete-button"></div>';
        }

        html += '<td class="' + column.attr("class") + '">' + content + "</td>";
      });
      html += "</tr>";
      html = $(html);
    }
    table.find("tbody").append(html);
  };

  var ucFirst = function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  var handleDeleteClick = function(e) {
    $(e.currentTarget)
      .closest("tr")
      .remove();
  };

  var handleFeaturedTypeChange = function(e) {
    $(e.currentTarget)
      .closest("form")
      .submit();
  };

  var initDraggableTables = function() {
    $("body").on("click", ".tableRowDelete .delete-button", handleDeleteClick);
    $("body").on("change", "#featuredType", handleFeaturedTypeChange);

    // limit dragging to desktop only
    if ($(window).width() > 760) {
      $(".table-draggable tbody").each(function(index, elem) {
        dragula({
          containers: [elem],
          delay: 200,
          direction: "vertical"
        })
          .on("drag", function(el, source) {
            scrollable = false;
          })
          .on("drop", function(el, source) {
            scrollable = true;
          });
      });
    } else {
      var upDownTd =
        '<td class="upDown"><a href="#" class="up"><span class="glyphicon glyphicon-chevron-up"></span></a><br> \
        <a href="#" class="down"><span class="glyphicon glyphicon-chevron-down"></span></a></td>';
      $(".table-draggable thead tr").prepend("<td>&nbsp;</td>");
      $(".table-draggable tbody tr").prepend(upDownTd);
    }

    // Enable up/down sorting
    $(".up,.down").click(function() {
      var row = $(this).parents("tr:first");
      if ($(this).is(".up")) {
        row.insertBefore(row.prev());
      } else {
        row.insertAfter(row.next());
      }
      // row.animate({ backgroundColor: "#FFF59D" }, "slow");
      row.css("background-color", "rgba(255, 245, 157, 1)");
      //   row.css("background-color", "#FFF59D");
      row.animate(
        {
          backgroundColor: "rgba(255, 255, 255, 0)"
        },
        1000
      );
      console.log("animate white");
    });
  };

  var handleSelectAllChange = function(e) {
    toggleSelectAll($(e.currentTarget));
  };

  var toggleSelectAll = function(item) {
    var selector = item.attr("data-action-selector");
    var checked = item.is(":checked");
    $(selector).prop("checked", checked);
  };
  var checkIfAllChecked = function(selector) {
    return;
    var allChecked = true;
    $(selector).each(function(index, item) {
      if (!$(item).is(":checked")) {
        allChecked = false;
      }
    });

    var selectAllCheckbox = $(
      'input.select-all[data-action-selector="' + selector + '"'
    );
    if (selectAllCheckbox.is(":checked") != allChecked) {
      $("body").off("change", "th input.select-all", handleSelectAllChange);
      $('input.select-all[data-action-selector="' + selector + '"').prop(
        "checked",
        allChecked
      );
      $("body").on("change", "th input.select-all", handleSelectAllChange);
    }
  };

  var handleCheckboxChange = function(e) {
    return;
    var item = $(e.currentTarget);
    var selector = item.attr("data-action-selector");
    checkIfAllChecked(selector);
  };

  var initSelectAll = function() {
    $("body").on("change", "th input.select-all", handleSelectAllChange);
    $("input.select-all").each(function(index, item) {
      item = $(item);
      var selector = item.attr("data-action-selector");
      $(selector)
        .attr("data-action-selector", selector)
        .on("change", handleCheckboxChange);

      checkIfAllChecked(selector);
    });
  };

  var handleDynamicRadioChange = function(e) {
    var item = $(e.currentTarget);
    var form = item.closest("form");
    form.submit();
  };

  var handleDynamicFormSubmit = function(e) {
    e.preventDefault();
    var form = $(e.currentTarget);
    $.ajax({
      url: form.attr("action"),
      method: form.attr("method").toUpperCase(),
      success: function(obj) {
        setTimeout(function() {
          form.removeClass("saving");
        }, 250);
      },
      error: function(obj) {
        alert("There was an error. Please refresh and try again.");
        form.addClass("error");
      },
      data: form.serializeArray(),
      dataType: "json",
      headers: {
        "Ajax-Request": "dynamicModule"
      }
    });
    form.addClass("saving");
  };

  var initOnChangeSelects = function() {
    $("body").on("change", 'select[data-on-change-submit="1"]', function(e) {
      var target = $(e.currentTarget);
      var form = target.closest("form");
      if (!target.val()) {
        window.location.href = form.attr("action");
      } else {
        form.submit();
      }
    });
  };

  var initDynamicForms = function() {
    if (!"form.dynamic-form".length) {
      return;
    }

    $("body").on("change", "form.dynamic-form input", handleDynamicRadioChange);
    $("body").on("submit", "form.dynamic-form", handleDynamicFormSubmit);
  };

  document.onreadystatechange = function() {
    if (document.readyState == "interactive") {
      initFileSelectors();
      initTypeAheads();
      initDraggableTables();
      initSelectAll();
      initDynamicForms();
      initOnChangeSelects();
    }
  };

  window.addEventListener(
    "touchmove",
    function(e) {
      if (!scrollable && $.browser.mobile) {
        e.preventDefault();
      }
    },
    { passive: false }
  );
})();
