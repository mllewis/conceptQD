// SIMILARITY JUDGEMENT EXPERIMENT FOR PAIRS
// Overview: 
//      (1) Helper
//      (2) Parameters and Stimulus Setup 
//      (3) Control Flow

// ---------------- 1. HELPER ------------------
// this gets the stimuli data from google sheet (specified below)
function getTrialData(this_url) {
    Tabletop.init( { key: this_url,
                     callback: saveTrialsToVars,
                     simpleSheet: true } );
}

function saveTrialsToVars(data) {
    // data comes through as a simple array since simpleSheet is turned on
    td = data

    // get objs to preload
    objs = []
    for (i = 0; i < num_trials; i++) {
      objs.push("images/drawings/" + td[trial_ids[i]].key_id_1 + ".jpeg") 
      objs.push("images/drawings/" + td[trial_ids[i]].key_id_2 + ".jpeg")   
    }

    // preload  images
    $.fn.preload = function() {
      this.each(function(){
            $('<img/>')[0].src = this;
        });
    };

    // preload two - not sure if this works?
    var images = new Array() // By creating image object and setting source, images preload
    for (i=0;i<objs.length;i++) {
      images[i] = new Image()
      images[i].src = objs[i]  
    }

}

// ---------------- 2. EXPERIMENT SETUP ------------------

// Define experimenter defined parameters
var paper_width = 674;
var paper_height = 100;
var circle_width = 20
var ISI = 1000
var google_spreadsheet_data_url = "https://script.google.com/macros/s/AKfycbz07BK833vq-UxYc_vf9lp8510Wd1rhWdls2JU34_Ckmo14dfU/exec" // where data is saved; RETRIEVE: https://docs.google.com/spreadsheets/d/1gJyp_OeLf4xUT829-_eFGYGy3mV7rH3afsiSom1H8z8/edit#gid=0
var num_crit_trials = 50
var attention_check_indices = [25,50] // where do you want the attention checks (same pairs) to go [0 indexing]? 
var total_unique_trials = 200 // per condition
var secret_code_id = "_D_"
var num_conditions = 2

var current_category
var condition_switch = Math.floor((Math.random() * num_conditions))
if (condition_switch == 0){ // links to stimuli for different categories
  current_category = "bread"
  google_spreadsheet_stimuli_url = "1lnlKFr6c7wY5jcODUp-HIrKYUULNOVv05l5wo07u36U"  // get these by "publish to web -> share (upper right)"
} else if (condition_switch == 1){
  current_category = "tree"
  google_spreadsheet_stimuli_url = "1gwF2wVZrZqrcnTDYp165zEYoSNipZCufD2mUsHeg4ms" 
}

// Define derived parameters
var subj_id = getCode("", 5, 5, random = false, symbols = "numbers") // get subj id
var num_trials = num_crit_trials + attention_check_indices.length 
var centerX = paper_width / 2;
var centerY = paper_height / 2;
var paper = Raphael("drawing_canvas", paper_width, paper_height);
var condition_switch = Math.floor((Math.random() * num_conditions)); // get catetegory type (condition)

// Initialize experiment logic variables
var num_ratings = -1 //initialize at -1
var td // array of all trial data from google sheets
var all_ids = Array.apply(null, {length: total_unique_trials}).map(Number.call, Number) // gets 1:N array
var trial_ids = sample_from_array(all_ids, num_trials) // sample trials without replacement
var objs = []
var current_likert_value
var current_rt

getTrialData(google_spreadsheet_stimuli_url); // get trial data

// ---------------- 3. CONTROL FLOW ------------------
// START experiment
showSlide("consent");

// MAIN EXPERIMENT
var experiment = {
    
    // SHOW INSTRUCTION SLIDE
    instructions: function () {
            $("#instructions_cat1").html('<p class="block-text2"> In this experiment, you will see pairs of drawings of ' +  current_category +'s.</p>')
            $("#instructions_cat2").html('<p class="block-text2"> Your job is to rate how similiar the two ' + current_category +'s are to each other. </p>')

            showSlide("instructions")
    },

    // SELECT NEXT ACTION
    next: function() {

        num_ratings++ // increment trial
        paper.clear();

        if (num_ratings == 0) {
           experiment.get_ratings()
        } else {
            experiment.save()
        }
    },

    // GET RATINGS DISPLAY FUNCTION
    get_ratings: function() {
        
        // add in attention check indicis at certain points
        if (attention_check_indices.indexOf(num_ratings) > -1){ 

          current_trial_type = "attention_check"
          current_pics = [td[trial_ids[num_ratings]].key_id_1,  td[trial_ids[num_ratings]].key_id_1] // two identical

        } else {
          // randomize sides of pictures
          current_trial_type = "critical_trial"
          current_pics = shuffle([td[trial_ids[num_ratings]].key_id_1, td[trial_ids[num_ratings]].key_id_2])
        }
     
        rating_image1_html = '<img src=images/drawings/' + current_pics[0] + '.jpeg alt="' + current_pics[0] + '" id="objImage" class = "objImage"/>';
        $("#ratingimage1").html(rating_image1_html)

        rating_image2_html = '<img src=images/drawings/' + current_pics[1] + '.jpeg alt="' + current_pics[1]  + '" id="objImage" class = "objImage"/>';
        $("#ratingimage2").html(rating_image2_html)

        rating_question_html = '<p style="font-size:24px;text-align: justify;"> How <b> similar </b> are the ' +  td[trial_ids[num_ratings]].category + 's in these two drawings? </p>';
        $("#ratingquestion").html(rating_question_html)

        // draw likert scale
        var circle1 = paper.circle(centerX - 150,centerY,circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })
     
        var circle2 = paper.circle(centerX - 100, centerY, circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })

        var circle3 = paper.circle(centerX - 50,centerY,circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })
  
        var circle4 = paper.circle(centerX,centerY,circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })

        var circle5 = paper.circle(centerX + 50,centerY,circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })

        var circle6 = paper.circle(centerX + 100,centerY,circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })

        var circle7 = paper.circle(centerX + 150,centerY,circle_width).attr({
                        fill: "white", 
                        stroke: "rgb(0,0,0)",
                        "stroke-width": 5,
                      })

        setTimeout(function(){ // this is a hack:  https://github.com/DmitryBaranovskiy/raphael/issues/491
            paper.text(centerX - 150, centerY, "1").attr({"font-size": 18});
            paper.text(centerX - 100, centerY, "2").attr({"font-size": 18});
            paper.text(centerX - 50, centerY, "3").attr({"font-size": 18,});
            paper.text(centerX, centerY, "4").attr({"font-size": 18,});
            paper.text(centerX + 50 , centerY, "5").attr({"font-size": 18,});
            paper.text(centerX + 100 , centerY, "6").attr({"font-size": 18,});
            paper.text(centerX + 150 , centerY, "7").attr({"font-size": 18,});

            paper.text(91, centerY, "Almost Identical").attr({"font-size": 16, "font-weight":"bold"});
            paper.text(596, centerY, "Completely Different").attr({"font-size": 16, "font-weight":"bold"});
        });

        $("#counter").html(num_ratings + 1 + ' / ' + num_trials)

        $(document).keyup(function(event){
              var keys = {"1": 49, "2": 50, "3": 51, "4": 52, "5": 53, "6": 54, "7": 55};
              switch(event.which) {
                case keys["1"]:
                   circle1.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI); 
                   current_likert_value = 1 
                   break;

                case keys["2"]:
                   circle2.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI); 
                   current_likert_value = 2
                   break;

                case keys["3"]:
                   circle3.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI); 
                   current_likert_value = 3
                   break;

                case keys["4"]:
                   circle4.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI);
                   current_likert_value = 4 
                   break;

                case keys["5"]:
                   circle5.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI); 
                   current_likert_value = 5
                   break;

                case keys["6"]:
                   circle6.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI); 
                   current_likert_value = 6
                   break;

                case keys["7"]:
                   circle7.attr("fill", "red");
                   $(document).unbind("keyup")
                   endTime = (new Date()).getTime()
                   current_rt = endTime - startTime
                   setTimeout(experiment.next, ISI); 
                   current_likert_value = 7
                   break;
                }
          })

       // start timer
       var startTime = (new Date()).getTime()
       showSlide("complex_rating")    

    }, 

    // SAVE DATA
    save: function() {
        eval('experiment.trial_ID_T' + num_ratings + ' = "' + td[trial_ids[num_ratings - 1]].trial_ID + '"')
        eval('experiment.trial_type_T' + num_ratings + ' = "' + current_trial_type + '"')
        eval('experiment.haus_bin_T' + num_ratings + ' = "' + td[trial_ids[num_ratings - 1]].hd_bin  + '"')
        eval('experiment.haus_sim_T' + num_ratings + ' = "' + td[trial_ids[num_ratings - 1]].hd_sim + '"')
        eval('experiment.drawing_key_id_1_T' + num_ratings + ' = "' + td[trial_ids[num_ratings - 1]].key_id_1 + '"')
        eval('experiment.drawing_key_id_2_T' + num_ratings + ' = "' + td[trial_ids[num_ratings - 1]].key_id_2 + '"')
        eval('experiment.category_T' + num_ratings + ' = "' + td[trial_ids[num_ratings - 1]].category + '"')
        eval('experiment.RT_T' + num_ratings + ' = "' + current_rt + '"')
        eval('experiment.rating_T' + num_ratings + ' =' + current_likert_value)
        
        // go to next trial
        if (num_ratings == num_trials) {
            experiment.end()
        } else {
            experiment.get_ratings()
        }
    },

    // END FUNCTION 
    end: function() {


        // get completion code
        var new_completion_code = getCode(secret_code_id, 8, 8, random = true, symbols = "letters")
        $("#completion_code").html('<p style="font-size:34px;color:red;"> ' +  new_completion_code + ' </p>')

        // stringify all data
        var data_string = "subj_id=" + subj_id + "&completion_code="+ new_completion_code + '&data=' + JSON.stringify(experiment)

        // save data to google sheet
        post_data(data_string, google_spreadsheet_data_url)
        

        setTimeout(function() {
              showSlide("finished");
              }, 500)
    }
}