module Questions exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Data exposing (..)
import Format exposing (..)
import Markdown exposing (..)
import Defaults
import String

import Material
import Material.Scheme
import Material.Textfield as Textfield
import Material.Options as Options exposing (css)
import Material.Toggles as Toggles
import Material.Options exposing (css)
import Material.Button as Button


-- MODEL

type alias Model = 
  { content : Content 
  , mdl : Material.Model
  , displayCompletionMessage : Bool
  }

type alias Content = 
  { title : String
  , instructions : String
  , questions : List Question
  , numberOfParagraphs : Int
  , percentageComplete : Int
  , completionMessage : String
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
      List.head model'.content.questions 
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

    content' =
      { title = Data.title
      , instructions = Data.instructions 
      , questions = List.indexedMap createQuestion Data.questions
      , numberOfParagraphs = numberOfParagraphs'
      , percentageComplete = 0
      , completionMessage = Data.completionMessage
      } 

    model' = 
      { content = content'
      , mdl = Material.model
      , displayCompletionMessage = False
      }

  in 
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
  = UpdateField Question String
  | MDL (Material.Msg Msg)
  | CheckForCompletion
  | UpdatePercentageComplete
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    
    MDL msg' ->
      Material.update msg' model

    CheckForCompletion ->
      let

        -- Find out which questions remain to be answered
        remainingAnswers =
          List.filter (\question -> not question.completed) model.content.questions

        -- Find out what the id numbers of the remaining unanswered questions are
        remainingAnswerIDs =
          List.map (\question -> question.id) remainingAnswers

        -- Add 1 to the remaining unanswered question id numbers to that they 
        -- match the displayed question numbers
        remainingQuestionNumbers =
          List.map (\id -> id + 1) remainingAnswerIDs

        remainingQuestionNumbersAsStrings =
          List.map (\number -> toString number) remainingQuestionNumbers

        percentageComplete =
          let
            remaining = 
              List.length remainingQuestionNumbers |> toFloat

            total =
              List.length model.content.questions |> toFloat

            completed =
              total - remaining
              |> (*) 100
          in
           completed / total |> floor

        completionMessage' =
          "Percentage Complete: "
          ++ toString percentageComplete
          ++ "%"
          ++ ". Please complete the remainig questions: " 
          ++ String.join ", " remainingQuestionNumbersAsStrings

      in
      { model 
          | displayCompletionMessage = True
      }
      ! []

    UpdateField question inputString ->
      let
        -- Set the `completed` Boolean flag on the answer
        completed' =
          if String.isEmpty inputString then
            False
          else
            True

        -- Update the current answer with textfield input value
        questions' currentQuestion =
          if currentQuestion.id == question.id then
            { currentQuestion 
              | answer = inputString
              , completed = completed' 
            }
          else
            currentQuestion

        content' modelContent =
          { modelContent
            | questions = List.map questions' modelContent.questions
            --, percentageComplete = percentageComplete'
          }

        model' =
          { model 
            | content = content' model.content
            , displayCompletionMessage = False
          }
      in
        update UpdatePercentageComplete model'

    UpdatePercentageComplete ->
      let 
        -- Find out which questions remain to be answered
        remainingAnswers =
          List.filter (\question -> not question.completed) model.content.questions

        -- Find out what the id numbers of the remaining unanswered questions are
        remainingAnswerIDs =
          List.map (\question -> question.id) remainingAnswers

        -- Add 1 to the remaining unanswered question id numbers to that they 
        -- match the displayed question numbers
        remainingQuestionNumbers =
          List.map (\id -> id + 1) remainingAnswerIDs

        remaining = 
          List.length remainingQuestionNumbers |> toFloat

        total =
          List.length model.content.questions |> toFloat

        completed =
          total - remaining
          |> (*) 100

        percentageComplete' =
           completed / total |> floor

        content' modelContent =
          { modelContent
              | percentageComplete = percentageComplete'
          }
      in
        { model 
            | content = content' model.content
        }
        ! []

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
      , "margin-top" => "-1.4em"
      , "padding-bottom" => "1.5em"
      ]

    listItemStyle =
      style
      [ "padding-top" => "4em"
      ]

    toggleStyle =
      style
      [ "background-color" => "red"
      , "display" => "inline"
      , "height" => "0px"
      ]

    checkboxStyle =
      style
      [ "margin-left" => "-3em"
      , "margin-top" => "-2px"
      ]

    completionMessageStyle =
      if model.content.percentageComplete == 100 then
        style
        [ "color" => "black"
        , "font-weight" => "normal"
        , "width" => "80%"
        ]
      else
        completionPercentageMessageStyle

    completionPercentageMessageStyle =
      style
      [ "color" => "mediumSeaGreen"
      , "font-weight" => "bold"
      , "width" => "80%"
      ]

    completionMessageContainerStyle =
      style
      [ "padding-top" => "2em"
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

    checkbox state =
      if state == True then
        Defaults.imagesLocation ++ "checkboxTrue.png"
      else
        Defaults.imagesLocation ++ "checkboxFalse.png"

    completionMessage =
      let
        -- Find out which questions remain to be answered
        remainingAnswers =
          List.filter (\question -> not question.completed) model.content.questions

        -- Find out what the id numbers of the remaining unanswered questions are
        remainingAnswerIDs =
          List.map (\question -> question.id) remainingAnswers

        -- Add 1 to the remaining unanswered question id numbers to that they 
        -- match the displayed question numbers
        remainingQuestionNumbers =
          List.map (\id -> id + 1) remainingAnswerIDs

        remainingQuestionNumbersAsStrings =
          List.map (\number -> toString number) remainingQuestionNumbers
      in
      case model.displayCompletionMessage of
        True ->
          if model.content.percentageComplete == 100 then
            model.content.completionMessage
          else
            "**" 
            ++ "Please complete the remaining questions: " 
            ++ (String.join ", " remainingQuestionNumbersAsStrings)
            ++ "**"

        False ->
          ""
  
    percentageCompleteMessage =
      "Percentage Complete: " 
      ++ toString model.content.percentageComplete
      ++ "%"

    questions question =
       let
        ordinaryTextfield =
          textarea 
          [ on "input" (Json.map (UpdateField question) targetValue)
          --, onBlur UpdatePercentageComplete
          , class "mdl-textfield__input"
          , rows question.rows
          , textfieldStyle
          , maxlength <| getMaxLength question.maxlength
          , autofocus <| setAutoFocus question
          ] 
          [ text question.answer ]

        mdlTextfield =
          Textfield.render MDL [ question.id ] model.mdl
          [ Textfield.label ""
          , Textfield.autofocus 
          , Textfield.maxlength <| getMaxLength question.maxlength
          , Textfield.rows question.rows

          -- What's the mdl equivalent for the `text` property?
          , Textfield.textarea
          , Textfield.value question.answer
          , Textfield.on "input" (Json.map (UpdateField question) targetValue)

          -- Assign a unique html `id` attribute that matches the `question.id`. This is used 
          -- by the `SetFocus` message to set the input focus to the first question
          -- in the tab list when a tab is clicked or the `next paragraph` button is clicked
          , Textfield.style [ Options.attribute <| Html.Attributes.id ("question" ++ toString (question.id)) ]
          , css "width" "90%"
          --, Textfield.text' question.answer
          ]
      in
      li [ listItemStyle ]
      [ img [ (src <| checkbox question.completed), checkboxStyle ] []
      , Markdown.toHtml [ questionStyle ] question.question 
      , div [ ]
        [ mdlTextfield 
          --ordinaryTextfield
        ]
      ]

    answers item =
      div []
      [ p [ ] [ text <| toString(item.id + 1) ++ ". " ++ item.answer ]
      ]

    doneButton =
       Button.render MDL [0] model.mdl
        [ Button.ripple
        , Button.raised
        , Button.colored
        , Button.onClick CheckForCompletion
        , css "background-color" "rgb(0, 127, 163)"
        , css "float" "right"
        , css "margin-top" "2em"
        ]
        [ text "Done" ]

    options =
      let
        defaultOptions = Markdown.defaultOptions
      in
      { defaultOptions 
          | smartypants = True
          , sanitize = True
      }


  in
    div []
     [ ol [] (List.map questions model.content.questions)
     , doneButton
     , div [ completionMessageContainerStyle ]
       [ p [ completionPercentageMessageStyle ] [ text percentageCompleteMessage ]
       , Markdown.toHtml [ completionMessageStyle ] completionMessage
       ]
     ]
     --|> Material.Scheme.top
     
