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
    // get list of row ids that apply to the current category
    targ_trials_id = []
    for (i = 0; i < Object.values(data).length; i++) {
      if(data[i].category == current_category){
          targ_trial_ids.push(i)
      }
    }

    var trial_ids = sample_from_array(targ_trial_ids, num_trials) // sample trials without replacement


    // save array of stimuli data for current category
    td = []
    for (i = 0; i < num_trials; i++) {
      td.push(data[trial_ids[i]])
    }
    // get objs to preload
    //objs = []
    //for (i = 0; i < num_trials; i++) {
    //  objs.push('images/drawings/' + current_category + '/'  + td[trial_ids[i]].key_id_1 + '.jpeg')
    //  objs.push('images/drawings/' + current_category + '/'  + td[trial_ids[i]].key_id_2 + '.jpeg')
    //}

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
var php_script = "http://127.0.0.1:8000/savetrialdata.php" // php script or saving data
google_spreadsheet_stimuli_url = "1lnlKFr6c7wY5jcODUp-HIrKYUULNOVv05l5wo07u36U" // where stim data lives
var num_conditions = 5 //5
var num_crit_trials = 50 //50
var attention_check_indices = [25,50] // where do you want the attention checks (same pairs) to go [0 indexing]?
var total_unique_trials = 200 // per condition

var paper_width = 674;
var paper_height = 100;
var circle_width = 20
var ISI = 1000
var secret_code_id = "_D_"
var current_completion_code = getCode(secret_code_id, 8, 8, random = true, symbols = "letters")

var current_category
var condition_switch = Math.floor((Math.random() * num_conditions))

// var condition_switch = 3// for testing

if (condition_switch == 0){ // links to stimuli for different categories
  current_category = "bread"
} else if (condition_switch == 1){
  current_category = "tree"
} else if (condition_switch == 2){
  current_category = "chair"
} else if (condition_switch == 3){
  current_category = "house"
} else if (condition_switch == 4){
  current_category = "bird"
}

// Define derived parameters
var subj_id = getCode("", 5, 5, random = false, symbols = "numbers") // get subj id
var num_trials = num_crit_trials + attention_check_indices.length
var centerX = paper_width / 2;
var centerY = paper_height / 2;
var paper = Raphael("drawing_canvas", paper_width, paper_height);

// Initialize experiment logic variables
var num_ratings = -1 //initialize at -1
var td // array of target condition trial data from google sheets
var targ_trial_ids = []

var objs = []
var current_likert_value
var current_rt

getTrialData(google_spreadsheet_stimuli_url); // get trial data

//var all_ids = Array.apply(null, {length: total_unique_trials}).map(Number.call, Number) // gets 1:N array
//alert(current_category)
//alert(JSON.stringify(targ_trial_ids))
//alert(num_trials)
//var trial_ids = sample_from_array(targ_trial_ids, num_trials) // sample trials without replacement
//alert(trial_ids)


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
            experiment.saveData()
          // go to next trial
          if (num_ratings == num_trials) {
              experiment.end()
          } else {
              experiment.get_ratings()
          }
        }
    },

    // GET RATINGS DISPLAY FUNCTION
    get_ratings: function() {


        // add in attention check indicis at certain points
        if (attention_check_indices.indexOf(num_ratings) > -1){

          current_trial_type = "attention_check"
          current_pics = [td[num_ratings].key_id_1,  td[num_ratings].key_id_1] // two identical

        } else {

          // randomize sides of pictures
          current_trial_type = "critical_trial"
         // alert(td[num_ratings].key_id_1)
          //alert(td[num_ratings].key_id_2)
          current_pics = shuffle([td[num_ratings].key_id_1, td[num_ratings].key_id_2])

        }

        rating_image1_html = '<img src=images/drawings/' + current_category + '/' + current_pics[0] + '.jpeg alt="' + current_pics[0] + '" id="objImage" class = "objImage"/>';
        $("#ratingimage1").html(rating_image1_html)

        rating_image2_html = '<img src=images/drawings/' + current_category + '/' + current_pics[1] + '.jpeg alt="' + current_pics[1]  + '" id="objImage" class = "objImage"/>';
        $("#ratingimage2").html(rating_image2_html)

        rating_question_html = '<p style="font-size:24px;text-align: justify;"> How <b> similar </b> are the ' +  current_category + 's in these two drawings? </p>';
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
    saveData: function() {
        var dataforTrial = subj_id + "," + num_ratings + "," + td[num_ratings-1].trial_ID;
		    dataforTrial += "," + td[num_ratings - 1].category + "," + current_trial_type;
		    dataforTrial += ","+ td[num_ratings - 1].hd_bin + "," + td[num_ratings - 1].hd_sim;
		    dataforTrial += "," + td[num_ratings - 1].key_id_1  + "," +  td[num_ratings - 1].key_id_2;
		    dataforTrial += "," + current_rt + "," + current_likert_value + "," +  current_completion_code + "\n";
		    $.post(php_script, {postresult_string: dataforTrial, subjectid: subj_id});	 // write to csv using php
		    // test with local php file: php -S 127.0.0.1:8000
    },

    // END FUNCTION
    end: function() {

        // get completion code
        $("#completion_code").html('<p style="font-size:34px;color:red;"> ' +  current_completion_code + ' </p>')

        setTimeout(function() {
              showSlide("finished");
              }, 500)
    }
}
