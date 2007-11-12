WITH Spiders;
WITH Ada.Text_IO;
WITH Ada.Numerics.Discrete_Random;
PROCEDURE Three_Drunken_Spiders IS
------------------------------------------------------------------
--| Multiple drunken spiders try to tour their room.
--| The spiders are represented as task objects.
--| Author: Michael B. Feldman, The George Washington University
--| Last Modified: December 1995
------------------------------------------------------------------

  SUBTYPE RandomSteps IS Positive RANGE 1..20;

  PACKAGE Random_20 IS NEW Ada.Numerics.Discrete_Random
    (Result_Subtype => RandomSteps);

  G: Random_20.Generator;  

  PACKAGE RandomHeading IS NEW Ada.Numerics.Discrete_Random
    (Result_Subtype => Spiders.Directions);

  D: RandomHeading.Generator;  

  -- Now a spider is a task object, as defined by this type.
  -- Note: default color is black.
  TASK TYPE Drunken_Spider_Task 
    (MyColor: Spiders.ScreenColors := Spiders.Black) IS

    -- one "start button" entry to bring spider to life
    ENTRY Hatch;

  END Drunken_Spider_Task;

  TASK BODY Drunken_Spider_Task IS

    Me: Spiders.Spider;

  BEGIN -- Drunken_Spider_Task

    ACCEPT Hatch;    -- come to life here

    -- Randomize all starting parameters
    Spiders.Start (Which => Me, 
                   Row => Random_20.Random(Gen => G), 
                   Col => Random_20.Random(Gen => G), 
                   WhichColor => MyColor, 
                   WhichWay => RandomHeading.Random(Gen => D));

    LOOP                     

      -- Spider will count steps correctly but might change direction
      FOR Count IN 1..Random_20.Random (Gen => G) LOOP

        BEGIN   -- to handle exception 
          Spiders.Step(Me);
        EXCEPTION
          WHEN Spiders.Hit_the_Wall =>  -- turn around 
            Spiders.Right (Me);
            Spiders.Right (Me);
          WHEN Spiders.Hit_a_Spider =>  -- turn right
            Spiders.Right (Me);
        END;

      END LOOP;

      Spiders.Right (Me);

    END LOOP;

  EXCEPTION

    WHEN OTHERS =>
      Ada.Text_IO.Put(Item => "This spider is dying.");
      Ada.Text_IO.New_Line;

  END Drunken_Spider_Task;

  -- Now declare some spider objects
  Charlotte : Drunken_Spider_Task(MyColor => Spiders.Green);
  Murgatroyd: Drunken_Spider_Task(MyColor => Spiders.Red);
  Arachne   : Drunken_Spider_Task(MyColor => Spiders.Blue); 

BEGIN -- Three_Drunken_Spiders

  Spiders.DrawRoom;

  -- Bring the spiders to life, then stand back and watch!
  Charlotte.Hatch;
  Murgatroyd.Hatch;
  Arachne.Hatch; 

END Three_Drunken_Spiders;
