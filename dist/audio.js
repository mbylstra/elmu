var PROFILING = 0;
var DEBUG = 1;
var ITERATIONS = 10;
var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;



timeElapsed = 0.0;
var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
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


if (DEBUG) {
     ITERATIONS = 0;
}

var elmGui = Elm.fullscreen(Elm.Gui);

//expose Elm modules
var Orchestrator = exposeElmModule(Elm.Orchestrator);
var ReactiveAudio = exposeElmModule(Elm.ReactiveAudio);

var updateGraph = function(initialAudioGraph, externalState) {
  return unpackTuple2(Orchestrator.updateGraph(initialAudioGraph)(externalState));
}

var initialAudioGraph = Orchestrator.toDict(ReactiveAudio.audioGraph);
var audioGraph = initialAudioGraph;

var externalState = {
  time: 0.0,
  externalInputState: {
    xWindowFraction: 0.0,
    yWindowFraction: 0.0,
    audioOn : false,
  }
}

var monoBuffer = [];

function fillBuffer() {
  // console.log('audioGraph', audioGraph);
  // console.log('externalState', externalState);
  for (var i = 0; i < BUFFER_SIZE; i++) {
    var result = updateGraph(audioGraph, externalState);
    audioGraph = result[0];
    monoBuffer[i] = result[1];
  }
}


if (PROFILING) {
    console.log('start profiling');
    var i = ITERATIONS;
    fillBuffer();
    console.log(monoBuffer);
} else {

    elmGui.ports.outgoingUserInput.subscribe(function(userInput) {
      externalState.externalInputState = userInput;
    });

    var audioCtx = new AudioContext();
    source = audioCtx.createBufferSource();
    var scriptNode = audioCtx.createScriptProcessor(BUFFER_SIZE, 1, 1);
    scriptNode.onaudioprocess = function(audioProcessingEvent) {
        var outputBuffer = audioProcessingEvent.outputBuffer;

        fillBuffer();

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
    }
    source.connect(scriptNode);
    scriptNode.connect(audioCtx.destination);
    source.start();
}
