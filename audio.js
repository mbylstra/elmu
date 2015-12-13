var elm = Elm.worker(Elm.ReactiveAudio, {
    requestBuffer: 4096,
});


var latestBuffer = [];
elm.ports.latestBuffer.subscribe(function(buffer) {
    latestBuffer = buffer;
//     console.log('latestBuffer', latestBuffer);
});


var audioCtx = new AudioContext();
source = audioCtx.createBufferSource();
var scriptNode = audioCtx.createScriptProcessor(4096, 1, 1);
scriptNode.onaudioprocess = function(audioProcessingEvent) {
    var outputBuffer = audioProcessingEvent.outputBuffer;
    for (var channel = 0; channel < outputBuffer.numberOfChannels; channel++) {
    var outputData = outputBuffer.getChannelData(channel);
        for (var i = 0; i < outputBuffer.length; i++) {
            outputData[i] = latestBuffer[i];
//             outputData[i] = 1.0;
        }
    }
    elm.ports.requestBuffer.send(4096);
}




source.connect(scriptNode);
scriptNode.connect(audioCtx.destination);
source.start();
