SELECT *
FROM [Berekeley_1617].[dbo].B_Report1_1617_withoutTIN
ORDER BY [Data of original registration] DESC

SELECT DISTINCT MTin
FROM [Berekeley_1314].[dbo].B_Report1_1314_withoutTIN

INSERT INTO 
Berkeley_1213.dbo.B_Report1_1213_withoutTIN
SELECT * FROM Berekeley_1314.dbo.B_Report1_1314_withoutTIN

