var PROFILING = 0;
var DEBUG = 0;
var ITERATIONS = 100;



timeElapsed = 0.0;
var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 2048;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 512;  //92 milliseconds, pretty shit!
var SAMPLE_RATE = 44100;
var SAMPLE_DURATION = 1.0 / SAMPLE_RATE;
var BUFFER_DURATION = SAMPLE_DURATION * BUFFER_SIZE;
var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;

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
    ITERATIONS = 1;
    var BUFFER_SIZE = 64;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 2048;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
    // var BUFFER_SIZE = 512;  //92 milliseconds, pretty shit!
    var SAMPLE_RATE = 44100;
    var SAMPLE_DURATION = 1.0 / SAMPLE_RATE;
    var BUFFER_DURATION = SAMPLE_DURATION * BUFFER_SIZE;
    var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;
}

var elmGui = Elm.fullscreen(Elm.Gui);

//expose Elm modules
var ReactiveAudio = exposeElmModule(Elm.ReactiveAudio);
var _Utils = exposeElmModule(Elm.Native.Utils);
var _List = exposeElmModule(Elm.Native.List);

var initialAudioGraph = _List.toArray(ReactiveAudio.audioGraph);
console.log(initialAudioGraph);

var externalState = {
  time: 0.0,
  externalInputState: {
    xWindowFraction: 0.0,
    yWindowFraction: 0.0,
    pitch: 0.0,
    audioOn : true,
  }
}

var graphListToObject = function(graphList) {
  var graph = {}
  for (var i = 0; i < graphList.length; i++) {
    var item = graphList[i];
    var type = item.ctor;
    var data = item._0;
    data.type = type;
    var id = data.id;
    graph[id] = data;
  }
  return graph;
}

var state = {
  // a list of phases
  Oscillator: {
    phases: {}
  }
}


// console.log(graphListToObject(initialAudioGraph));
var audioGraph = graphListToObject(initialAudioGraph);
console.log('audioGraph', audioGraph);

// no need - state is already there as an object. just mutate the fucker!
var ids = Object.keys(audioGraph);
var destination;
for (var i = 0; i < ids.length; i++) {
  var id = ids[i];
  var node = audioGraph[id];
  // console.log(node);
  if (node.type == 'Destination') {
    destination = node;
  }
}

// console.log('dest', destination);


var getNodeValue = function(audioGraph, node) {
  // console.log('node', node);
  if (node.type == "Destination") {
    return getInputValue(audioGraph, node.input);
  } else if (node.type == "Oscillator") {
    var frequency = getInputValue(audioGraph, node.inputs.frequency);
    var frequencyOffset = getInputValue(audioGraph, node.inputs.frequencyOffset);
    var phaseOffset = getInputValue(audioGraph, node.inputs.phaseOffset);
    var result = node.func(frequency)(frequencyOffset)(phaseOffset)(node.state.phase);
    // console.log('result', result)
    node.state.phase = result._1;
    // console.log('node.state.phase', node.state.phase);
    return result._0;
  } else if (node.type == "Add") {
    // console.log('add');
    var value = 0;
    var inputs = _List.toArray(node.inputs);
    // console.log('inputs', inputs);
    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      // console.log('input', input);
      value += getInputValue(audioGraph, inputs[i]);
    }
    // console.log('value', value);
    return value;
  }
}

var getInputValue = function(audioGraph, input) {
  var type = input.ctor;
  if (type == "Value") {
    return input._0
  } else if (type == "Default") {
    return 0.0;
  } else if (type == "ID") {
    // console.log("audioGraph", audioGraph);
    // console.log('input', input);
    return getNodeValue(audioGraph, audioGraph[input._0]);
  } else if (type == "GUI") {
    // console.log("audioGraph", audioGraph);
    // console.log('input', input);
    var guiId = input._0;
    // console.log('GUI?');
    // console.log('externalState', externalState);
    return externalState.externalInputState[guiId];
  }
}

var updateGraph = function(audioGraph, externalState) {
  return getNodeValue(audioGraph, destination);
}

// console.log(state);
var output = updateGraph(audioGraph);
// console.log(output);

// var elmAudioGraph = initialAudioGraph;


var monoBuffer = [];

function fillBuffer() {
  // console.log('audioGraph', audioGraph);
  // console.log('externalState', externalState);
  for (var i = 0; i < BUFFER_SIZE; i++) {
    var result = updateGraph(audioGraph, externalState);
    monoBuffer[i] = result;
  }
}


if (PROFILING) {

    console.log('start profiling');
    for (var i = 0; i < ITERATIONS; i++) {
        fillBuffer();
    }
    if (PROFILING && DEBUG) {
        console.log('buffer', monoBuffer);
    }
    endTime = window.performance.now();
    millisElapsed = endTime - startTime;
    secondsElapsed = millisElapsed / 1000.0;
    console.log('secondsElapsed: ', secondsElapsed);
    console.log('max allowed duration: ', MAX_ALLOWED_DURATION);
    console.log('CPU percent:', (secondsElapsed / MAX_ALLOWED_DURATION) * 100.0);
} else {
    elmGui.ports.outgoingUserInput.subscribe(function(userInput) {
      externalState.externalInputState = userInput;
      // console.log('userInput', userInput);
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
