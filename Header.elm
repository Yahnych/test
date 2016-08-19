

module Header exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Defaults exposing (..)


-- MODEL

type alias Model = 
  { logo : String
  , markdown : String
  }


init : Model
init = 
  { logo = Defaults.imagesLocation ++ "logo_WritersDeskLong_48.png"
  , markdown = ""
  }


-- UPDATE

type Msg 
  = NoOp
  

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    NoOp ->
      model ! []


-- VIEW

(=>) : a -> b -> ( a, b )
(=>) = (,)

view : Model -> Html Msg
view model =
  let
    logoContainerStyle =
      style
      [ "position" => "fixed"
      ]
  in
  div []
    [ img [ src model.logo ] []
    ]


