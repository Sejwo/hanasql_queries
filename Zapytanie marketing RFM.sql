SELECT
    *
FROM
    (
        SELECT
            T0."CardName" AS "Nazwa klienta",
            T0."DocCur" AS "Waluta dokumentu",
            T0."DocTotal" AS "Dokument(WS)",
            T1."SlpName" AS "Handlowiec",
            ROW_NUMBER() OVER(
                PARTITION BY T0."CardName"
                ORDER BY
                    T0."DocDate" DESC
            ) AS ROW,
            --aktualnie miesiąc różnicy, może być dzień/rok/minuta nie ma znaczenia
            MONTHS_BETWEEN(T0."DocDate", CURRENT_DATE) AS "Recency",
            COUNT(T0."CardName") OVER(
                PARTITION BY T0."CardName"
                ORDER BY
                    T0."DocDate" ASC
            ) AS "Frequency",
            SUM(T0."DocTotal") OVER(
                PARTITION BY T0."CardName"
                ORDER BY
                    T0."DocDate" ASC
            ) AS "Monetary"
        FROM
            ORDR T0
            INNER JOIN OSLP T1 ON T0."SlpCode" = T1."SlpCode"
        WHERE
            T0."CANCELED" = 'N'
            AND T0."CardCode" NOT IN () --nazwy spółek powiązanych
            AND T0."DocTotal" > 0.01 --nie branie pod uwagę materiałów marketingowych/reklamacji
            AND T0."SlpCode" >=0 -- branie pod uwagę tylko sprzedawców aktywnych
        ORDER BY
            T0."DocDate" DESC
    ) S0
WHERE
    S0."ROW" = 1;
