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
import Dom.Scroll as Scroll
import Dom
import Task
import List.Extra

import Material
import Material.Options exposing (css)
import Material.Button as Button
import Material.Options as Options exposing (css)
import Material.Tabs as Tabs
import Material.Textfield as Textfield
import Material.Icon as Icon
-- import Material.Scheme
-- import Material.Color as Color


-- MODEL

type alias Model = 
  { content : Content 
  , mdl : Material.Model
  , displayCompletionMessage : Bool
  , selectedGroupId : Int
  }

type alias Content = 
  { title : String
  , instructions : String
  , questions : List Question
  , questionGroups : List Data.QuestionGroup 
  , numberOfParagraphs : Int
  , percentageComplete : Int
  , selectedGroupPercentageComplete : Int
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
      , groupId = question.groupId
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
        , groupId = 0
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
      , questionGroups = Data.questionGroups
      , numberOfParagraphs = numberOfParagraphs'
      , percentageComplete = 0
      , selectedGroupPercentageComplete = 0
      , completionMessage = Data.completionMessage
      } 

    model' = 
      { content = content'
      , mdl = Material.model
      , displayCompletionMessage = False
      , selectedGroupId = 0
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
  , groupId : Int
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
  | GotToNextParagraph
  -- | UpdateSelectedGroupIdPercentageComplete
  | SelectTab Int
  --| SetFocus
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    
    MDL msg' ->
      Material.update msg' model

    CheckForCompletion ->
      { model 
          | displayCompletionMessage = True
      }
      ! []

    GotToNextParagraph ->
      let
        model' = 
          { model
              | selectedGroupId = model.selectedGroupId + 1
          }

        -- After the `selectedGroupId` is set, update the model content with the new
        -- percentages complete for the entire essay and the current group
        content' modelContent =
          { modelContent
              | percentageComplete = percentageComplete modelContent.questions
              , selectedGroupPercentageComplete = percentageComplete (selectedGroupQuestions model')
          }

        model'' =
          { model'
              | content = content' model'.content
          } 
      in 
      model''
      ! [ Task.perform (always NoOp) (always NoOp) (Scroll.toTop "questionsContainer") 
        , setFocus model''
        ]

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
        content' modelContent =
          { modelContent
              | percentageComplete = percentageComplete model.content.questions
              , selectedGroupPercentageComplete = percentageComplete (selectedGroupQuestions model)
          }

        model' =
          { model 
            | content = content' model.content
          }
      in
        model' ! []

    SelectTab value ->
      let

        -- The model needs to be updated first so that the new `selectedGroupId` can be set
        model' = 
          { model
              | selectedGroupId = value
          } 

        -- After the `selectedGroupId` is set, update the model content with the new
        -- percentages complete for the entire essay and the current group
        content' modelContent =
          { modelContent
              | percentageComplete = percentageComplete modelContent.questions
              , selectedGroupPercentageComplete = percentageComplete (selectedGroupQuestions model')
          }

        model'' =
          { model'
              | content = content' model'.content
          } 
      in 
        -- update UpdateSelectedGroupIdPercentageComplete model'
         model'' ! [ setFocus model'' ]

    NoOp ->
      model 
      ! []


-- Helpter functions

-- Set the focust to the currently selected input textfield

setFocus : Model -> Cmd Msg
setFocus model =
  Task.perform (always NoOp) (always NoOp) (Dom.focus ("question" ++ ( toString ( .id (firstQuestionInSelectedGroup model) ))))

-- A standard default question

defaultQuestion : Question
defaultQuestion = 
  { question = ""
  , answer = "This is a test"
  , completed = False
  , editing = False
  , id = 0
  , paragraphId = 0
  , groupId = 0
  , rows = 0
  , maxlength = 0
  , format = Format.Normal
  }

listOfQuestionGroups : Model -> List (List Question)
listOfQuestionGroups model =
  List.Extra.groupWhile (\x y -> x.groupId == y.groupId) model.content.questions

selectedQuestionList : Model -> List Question
selectedQuestionList model  =
  List.Extra.getAt model.selectedGroupId (listOfQuestionGroups model)
    |> Maybe.withDefault [ defaultQuestion ]

firstQuestionInSelectedGroup : Model -> Question
firstQuestionInSelectedGroup model =
  List.head (selectedQuestionList model)
    |> Maybe.withDefault defaultQuestion

-- All the questions in the selected group
selectedGroupQuestions : Model -> List Question
selectedGroupQuestions model =
  List.filter (\question -> question.groupId == model.selectedGroupId) model.content.questions

-- Calculate the percentage of answered questions
percentageComplete : List Question -> Int
percentageComplete questions =
  let
    -- Find out which questions remain to be answered
    remainingAnswers =
      List.filter (\question -> not question.completed) questions

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
      List.length questions |> toFloat

    completed =
      total - remaining
      |> (*) 100
  in
    completed / total |> floor


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
      [ "width" => "95%"
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
      , "padding-left" => "1.3em"
      ]

    questionHeadingStyle =
      style
      [ "padding-top" => "2em"
      , "font-size" => "1.2em"
      , "padding-bottom" => "0"
      , "margin-bottom" => "0"
      , "font-weight" => "bold"
      , "line-height" => "1.2em"
      ]

    listItemStyle =
      style
      [ "padding-top" => "3em"
      ]

    tabVisibilityStyle question =
      if model.selectedGroupId == question.groupId then
        style
        [ "display" => "block"
        ]
      else
        style
        [ "display" => "none"
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
      , "margin-top" => "-3px"
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

    questionNumberStyle =
      style
      [ "padding-left" => "1.8em"
      --, "padding-right" => "2em"
      ]

    questionsContentContainerStyle =
      style
      [-- "padding-top" => "-5%"
      --, "background-color" => "aliceBlue"
      ]

    scrollingQuestionsContentContainerStyle =
      style
      [-- "padding" => "2vh 5vw 5vh 5vw"
      "padding-top" => "20%"
      , "padding-left" => "5%"
      , "overflow-y" => "scroll"
      --, "position" => "absolute"
      --, "top" => "50%"
      --, "left" => "10%"
      , "height" => "auto"
      , "width" => "95%"
      --, "overflow-y" => "auto"
      --, "overflow-x" => "auto"
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
  
    totalPercentageCompleteMessage =
      "Total essay complete: " 
      ++ toString model.content.percentageComplete
      ++ "%"

    selectedGroupPercentageCompleteMessage =
      "Current paragraph complete: " 
      ++ toString model.content.selectedGroupPercentageComplete
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

        mdlCheckbox completed =
          Icon.i "check box outline"

      in
      li [ listItemStyle, (tabVisibilityStyle question) ]
      [ img [ (src <| checkbox question.completed), checkboxStyle ] []
      --  mdlCheckbox question.completed
      , span [ questionNumberStyle ] [ text <| (toString (question.id + 1) ++ ". ") ]
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
       let
         toggleVisibility =
           if model.selectedGroupId == List.length model.content.questionGroups - 1 then
             css "display" "block"
           else 
             css "display" "none"
       in
       Button.render MDL [100] model.mdl
        [ Button.ripple
        , Button.raised
        , Button.colored
        , Button.onClick CheckForCompletion
        --, css "background-color" "rgb(0, 127, 163)"
        , css "float" "right"
        , css "margin-top" "2em"
        , toggleVisibility
        ]
        [ text "Done" ]

    nextButton =
       let
         toggleVisibility =
           if model.selectedGroupId /= List.length model.content.questionGroups - 1 then
             css "display" "block"
           else 
             css "display" "none"
       in
       Button.render MDL [200] model.mdl
        [ Button.ripple
        , Button.raised
        , Button.colored
        , Button.onClick GotToNextParagraph
        --, css "background-color" "rgb(0, 127, 163)"
        , css "float" "right"
        , css "margin-top" "2em"
        , toggleVisibility
        ]
        [ text "Next Paragraph" ]

    options =
      let
        defaultOptions = Markdown.defaultOptions
      in
      { defaultOptions 
          | smartypants = True
          , sanitize = True
      }

    -- Provided the questions as a single list, without tabs
    questionsContent =
      div [ questionsContentContainerStyle ]
       [ ol [] (List.map questions model.content.questions)
       , doneButton
       , nextButton
       , div [ completionMessageContainerStyle ]
         [ p [ completionPercentageMessageStyle ] [ text selectedGroupPercentageCompleteMessage ]
         , p [ completionPercentageMessageStyle ] [ text totalPercentageCompleteMessage ]
         , Markdown.toHtml [ completionMessageStyle ] completionMessage
         ]
       ]

    questionGroupHeading = 
      let
        defaultGroup = 
          { title = "No title"
          , description = "No descrition"
          , navigationHeading = "None"
          , groupId = 0
          }

        selectedGroup =
          List.filter (\group -> group.groupId == model.selectedGroupId) model.content.questionGroups
          |> List.head
          |> Maybe.withDefault defaultGroup
      in
        h2 [ questionHeadingStyle ] [ text selectedGroup.title ]

    tabbedQuestionsContent =
      let
        listOfQuestionGroups : List (List Question)
        listOfQuestionGroups =
          List.Extra.groupWhile (\x y -> x.groupId == y.groupId) model.content.questions

        selectedQuestionList : Int -> List Question
        selectedQuestionList selectedGroupId =
          List.Extra.getAt selectedGroupId listOfQuestionGroups
          |> Maybe.withDefault [ defaultQuestion ]

        allQuestionsComplete selectedGroupId =
          List.all (\question -> question.completed ) (selectedQuestionList selectedGroupId)

        icon selectedGroupId =
          if allQuestionsComplete selectedGroupId then
           Icon.i "done"
          else
           Icon.i ""

        tab questionGroup =
          Tabs.label 
          [ ] 
          [ Options.span [ css "width" "10px" ] []

          -- Display the checkmark icon only if all the questions 
          -- in the current group have been answered
          , icon questionGroup.groupId
          , text questionGroup.navigationHeading
          ]

        tabs =
          List.map tab model.content.questionGroups
      in
      div [ ]
      [ Tabs.render MDL [0] model.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab SelectTab
        , Tabs.activeTab model.selectedGroupId
        --, Color.background (Color.color Color.Pink Color.S500)
        --, css "padding-top" "30%"
        ]
        tabs
        [ Options.div 
          []
          []
        ]
      ]


  in
    div [ ] 
    [ tabbedQuestionsContent
    , questionGroupHeading
    , questionsContent
    ]
    -- questionsContent
    -- |> Material.Scheme.topWithScheme Color.Indigo Color.Pink
