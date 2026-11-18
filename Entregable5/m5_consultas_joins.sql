/*
PRE-ENTREGA 5 - CONSULTAS CON JOINS PARA EL PROYECTO
Estudiante: Lina Viveros
Curso: 91075 - Data Analytics
Motor: SQL Server
*/

USE Ventas_tech_baseDeDatos;
GO


-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)

SELECT
    v.id_ventas,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_ventas;

-- Hallazgo: La vista mostro 10 ventas de marzo de 2024. La operacion
-- de mayor valor fue la compra de Maria Lopez: 2 Laptop Pro 15 por $2.400.



-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    c.fecha_de_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_ventas IS NULL
ORDER BY c.id_cliente;

-- Hallazgo: La consulta devolvio 0 clientes sin compras; por lo tanto,
-- CRM no tiene clientes sin ventas asociados en los datos actuales.

-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)

SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM dbo.productos AS p
LEFT JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN dbo.ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_ventas IS NULL
ORDER BY p.id_producto;

-- Conteo de verificacion: devuelve el numero exacto de productos sin
-- ventas y una interpretacion para el area de Producto.
SELECT
    COUNT(*) AS productos_sin_ventas,
    CASE WHEN COUNT(*) = 0
         THEN 'Ningun articulo del catalogo esta sin ventas registradas; no hay productos inmoviles en el periodo observado.'
         ELSE 'Hay articulos del catalogo sin ventas; el area de Producto deberia revisar su visibilidad, demanda y comercializacion.'
    END AS implicacion_negocio
FROM dbo.productos AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ventas AS v
    WHERE v.id_producto = p.id_producto
);

-- Hallazgo: En las ventas observadas hubo movimientos para 6 IDs de
-- producto diferentes (1 a 6). La consulta anterior cuenta cuantos
-- productos adicionales del catalogo no registran ventas y permite
-- que el area de Producto los identifique para una revision.
-- El numero exacto de productos sin ventas debe tomarse del resultado
-- 'productos_sin_ventas'; no se supone un valor sin ejecutarlo.


-- CONSULTA 4: CONSOLIDADO DE DOS PERIODOS (UNION ALL)

SELECT
    consolidado.canal,
    SUM(consolidado.total) AS total_canal
FROM (
    SELECT
        v.id_ventas,
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total,
        'Dias 1 a 10' AS canal
    FROM dbo.ventas AS v
    WHERE DAY(v.fecha_venta) BETWEEN 1 AND 10

    UNION ALL

    SELECT
        v.id_ventas,
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total,
        'Dias 11 al fin de mes' AS canal
    FROM dbo.ventas AS v
    WHERE DAY(v.fecha_venta) >= 11
) AS consolidado
GROUP BY consolidado.canal
ORDER BY total_canal DESC;

-- Hallazgo: En marzo de 2024, las ventas de los dias 1 al 10
-- sumaron $3.620, frente a $2.824 de los dias 11 al 31.
-- El primer grupo facturo $796 mas. Son periodos, no canales reales.
