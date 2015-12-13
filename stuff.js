//attempt at ports:

var latestBuffer;

elm.ports.bufferFilled.subscribe(
    function(data) {
        latestBuffer = data;
        // how do we get the data to that function below???
    }
);

scriptNode.onaudioprocess = function(audioProcessingEvent) {
  elm.ports.bufferRequest.send(true);   //we don't care about input data, so just send true as notification to generate more data
  // just send the latest buffer!
    return latestBuffer;
    // hopefully we won't get wierd messed up stuff!
    // does this mean we'll always be one buffer behind? Kind of a big waste???
  //somehow here we wait for the next buffer function to be called!
    //this will return immediately. Somehow we need to block!
}

elm.ports.bufferRequest
