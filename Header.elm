module Header exposing (Model, Msg, init, update, view ) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Defaults exposing (..)


-- MODEL

type alias Model = 
  { logo : String
  }


init : Model
init = 
  { logo = Defaults.imagesLocation ++ "logoTVO_WritersDesk.png"
  }


-- UPDATE

type Msg 
  = NoOp


update : Msg -> Model -> Model
update message model =
  case message of 
    NoOp ->
      model


-- VIEW

view : Model -> Html Msg
view model =
  div []
  [ img [ src model.logo ] []
  ]


