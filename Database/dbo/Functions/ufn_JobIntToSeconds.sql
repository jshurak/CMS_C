CREATE FUNCTION [dbo].[ufn_JobIntToSeconds]
(
      @run_duration INT
/*=========================================================================
Created By: Brian K. McDonald, MCDBA, MCSD (www.SQLBIGeek.com)
Email:      bmcdonald@SQLBIGeek.com
Twitter:    @briankmcdonald
Date:       10/29/2010
Purpose:    Convert the duration of a job to seconds
            A value of 13210 would be 1 hour, 32 minutes and 10 seconds,
            but I want to return this value in seconds. Which is 5530!
            Then I can sum all of the values and to find total duration.
 
Usage:      SELECT dbo.ufn_JobIntToSeconds (13210)
----------------------------------------------------------------------------
Modification History
----------------------------------------------------------------------------
 
==========================================================================*/
)
RETURNS INT
AS
BEGIN
 
RETURN
CASE
            --hours, minutes and seconds
            WHEN LEN(@run_duration) > 4 THEN CONVERT(VARCHAR(4),LEFT(@run_duration,LEN(@run_duration)-4)) * 3600
             + LEFT(RIGHT(@run_duration,4),2) * 60 + RIGHT(@run_duration,2)
            --minutes and seconds
            WHEN LEN(@run_duration) = 4 THEN LEFT(@run_duration,2) * 60 + RIGHT(@run_duration,2)
            WHEN LEN(@run_duration) = 3 THEN LEFT(@run_duration,1) * 60 + RIGHT(@run_duration,2)
      ELSE --only seconds    
            RIGHT(@run_duration,2) 
      END
END
