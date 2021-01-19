// posts data to a google sheets
// this is modified from: http://railsrescue.com/blog/2015-05-28-step-by-step-setup-to-send-form-data-to-google-sheets/
// follow directions at this site to set up google doc; google_sheet_link must be passed to this function

// variable to hold request
var request;

function post_data(experiment_data, google_sheet_link){

    // Abort any pending request
    if (request) {
        request.abort();
    }
    
    // Fire off the request to /form.php
    request = $.ajax({
        url: google_sheet_link,
        type: "post",
        data: experiment_data
    });

    // Callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        // Log a message to the console
        console.log("Hooray, it worked!");
        console.log(response);
        console.log(textStatus);
        console.log(jqXHR);
    });

    // Callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // Log the error to the console
        console.error(
            "The following error occurred: "+
            textStatus, errorThrown
        );
    });
}
