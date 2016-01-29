module Audio.AudioNodeFunctions where

--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Audio.MainTypes exposing(..)

--------------------------------------------------------------------------------
-- Types
--------------------------------------------------------------------------------

type OscillatorType = Saw | Square | Triangle | Sin


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
sampleRate : Int
sampleRate = 44100

sampleDuration : Float
sampleDuration = 1.0 / toFloat sampleRate
-- some basic math

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

fmod : Float -> Float -> Float
fmod a b =
    let
        divided = a / b
    in
        divided - toFloat (floor divided)

sampleLength : Int -> Float
sampleLength sampleRate =
    1.0 / toFloat sampleRate

timeSeconds : Int -> Int -> Int -> Float
timeSeconds buffersElapsed bufferSize sampleRate =
    toFloat buffersElapsed * toFloat bufferSize * sampleLength sampleRate

getPeriodSeconds : Float -> Float
getPeriodSeconds frequency = 1.0 / frequency

getPhaseFraction : Float -> Float -> Float
getPhaseFraction frequency currTime =
    let
        period = getPeriodSeconds frequency
    in
        -- fmod (log "currTime" currTime) (log "period" period)
        fmod currTime period

bias : Float -> Float
bias value =
    (value * 2.0) - 1.0


--------------------------------------------------------------------------------
-- Oscillators
--------------------------------------------------------------------------------

sawWave : Float -> Float
sawWave phase =
    bias phase

squareWave' : Float -> Float
squareWave' phase =
    if phase < 0.5 then 1.0 else -1.0


triangleWave : Float -> Float
triangleWave phase =
    bias
        ( if
            phase < 0.5
          then
            phase * 2.0
          else
            (1.0 - phase) * 2.0
        )

sinWave' : Float -> Float
sinWave' phase =
    sin (phase * 2.0 * pi)


oscillator : OscillatorType -> Float -> Float -> Float
oscillator oscillatorType frequency currTime =
    let
        phase = getPhaseFraction frequency currTime
    in
        case oscillatorType of
            Saw -> sawWave phase
            Square -> squareWave' phase
            Triangle -> triangleWave phase
            Sin -> sinWave' phase


average : List Float -> Float
average values =
    List.sum values / toFloat (List.length values)


simpleLowPassFilter : ValueFloat -> List ValueFloat -> Float
simpleLowPassFilter currValue prevValues =
    let
        value = average <| [currValue] ++ prevValues
    in
        value * 1.1





squareWave : Float -> Float -> Float -> Float -> (Float, Float)
squareWave frequency frequencyOffset phaseOffset prevPhase =
    let
        phaseOffset = phaseOffset / 2.0
        periodSeconds = getPeriodSeconds (frequency + frequencyOffset)
        phaseIncrement = sampleDuration / periodSeconds -- we should be able to memoize this
        currPhase = prevPhase + phaseIncrement
        outputPhase = currPhase + phaseOffset
        outputPhaseNormed = fmod outputPhase 1.0 -- pehraps fmoddign large numbers slow?
        amplitude = if outputPhaseNormed > 0.5 then 1.0 else -1.0 --can't really make this any simpler
    in
        (amplitude, currPhase)
            -- I don't think updating a tuple would use much cpu (although *it would* create a new JS object everytime, but reusing an array would probably be faster)


zeroWave : Float -> Float -> Float -> Float -> (Float, Float)
zeroWave frequency frequencyOffset phaseOffset prevPhase = (0.0, 0.0)


gain : GainF
gain signalValue gainValue =
    signalValue * gainValue











--------------------------------------------------------------------------------
-- TESTS
--------------------------------------------------------------------------------



-- main =
--     elementRunner tests
