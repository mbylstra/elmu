import String
import Html
import Svg exposing (svg, path, rect)
import Svg.Attributes exposing (d, stroke, fill, strokeWidth, x, y, width, height, viewBox)
import Html exposing (div)
import Html.Attributes exposing (style)

polarToCartesian : Float -> Float -> Float -> Float -> (Float, Float)
polarToCartesian centerX centerY radius angleInDegrees =
  let
    angleInRadians = (angleInDegrees - 90.0) * pi / 180.0
  in
    ( centerX + (radius * (cos angleInRadians))
    , centerY + (radius * (sin angleInRadians))
    )


boolToIntString : Bool -> String
boolToIntString b =
  case b of
    True -> "1"
    False -> "0"


type alias ArcArgs =
  { absolute : Bool
  , radius : (Float, Float)
  , xAxisRotation : Float
  , largeArc : Bool
  , sweep : Bool
  , endPoint : (Float, Float)
  }

arcSegment : ArcArgs -> String
arcSegment args =
  let
    (radiusX, radiusY) = args.radius
    (endX, endY) = args.endPoint
  in
    [ if args.absolute then "A" else "a" -- 'A' for arc. Capital for absolute, lower for relative - isn't it obvious?!
    , toString radiusX  -- radius X
    , toString radiusY -- radius Y
    , toString args.xAxisRotation  -- x axis rotation
    , boolToIntString args.largeArc -- large arc flag
    , boolToIntString args.sweep  -- sweep flag
    , toString endX
    , toString endY
    ]
    |> String.join " "


type alias ArcShapeArgs =
  { radius : Float
  , centerPoint : (Float, Float)
  , startAngle : Float
  , endAngle : Float
  }

fromDegrees = degrees
fromRadians = radians

arcShape : ArcShapeArgs -> String
arcShape args =
  let
    startAngleRadians = 0.0
    endAngleRadians = fromDegrees args.endAngle
    -- radius = 1.0
    radius = args.radius
    -- startPoint = fromPolar (radius, 0.0)
    (endPointX, endPointY) = fromPolar (radius, endAngleRadians)
    (centerX, centerY) = args.centerPoint
    endPointX' = endPointX + radius
    endPointY' =  (radius * 2.0) - (endPointY + radius)
    largeArc = if args.endAngle >= 180.0 then True else False

    startPointXAngle0 = centerX + radius
    startPointYAngle0 = centerY

    _ = Debug.log "radius" radius
    _ = Debug.log "endAngleDegrees" args.endAngle
    _ = Debug.log "endAngleRadians" endAngleRadians
    -- _ = Debug.log "startPoint" startPoint
    _ = Debug.log "endPointX" endPointX
    _ = Debug.log "endPointY" endPointY
    _ = Debug.log "endPointX'" endPointX'
    _ = Debug.log "endPointY'" endPointY'
  in
    ("M " ++ (toString startPointXAngle0) ++ " " ++ (toString startPointYAngle0) ++ " " ++
      ( arcSegment
        { absolute=True
        , endPoint=(endPointX', endPointY')
        , radius=(args.radius, args.radius)
        -- , radius=(0.0, 0.0)  -- draw straight line while figuring it out!
        , sweep=False
        , largeArc=largeArc
        , xAxisRotation=0.0
        }
      )
    )


-- arcShapeD : Float -> Float -> Float -> Float -> Float -> String
-- arcShapeD x y radius startAngle endAngle =
--   let
--     (startX, startY) = polarToCartesian x y radius endAngle
--     (endX, endY) = polarToCartesian x y radius startAngle
--     arcSweep =
--       if endAngle - startAngle <= 180.0 then "0" else "1"
--     d =
--       [ "M"
--         , toString startX
--         , toString startY
--       , "A"  -- path is of type Arc, capital means absolute
--         , toString radius  -- radius X
--         , toString radius -- radius Y
--         , "0"  -- x axis rotation
--         , "0" -- large arc flag
--         , arcSweep  -- sweep flag
--         , toString endX  -- sweep flag
--         , toString endY
--       ]
--       |> String.join " "
--   in
--     d



example1 : Html.Html
example1 =
  div
    [ style [("margin", "100px")]]
    [ svg
      []
      [ path
          [
            d
              ("M 50 50 M -50 -50 " ++
                ( arcSegment
                  { absolute=True
                  , endPoint=(100.0,100.0)
                  , radius=(0.000001,0.000001) -- this is bullshit!
                  , sweep=False
                  , largeArc=False
                  , xAxisRotation=0.0
                  }
                )
              )
          , stroke "black"
          , fill "none"
          , strokeWidth "10"
          ]
          []
      ]
    ]
example2 =
  svg
    [ style [("border", "1px solid red"), ("margin", "50px")]
    , width "200", height "200", viewBox "0 0 200 200"
    ]
    -- [ style [("border", "1px solid red")]]

    [ rect [x "0", y "0", width "200", height "200", fill "none", stroke "red"] []
    , path
        [ d (arcShape {radius=100.0,centerPoint=(100.0,100.0),startAngle=0.0,endAngle=90.0})
        , stroke "black"
        , fill "none"
        , strokeWidth "10"
        ]
        []
    ]


-- lets get a normalised one working first.

main : Html.Html
-- main = example1
main = example2


-- x = fromPolar (0, 0)
-- x = fromPolar (1.0, 0)
-- x = fromPolar (1.0, pi/2.0)
-- y = pi
