window.MAV = window.MAV || {};
window.MAV.controllers = window.MAV.controllers || {};
window.MAV.controllers.Users = (function() {
    var site = null;
    var isInit = false;
    var $ = null;

    var _updateUserStatuses = function(userStatuses) {
        $.each(userStatuses, function(index, userStatus) {
            userItems = $(site.containers.main + ' [data-user-id="' + userStatus.id + '"]');
            if (userItems.length) {
                var status = userStatus.isFollowing ? true : false;
                userItems.attr("data-is-following", userStatus.isFollowing);
            }
        });
    };

    var _initUserProfileEdit = function(obj) {
        $.getCachedScript(site.config.externalJs.upload).done(function(script, textStatus) {
            Dropzone.autoDiscover = false;
            _initProfileDropzone();
        });
    };

    var _initProfileDropzone = function() {
        $(".dropzone-form").each(function(index, form) {
            form = $(form);
            var previewContainer = form.find(".profile-image");
            var dropzone = new Dropzone(form[0], {
                paramName: "profileImage",
                thumbnailWidth: null,
                thumbnailHeight: null,
                headers: {
                    "Ajax-Request": "dynamicModule"
                },
                acceptedFiles: ".jpg,.jpeg,.png",
                autoProcessQueue: false,
                maxFiles: 1,
                previewsContainer: previewContainer[0],
                transformFile: function(file, done) {
                    $(file.previewElement).find('img').croppie('result', {
                        type: 'base64'
                    }).then(function (res) {
                        done(Dropzone.dataURItoBlob(res));
                    });
                }
            });

            form.on("click", "[data-dz-remove]", function(e) {
                e.preventDefault();
                if (dropzone.files.length > 0) {
                    dropzone.removeAllFiles();
                } else {
                    form.append('<input type="hidden" name="profileImage" value="-1" />')
                        .find(".profile-image")
                        .append('<div class="profile-image-placeholder svgicon--profile-default"></div>');
                }

                if (!form.find("img, .profile-image-proxy").length) {
                    form.find("[data-dz-add]").text('Add Photo');
                    $(this).hide();
                }
            });

            form.on("submit", function(e) {
                e.preventDefault();
                if (dropzone.files.length < 1) {
                    return true;
                } else {
                    e.stopPropagation();
                    dropzone.processQueue();
                }
            });

            dropzone.on("addedfile", function(file) {
                if (dropzone.files.length > 1) {
                    dropzone.removeFile(dropzone.files[0])
                }
                form.find("[data-dz-add]").text('Replace Photo');
                form.find("[data-dz-remove]").show();
                form.find('[name="profileImage"]').remove();
            });

            dropzone.on("complete", function(e) {
                var args = {
                    isForm: true,
                    responseTime: new Date().getTime()
                };
                site.successAction(args, JSON.parse(e.xhr.response, e.xhr.statusText, e.xhr));
            });

            dropzone.on("thumbnail", function(file) {
                var img = form.find(".dz-image img");
                var height = file.height ? file.height : img.height();
                var width = file.width ? file.width : img.width();
                var counter = 0;
                var zoom = 225 / width;
                var isDisabled = true;
                img.croppie({
                    enforceBoundary: true,
                    mouseWheelZoom: true,
                    showZoomer: false,
                    viewport: { width: 128, height: 128, type: "circle" },
                    update: function() {
                        if (counter == 0) {
                            counter++;
                            img.croppie("setZoom", zoom + "");
                        }
                    }
                });
            });
        });
    };

    var _init = function(e, obj) {
        if (obj.subType == "user-edit-following-confirm") {
            _updateUserStatuses(obj.userStatuses);
        } else if (obj.subType == "user-profile-edit") {
            _initUserProfileEdit(obj);
        }

        if (e) {
            $.event.trigger("site:finishInit", obj);
        }
    };

    var _handleKidSelectToggle = function(e) {
        $("#kidselect-menu").toggleClass("is-shown");
    };

    return {
        init: function(initSite, jquery) {
            if (isInit) {
                return;
            }
            isInit = true;
            $ = jquery;
            site = initSite;
            if (site.config.debugMode) {
                console.log("Users.init");
            }
            $(document).on("users:init", _init);
            $(site.containers.main).on("click", "#kidselect-icon", _handleKidSelectToggle);
        }
    };
})();
