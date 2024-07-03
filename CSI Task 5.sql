-- Drop the stored procedure if it exists
IF OBJECT_ID('UpdateSubjectAllotments', 'P') IS NOT NULL
    DROP PROCEDURE UpdateSubjectAllotments;
GO

-- Create the SubjectAllotments table if it does not exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SubjectAllotments' AND xtype='U')
BEGIN
    CREATE TABLE SubjectAllotments (
        StudentID varchar(50),
        SubjectID varchar(50),
        Is_Valid bit,
        PRIMARY KEY (StudentID, SubjectID)
    );
END;
GO

-- Create the SubjectRequest table if it does not exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SubjectRequest' AND xtype='U')
BEGIN
    CREATE TABLE SubjectRequest (
        StudentID varchar(50),
        SubjectID varchar(50)
    );
END;
GO

-- Insert sample data into SubjectAllotments table
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
SELECT '159103036', 'PO1491', 1 WHERE NOT EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = '159103036' AND SubjectID = 'PO1491');
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
SELECT '159103036', 'PO1492', 0 WHERE NOT EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = '159103036' AND SubjectID = 'PO1492');
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
SELECT '159103036', 'PO1493', 0 WHERE NOT EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = '159103036' AND SubjectID = 'PO1493');
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
SELECT '159103036', 'PO1494', 0 WHERE NOT EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = '159103036' AND SubjectID = 'PO1494');
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
SELECT '159103036', 'PO1495', 0 WHERE NOT EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = '159103036' AND SubjectID = 'PO1495');
GO

-- Insert sample data into SubjectRequest table
INSERT INTO SubjectRequest (StudentID, SubjectID)
SELECT '159103036', 'PO1496' WHERE NOT EXISTS (SELECT 1 FROM SubjectRequest WHERE StudentID = '159103036' AND SubjectID = 'PO1496');
GO

-- Create the stored procedure
CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Declare variables to hold student and subject IDs
    DECLARE @StudentID varchar(50)
    DECLARE @RequestedSubjectID varchar(50)
    DECLARE @CurrentSubjectID varchar(50)

    -- Declare cursor to iterate over SubjectRequest table
    DECLARE subject_request_cursor CURSOR FOR
    SELECT StudentID, SubjectID
    FROM SubjectRequest

    OPEN subject_request_cursor

    FETCH NEXT FROM subject_request_cursor INTO @StudentID, @RequestedSubjectID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student exists in the SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID)
        BEGIN
            -- Get the current valid subject for the student
            SELECT @CurrentSubjectID = SubjectID 
            FROM SubjectAllotments 
            WHERE StudentID = @StudentID AND Is_Valid = 1

            -- If the current subject is different from the requested subject, update the records
            IF @CurrentSubjectID != @RequestedSubjectID
            BEGIN
                -- Update the current valid subject to invalid
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentID = @StudentID AND Is_Valid = 1

                -- Insert the new subject with Is_Valid = 1
                INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
                VALUES (@StudentID, @RequestedSubjectID, 1)
            END
        END
        ELSE
        BEGIN
            -- If the student does not exist in the SubjectAllotments table, insert the new subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @RequestedSubjectID, 1)
        END

        FETCH NEXT FROM subject_request_cursor INTO @StudentID, @RequestedSubjectID
    END

    CLOSE subject_request_cursor
    DEALLOCATE subject_request_cursor

    -- Clean up the SubjectRequest table after processing
    DELETE FROM SubjectRequest
END;
GO

-- Execute the stored procedure
EXEC UpdateSubjectAllotments;

-- Verify the changes in the SubjectAllotments table
SELECT * FROM SubjectAllotments;
GO
