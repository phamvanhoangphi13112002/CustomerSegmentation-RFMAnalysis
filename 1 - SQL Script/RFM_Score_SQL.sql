SELECT * FROM sales;
SELECT * FROM customer;
SELECT * FROM [segment scores];
-- -- -- -- -- -- -- RFM Calculate -- -- -- -- -- -- -- 
WITH RFM_Base 
AS
(
  SELECT s.Customer_ID as CustomerID,
		c.Customer_Name AS CustomerName,
		DATEDIFF(DAY, MAX(s.Order_Date), CONVERT(DATE, GETDATE())) AS Recency_Value,
		COUNT(DISTINCT s.Order_ID) AS Frequency_Value,
		ROUND(SUM(s.Sales), 2) AS Monetary_Value
  FROM sales AS s
  INNER JOIN customer AS c ON s.Customer_ID = c.Customer_ID
  GROUP BY s.Customer_ID,c.Customer_Name
)
-- SELECT * FROM RFM_Base
, RFM_Score 
AS
(
  SELECT *,
    NTILE(5) OVER (ORDER BY Recency_Value DESC) as R_Score,
    NTILE(5) OVER (ORDER BY Frequency_Value ASC) as F_Score,
    NTILE(5) OVER (ORDER BY Monetary_Value ASC) as M_Score
  FROM RFM_Base
)
-- SELECT * FROM RFM_Score
, RFM_Final
AS
(
SELECT *,
  CONCAT(R_Score, F_Score, M_Score) as RFM_Overall
  -- , (R_Score + F_Score + M_Score) as RFM_Overall1
  -- , CAST(R_Score AS char(1))+CAST(F_Score AS char(1))+CAST(M_Score AS char(1)) as RFM_Overall2
FROM RFM_Score
)
-- SELECT * FROM RFM_Final
SELECT f.*, sg.Segment
FROM RFM_Final f
JOIN [segment scores] sg ON f.RFM_Overall = sg.Scores
; 
-- -- -- -- -- -- -- Done -- -- -- -- -- -- -- 