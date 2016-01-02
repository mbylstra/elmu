





timeElapsed = 0.0;
// var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 2048;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 512;  //92 milliseconds, pretty shit!
var SAMPLE_RATE = 44100;
var SAMPLE_DURATION = 1.0 / SAMPLE_RATE;
var BUFFER_DURATION = SAMPLE_DURATION * BUFFER_SIZE;

buffersElapsed = 0;

var latestUserInput = {
    mousePosition: {x: 0, y: 0},
    windowDimensions: {x: 0, y: 0},
    audioOn: false
}

var startTime = window.performance.now();
var endTime = null;

var unpackTuple2 = function(tuple2) {
  return [tuple2._0, tuple2._1]
}


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

    var elmGui = Elm.fullscreen(Elm.Gui);
    // var elmAudio = Elm.worker(Elm.ReactiveAudio);



    //expose Elm modules
    var Orchestrator = exposeElmModule(Elm.Orchestrator);

    var updateGraph = function(initialAudioGraph, externalState) {
      return unpackTuple2(Orchestrator.updateGraph(initialAudioGraph)(externalState));
    }
    var ReactiveAudio = exposeElmModule(Elm.ReactiveAudio);

    var initialAudioGraph = Orchestrator.toDict(ReactiveAudio.audioGraph);
    var audioGraph = initialAudioGraph;




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

    // var result = updateGraph(initialAudioGraph, externalState);
    //expose Elm modules
    // var Orchestorator = Elm.Orchestrator.make(elmAudio);


    // var latestBuffer = [];


    elmGui.ports.outgoingUserInput.subscribe(function(userInput) {
      // latestUserInput = userInput;
      externalState.externalInputState = userInput;
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
        var outputBuffer = audioProcessingEvent.outputBuffer;

        var monoBuffer = [];
        for (var i = 0; i < BUFFER_SIZE; i++) {
          var result = updateGraph(audioGraph, externalState);
          audioGraph = result[0];
          monoBuffer[i]= result[1];
        }
        // here we fill the buffer (and use same values for both channels)

        for (var channelNumber = 0; channelNumber < outputBuffer.numberOfChannels; channelNumber++) {
          var outputData = outputBuffer.getChannelData(channelNumber);
              for (var i = 0; i < outputBuffer.length; i++) {
                  var value;
                  if (externalState.externalInputState.audioOn) {
                    value = monoBuffer[i];
                  } else {
                    value = 0.0;
                  }
                  outputData[i] = value;
              }
          }

// -- updateBufferState : UserInput -> BufferState -> BufferState
// -- updateBufferState userInput prevBufferState =
// --
// --     let
// --
// --         externalInputState : ExternalInputState
// --         externalInputState =
// --             { xWindowFraction = toFloat userInput.mousePosition.x / toFloat userInput.windowDimensions.width
// --             , yWindowFraction = toFloat userInput.mousePosition.y / toFloat userInput.windowDimensions.height
// --             , audioOn = userInput.audioOn
// --             }
// --         -- _ = Debug.log "externalInputState: " externalInputState
// --
// --         time = prevBufferState.time + sampleDuration
// --
// --         -- frequency = 40.0 + (xWindowFraction * 10000.0) -- how do we pass this in?
// --
// --         initialGraph = prevBufferState.graph
// -- {-         _ = Debug.log "sampleCuration" sampleDuration
// --         _ = Debug.log "updateBufferState time" time -}
// --
// --
// --         -- surely we can do this without having to manually create a counter?
// --         -- we can just iterate over the last buffer, and ignore values
// --
// --         prevBuffer = prevBufferState.buffer
// --
// --         initialBufferState : BufferState
// --         initialBufferState =
// --             { time = time
// --             , graph = initialGraph
// --             , buffer = prevBuffer
// --             , bufferIndex = 0
// --             , externalInputState = externalInputState
// --             }
// --
// --         -- we must expose this as a public function
// --         updateForSample {time, graph, buffer, bufferIndex} =
// --             let
// --                 newTime  = time + sampleDuration
// --                 externalState =
// --                     { time = newTime
// --                     , externalInputState = externalInputState
// --                     }
// -- --                 _ = Debug.log "udpateForSample newTime" newTime
// --                 newBufferIndex = bufferIndex + 1
// -- --                 _ = Debug.log "newBufferIndex" newBufferIndex
// -- --                 _ = Debug.log "value" value
// --             in
// --                 if
// --                     externalInputState.audioOn == True
// --                 then
// --                     let
// --                         -- this is pretty much all elm will do
// --                         (newGraph, value) = updateGraph graph externalState
// --                     in
// --                         -- this will be done in JS land
// --                         { time  = newTime
// --                         , graph = newGraph
// --                         , buffer = Array.set newBufferIndex value buffer
// --                         , bufferIndex = newBufferIndex
// --                         , externalInputState =  externalInputState
// --                         }
// --                 else
// --                     { time  = newTime
// --                     , graph = graph
// --                     , buffer = Array.set newBufferIndex 0.0 buffer
// --                     , bufferIndex = newBufferIndex
// --                     , externalInputState =  externalInputState
// --                     }
// --     in
// --         foldn updateForSample initialBufferState bufferSize
    }




    source.connect(scriptNode);
    scriptNode.connect(audioCtx.destination);
    source.start();
}
