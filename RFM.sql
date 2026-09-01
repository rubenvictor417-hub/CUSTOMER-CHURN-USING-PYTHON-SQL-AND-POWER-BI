create database CHURN;
use CHURN;

SELECT * FROM [dbo].[churn_cleaned];



WITH CHURN_ANALYSIS AS (
    SELECT
        CustomerID,
        DATEDIFF(day, MAX(InvoiceDate), (SELECT MAX(InvoiceDate) FROM dbo.churn_cleaned)) AS raw_recency,
        COUNT(DISTINCT InvoiceNo) AS raw_frequency,
        SUM(Quantity * UnitPrice) AS raw_monetary
    FROM dbo.churn_cleaned
    GROUP BY CustomerID),

rfm_scores AS (
    SELECT
        CustomerID,
        raw_recency,
        raw_frequency,
        raw_monetary,
        NTILE(5) OVER (ORDER BY raw_recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY raw_frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY raw_monetary ASC) AS m_score
    FROM CHURN_ANALYSIS
)
SELECT
    CustomerID,
    raw_recency,
    raw_frequency,
    raw_monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score ,f_score ,m_score) AS rfm
FROM rfm_scores
order by rfm desc;


