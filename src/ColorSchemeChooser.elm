module ColorSchemeChooser where

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import Random exposing (Seed)
import Array exposing (Array)
import Maybe exposing (withDefault)

import ColorScheme exposing (ColorScheme)
import ColorExtra exposing (toCssRgb)


-- clicking more schemes should fetch more schemes
-- clicking randomise should choose a different scheme from
-- the list of schemas


-- MODEL


-- type alias RandModel =
--   { nextSeed : Seed
--   , currentInt : Int
--   }

-- initRandModel : RandModel
-- initRandModel =
--   { nextSeed = firstSeed
--   , currentInt = 0
--   }


randomInt : Int -> Seed -> (Int, Seed)
randomInt n seed =
  Random.generate (Random.int 0 n) seed


-- updateRand : Int -> RandModel -> RandModel
-- updateRand n model =
--   randomInt n model

type alias Model =
  { colorSchemes : Array ColorScheme
  , current : ColorScheme
  , seed : Seed
  }


init : Seed -> ColorScheme -> Model
init seed colorScheme =
  { colorSchemes = Array.fromList [colorScheme]
  , current = colorScheme
  , seed = seed
  }

setColorSchemes : Model -> Array ColorScheme -> Model
setColorSchemes model colorSchemes =
  { model | colorSchemes = colorSchemes }

getCurrent : Model -> ColorScheme
getCurrent model = model.current

-- UPDATE

type alias Index = Int
type Action
  = SelectRandom
--
update : Action -> Model -> Model
update action model =
  case action of
    SelectRandom ->
      let
        (index, seed) = randomInt (Array.length model.colorSchemes) model.seed
        _ = Debug.log "SelectRandom" model
      in
        { model |
            current = withDefault model.current (Array.get index model.colorSchemes)
          , seed = seed
        }

-- VIEW

currentColorSchemeView : ColorScheme -> Html
currentColorSchemeView colorScheme =
  let
    fields =
      [ .windowBackground
      , .pianoBlacks
      , .pianoWhites
      , .knobBackground
      , .knobForeground
      , .controlPanelBackground
      , .controlPanelBorders
      ]
    colors = List.map (\field -> field colorScheme) fields
    colorView color =
      div [style [("background-color", (toCssRgb color))]] []
  in
    div [ class "color-scheme-colors"] (List.map colorView colors)

view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "color-scheme-chooser"]
    [ div [class "current-color-scheme"]
      [ button [ onClick address SelectRandom ] [ text "random"]
      ,  currentColorSchemeView model.current
      ]
    ]
    --     [ button [ onClick address Decrement ] [ text "-" ]
    -- , div [ countStyle ] [ text (toString model) ]
    -- , button [ onClick address Increment ] [ text "+" ]
    -- ]
