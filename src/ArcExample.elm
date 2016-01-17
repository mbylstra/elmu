import Html
import Html exposing (div)
import Html.Attributes exposing (style)

import Svg exposing (svg, path, rect)
import Svg.Attributes exposing (d, stroke, fill, strokeWidth, x, y, width, height, viewBox)

import Arc exposing (arc)

example : Html.Html
example =
  svg
    [ style [("border", "20px solid rgba(255, 0, 0, 0.1)"), ("margin", "50px")]
    , width "200", height "200", viewBox "0 0 200 200"
    ]

    [ rect [x "0", y "0", width "200", height "200", fill "none"] []
    , path
        [ d (arc
              { radius=80.0
              , centerPoint=(100.0,100.0)
              , startAngle=45.0
              , endAngle=315.0
              }
            )
        , stroke "black"
        , fill "none"
        , strokeWidth "40"
        ]
        []
    ]

main : Html.Html
main = example
