module AudioUtil where

pitchToFrequency : Float -> Float
pitchToFrequency pitch =
  2^((pitch - 49.0) / 12.0) * 440.0
