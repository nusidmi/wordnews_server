// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//


//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .

function play(id) {
    //Get Audio elem
    var audioElem = document.getElementById(id);
    
    //Get audio sources from element
    var audioSources = audioElem.getElementsByTagName("source");
    var index = 1;
    
    //This function will auto loop to play the next track until the last one and reset it back to 0 
    var playNext = function() {
        if (index < audioSources.length) {
            audioElem.src = audioSources[index].src;
            index += 1;
            // use timeout to prevent The play() request was interrupted by a call to pause() error
            setTimeout(function() {
                audioElem.play()
            }, 10);
        } else {
            //Reset back to first audio source
            audioElem.src = audioSources[0].src;
            audioElem.pause();
            index = 1;
        }
    };
    //Add event for end of audio play to play next track
    audioElem.addEventListener('ended', playNext);
    audioElem.src = audioSources[0].src;
    setTimeout(function() {
        audioElem.play()
    }, 10);
}