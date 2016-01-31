var PROFILING = 1;
var DEBUG = 1;
var ITERATIONS = 1;



timeElapsed = 0.0;
// var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 4096;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 2048;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 8192;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 8192;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 16384;  //92 milliseconds, pretty shit!
// var BUFFER_SIZE = 512;  //92 milliseconds, pretty shit!
var BUFFER_SIZE = 1024;  //92 milliseconds, pretty shit!
var SAMPLE_RATE = 44100;
var SAMPLE_DURATION = 1.0 / SAMPLE_RATE;
var BUFFER_DURATION = SAMPLE_DURATION * BUFFER_SIZE;
var MAX_ALLOWED_DURATION = ITERATIONS * BUFFER_DURATION;

buffersElapsed = 0;

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

// var elmGui = Elm.fullscreen(Elm.Gui, {randomPrimer: Date.now()});
var elmGui = Elm.fullscreen(Elm.Gui);

//expose Elm modules
var ReactiveAudio = exposeElmModule(Elm.ReactiveAudio);
var BufferHandler = exposeElmModule(Elm.BufferHandler);
console.log('BufferHandler', BufferHandler);
// var  = exposeElmModule(Elm.ReactiveAudio);
var _Utils = exposeElmModule(Elm.Native.Utils);
var _List = exposeElmModule(Elm.Native.List);

// var initialAudioGraph = _List.toArray(ReactiveAudio.audioGraph);
// console.log(initialAudioGraph);
var audioGraph = ReactiveAudio.audioGraph;

var bufferState = BufferHandler.initialState;
console.log(bufferState);
bufferState.graph = audioGraph;
console.log('bufferState', bufferState);

// TODO: get this from elm! So it's properly type checked. Should map fine.
// THIS IS GETTING REALLY UNSUSTAINABLE!
// but maybe a bit difficult as we have no way of easily getting the initial value?
// at least without doing some native hacks?
// var externalState = {
//   time: 0.0,
//   externalInputState: {
//     frequency: 400.0,
//     audioOn : true,
//     knobs : {attack:0, decay:0, release:0, sustain:0}
//   }
// }


// var tupleArrayToObject = function(tuples) {
//   var o = {}
//   for (var i = 0; i < tuples.length; i++) {
//     var tuple = tuples[i];
//     o[tuple[0]] = tuple[1];
//   }
//   return o;
// }
//
// var elmAudioNodeToJS = function(elmAudioNode) {
//   var type = elmAudioNode.ctor;
//   var node = elmAudioNode._0;
//   node.type = type;
//   return node;
// }
//
// var graphListToObject = function(graphList) {
//   var graph = {}
//   for (var i = 0; i < graphList.length; i++) {
//     var elmAudioNode = graphList[i];
//     var node = elmAudioNodeToJS(elmAudioNode);
//     var id = node.id;
//     graph[id] = node;
//   }
//   return graph;
// }
//
// var state = {
//   // a list of phases
//   Oscillator: {
//     phases: {}
//   }
// }


// console.log(graphListToObject(initialAudioGraph));
// var audioGraph = graphListToObject(initialAudioGraph);
console.log('audioGraph', audioGraph);

// no need - state is already there as an object. just mutate the fucker!
// var ids = Object.keys(audioGraph);
// var destination;
// for (var i = 0; i < ids.length; i++) {
//   var id = ids[i];
//   var node = audioGraph[id];
//   // console.log(node);
//   if (node.type == 'Destination') {
//     destination = node;
//   }
// }
//
// console.log('dest', destination);


// var getNodeValue = function(audioGraph, node) {
//   // console.log('getNodeValue', node);
//
//   /* This is really dodgy. Pointlessly happens on every sample, and is really brittle!
//     It should happen on initialisation or if the audio graph has changed (which is rare)
//   */
//   if (node.hasOwnProperty('ctor')) {
//     node = elmAudioNodeToJS(node);
//   }
//   switch (node.type) {
//     case "Destination":
//       return getInputValue(audioGraph, node.input);
//     case "Oscillator":
//       var frequency = getInputValue(audioGraph, node.inputs.frequency);
//       var frequencyOffset = getInputValue(audioGraph, node.inputs.frequencyOffset);
//       var phaseOffset = getInputValue(audioGraph, node.inputs.phaseOffset);
//       var result = node.func(frequency)(frequencyOffset)(phaseOffset)(node.state.phase);
//       // console.log('result', result)
//       node.state.phase = result._1;
//       // console.log('node.state.phase', node.state.phase);
//       return result._0;
//     case "Add":
//       // console.log('add');
//       var result = 0;
//       var inputs = _List.toArray(node.inputs);
//       // console.log('inputs', inputs);
//       for (var i = 0; i < inputs.length; i++) {
//         var input = inputs[i];
//         // console.log('input', input);
//         result += getInputValue(audioGraph, inputs[i]);
//       }
//       // console.log('Add value', result);
//       return result;
//     case "Gain":
//       var signal = getInputValue(audioGraph, node.inputs.signal)
//       // console.log('signal', signal);
//       var gain = getInputValue(audioGraph, node.inputs.gain)
//       // console.log('gain', gain);
//       var result = node.func(signal)(gain)
//       // console.log('result', result);
//       return result;
//     default:
//       throw ("node type `" + node.type + "` not implemented in JS land yet :(");
//   }
// }
//
// var getInputStateFromDottedPath = function(dottedPath, inputState) {
//   var path = dottedPath.split(".");
//   // this is hurting my brain, so let's cheat and assume only one level of depth :p
//
//   var getNode = function (propertyName, node) {
//     if (node.hasOwnProperty(propertyName)) {
//       return node[propertyName];
//     } else {
//       throw ""
//     }
//   }
//
//   if (path.length == 1) {
//     // console.log('path length 1');
//     return getNode(path[0], inputState)
//   } else {
//     var parent = getNode(path[0], inputState);
//     return getNode(path[1], parent);
//   }
// }
//
// var getInputValue = function(audioGraph, input) {
//   var type = input.ctor;
//   // console.log('input', input);
//   // console.log('type', type);
//
//   switch (type) {
//     case "Value":
//       return input._0;
//       break;
//     case "Default":
//       return 0.0;
//       break;
//     case "ID":
//       return getNodeValue(audioGraph, audioGraph[input._0]);
//       break;
//     case "GUI":
//       var guiId = input._0;
//       var inputState = externalState.externalInputState
//       // console.log('inputState', inputState);
//       try {
//         return getInputStateFromDottedPath(guiId, inputState);
//       } catch(e) {
//         throw "GUI id `" + guiId + "` does not exist. These do: " + JSON.stringify(inputState)
//       }
//       break;
//     case "Node":
//       var node = input._0;
//       // console.log("node:", node);
//       return getNodeValue(audioGraph, node);
//     default:
//       throw (" input type `" + type + "` not implemented in JS land yet :(");
//   }
// }

// var updateGraph = function(audioGraph, externalState) {
//   return getNodeValue(audioGraph, destination);
// }

// console.log(state);
// var output = updateGraph(audioGraph);
// console.log(output);

// var elmAudioGraph = initialAudioGraph;


// var monoBuffer = [];
//
// function fillBuffer() {
//   // console.log('audioGraph', audioGraph);
//   // console.log('externalState', externalState);
//   for (var i = 0; i < BUFFER_SIZE; i++) {
//     var result = updateGraph(audioGraph, externalState);
//     monoBuffer[i] = result;
//   }
// }


if (PROFILING) {

    console.log('start profiling');
    for (var i = 0; i < ITERATIONS; i++) {
        // fillBuffer();
        console.log('start');
        console.log('updateBufferState', BufferHandler.updateBufferState);
        bufferState = BufferHandler.updateBufferState(bufferState.externalInputState)(bufferState);
        console.log('end');

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
    //TODO: re-enable, fix the ports issue
    // elmGui.ports.outgoingUiModel.subscribe(function(userInput) {
    //   // console.log('userInput', userInput);
    //   userInput.knobs = tupleArrayToObject(userInput.knobs);
    //   externalState.externalInputState = userInput;
    //   // console.log('userInput', userInput);
    //   // console.log('userInput', userInput.slider1);
    // });

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

          // would be good if we could pass in outputData, rather than user previous array and have to copy across
          for (var i = 0; i < outputBuffer.length; i++) {
              var value;
              if (externalState.externalInputState.audioOn) {
                value = buffer[i];
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
