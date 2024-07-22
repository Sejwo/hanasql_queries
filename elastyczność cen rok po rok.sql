SELECT
  S0."Year",
  S2."ItmsGrpNam",
  S0."ItemCode",
  S0."TotalQuantity",
  S0."AveragePrice",
  S0."PrevQuantity",
  S0."PrevPrice",
  S0."QuantityChange",
  S0."PriceChange",
  CASE 
    WHEN NULLIF(S0."PriceChange", 0) IS NULL THEN NULL
    ELSE S0."QuantityChange" / S0."PriceChange"
  END AS "Elasticity",
  CASE
    WHEN NULLIF(S0."PriceChange", 0) IS NULL THEN 'Błąd dzielenie przez 0' 
    WHEN ABS(S0."QuantityChange" / S0."PriceChange") > 1 THEN 'Elastyczna'
    WHEN ABS(S0."QuantityChange" / S0."PriceChange") = 1 THEN 'Jednostkowo elastyczny'
    WHEN ABS(S0."QuantityChange" / S0."PriceChange") < 1 THEN 'Nieleastyczna'
    ELSE 'Brak - Pusta któraś ze zmiennych'
  END AS "ElasticityType"
FROM
  (SELECT
     YEAR(T0."DocDate") AS "Year",
     T1."ItemCode",
     SUM(T1."Quantity") AS "TotalQuantity",
	 
     AVG(CASE 
			 WHEN T1."Currency" LIKE '%PLN%' THEN T1."Price"
			 ELSE T1."Price"*T1."Rate"
			 END
			 ) AS "AveragePrice",
	 
     LAG(SUM(T1."Quantity"), 1) OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T0."DocDate")) AS "PrevQuantity",
     LAG(AVG(T1."Price"), 1) OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T0."DocDate")) AS "PrevPrice",
     (SUM(T1."Quantity") - LAG(SUM(T1."Quantity"), 1) OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T0."DocDate"))) / NULLIF(LAG(SUM(T1."Quantity"), 1) OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T0."DocDate")), 0) AS "QuantityChange",
     (AVG(CASE 
			  WHEN T1."Currency" LIKE '%PLN%' THEN T1."Price"
			  ELSE T1."Price"*T1."Rate"
			  END) 
	          - LAG(AVG(CASE 
								WHEN T1."Currency" LIKE '%PLN%' THEN T1."Price"
								ELSE T1."Price"*T1."Rate"
								END), 1) 
								OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T0."DocDate"))) / NULLIF(LAG(AVG(CASE 
			 WHEN T1."Currency" LIKE '%PLN%' THEN T1."Price"
			 ELSE T1."Price"*T1."Rate"
			 END), 1) OVER (PARTITION BY T1."ItemCode" ORDER BY YEAR(T0."DocDate")), 0) AS "PriceChange"
   FROM "ORDR" T0
   INNER JOIN "RDR1" T1 ON T0."DocEntry" = T1."DocEntry"
   WHERE T0."CANCELED" = 'N' AND T0."CardCode" NOT IN ('related companies') AND T1."Price" > 0.02
   GROUP BY YEAR(T0."DocDate"), T1."ItemCode") S0
INNER JOIN OITM S1 ON S1."ItemCode" = S0."ItemCode"
INNER JOIN OITB S2 ON S1."ItmsGrpCod" = S2."ItmsGrpCod"
WHERE S0."PrevQuantity" IS NOT NULL AND S0."PrevPrice" IS NOT NULL
ORDER BY S0."Year", S2."ItmsGrpNam";