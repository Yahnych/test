module WritingAdvice exposing (init, update, view) --where

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Questions exposing (..)
import Essay exposing (..)
import Markdown
import Header exposing (..)


-- MODEL

type alias Model = 
  { questions : Questions.Model
  , essay : Essay.Model
  , header : Header.Model
  }


init : (Model, Cmd Msg)
init =
  let 
    questions' =
      Questions.init
  in
  { questions = questions'
  , essay = Essay.init 
  , header = Header.init
  }
  ![]


-- UPDATE

type Msg
  = UpdateQuestions Questions.Msg
  | UpdateHeader Header.Msg
  | UpdateHtmlEssay Essay.Msg
  | UpdateMarkdown --Questions.Model
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    {-
    UpdateQuestions msg ->
      { model | questions = questions' msg } 
      ![ snd(update (UpdateMarkdown (questions' msg)) model) ]

    UpdateMarkdown questions ->
      { model | essay = Essay.update (Essay.CreateMarkdown questions) model.essay }
      ![]
    -}
    UpdateQuestions msg ->
      let
        model' = { model | questions =  Questions.update msg model.questions } 
      in
        update UpdateMarkdown model'

    UpdateMarkdown ->
      { model | essay = Essay.update (Essay.UpdateMarkdown model.questions) model.essay }
      ![]

    UpdateHeader msg ->
      { model | header = Header.update msg model.header }
      ![]

    UpdateHtmlEssay msg ->
      { model | essay = Essay.update msg model.essay }
      ![]
    
    NoOp ->
      model 
      ![]


-- VIEW

(=>) = (,)

view : Model -> Html Msg
view model =
  let
    mainContainerStyle =
      style
      [ "margin" => "0px"
      , "padding" => "0px"
      , "width" => "100vw"
      , "height" => "100vh"
      ]
    questionContainerStyle =
      style
      [ "padding" => "2vh 5vw 5vh 5vw"
      , "overflow" => "hidden"
      , "overflow-y" => "auto"
      , "overflow-x" => "auto"
      --, "background-color" => "aliceBlue" 
      ]
    essayContainerStyle =
      style
      [ "padding" => "5vh 5vw 5vh 5vw"
      , "overflow" => "hidden"
      , "overflow-y" => "auto"
      , "overflow-x" => "auto"
      --, "background-color" => "seaGreen"
      , "background-image" => "url(images/paper.png)" 
      , "-webkit-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "-moz-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      ]
    titleStyle =
      style
      [ "font-size" => "3.5em"
      , "font-family" => "SuisseIntl-Thin"
      , "padding-top" => "0.5em"
      ]


  in 
  div [ class "mdl-grid", mainContainerStyle ]
    [ div 
       [ class "mdl-cell mdl-cell--6-col", questionContainerStyle ]
       [ App.map UpdateHeader (Header.view model.header)
       , h1 [ titleStyle ] [ text model.questions.title ]
       , App.map UpdateQuestions (Questions.view model.questions)
       ]
    , div 
       [ class "mdl-cell mdl-cell--6-col", essayContainerStyle ] 
       [ App.map UpdateHtmlEssay (Essay.view model.questions) 
       , Markdown.toHtml [] model.essay.markdown
       ]
    ]

