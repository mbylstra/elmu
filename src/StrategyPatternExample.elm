-- /* Encapsulated family of Algorithms
--  * Interface and its implementations
--  */
-- public interface IBrakeBehavior {
--     public void brake();
-- }
--
-- public class BrakeWithABS implements IBrakeBehavior {
--     public void brake() {
--         System.out.println("Brake with ABS applied");
--     }
-- }
--
-- public class Brake implements IBrakeBehavior {
--     public void brake() {
--         System.out.println("Simple Brake applied");
--     }
-- }

{- at it's most abstract, the break function does
  nothing more than transform the state of the car.
  This assumes a very simplistic model of breaking,
  where the break is applied will full force for
  a length of time that is undefined. Perhaps
  the lenght of time is assumed to be the lenght
  of one tick of the clock or maybe a millisecond.
  This type signature is the equivalent of the IBreakBehavior
  Interface in the Java example
-}

import Color exposing (Color)

type alias BreakFunction carModel = (carModel -> carModel)

type alias CarModelA =
  { speed : Float
  , color : Color
  }

fullyGenericBreak : BreakFunction carModel
fullyGenericBreak carModel =
  -- If we don't know anything about the carModel,
  -- there's not really much we can do, other
  -- than just return the model that was provided.
  -- We know nothing about the type of carModel. It
  -- could be a record, a Dict, or something else.
  -- So while this function will compile, and will work for any
  -- car model, it's also completely useless. Actually, it's
  -- worse than useless - if you use this function
  -- breaking will do nothing, and the car will
  -- crash into the wall!
  carModel

{- now we have a function that takes a concrete type (CarModelA)
 -}
break : BreakFunction CarModelA
break car =
  { car | speed = car.speed - 0.1 }

{-
    Voilà, we have a break function. That's really all there is to it if
    that's all we need. But it's a bit lacking. Ideally we'd be able to apply
    more than one break pressure.
-}

hardBreak : BreakFunction CarModelA
hardBreak car =
  { car | speed = car.speed - 0.2 }

{-
  Now we have two break functions, both of which obey the BreakFunction interface / type signature.
  They can easily be interchanged by the calling program, without any change other
  than the function name. Example:
-}

type Action = Break | Accelerate

update : Action -> CarModelA -> CarModelA
update action model =
  case action of
    Break
      -> break model -- the break function can trivially be swapped out with the
                     -- hardBreak function to change the behaviour of the
                     -- program. You can even do this mid game with hot-swapping,
                     -- as the type signatures are the same. This is pretty
                     -- awesome for interactive development!
    Accelerate
      -> Debug.crash("Not yet implemented")

update : BreakFunction -> Action -> CarModelA -> CarModelA
update breakFunction action model =
  case action of
    Break
      -> breakFunction model -- the break function can trivially be swapped out with the
                     -- hardBreak function to change the behaviour of the
                     -- program. You can even do this mid game with hot-swapping,
                     -- as the type signatures are the same. This is pretty
                     -- awesome for interactive development!
    Accelerate
      -> Debug.crash("Not yet implemented")


-- update hardBreak action model
-- update softBreak action model


{-
  Let's imagine that the touchItem.force Web API has been implemented and browers
  and that there's some hardware that supports it. In this case you would not be
  satisfied with just two break pressure levels, you would want a spectrum.
  Rather than having to implement a function for each pressure level, partial
  applicatio can be used   ??? can it?
-}

breakWithPressure : Float -> CarModelA -> CarModelA
breakWithPressure pressure car =
  { car | speed = car.speed - (0.1 * pressure) }

{-
  This function no longer obeys the BreakFunction type alias, so it can't
  be used with our modified update function
-}

breakWithPressure : Float -> CarModelA -> CarModelA
breakWithPressure pressure car =
  { car | speed = car.speed - (0.1 * pressure) }
t

ype Action = Break Float | Accelerate Float
 -- The Break type constructor now takes Float as an argument, representing
-- the break pressure.

performUpdate action model =
  let
    updateFunction =
  in
    update updateFunction action model
