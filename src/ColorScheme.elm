module ColorScheme where

import Color exposing (Color)

type alias ColorScheme =
  { windowBackground: Color
  , pianoWhites: Color
  , pianoBlacks: Color
  , knobBackground: Color
  , knobForeground: Color
  , controlPanelBackground: Color
  , controlPanelBorders: Color
  }

defaultColorScheme : ColorScheme
defaultColorScheme =
  -- { windowBackground= Color.white
  { windowBackground= Color.red
  -- , pianoWhites= Color.white
  , pianoWhites= Color.green
  -- , pianoBlacks= Color.black
  , pianoBlacks= Color.blue
  , knobBackground= Color.black
  , knobForeground= Color.lightRed
  , controlPanelBackground= Color.white
  , controlPanelBorders= Color.black
  }
