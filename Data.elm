module Data exposing (..) --where

import Format exposing (..)

{-
My only suggested change at this time is to change question #4 to:
“What is the title of the work you have excerpted and who is its author?”
-}

type alias Question = 
  { question : String
  , paragraphId : Int
  , groupId : Int
  , rows : Int
  , maxlength : Int
  , format : Format.FormatStyle
  }


title : String
title = "Resilience in Land Claim Struggles"


instructions : String
instructions = 
  """
Answer the questions on the left to build your essay.
  """

completionMessage : String
completionMessage =
  """
Your essay is complete. Make any revisions by updating your answers to the questions above. 
  """

type alias QuestionGroup = 
  { title : String
  , description : String
  , navigationHeading : String
  , groupId : Int
  }

questionGroups : List QuestionGroup
questionGroups =
  [
    { title = "Paragraph 1: Introduction"
    , description = ""
    , navigationHeading = "One"
    , groupId = 0
    }
  ,
    { title = "Paragraph 2: How the Inuit showed resilience in the Nunavut land claim"
    , description = ""
    , navigationHeading = "Two"
    , groupId = 1
    }
  ,
    { title = "Paragraph 3: How the Tsilhqot’in showed resilience in their land claim in British Columbia"
    , description = ""
    , navigationHeading = "Three"
    , groupId = 2
    }
  ,
    { title = "Paragraph 4: How the Métis showed resilience in their land claim in Manitoba"
    , description = ""
    , navigationHeading = "Four"
    , groupId = 3
    }
  ,
    { title = "Paragraph 5: Conclusion"
    , description = ""
    , navigationHeading = "Five"
    , groupId = 4
    }
  ]

questions : List Question
questions =
  [ 
    -- Paragraph 1

    { question = 
        """
What is the general topic of your essay?  
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Why are land claims an important or interesting topic?
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What specific land claims will you discuss in this essay?
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is resilience? Why is resilience important for Indigenous peoples? 
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is your thesis statement?
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 2

    { question = 
        """
What is your argument (what statement are you going to prove in this paragraph)?  
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the first point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this first point?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point? 
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the second point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this second point? 
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the third point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this third point? 
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How can you summarize all the elements of the argument that you just presented?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 3

    { question = 
        """
What is your argument (what statement are you going to prove in this paragraph)?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the first point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this first point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the second point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this second point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the third point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this third point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How can you summarize all the elements of the argument that you just presented?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 4

    { question = 
        """
What is your argument (what statement are you going to prove in this paragraph)?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the first point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this first point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the second point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this second point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the third point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this third point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How can you summarize all the elements of the argument that you just presented?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 4

    { question = 
        """
What is the overall argument of your essay?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Can you provide a summary of the main points you presented in the essay?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What have you learned about the resilience of Indigenous peoples?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
In what ways does the topic of this essay relate to the broader issues that Indigenous peoples face in Canada?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ]