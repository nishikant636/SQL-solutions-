/* CREATE TABLE HZL_Table (
    Date DATE,
    BU VARCHAR(10),
    Value INT
);
 
 
 
 INSERT INTO HZL_Table (Date, BU, Value) VALUES
('2024-01-01', 'hzl', 3456),
('2024-02-01', 'hzl', NULL),
('2024-03-01', 'hzl', NULL),
('2024-04-01', 'hzl', NULL),
('2024-01-01', 'SC', 32456),
('2024-02-01', 'SC', NULL),
('2024-03-01', 'SC', NULL),
('2024-04-01', 'SC', NULL),
('2024-05-01', 'SC', 345),
('2024-06-01', 'SC', NULL);
 

select * from hzl_table;


*/

WITH RECURSIVE CTE AS (
    SELECT 
        Date,
        BU,
        Value
    FROM 
        HZL_Table
    WHERE 
        Date = (SELECT MIN(Date) FROM HZL_Table WHERE BU = HZL_Table.BU)
    
    UNION ALL
    
    SELECT 
        h.Date,
        h.BU,
        COALESCE(h.Value, c.Value) AS Value
    FROM 
        HZL_Table h
    INNER JOIN 
        CTE c ON h.BU = c.BU AND h.Date = DATE_ADD(c.Date, INTERVAL 1 MONTH)
)
SELECT 
    Date,
    BU,
    Value
FROM 
    CTE
ORDER BY 
    BU, Date;

