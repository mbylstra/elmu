module AudioNodes where

type alias ValueFloat = Float
type alias TimeFloat = Float

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

squareWave : Float -> Float
squareWave phase =
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

sinWave : Float -> Float
sinWave phase =
    sin (phase * 2.0 * pi)



oscillator : OscillatorType -> Float -> Float -> Float
oscillator oscillatorType frequency currTime =
    let
        phase = getPhaseFraction frequency currTime
    in
        case oscillatorType of
            Saw -> sawWave phase
            Square -> squareWave phase
            Triangle -> triangleWave phase
            Sin -> sinWave phase


gain : Float -> Float -> Float
gain amount value = amount * value



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
        value
--         currValue
