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
title = "Analyzing Issues"


instructions : String
instructions = 
  """
Answer the questions on the left and your formatted answers will appear below.
  """

completionMessage : String
completionMessage =
  """
You've completed all the questions.
  """

questions : List Question
questions =
  [ 
    { question = 
        """
What is the issue?
        """
    , paragraphId = 0
    , rows = 1
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Why do people care about this issue?
        """
    , paragraphId = 1
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What do the sources you consulted say about this issue?
        """
    , paragraphId = 2
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How are groups and individuals affected? Who benefits most if the issue is resolved? Who benefits the least? 
        """
    , paragraphId = 3
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Of all the groups and individuals affected, who has the most power? The least?
        """
    , paragraphId = 4
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What bias/perspective does each group or individual have? 
        """
    , paragraphId = 5
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What solutions will benefit which groups?
        """
    , paragraphId = 6
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
If different groups propose different solutions, how do they support them?
        """
    , paragraphId = 7
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Where do these solutions come together?
        """
    , paragraphId = 8
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Where do these solutions come into conflict? 
        """
    , paragraphId = 9
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What do you recommend as the "best" solution or solutions?
        """
    , paragraphId = 10
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What are the strengths and weaknesses of your recommended solutions?
        """
    , paragraphId = 11
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How could your solutions be implemented? What process would you recommend?
        """
    , paragraphId = 12
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What would your next steps be?
        """
    , paragraphId = 13
    , rows = 5
    , maxlength = 0
    , format = Format.Normal
    }
  ]