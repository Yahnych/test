module Questions exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Data exposing (..)
import Format exposing (..)
import Markdown
import Defaults

import Material
import Material.Scheme
import Material.Textfield as Textfield
import Material.Options exposing (css)


-- MODEL

type alias Model = 
  { title : String
  , instructions : String
  , questions : List Question
  , field : String
  , numberOfParagraphs : Int
  , focusChanged : Bool
  --, mdl : Material.Model
  --, answer : String
  --, essay : Essay

  }

type alias Content = 
  { instructions : String
  , questions : List Question
  , field : String
  , numberOfParagraphs : Int
  , focusChanged : Bool
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

    firstQuestion =
      List.head model'.questions 
      |> Maybe.withDefault 
        { question = ""
        , answer = "This is a test"
        , completed = False
        , editing = False
        , id = 0
        , paragraphId = 0
        , rows = 0
        , maxlength = 0
        , format = Format.Normal
        }

    firstAnswer =
      firstQuestion.answer

    model' =
      { title = Data.title
      , instructions = Data.instructions 
      , questions = List.indexedMap createQuestion Data.questions
      , field = ""
      , focusChanged = False
      , numberOfParagraphs = numberOfParagraphs'
      --, mdl = Material.model
      } 


  in 
    --{ model' | field = firstAnswer }
    model'


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
  --| MDL Material.Msg
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    
    -- Update the model's `field` property each time the user
    -- types into an input field
    UpdateFieldOnInput string ->
      { model 
        | field = string
        , focusChanged = False 
      }
      ! []

    -- When the user selects an input field, Set the model's `field` 
    -- property to whatever the current value of that input field is 
    UpdateFieldOnFocus question ->
      let 

        -- This is required so that the existing field value doesn't replace
        -- an existing answer with a blank string
        fieldValue answer =
          if answer /= "" then
            answer
          else
            ""

      in
      { model 
        | field = fieldValue question.answer 
        , focusChanged = True
      }
      ! []

    -- Update the question's `answer` property with the model's current
    -- field value, and update the model's list of questions
    AddAnswer question ->

      let

        -- This is required so that the existing field value doesn't replace
        -- an existing answer with a blank string. This happens when a new
        -- model was loaded from local storage
        answer' =
         if model.field /= "" then 
            model.field 
         else 
            question.answer 

        questions' currentQuestion =
          if currentQuestion.id == question.id then
            { currentQuestion 
              | answer = answer'
              , completed = True 
            }
          else
            currentQuestion
      in
        { model
            | questions = List.map questions' model.questions 
        } 
      ! []
    
    {-
    MDL msg ->
      Material.update MDL msg model
    -}

    NoOp ->
      model 
      ! []


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
        {-
        [ Textfield.render MDL [0] model.mdl
          [ Textfield.label "Multiline with 6 rows"
          , Textfield.floatingLabel
          , Textfield.textarea
          , Textfield.rows 6
          ]
        ] 
        -}
        
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
          [ text question.answer ]
        ]
      ]
    |> Material.Scheme.top

    answers item =
      div []
      [ p [ ] [ text <| toString(item.id + 1) ++ ". " ++ item.answer ]
      ]

  in
    div []
     [ ol [] (List.map questions model.questions)
     ]
     
