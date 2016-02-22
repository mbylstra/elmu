var PROFILING = 1;
var DEBUG = 0;
var ITERATIONS = 200;


var elmGui = Elm.fullscreen(Elm.Gui);

timeElapsed = 0.0;
// var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 16384;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 512;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 2;  //92 milliseconds, pretty shit!

var BUFFER_SIZE = elmGui.ports.bufferSizePort
var SAMPLE_RATE = 44100;
var SAMPLE_DURATION = 1.0 / SAMPLE_RATE;
var BUFFER_DURATION = SAMPLE_DURATION * BUFFER_SIZE;
var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;

buffersElapsed = 0;

var startTime = window.performance.now();
var endTime = null;

var uiModel;

if (DEBUG) {
    ITERATIONS = 1;
    var BUFFER_SIZE = 10;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 2048;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 512;  //92 milliseconds, pretty shit!
    var SAMPLE_RATE = 44100;
    var SAMPLE_DURATION = 1.0 / SAMPLE_RATE;
    var BUFFER_DURATION = SAMPLE_DURATION * BUFFER_SIZE;
    var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;
}

// var elmGui = Elm.fullscreen(Elm.Gui, {randomPrimer: Date.now()});

//expose Elm modules
var ReactiveAudio = exposeElmModule(Elm.ReactiveAudio);
var BufferHandler = exposeElmModule(Elm.BufferHandler);
// console.log('BufferHandler', BufferHandler);
// var  = exposeElmModule(Elm.ReactiveAudio);
var _Utils = exposeElmModule(Elm.Native.Utils);
var _List = exposeElmModule(Elm.Native.List);

var audioGraph = ReactiveAudio.audioGraph;

var bufferState = BufferHandler.initialState;
// console.log(bufferState);
bufferState.graph = audioGraph;

// console.log('bufferState', bufferState);
// console.log('audioGraph', audioGraph);

if (PROFILING) {

    console.log('start profiling');
    for (var i = 0; i < ITERATIONS; i++) {
        // fillBuffer();
        // console.log('start');
        // console.log('updateBufferState', BufferHandler.updateBufferState);
        bufferState = BufferHandler.updateBufferState(uiModel)(bufferState);
        // console.log('bufferState', bufferState);
        // console.log('end');

    }
    if (PROFILING && DEBUG) {
        // console.log('buffer', monoBuffer);
        console.log('bufferState', bufferState);
    }
    endTime = window.performance.now();
    millisElapsed = endTime - startTime;
    secondsElapsed = millisElapsed / 1000.0;
    console.log('secondsElapsed: ', secondsElapsed);
    console.log('max allowed duration: ', MAX_ALLOWED_DURATION);
    console.log('CPU percent:', (secondsElapsed / MAX_ALLOWED_DURATION) * 100.0);
} else {
    elmGui.ports.outgoingUiModel.subscribe(function(uiModel) {
      window.uiModel = uiModel;
    });

    var audioCtx = new AudioContext();
    source = audioCtx.createBufferSource();
    console.log('BUFFER_SIZE', BUFFER_SIZE);
    var scriptNode = audioCtx.createScriptProcessor(BUFFER_SIZE, 1, 1);
    scriptNode.onaudioprocess = function(audioProcessingEvent) {
        var outputBuffer = audioProcessingEvent.outputBuffer;

        // fillBuffer();
        bufferState = BufferHandler.updateBufferState(bufferState.externalInputState)(bufferState);
        var newBuffer = bufferState.buffer;

        for (var channelNumber = 0; channelNumber < outputBuffer.numberOfChannels; channelNumber++) {
          var outputData = outputBuffer.getChannelData(channelNumber);

          // would be good if we could pass in outputData, rather than using the previous array and have to copy across
          for (var i = 0; i < outputBuffer.length; i++) {
              var value;
              // if (externalState.externalInputState.audioOn) {
              value = newBuffer[i];
              // } else {
              // value = 0.0;
              // }
              outputData[i] = value;
          }
        }
    }
    source.connect(scriptNode);
    scriptNode.connect(audioCtx.destination);
    source.start();
}
