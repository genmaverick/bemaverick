window.MAV = window.MAV || {};
window.MAV.controllers = window.MAV.controllers || {};
window.MAV.controllers.Challenges = (function() {
    var site = null;
    var isInit = false;
    var $ = null;
    var hasUploadJs = false;

    var _initChallengeReponseAdd = function() {
        if (hasUploadJs) {
            _initDropzones();
        } else {
            $.getCachedScript(site.config.externalJs.upload).done(function(script, textStatus) {
                Dropzone.autoDiscover = false;
                hasUploadJs = true;
                _initDropzones();
            });
        }
    };

    var _checkForm = function(form, dropzone) {
        var isFormValid = false;
        var responseType = "";
        if (dropzone.files.length > 0) {
            var isFormValid = true;
            if (dropzone.files[0] && dropzone.files[0].type.indexOf("image") !== -1) {
                responseType = "image";
            } else if (dropzone.files[0].type.indexOf("video") !== -1) {
                responseType = "video";
            }
            form.find("input, textarea").each(function(index, item) {
                item = $(item);
                if (item.prop("required") && !item.val()) {
                    isFormValid = false;
                    return false;
                }
            });
        }
        form.find(".response-type").val(responseType);
        if (isFormValid) {
            form.addClass("form-is-valid");
        } else {
            form.removeClass("form-is-valid");
        }
    };

    var previousFile = null;
    var _initDropzones = function() {
        previousFile = null;

        $(".dropzone-form").each(function(index, form) {
            form = $(form);
            var previewContainer = form.find(".dropzone-previews");
            var isDraggingSuppported = Dropzone.isBrowserSupported() && !site.detectedMobile;

            var dropzone = new Dropzone(form.find(".dropzone")[0], {
                paramName: "file",
                autoProcessQueue: false,
                url: form.attr("data-action"),
                method: form.attr("data-method"),
                addRemoveLinks: true,
                maxFiles: 1,
                maxFilesize: site.config.uploadFileSizeMax,
                thumbnailWidth: null,
                thumbnailHeight: null,
                headers: {
                    "Ajax-Request": "dynamicModule"
                },
                acceptedFiles: ".jpg,.png,.jpeg,.mp4,.mov,.mpeg",
                previewsContainer: previewContainer[0],
                dictDefaultMessage: isDraggingSuppported
                    ? '<b></b> Drag file here or <span class="browse">Browse</span>'
                    : '<b></b> <span class="browse">Select</span> a file to upload'
            });

            // for video files, use frame-grab to generate a preview.
            dropzone.on("addedfile", function(file) {
                // check file extension, see:
                // http://stackoverflow.com/questions/190852/how-can-i-get-file-extensions-with-javascript

                if (file.status == "error") {
                    return "";
                }

                var comps = file.name.split(".");
                if (comps.length === 1 || (comps[0] === "" && comps.length === 2)) {
                    return;
                }
                var ext = comps.pop().toLowerCase();
                var isVideo = file.type.indexOf("video") != -1;
                if (isVideo || ext == "mov" || ext == "mpeg" || ext == "mp4" || ext == "wmv") {
                    // create a hidden <video> element with video file.
                    FrameGrab.blob_to_video(file).then(
                        function videoRendered(videoEl) {
                            var frameGrab = new FrameGrab({ video: videoEl });
                            frameGrab.grab("img", 0).then(
                                function frameGrabbed(itemEntry) {
                                    dropzone.emit("thumbnail", file, itemEntry.container.src);
                                },
                                function frameFailedToGrab(reason) {
                                    console.log("Can't grab the video frame from file: " + file.name + ". Reason: " + reason);
                                }
                            );
                        },
                        function videoFailedToRender(reason) {
                            console.log("Can't convert the file to a video element: " + file.name + ". Reason: " + reason);
                        }
                    );
                }
            });

            dropzone.on("addedfile", function() {
                if (previousFile) {
                    this.removeFile(previousFile);
                }
                previousFile = this.files[0];
                _checkForm(form, dropzone);
            });

            dropzone.on("error", function(e, message) {
                if (message) {
                    alert(message);
                }
                if (previousFile) {
                    this.removeFile(previousFile);
                    previousFile = null;
                }
            });
            dropzone.on("removedfile", function() {
                previousFile = null;
                _checkForm(form, dropzone);
            });
            dropzone.on("sending", function(file, xhr, formData) {
                form.find("input, textarea").each(function(index, item) {
                    item = $(item);
                    formData.append(item.attr("name"), item.val());
                });
            });
            dropzone.on("complete", function(e) {
                if (!e || !e.xhr || !e.xhr.response) {
                    return;
                }

                var args = {
                    isForm: true,
                    responseTime: new Date().getTime()
                };
                site.successAction(args, JSON.parse(e.xhr.response), e.xhr.statusText, e.xhr);
            });

            form.find(".submit").on("click", function(e) {
                if (form.hasClass("form-is-valid")) {
                    dropzone.processQueue();
                }
            });
            dropzone.on("thumbnail", function(file) {
                var img = form.find(".dz-image img");
                var height = file.height ? file.height : img.height();
                var width = file.width ? file.width : img.width();
                var counter = 0;
                var zoom = 225 / width;
                var isDisabled = true;
                img.croppie({
                    enforceBoundary: false,
                    mouseWheelZoom: isDisabled ? false : true,
                    showZoomer: isDisabled ? false : true,
                    viewport: { width: 225, height: 300, type: "square" },
                    update: function() {
                        if (counter == 0) {
                            counter++;
                            img.croppie("setZoom", zoom + "");
                        }
                        console.log(img.croppie("get"));
                    }
                });
                if (isDisabled) {
                    form.find(".dz-image").addClass("disabled");
                }
            });
            form.find("input, textarea").on("input change", function(e) {
                _checkForm(form, dropzone);
            });
        });
    };

    var _init = function(e, obj) {
        if (obj.subType == "challenge-add-response") {
            _initChallengeReponseAdd();
        }
        if (e) {
            $.event.trigger("site:finishInit", obj);
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
            if (site.config.debugMode) {
                console.log("Challenges.init");
            }
            $(document).on("challenges:init", _init);
        }
    };
})();
