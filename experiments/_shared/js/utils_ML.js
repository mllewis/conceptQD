//create random code for final message
//start code creation script
function randLetter(symbols) {
    if (symbols == "letters") {
      var possible_chars = "abcdefghijklmnoX";
    } else {
      var possible_chars = "123456789"
    }
     
     var int =  Math.floor((Math.random() * possible_chars.length));
     var rand_letter = possible_chars[int];
     return rand_letter;
}

function getCode(secretCodeIdentifier, n_left, n_right, random, symbols){
  var code="";

  if (random){
    var n_left_pad =  Math.floor((Math.random() * n_left));
    var n_right_pad =  Math.floor((Math.random() * n_right));
  } else {
    var n_left_pad = n_left
    var n_right_pad = n_right
  }

  for (var i = 0; i < n_left_pad; i++){
     code = code.concat(randLetter(symbols));
  }
  
  code = code.concat(secretCodeIdentifier);
                         
  for (var i = 0; i < n_right_pad; i++){
    code = code.concat(randLetter());
  }

  return code
}

// show slide function
function showSlide(id) {
    $(".slide").hide(); //jquery - all elements with class of slide - hide
    $("#" + id).show(); //jquery - element with given id - show
}

//array shuffle function
shuffle = function(o) { //v1.0
    for (var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
}

