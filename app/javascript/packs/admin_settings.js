// AUTHOR: HERLEEN KAUR
// Code related to JS for the admin settings homepage (accessed by clicking 'Assign Admins & Edit Interface' from admin homepage)
// This includes switching between the 'assign admins' and 'edit interface' tabs and the relevant buttons for each form

$(document).ready(function(){
    // handles radio buttons for challenges
    $("#type_site").on("click", function(){
        thisRadio = $(this);
        thatRadio = $("#type_user");
        if (thisRadio.hasClass("imChecked")) {
            thisRadio.removeClass("imChecked");
            thisRadio.prop('checked', false);
            thatRadio.prop('checked', true);
            thatRadio.addClass("imChecked");
        } else {
          $(".challenge-radio").removeClass("imChecked");
          thatRadio.removeClass("imChecked");
          thatRadio.prop('checked', false);
          thisRadio.prop('checked', true);
          thisRadio.addClass("imChecked");
        }
    });
    $("#type_user").on("click", function(){
        thisRadio = $(this);
        thatRadio = $("#type_site");
        if (thisRadio.hasClass("imChecked")) {
            thisRadio.removeClass("imChecked");
            thisRadio.prop('checked', false);
            thatRadio.prop('checked', true);
            thatRadio.addClass("imChecked");
        } else {
          $(".challenge-radio").removeClass("imChecked");
          thatRadio.removeClass("imChecked");
          thatRadio.prop('checked', false);
          thisRadio.prop('checked', true);
          thisRadio.addClass("imChecked");
        }
    });

    // handles clicking on the interface tab
    $("#interface-tab").on('click', function() {
    // edits the look of the tabs (if active or inactive)
        if ($("#interface-tab").hasClass("admin-nav-active")){
            return;
        } else {
            $("#interface-tab").removeClass("admin-nav-inactive");
            $("#interface-tab").addClass("admin-nav-active");
            if ($("#admin-tab").hasClass("admin-nav-active")){
                $("#admin-tab").removeClass("admin-nav-active");
                $("#admin-tab").addClass("admin-nav-inactive");
            };
            // shows the interface page and hides the assign admin form
            $("#assign-admin-div").hide();
            $("#edit-interface-div").show();
        }
    });
    $("#admin-tab").on('click', function() {
        // edits the look of the tabs (if active or inactive)
        if ($("#admin-tab").hasClass("admin-nav-active")){
            return;
        } else {
            $("#admin-tab").removeClass("admin-nav-inactive");
            $("#admin-tab").addClass("admin-nav-active");
            if ($("#interface-tab").hasClass("admin-nav-active")){
                $("#interface-tab").removeClass("admin-nav-active");
                $("#interface-tab").addClass("admin-nav-inactive");
            };
            // shows the assign admin page and hides the interface form
            $("#edit-interface-div").hide();
            $("#assign-admin-div").show();
        }
    });

    // shows the confirmation page of assigning an admin
    $(".assign-admin").on("click", function () {
        thisDiv = $("#create-admin-form");

        if (thisDiv.css("display") == "none") {
            thisDiv.show();
        } else {
            thisDiv.hide();
        }
    });
    // shows the cancel page of assigning an admin
    $("#admin-cancel").on("click", function () {
        thisDiv = $("#create-admin-form");
        thisDiv.hide();

        $("#create-admin-cancel").show();
    });

    // form validation of assign admin form
    $("#admin-submit").on("click", function () {
        if($("#admin-name").val().empty() && $("#admin-email").val().empty()) {
            alert("Submission failed: please enter a name and email")
        }
        else if($("#admin-name").val().empty()) {
            alert("Submission failed: please enter a name")
        }
        else if($("#admin-email").val().empty()) {
            alert("Submission failed: please enter an email")
        }
        else {
            thisDiv = $("#create-admin-form");
            thisDiv.hide();
            $("#create-admin-submit").show();
        }
    });
    $("#admin-back").on("click", function () {
        thisDiv = $("#create-admin-cancel");
        thisDiv.hide();
        $("#create-admin-form").show();
    });

    // clicking on either of the Facebook or Google auth checkboxes reveals the necessary input fields
    if ($("#edit_facebookauth").prop("checked") == true) {
        $("#edit_facebookauth_fields").show();
    }
    if ($("#edit_googleauth").prop("checked") == true) {
        $("#edit_googleauth_fields").show();
    }

    $("#edit_facebookauth").on("click", function(){
        thisBox = $(this);
        if (thisBox.prop("checked") == true) {
            $("#edit_facebookauth_fields").show();
        } else {
            $("#edit_facebookauth_fields").hide();
        }
    });
    $("#edit_googleauth").on("click", function(){
        thisBox = $(this);
        if (thisBox.prop("checked") == true) {
            $("#edit_googleauth_fields").show();
        } else {
            $("#edit_googleauth_fields").hide();
        }
    });
});