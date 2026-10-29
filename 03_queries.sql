
-- ============================================================
-- ARCHIVO: 03_queries.sql
-- PROYECTO: BUÑUELON POS
-- EMPRESA: Don Buñuelón Comelón
-- OBJETIVO: Consultas para comprobar datos y relaciones
-- ============================================================

USE `don buñuelon`;

-- ============================================================
-- #1. ¿Cuáles son los productos con mayor precio?
-- ============================================================

SELECT ID_Producto, Nombre, Precio_Venta
FROM producto
ORDER BY Precio_Venta DESC
LIMIT 10;

-- Esperado: Los 10 productos con mayor precio.


-- ============================================================
-- #2. ¿Qué productos tienen poco inventario?
-- ============================================================

SELECT ID_Producto, Nombre, Stock_Actual
FROM producto
WHERE Stock_Actual <= 10
ORDER BY Stock_Actual ASC;

-- Esperado: Productos cuyo stock es igual o inferior a 10.


-- ============================================================
-- #3. ¿Qué productos pertenecen a cada categoría?
-- JOIN de 2 tablas
-- ============================================================

SELECT
    p.ID_Producto,
    p.Nombre AS Producto,
    c.Descripcion AS Categoria,
    p.Precio_Venta
FROM producto p
INNER JOIN categoria c
    ON p.FK_Categoria = c.ID_Categoria
ORDER BY c.Descripcion, p.Nombre;

-- Esperado: Productos acompañados de su categoría.


-- ============================================================
-- #4. ¿Qué productos no tienen proveedor asociado?
-- LEFT JOIN
-- ============================================================

SELECT
    p.ID_Producto,
    p.Nombre
FROM producto p
LEFT JOIN proveedor pr
    ON pr.FK_Producto = p.ID_Producto
WHERE pr.ID_Proveedor IS NULL;

-- Esperado: Productos que no aparecen relacionados
-- con ningún proveedor.


-- ============================================================
-- #5. ¿Qué proveedores suministran cada producto?
-- JOIN de 2 tablas
-- ============================================================

SELECT
    pr.ID_Proveedor,
    pr.Razon_Social AS Proveedor,
    pr.Telefono,
    p.Nombre AS Producto
FROM proveedor pr
INNER JOIN producto p
    ON pr.FK_Producto = p.ID_Producto
ORDER BY pr.Razon_Social;

-- Esperado: Proveedores con los productos asociados.


-- ============================================================
-- #6. ¿Cuáles son las ventas con su empleado y método de pago?
-- JOIN de 3 tablas
-- ============================================================

SELECT
    v.ID_Venta,
    v.Fecha_Hora,
    e.Nombre AS Empleado,
    mp.Tipo AS Metodo_Pago,
    v.Total
FROM venta v
INNER JOIN empleado e
    ON v.FK_Usuario = e.ID_Usuario
INNER JOIN metodo_pago mp
    ON v.FK_Pago = mp.ID_Pago
ORDER BY v.Fecha_Hora DESC;

-- Esperado: Cada venta con el empleado y método de pago.


-- ============================================================
-- #7. ¿Cuánto dinero se ha vendido en total?
-- Función de agregación
-- ============================================================

SELECT
    COUNT(*) AS Cantidad_Ventas,
    COALESCE(SUM(Total), 0) AS Total_Vendido,
    COALESCE(AVG(Total), 0) AS Promedio_Venta
FROM venta;

-- Esperado: Cantidad de ventas, suma total y promedio.


-- ============================================================
-- #8. ¿Cuánto se ha vendido por método de pago?
-- GROUP BY
-- ============================================================

SELECT
    mp.Tipo AS Metodo_Pago,
    COUNT(v.ID_Venta) AS Cantidad_Ventas,
    COALESCE(SUM(v.Total), 0) AS Total_Recaudado
FROM metodo_pago mp
LEFT JOIN venta v
    ON v.FK_Pago = mp.ID_Pago
GROUP BY mp.ID_Pago, mp.Tipo
ORDER BY Total_Recaudado DESC;

-- Esperado: Cantidad y valor de ventas para cada método.


-- ============================================================
-- #9. ¿Qué empleados han registrado más de una venta?
-- GROUP BY + HAVING
-- ============================================================

SELECT
    e.ID_Usuario,
    e.Nombre AS Empleado,
    COUNT(v.ID_Venta) AS Cantidad_Ventas
FROM empleado e
INNER JOIN venta v
    ON v.FK_Usuario = e.ID_Usuario
GROUP BY e.ID_Usuario, e.Nombre
HAVING COUNT(v.ID_Venta) > 1
ORDER BY Cantidad_Ventas DESC;

-- Esperado: Empleados con más de una venta registrada.


-- ============================================================
-- #10. ¿Qué clientes están asociados a cada usuario?
-- JOIN de 2 tablas
-- ============================================================

SELECT
    c.ID_Cliente,
    c.Nit_Cedula,
    c.Nombre_Razon AS Cliente,
    c.Direccion,
    e.Nombre AS Usuario_Asociado
FROM cliente c
INNER JOIN empleado e
    ON c.FK_Usuario = e.ID_Usuario
ORDER BY c.Nombre_Razon;

-- Esperado: Clientes con el usuario relacionado.


-- ============================================================
-- #11. ¿Cuáles son los roles y cuántos empleados tienen?
-- LEFT JOIN + GROUP BY
-- ============================================================

SELECT
    r.ID_Rol,
    r.Nombre_Rol,
    COUNT(e.ID_Usuario) AS Cantidad_Empleados
FROM roles r
LEFT JOIN empleado e
    ON e.FK_Rol = r.ID_Rol
GROUP BY r.ID_Rol, r.Nombre_Rol
ORDER BY Cantidad_Empleados DESC;

-- Esperado: Roles con la cantidad de empleados asociados.


-- ============================================================
-- #12. ¿Cuáles son los detalles de cada venta?
-- JOIN de 3 tablas
-- ============================================================

SELECT
    dv.ID_Detalle,
    v.ID_Venta,
    p.Nombre AS Producto,
    dv.Cantidad,
    dv.Subtotal,
    dv.IVA_Impuestos
FROM detalle_venta dv
INNER JOIN venta v
    ON dv.FK_Venta = v.ID_Venta
INNER JOIN producto p
    ON dv.FK_Producto = p.ID_Producto
ORDER BY v.ID_Venta, dv.ID_Detalle;

-- Esperado: Productos, cantidades e importes de cada venta.


-- ============================================================
-- #13. ¿Qué ventas tienen un total superior al promedio?
-- Subconsulta
-- ============================================================

SELECT
    ID_Venta,
    Fecha_Hora,
    Total
FROM venta
WHERE Total > (
    SELECT AVG(Total)
    FROM venta
)
ORDER BY Total DESC;

-- Esperado: Ventas cuyo total supera el promedio general.


-- ============================================================
-- #14. ¿Cuánto inventario representa cada producto en dinero?
-- Cálculo con los campos existentes
-- ============================================================

SELECT
    ID_Producto,
    Nombre,
    Stock_Actual,
    Precio_Venta,
    Stock_Actual * Precio_Venta AS Valor_Inventario
FROM producto
ORDER BY Valor_Inventario DESC;

-- Esperado: Valor estimado del inventario por producto.


-- ============================================================
-- #15. ¿Cuáles son las cajas y sus clientes asociados?
-- LEFT JOIN
-- ============================================================

SELECT
    ca.ID_Caja,
    ca.Saldo_Inicial,
    ca.Saldo_Final,
    c.Nombre_Razon AS Cliente
FROM caja ca
LEFT JOIN cliente c
    ON ca.FK_Cliente = c.ID_Cliente
ORDER BY ca.ID_Caja;

-- Esperado: Cajas con su saldo y cliente relacionado,
-- cuando existe un cliente asociado.


-- ============================================================
-- #16. Vista para consultar las ventas con sus relaciones
-- ============================================================

CREATE OR REPLACE VIEW v_resumen_ventas AS
SELECT
    v.ID_Venta,
    v.Fecha_Hora,
    e.Nombre AS Empleado,
    mp.Tipo AS Metodo_Pago,
    v.Total
FROM venta v
INNER JOIN empleado e
    ON v.FK_Usuario = e.ID_Usuario
INNER JOIN metodo_pago mp
    ON v.FK_Pago = mp.ID_Pago;

-- Consultar la vista:
SELECT * FROM v_resumen_ventas
ORDER BY Fecha_Hora DESC;

-- Esperado: Resumen de las ventas con empleado y pago.


-- ============================================================
-- #17. Transacción de prueba: modificar una venta
-- Se deshace el cambio al ejecutar ROLLBACK.
-- ============================================================

START TRANSACTION;

UPDATE venta
SET Total = Total + 100
WHERE ID_Venta = -1;

-- Comprobar el resultado de la operación:
SELECT ID_Venta, Total
FROM venta
WHERE ID_Venta = -1;

ROLLBACK;

-- Esperado: No se modifica ninguna venta porque el
-- identificador -1 no corresponde a una venta real.


-- ============================================================
-- FIN DEL ARCHIVO 03_queries.sql
-- ============================================================
