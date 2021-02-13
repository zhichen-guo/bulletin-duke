// AUTHOR: HERLEEN KAUR AND ZHICHEN GUO
// Code related to JS for the initial customize interface page that is displayed when there is no interface created
// This includes code for arrow navigation and revealing authentication fields, and also form validation

$(document).ready(function(){

    // form validation
    function invalidInput(tag, message) {
        if ($("input:invalid").hasClass(tag)) {
            $(message).show();
        } else {
            $(message).hide();
        }
    }

    function emptyInput(tag, message){
        if (!$(tag).prop("disabled") && $(tag).val().trim() == ""){
            $(message).show();
        } else {
            $(message).hide();
        }
    }

    function emptyInvalidInput(tag, message1, message2) {
        if ($("input:invalid").hasClass(tag)) {
            if ($("#" + tag).val().trim() == "") {
                $(message2).show();
                $(message1).hide();
            } else {
                $(message1).show();
                $(message2).hide();
            }
        } else {
            $(message1).hide();
            $(message2).hide();
        }
    }

    // alerts with confirmation message of submitting entire form
    $("#custom-interface-submit").on("click", function() {
        alert("You are about to submit this form. Are you sure you want to do this? Please note that this form may take up to 3-5 minutes to submit after you hit OK. Do not click out of this browser or click the submit button more than once. Thank you!");
    });
    
    // navigating from step 1 to step 2
    // form validation of first page
    $("#custom-one-to-two").on("click", function() {
        if ($("input:invalid").hasClass("custom-pg1-tag")){
            emptyInvalidInput("custom-email-1", "#email-invalid-1", "#email-empty-1");
            emptyInput("#custom-name-1", "#name-empty-1");
            emptyInput("#custom-inst-name", "#inst-empty");
            emptyInput("#fb-client-id", "#fb-id-empty");
            emptyInput("#fb-client-secret", "#fb-secret-empty");
            emptyInput("#google-client-id", "#google-id-empty");
            emptyInput("#google-client-secret", "#google-secret-empty");
            emptyInput("#fb-redirect-url", "#fb-url-empty");
            emptyInput("#google-redirect-url", "#google-url-empty");
        } else {
            $("#google-id-empty").hide();
            $("#google-secret-empty").hide();
            $("#fb-id-empty").hide();
            $("#fb-secret-empty").hide();
            $("#email-empty-1").hide();
            $("#email-invalid-1").hide();
            $("#inst-empty").hide();
            $("#name-empty-1").hide();
            $("#custom-step-one").hide();
            $("#header-step-1").hide();
            $("#custom-step-two").show();
            $("#header-step-2").show();
        }
    });
    
    // navigating from step 2 back to step 1
    $("#custom-two-to-one").on("click", function() {
        $("#custom-step-two").hide();
        $("#header-step-2").hide();
        $("#custom-step-one").show();
        $("#header-step-1").show();
    });

    
    // navigating from step 2 to step 3
    // form validation of second page
    $("#custom-two-to-three").on("click", function() {
        if ($("input:invalid").hasClass("ui-color-input")) {
            invalidInput("primary-color-input", "#hex-invalid-1");
            invalidInput("secondary-color-input", "#hex-invalid-2");
            invalidInput("accent-color-input", "#hex-invalid-3");
        } else {
            $("#hex-invalid-3").hide();
            $("#hex-invalid-2").hide();
            $("#hex-invalid-1").hide();
            $("#custom-step-two").hide();
            $("#header-step-2").hide();
            $("#custom-step-three").show();
            $("#header-step-3").show();
        };
    });

    // navigating from step 3 back to step 2
    $("#custom-three-to-two").on("click", function() {
        $("#custom-step-three").hide();
        $("#header-step-3").hide();
        $("#custom-step-two").show();
        $("#header-step-2").show();
    });

    // clicking on either of the Facebook or Google auth checkboxes reveals the necessary input fields
    if ($("#facebookauth").prop("checked") == true) {
        $("#facebook-auth-fields").show();
    }
    if ($("#googleauth").prop("checked") == true) {
        $("#google-auth-fields").show();
    }
    $("#facebookauth").on("click", function(){
        thisBox = $(this);
        if (thisBox.prop("checked") == true) {
            $("#facebook-auth-fields").show();
            $("#fb-client-id").prop("disabled", false);
            $("#fb-client-secret").prop("disabled", false);
            $("#fb-redirect-url").prop("disabled", false);
        } else {
            $("#facebook-auth-fields").hide();
            $("#fb-client-id").prop("disabled", true);
            $("#fb-client-secret").prop("disabled", true);
            $("#fb-redirect-url").prop("disabled", true);
        }
    });
    $("#googleauth").on("click", function(){
        thisBox = $(this);
        if (thisBox.prop("checked") == true) {
            $("#google-auth-fields").show();
            $("#google-client-id").prop("disabled", false);
            $("#google-client-secret").prop("disabled", false);
            $("#google-redirect-url").prop("disabled", false);
        } else {
            $("#google-auth-fields").hide();
            $("#google-client-id").prop("disabled", true);
            $("#google-client-secret").prop("disabled", true);
            $("#google-redirect-url").prop("disabled", true);
        }
    });

    // shows the second landmark field and the plus button for the third landmark
    $("#custom-address-plus2").on("click", function() {
        $("#custom-address-plus2").hide();
        $("#custom-address-2").css("display", "flex");
        $("#custom-address-cancel2").show();
        $(".address-input-2").prop("disabled", false);
        if ($("#custom-address-3").css("display") == "none") {
            $("#custom-address-plus3").show();
        }
    });
    // shows the third landmark field
    $("#custom-address-plus3").on("click", function() {
        $("#custom-address-plus3").hide();
        $("#custom-address-3").css("display", "flex");
        $("#custom-address-cancel3").show();
        $(".address-input-3").prop("disabled", false);
    });
    // hides the second landmark and displays the plus button for the second landmark
    $("#custom-address-cancel2").on("click", function() {
        $("#custom-address-2").hide();
        $("#custom-address-cancel2").hide();
        $("#custom-address-plus2").show();
        $("#custom-address-plus3").hide();
        $(".address-input-2").prop("disabled", true);
    });
    // hides the third landmark and displays the plus button for the third landmark 
    $("#custom-address-cancel3").on("click", function() {
        $("#custom-address-3").hide();
        $("#custom-address-cancel3").hide();
        $(".address-input-3").prop("disabled", true);
        if ($("#custom-address-2").css("display") == "flex") {
            $("#custom-address-plus3").show();
        }
    });
});
