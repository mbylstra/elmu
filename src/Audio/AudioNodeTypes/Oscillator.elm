module Audio.AudioNodeTypes.Oscillator where

setFrequency : Float -> { a | frequency : Float } -> { a | frequency : Float}
setFrequency frequency props =
  { props | frequency = frequency }

setFrequencyOffset : Float -> { a | frequencyOffset : Float } -> { a | frequencyOffset : Float}
setFrequencyOffset frequencyOffset props =
  { props | frequencyOffset = frequencyOffset }

setPhaseOffset : Float -> { a | phaseOffset : Float } -> { a | phaseOffset : Float}
setPhaseOffset phaseOffset props =
  { props | phaseOffset = phaseOffset }

accessors =
  [(.frequency, setFrequency)
  ,(.frequencyOffset, setFrequencyOffset)
  ,(.phaseOffset, setPhaseOffset)
  ]
