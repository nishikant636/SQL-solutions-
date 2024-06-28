CREATE PROCEDURE AllocateSubjects()
BEGIN
  -- Declare variables
  DECLARE v_studentId INT;
  DECLARE v_subjectId VARCHAR(10);
  DECLARE v_preference INT;
  DECLARE v_remainingSeats INT;
  DECLARE v_studentGPA DECIMAL(4,2);
  DECLARE v_done INT DEFAULT 0;
  DECLARE v_donePref INT DEFAULT 0;

  -- Create a cursor to iterate through the students
  DECLARE studentCursor CURSOR FOR
    SELECT s.StudentId, s.GPA
    FROM StudentDetails s
    ORDER BY s.GPA DESC;

  -- Handler for cursor end
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

  -- Open the cursor
  OPEN studentCursor;

  -- Loop through each student
  studentLoop: LOOP
    -- Fetch the next student
    FETCH studentCursor INTO v_studentId, v_studentGPA;

    -- Check if there are any more students
    IF v_done THEN
      LEAVE studentLoop;
    END IF;

    -- Reset donePref for each student
    SET v_donePref = 0;

    -- Loop through the student's preferences
    preferenceLoop: LOOP
      -- Get the next preference
      SELECT sp.SubjectId, sp.Preference
      INTO v_subjectId, v_preference
      FROM StudentPreference sp
      WHERE sp.StudentId = v_studentId
      AND sp.Preference = (
        SELECT MIN(Preference)
        FROM StudentPreference
        WHERE StudentId = v_studentId
        AND SubjectId NOT IN (
          SELECT SubjectId
          FROM Allotments
          WHERE StudentId = v_studentId
        )
      );

      -- Check if there are any more preferences
      IF v_subjectId IS NULL THEN
        -- Student is unallotted
        INSERT INTO UnallotedStudents (StudentId)
        VALUES (v_studentId);
        LEAVE studentLoop;
      END IF;

      -- Check if the subject has remaining seats
      SELECT sd.RemainingSeats
      INTO v_remainingSeats
      FROM SubjectDetails sd
      WHERE sd.SubjectId = v_subjectId;

      -- If the subject has remaining seats, allocate the subject to the student
      IF v_remainingSeats > 0 THEN
        -- Allocate the subject to the student
        INSERT INTO Allotments (SubjectId, StudentId)
        VALUES (v_subjectId, v_studentId);

        -- Update the remaining seats for the subject
        UPDATE SubjectDetails
        SET RemainingSeats = RemainingSeats - 1
        WHERE SubjectId = v_subjectId;

        LEAVE preferenceLoop;
      ELSE
        SET v_donePref = 1;
      END IF;
    END LOOP preferenceLoop;
  END LOOP studentLoop;

  -- Close the cursor
  CLOSE studentCursor;
END 


