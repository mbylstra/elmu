





timeElapsed = 0.0;
var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
var SAMPLE_RATE = 44100;
var BUFFER_DURATION = (1 / SAMPLE_RATE) * BUFFER_SIZE;
console.log('buffer duration', BUFFER_DURATION);

buffersElapsed = 0;

var latestUserInput = {
    mousePosition: {x: 0, y: 0},
    windowDimensions: {x: 0, y: 0},
    audioOn: false
}



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
    var elmGui = Elm.fullscreen(Elm.Gui);


    var i = ITERATIONS;
    // elm.ports.latestBuffer.subscribe(function(buffer) {
    //     if (PROFILING && DEBUG) {
    //         console.log('buffer', buffer);
    //     }
    //     if (i > 0) {
    //         elm.ports.requestBuffer.send(true);
    //         i--;
    //     } else {
    //         endTime = window.performance.now();
    //         millisElapsed = endTime - startTime;
    //         secondsElapsed = millisElapsed / 1000.0;
    //         console.log('secondsElapsed: ', secondsElapsed);
    //         console.log('max allowed duration: ', MAX_ALLOWED_DURATION);
    //         console.log('CPU percent:', (secondsElapsed / MAX_ALLOWED_DURATION) * 100.0);
    //
    //     }
    // });

} else {
    console.log(Elm);
    console.log('Elm.ReactiveAudio', Elm.ReactiveAudio);
    console.log('Elm.Gui', Elm.ReactiveAudio);

    var elmGui = Elm.fullscreen(Elm.Gui);
    // var elmAudio = Elm.worker(Elm.ReactiveAudio);



    //expose Elm modules
    var Orchestrator = exposeElmModule(Elm.Orchestrator);
    var ReactiveAudio = exposeElmModule(Elm.ReactiveAudio);

    var initialAudioGraph = Orchestrator.toDict(ReactiveAudio.audioGraph);
    var audioGraph = initialAudioGraph;
    console.log('audioGraph', ReactiveAudio.audioGraph);




// type alias ExternalInputState =
//     { xWindowFraction : Float
//     , yWindowFraction : Float
//     , audioOn : Bool
//     }
// type alias ExternalState =
//     { time : Float
//     , externalInputState : ExternalInputState
//     }


    var externalState = {
      time: 0.0,
      externalInputState: {
        xWindowFraction: 0.0,
        yWindowFraction: 0.0,
        audioOn : false,
      }
    }

    var result = Orchestrator.updateGraph(initialAudioGraph)(externalState);
    console.log('result', result);
    // console.log('result()', result());
    //expose Elm modules
    // var Orchestorator = Elm.Orchestrator.make(elmAudio);

    // console.log(elmAudio);

    // var latestBuffer = [];


    elmGui.ports.outgoingUserInput.subscribe(function(userInput) {
      // console.log('userInput', userInput);
      latestUserInput = userInput;
    });


    // var Orchestrator = Elm.Orchestrator.make(elm);
    // var ReactiveAudio = Elm.ReactiveAudio.make(elm);
    // console.log('audioGraph', ReactiveAudio.audioGraph);


    var audioCtx = new AudioContext();
    source = audioCtx.createBufferSource();
    var scriptNode = audioCtx.createScriptProcessor(BUFFER_SIZE, 1, 1);
//     var iirFilter = audioCtx.createIIRFilter();
//     var lowpass = audioCtx.createBiquadFilter();
    scriptNode.onaudioprocess = function(audioProcessingEvent) {
      // console.log('latest user input', latestUserInput);
    //     var outputBuffer = audioProcessingEvent.outputBuffer;
    //     for (var channel = 0; channel < outputBuffer.numberOfChannels; channel++) {
    //     var outputData = outputBuffer.getChannelData(channel);
    //         for (var i = 0; i < outputBuffer.length; i++) {
    //             outputData[i] = latestBuffer[i];
    // //             outputData[i] = 1.0;
    //         }
    //     }
        // elm.ports.requestBuffer.send(true);
    }




    source.connect(scriptNode);
    scriptNode.connect(audioCtx.destination);
    source.start();
}
