module Data exposing (..) --where

import Format exposing (..)

{-
My only suggested change at this time is to change question #4 to:
“What is the title of the work you have excerpted and who is its author?”
-}

type alias Question = 
  { question : String
  , paragraphId : Int
  , rows : Int
  , maxlength : Int
  , format : Format.FormatStyle
  }


title : String
title = "Opinion Paragraph"


instructions : String
instructions = 
  """
Answer the questions on the left to build your paragraph.
  """

completionMessage : String
completionMessage =
  """
Now that you’ve written your draft, review and revise your paragraph using the following questions and steps. (You can make changes to your paragraph by updating your answers above.):  

1. Read the paragraph out loud. This can help you pick up on anything that sounds repetitive, awkward, or choppy.

2. Ask yourself the following questions about the content and flow:
  * What should I add?
  * What should I take out? 
  * What should I move?
  * Is the paragraph clear and easy to follow?
  * Are there transitions between ideas? (e.g., Have I used words such as "Firstly," "Secondly," "Thirdly," "Finally," "Thus," "Therefore," and so on?)  

3. Ask yourself the following questions about the style and format:
  - Is the first line of the paragraph indented?
  - Is the paragraph complete (correctly structured)? 
  - Are all of the sentences complete?
  - Does each sentence begin with a capital letter?    
  - Does each sentence end with a punctuation mark?
  - Is each sentence free of spelling and grammatical errors?
  """

questions : List Question
questions =
  [ 
    { question = 
        """
What is the title of your paragraph?
        """
    , paragraphId = 0
    , rows = 1
    , maxlength = 500
    , format = Format.Title
    }
  ,
    { question = 
        """
Topic sentence:
        """
    , paragraphId = 0
    , rows = 3
    , maxlength = 500
    , format = Format.Normal
    }
  ,
    { question = 
        """
First supporting point with facts, examples, and/or evidence:
        """
    , paragraphId = 0
    , rows = 3
    , maxlength = 500
    , format = Format.Normal
    }
  ,
    { question = 
        """
Second supporting point with facts, examples, and/or evidence:
        """
    , paragraphId = 0
    , rows = 3
    , maxlength = 500
    , format = Format.Normal
    }
  ,
    { question = 
        """
Third supporting point with facts, examples, and/or evidence:
        """
    , paragraphId = 0
    , rows = 3
    , maxlength = 500
    , format = Format.Normal
    }
  ]