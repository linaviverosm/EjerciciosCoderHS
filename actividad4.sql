
USE Ventas_Tech_DB;
GO

-- ==========================================
-- PRE-ENTREGA MODULO 4 - DATA ANALYTICS
-- RETAILPRO: CONSULTAS SQL DE NEGOCIO
-- Estudiante: Lina Viveros
-- Curso: 91075 - Data Analytics
-- ==========================================


-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL

SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(id_venta) AS cantidad_pedidos,
    CAST(
        AVG(cantidad * precio_unitario)
        AS DECIMAL(10,2)
    ) AS ticket_promedio
FROM ventas
GROUP BY
    YEAR(fecha_venta),
    MONTH(fecha_venta)
ORDER BY
    anio, mes;


-- CONSULTA 2: TOP 5 PRODUCTOS POR FACTURACION

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


-- CONSULTA 3: CLIENTES RECURRENTES

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC;


-- CONSULTA 4: PRODUCTOS FRENTE AL PROMEDIO

WITH facturacion_productos AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)

SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado >= (
            SELECT AVG(total_facturado)
            FROM facturacion_productos
        )
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS evaluacion_promedio
FROM facturacion_productos
ORDER BY total_facturado DESC;


-- HALLAZGOS DEL ANALISIS

-- 1. Durante marzo de 2024, RetailPro registró
--    una facturación total de $6.444,00 en
--    10 pedidos, con un ticket promedio
--    de $644,40 por operación.

-- 2. El producto con ID 1 generó $3.600,00,
--    equivalente al 55,87 % de la facturación
--    total, a pesar de vender solo 3 unidades.

-- 3. Los cinco clientes realizaron 2 pedidos
--    cada uno. Sin embargo, el cliente 1
--    generó el mayor gasto acumulado ($2.640),
--    mientras que el cliente 4 registró
--    el menor ($510).