


timeElapsed = 0.0;
var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
var SAMPLE_RATE = 44100;
var BUFFER_DURATION = (1 / SAMPLE_RATE) * BUFFER_SIZE;
console.log('buffer duration', BUFFER_DURATION);

buffersElapsed = 0;



var startTime = window.performance.now();
var endTime = null;

var ITERATIONS = 10;
var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;
var PROFILING = 0;
var DEBUG = 1;

if (DEBUG) {
     ITERATIONS = 0;
}

if (PROFILING) {
    console.log('start profiling');
    var elm = Elm.worker(Elm.ReactiveAudio, {
        requestBuffer: true,
    });


    var i = ITERATIONS;
    elm.ports.requestBuffer.send(true);
    elm.ports.latestBuffer.subscribe(function(buffer) {
        if (PROFILING && DEBUG) {
            console.log('buffer', buffer);
        }
        if (i > 0) {
            elm.ports.requestBuffer.send(true);
            i--;
        } else {
            endTime = window.performance.now();
            millisElapsed = endTime - startTime;
            secondsElapsed = millisElapsed / 1000.0;
            console.log('secondsElapsed: ', secondsElapsed);
            console.log('max allowed duration: ', MAX_ALLOWED_DURATION);
            console.log('CPU percent:', (secondsElapsed / MAX_ALLOWED_DURATION) * 100.0);

        }
    });

} else {
    var elm = Elm.worker(Elm.ReactiveAudio, {
        requestBuffer: true,
    });

    var latestBuffer = [];
    elm.ports.latestBuffer.subscribe(function(buffer) {
        latestBuffer = buffer;
    });
    var audioCtx = new AudioContext();
    source = audioCtx.createBufferSource();
    var scriptNode = audioCtx.createScriptProcessor(BUFFER_SIZE, 1, 1);
//     var iirFilter = audioCtx.createIIRFilter();
//     var lowpass = audioCtx.createBiquadFilter();
    scriptNode.onaudioprocess = function(audioProcessingEvent) {
        var outputBuffer = audioProcessingEvent.outputBuffer;
        for (var channel = 0; channel < outputBuffer.numberOfChannels; channel++) {
        var outputData = outputBuffer.getChannelData(channel);
            for (var i = 0; i < outputBuffer.length; i++) {
                outputData[i] = latestBuffer[i];
    //             outputData[i] = 1.0;
            }
        }
        buffersElapsed += 1;
        timeElapsed += BUFFER_DURATION;
        if (buffersElapsed % 10 == 0) {
            console.log('time elapsed: ', timeElapsed);
        }
        elm.ports.requestBuffer.send(true);
    }




    source.connect(scriptNode);
    scriptNode.connect(audioCtx.destination);
    source.start();
}
