module Questions exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Data exposing (..)
import Format exposing (..)
import Markdown
import Defaults


-- MODEL

type alias Model = 
  { title : String
  , instructions : String
  , questions : List Question
  , field : String
  , previousField : String
  , numberOfParagraphs : Int
  --, answer : String
  --, essay : Essay

  }

init : Model
init =
  let
    createQuestion id' question =
      { question = question.question
      , answer = ""
      , completed = False
      , editing = False
      , id = id'
      , paragraphId = question.paragraphId
      , rows = question.rows
      , maxlength = question.maxlength
      , format = question.format
      }

    numberOfParagraphs' =
      let
        paragraphIds =
          List.map (\question -> question.paragraphId) Data.questions
      in 
        List.maximum paragraphIds |> Maybe.withDefault 0


  in 
  { title = Data.title
  , instructions = Data.instructions 
  , questions = List.indexedMap createQuestion Data.questions
  , field = ""
  , previousField = ""
  , numberOfParagraphs = numberOfParagraphs'
  } 


-- Question
type alias Question =
  { question : String
  , answer : String
  , completed : Bool
  , editing : Bool
  , id : Int
  , paragraphId : Int
  , rows : Int
  , maxlength : Int
  , format : Format.FormatStyle
  }

-- Sentence
type alias Sentence =
  { content : String
  , completed : Bool
  , editing : Bool
  --, id : Int
  }

-- Paragraph 
type alias Paragraph =
  { sentences : List Sentence
  --, id : Int
  }

-- Essay
type alias Essay =
  { paragraphs : List Paragraph
  }


-- UPDATE

type Msg
  = UpdateFieldOnInput String
  | UpdateFieldOnFocus Question
  | AddAnswer Question 
  | NoOp


update : Msg -> Model -> Model
update msg model =
  case msg of
    
    -- Update the model's `field` property each time the user
    -- types into an input field
    UpdateFieldOnInput string ->
      { model | field = string }

    -- When the user selects and input field, Set the model's `field` 
    -- property to whatever the curren value of that input field is 
    UpdateFieldOnFocus question ->
      { model | field = question.answer }

    -- Update the question's `answer` property with the model's current
    -- field value, and update the model's list of questions
    AddAnswer question ->
      let
        questions' currentQuestion =
          if currentQuestion.id == question.id then
            { currentQuestion 
              | answer = model.field
              , completed = True 
            }
          else
            currentQuestion
      in
        { model
            | questions = List.map questions' model.questions 
        } 
    
    NoOp ->
      model 


-- A function to check whether the user has pressed the Enter key (code 13).
-- If so, the Add message is returned
onEnter : msg -> msg -> Attribute msg
onEnter fail success =
  let
    tagger code =
      if code == 13 then success
      else fail
  in
    on "keyup" (Json.map tagger keyCode)



-- VIEW

(=>) : a -> b -> ( a, b )
(=>) = (,)

-- `questionsView` is the view for the left side of the app, which 
-- includes all the questions
view : Model -> Html Msg
view model =
  let
    textfieldStyle = 
      style
      [ "width" => "100%"
      , "font-family" => Defaults.essayFont
      , "font-size" => "1em"
      , "line-height" => "1.5em"
      , "padding" => "1em"
      ]

    questionStyle =
      style
      [ "font-size" => "1.2em"
      ]

    listItemStyle =
      style
      [ "padding-top" => "4em"
      ]

    getMaxLength maxlength =
      if maxlength /= 0 then
        maxlength
      else
        500

    setAutoFocus question =
      if question.id == 0 then
        True
      else
        False

    questions question =
      li [ listItemStyle ]
      [ Markdown.toHtml [ questionStyle ] question.question 
      , div [ ] 
        [ textarea 
          [ on "input" (Json.map UpdateFieldOnInput targetValue)
          , onEnter NoOp (AddAnswer question)
          , onBlur (AddAnswer question)
          , onFocus (UpdateFieldOnFocus question)
          , class "mdl-textfield__input"
          , rows question.rows
          , textfieldStyle
          , maxlength <| getMaxLength question.maxlength
          , autofocus <| setAutoFocus question
          ] 
          []
        ]
      ]

    answers item =
      div []
      [ p [ ] [ text <| toString(item.id + 1) ++ ". " ++ item.answer ]
      ]

  in
     ol [] (List.map questions model.questions)
  -- Old
  {-
  div [ class "mdl-cell mdl-cell--6-col", style questionContainer ]
    [ img [ src "images/logoTVO_WritersDesk.png" ] [ ]
    , h1 [ titleStyle ] [ text model.title ]
    , ol [ ] (List.map questions model.questions)
    -- Diagnostic
    {-
    , p [] [ text ("Paragraphs: " ++ toString(model.numberOfParagraphs))]
    , p [] [ text model.field ]
    , div [] (List.map answers model.questions)
    -}
    ]
  -}
  
