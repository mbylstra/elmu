var elm = Elm.worker(Elm.ReactiveAudio, {
    requestBuffer: true,
});


var latestBuffer = [];
elm.ports.latestBuffer.subscribe(function(buffer) {
    latestBuffer = buffer;
//     console.log('latestBuffer', latestBuffer);
});



timeElapsed = 0.0;
bufferSize = 4096;
sampleRate = 44100;
bufferDuration = (1 / sampleRate) * bufferSize;
buffersElapsed = 0;


var audioCtx = new AudioContext();
source = audioCtx.createBufferSource();
var scriptNode = audioCtx.createScriptProcessor(bufferSize, 1, 1);
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
    timeElapsed += bufferDuration;
    if (buffersElapsed % 10 == 0) {
        console.log('time elapsed: ', timeElapsed);
    }
    elm.ports.requestBuffer.send(true);
}




source.connect(scriptNode);
scriptNode.connect(audioCtx.destination);
source.start();
