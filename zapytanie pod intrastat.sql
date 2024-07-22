WITH cte0 AS (
    SELECT
        T0."DocNum" AS "Numer dokumentu",
        T0."DocDate" AS "Data księgowania",
        T0."CardName" AS "Nazwa odbiorcy/dostawcy",
        T0."LicTradNum" AS "NIP klienta",
        T4."Country" AS "Kod Kraju",
        T1."ItemCode" AS "Indeks",
        T1."ItemType" AS "Rodzaj towaru",
        T1."Dscription" AS "Opis towaru/usługi",
        T1."Quantity" AS "Ilość",
        T1."unitMsr" AS "Jednostka",
        T1."Price" AS "Cena po upuście",
        T1."Currency" AS "Waluta ceny",
        T1."StockPrice" AS "Cena zakupu",
        T1."TotalFrgn" AS "Pozycja razem (WO)",
        T1."TotalSumSy" AS "Pozycja razem (WS)",
        T1."GrssProfit" AS "Zysk brutto pozycji",
        T2."InvntItem" AS "Magazynowe",
        T6."Code" AS "Kod Intrastat",
        T6."Descr" AS "Grupa Intrastat"
    FROM
        OINV T0
        INNER JOIN INV1 T1 ON T1."DocEntry" = T0."DocEntry"
        LEFT JOIN OITM T2 ON T2."ItemCode" = T1."ItemCode"
        INNER JOIN OCRD T3 ON T3."CardCode" = T0."CardCode"
        LEFT JOIN CRD1 T4 ON T4."CardCode" = T3."CardCode"
        LEFT JOIN ITM10 T5 ON T2."ItemCode" = T5."ItemCode"
        INNER JOIN ODCI T6 ON T5."ISCommCode" = T6."AbsEntry"
        AND T4."LineNum" = 0
        AND T4."Country" IN (
            'AT',
            'BE',
            'BG',
            'HR',
            'CY',
            'CZ',
            'DK',
            'EE',
            'FI',
            'FR',
            'GR',
            'ES',
            'IE',
            'LT',
            'LU',
            'LV',
            'MT',
            'NL',
            'DE',
            'PL',
            'PT',
            'RO',
            'SK',
            'SI',
            'SE',
            'HU',
            'IT'
        )
    WHERE
        T0."CANCELED" = 'N'
cte1 AS(
    SELECT * FROM cte0 U0
)
SELECT
    *
FROM
    cte1 W0;