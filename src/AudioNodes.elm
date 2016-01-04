module AudioNodes where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------



import Dict exposing (Dict)
import Array exposing (Array)
import ElmTest exposing (..)






--------------------------------------------------------------------------------
-- Types
--------------------------------------------------------------------------------
type alias ValueFloat = Float
type alias TimeFloat = Float
type alias FrequencyFloat = Float
type alias PhaseOffsetFloat = Float
type alias OutputFloat = Float
type alias PhaseFloat = Float
type alias FrequencyOffsetFloat = Float

type alias OscillatorF =
    FrequencyFloat
    -> FrequencyOffsetFloat
    -> PhaseOffsetFloat
    -> TimeFloat
    -> (OutputFloat, PhaseFloat)
type alias GainF = Float -> Float -> Float


sampleRate = 44100
sampleDuration = 1.0 / toFloat sampleRate
-- some basic math

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







type OscillatorType = Saw | Square | Triangle | Sin


bias : Float -> Float
bias value =
    (value * 2.0) - 1.0


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


-- let's ditch the oscillator abstraction and focus on sinWave'

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
{-         _ = Debug.log "currValue" currValue
        _ = Debug.log "prevValues" prevValues -}
        value = average <| [currValue] ++ prevValues
--         _ = Debug.log "output" value
    in
        value * 1.1
--         currValue


{- sinWave : Float -> Float -> Float -> Float
sinWave frequency phaseOffset currTime =  -- I'm not really sure what order the args should be
    let
        phase = (getPhaseFraction frequency currTime) + phaseOffset
    in
        sinWave' phase -}

sinLookupFrequency = 20.0
sinLookupDuration = 1.0 / sinLookupFrequency
sinLookupArrayLength = floor (sinLookupDuration / sampleDuration)

sinLookup : Array Float
sinLookup =
    let
        getSample n =
            let
                phase = toFloat n / toFloat sinLookupArrayLength
            in
                sin (phase * 2.0 * pi)
    in
        Array.initialize sinLookupArrayLength getSample


sinWave : Float -> Float -> Float -> Float -> (Float, Float)
sinWave frequency frequencyOffset phaseOffset prevPhase =
    -- currently ignore frequencyOffset
    let
        phaseOffset = phaseOffset / 2.0
        periodSeconds = getPeriodSeconds (frequency + frequencyOffset)
        phaseIncrement = sampleDuration / periodSeconds
        currPhase = prevPhase + phaseIncrement
        outputPhase = currPhase + phaseOffset
        -- outputPhaseNormed = if outputPhase > 1.0 then outputPhase - 1.0 else outputPhase

        outputPhaseNormed = fmod outputPhase 1.0
        -- amplitude = sin (outputPhase * 2.0 * pi)
        lookupArrayIndex = floor (outputPhaseNormed * toFloat sinLookupArrayLength)
        -- debug = ((toString lookupArrayIndex) ++ " " ++ (toString sinLookupArrayLength) ++  " " ++ (toString outputPhaseNormed))
        -- _ = Debug.log "---------------" "-"
        -- _ = Debug.log "stuff"  debug
        -- _ = Debug.log "sinLookupArrayLength"
        -- _ = Debug.log "outputPhaseNormed" outputPhaseNormed
        amplitude =
            case Array.get lookupArrayIndex sinLookup of
                Just amplitude' -> amplitude'
                -- Nothing -> Debug.crash("arraylookup out of index. length is " ++ toString sinLookupArrayLength ++ " but index is " ++ toString lookupArrayIndex ++ " Debug: " ++ debug)
                Nothing -> Debug.crash("arraylookup out of index")
                    -- _ = Debug.log "stuff" ((toString lookupArrayIndex) ++ " " ++ (toString sinLookupArrayLength) ++  " " ++ (toString outputPhaseNormed))
                -- Nothing -> Debug.crash("arraylookup out of index")


    in
{-         if (frequencyOffset /= 666.0)
        then
{-             let
                _ = Debug.log "amp" amplitude
                _ = Debug.log "outputPhase" outputPhase
                _ = Debug.log "phaseOffset" phaseOffset
                _ = Debug.log "currPhase" currPhase
                _ = Debug.log "phaseIncrement" phaseIncrement
                _ = Debug.log "period Seconds" periodSeconds
                _ = Debug.log "prevPhase" prevPhase
                _ = Debug.log "-------------------------------" True
            in  -}
            (amplitude, currPhase)

        else -}
{-             let
                _ = Debug.log "MODULATOR amp" amplitude
                _ = Debug.log "outputPhase" outputPhase
                _ = Debug.log "phaseOffset" phaseOffset
                _ = Debug.log "currPhase" currPhase
                _ = Debug.log "phaseIncrement" phaseIncrement
                _ = Debug.log "period Seconds" periodSeconds
                _ = Debug.log "prevPhase" prevPhase
                _ = Debug.log "-------------------------------" True
                _ = Debug.log "-------------------------------" True
            in -}
        (amplitude, currPhase)  -- I actually think returning a tuple is problematic for performance! You want to stick to as basic as possible data types.

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


tests : Test
tests =
    suite "sineWave"
        [
          test "sineWave"
            (assertEqual
                (0.0, 0.0)
--                 (sinWave 10025.0 0.0 0.0)
                (sinWave 11025.0 0.0 0.0 0.0)
            )
        , test "sinLookup"
            (assertEqual
                (Array.fromList([0.0]))
                (sinLookup)
            )
        ]



main =
    elementRunner tests
