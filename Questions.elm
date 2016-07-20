module Questions exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Data exposing (..)
import Format exposing (..)
import Markdown
import Defaults
import String

import Material
import Material.Scheme
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Material.Options exposing (css)
import Material.Button as Button


-- MODEL

type alias Model = 
  { content : Content 
  , mdl : Material.Model
  , completionMessage : String
  }

type alias Content = 
  { title : String
  , instructions : String
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
      , field = "" 
      , focusChanged = False
      , numberOfParagraphs = numberOfParagraphs'
      --, mdl = Material.model
      } 

    model' = 
      { content = content'
      , mdl = Material.model
      , completionMessage = ""
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

{-
type Msg
  = UpdateFieldOnInput String
  | UpdateFieldOnFocus Question
  | AddAnswer Question 
  | MDL Material.Msg
  | CheckForCompletion
  | NoOp
-}

type Msg
  = UpdateField Question String
  | MDL Material.Msg
  | CheckForCompletion
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
   {- 
    -- Update the model's `field` property each time the user
    -- types into an input field
    UpdateFieldOnInput string ->
      let
        content' modelContent =
          { modelContent
              | field = string
              , focusChanged = False 
          }

      in
      { model 
          | content = content' model.content
      }
      ! []

    -- When the user selects an input field, Set the model's `field` 
    -- property to whatever the current value of that input field is 
    UpdateFieldOnFocus question ->
      let 

        -- This is required so that the existing field value doesn't replace
        -- an existing answer with a blank string
        fieldValue answer =
          if answer /= "" || question.id == 0 then
            answer
          else
            ""

        content' modelContent =
          { modelContent
              | field = question.answer --fieldValue question.answer 
              , focusChanged = True
          }
      in
      { model 
          | content = content' model.content
      }
      ! []

    -- Update the question's `answer` property with the model's current
    -- field value, and update the model's list of questions
    AddAnswer question ->

      let

        -- This is required so that the existing field value doesn't replace
        -- an existing answer with a blank string. This happens when a new
        -- model was loaded from local storage
        {-
        answer' =
         if model.content.field /= "" then 
            model.content.field 
         else 
            question.answer 
        -}
        answer' =
         if model.content.field == "" && question.answer /= "" then 
            question.answer 
         else 
            model.content.field 

        completed' =
          if String.isEmpty model.content.field then
            False
          else
            True


        questions' currentQuestion =
          if currentQuestion.id == question.id then
            { currentQuestion 
              | answer = model.content.field --answer'
              --| answer = answer'
              , completed = completed' 
            }
          else
            currentQuestion


        content' modelContent =
          { modelContent
              | questions = List.map questions' modelContent.questions
          }

      in
        { model 
            | content = content' model.content
        }
      ! []
    -}
    
    MDL msg ->
      Material.update MDL msg model

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
          | completionMessage = completionMessage'
      }
      ! []

    UpdateField question inputString ->
      let
        completed' =
          if String.isEmpty inputString then
            False
          else
            True

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
      ]

    completionMessageStyle =
      style
      [ "color" => "mediumSeaGreen"
      , "font-weight" => "bold"
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
  
    {-
    questions question =
      li [ listItemStyle ]
      [ Markdown.toHtml [ questionStyle ] question.question 
      , Textfield.render MDL [ question.id ] model.mdl
        [ Textfield.label "Multiline with 6 rows"
        , Textfield.floatingLabel
        , Textfield.textarea
        , Textfield.rows question.rows 
        , on "input" (Json.map UpdateFieldOnInput targetValue)
        , onEnter NoOp (AddAnswer question)
        , onBlur (AddAnswer question)
        , onFocus (UpdateFieldOnFocus question)
        --, class "mdl-textfield__input"
        , textfieldStyle
        , maxlength <| getMaxLength question.maxlength
        , autofocus <| setAutoFocus question
        ]
      ]
    |> Material.Scheme.top
    -}
    {-
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
    -}
    {-
    questions question =
      li [ listItemStyle ]
      [ div [ toggleStyle ]
          [
            Toggles.checkbox MDL [ question.id ] model.mdl
            [ Toggles.value question.completed
            , css "color" "red"
            , css "margin-left" "-3em"
            ]
          []
          ]
      , Markdown.toHtml [ questionStyle ] question.question 
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
          [ text question.answer ]
        ]
      ]
    |> Material.Scheme.top
    -}
    questions question =
      li [ listItemStyle ]
      [ img [ (src <| checkbox question.completed), checkboxStyle ] []
      , Markdown.toHtml [ questionStyle ] question.question 
      , div [ ]
        {-
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
        -}
        [ textarea 
          [ on "input" (Json.map (UpdateField question) targetValue)
          , class "mdl-textfield__input"
          , rows question.rows
          , textfieldStyle
          , maxlength <| getMaxLength question.maxlength
          , autofocus <| setAutoFocus question
          ] 
          [ text question.answer ]
        ]
      ]
 

    answers item =
      div []
      [ p [ ] [ text <| toString(item.id + 1) ++ ". " ++ item.answer ]
      ]

    doneButton =
       Button.render MDL [0] model.mdl
        [ Button.onClick CheckForCompletion
        , Button.ripple
        , Button.colored
        , Button.raised
        , css "background-color" "rgb(0, 127, 163)"
        , css "float" "right"
        , css "margin-top" "2em"
        ]
        [ text "Done" ]

  in
    div []
     [ p [] [ text model.content.field ]
     , ol [] (List.map questions model.content.questions)
     , doneButton
     , p [ completionMessageStyle ] [ text model.completionMessage ]
     ]
     |> Material.Scheme.top
     
