module ReactiveAudio where

import Array exposing (Array)
import Debug exposing (log)

-- let's just hardcode sample rate for now (it's easier!)

port requestBuffer : Signal Bool

bufferSize = 4096

updateCurrentTime : Bool -> Float -> Float
updateCurrentTime _ prevTime =
    prevTime + (bufferSize * sampleDuration)

clockSignal : Signal Float
clockSignal = Signal.foldp updateCurrentTime 0 requestBuffer




-- hmm, the filter itself must remember its previous inputs. This must
-- be handled by the orchestrator


getLatestBuffer : Float -> Array Float
getLatestBuffer currentTimeSeconds =

    let
        initFunc : Int -> Float
        initFunc bufferIndex =
            let
                currentTime = getSampleTime bufferIndex currentTimeSeconds
            in
                getBufferVal currentTime
    in
        Array.initialize bufferSize initFunc


-- we should use foldp to keep track of current time in seconds





port latestBuffer : Signal (Array Float)
port latestBuffer = Signal.map getLatestBuffer clockSignal
