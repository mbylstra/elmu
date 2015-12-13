module ReactiveAudio where

import Array exposing (Array)

port requestBuffer : Signal Int


squareWave : Int -> Float
squareWave i =
    if (i % 100) > 50 then 1.0 else -1.0

sawWave : Int -> Float
sawWave i =
    toFloat (i % 100)

getLatestBuffer : Int -> Array Float
getLatestBuffer bufferSize =
    Array.initialize bufferSize sawWave

port latestBuffer : Signal (Array Float)
port latestBuffer = Signal.map getLatestBuffer requestBuffer
