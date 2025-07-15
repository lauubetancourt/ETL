-- 1. En qué meses del año los clientes solicitan más servicios de mensajería
-- SELECT
--     TO_CHAR(fecha_solicitud, 'Month') AS nombre_mes,
--     COUNT(*) AS total_registros
-- FROM
--     mensajeria_servicio
-- GROUP BY
--     nombre_mes,
--     EXTRACT(MONTH FROM fecha_solicitud) -- Se incluye para asegurar un orden correcto
-- ORDER BY
-- 	total_registros DESC



-- 2. Cuáles son los días donde más solicitudes hay
-- SELECT
--     EXTRACT(DOW FROM fecha_solicitud) AS numero_dia_semana, -- 0 = Domingo, 1 = Lunes, ..., 6 = Sábado
--     TO_CHAR(fecha_solicitud, 'Day') AS nombre_dia_semana,
--     COUNT(*) AS total_registros
-- FROM
--     mensajeria_servicio
-- GROUP BY
--     numero_dia_semana,
--     nombre_dia_semana
-- ORDER BY
--     total_registros DESC



-- 3. A qué hora los mensajeros están más ocupados
-- WITH eventos_con_timestamp AS (
--     SELECT
--         es.servicio_id,
--         e.nombre AS estado,
--         (es.fecha + es.hora) AS timestamp
--     FROM mensajeria_estadosservicio es
--     JOIN mensajeria_estado e ON es.estado_id = e.id
-- ),

-- pivot_servicio AS (
--     SELECT
--         servicio_id,
--         MIN(CASE WHEN estado = 'Iniciado'            THEN timestamp END) AS ts_iniciado,
--         MIN(CASE WHEN estado = 'Con mensajero Asignado' THEN timestamp END) AS ts_asignado,
--         MIN(CASE WHEN estado = 'Recogido por mensajero' THEN timestamp END) AS ts_recogido,
--         MIN(CASE WHEN estado = 'Entregado en destino' THEN timestamp END) AS ts_entregado,
--         MIN(CASE WHEN estado = 'Terminado completo'  THEN timestamp END) AS ts_cerrado
--     FROM eventos_con_timestamp
--     GROUP BY servicio_id
-- ),

-- -- Nueva CTE para unir las horas de todos los timestamps de interés
-- horas_de_todos_los_estados AS (
--     SELECT EXTRACT(HOUR FROM ts_asignado) AS hora_del_dia FROM pivot_servicio WHERE ts_asignado IS NOT NULL
--     UNION ALL
--     SELECT EXTRACT(HOUR FROM ts_recogido) AS hora_del_dia FROM pivot_servicio WHERE ts_recogido IS NOT NULL
--     UNION ALL
--     SELECT EXTRACT(HOUR FROM ts_entregado) AS hora_del_dia FROM pivot_servicio WHERE ts_entregado IS NOT NULL
-- )

-- SELECT
--     hora_del_dia,
--     COUNT(*) AS total_registros
-- FROM
--     horas_de_todos_los_estados
-- WHERE
--     hora_del_dia IS NOT NULL -- Aunque ya se filtró en UNION ALL, es una buena práctica
-- GROUP BY
--     hora_del_dia
-- ORDER BY
-- 	total_registros DESC,
--     hora_del_dia ASC



-- 4. Número de servicios solicitados por cliente y por mes
-- SELECT
--     cliente_id,
--     EXTRACT(MONTH FROM fecha_solicitud) AS numero_mes,
--     TO_CHAR(fecha_solicitud, 'Month') AS nombre_mes,
--     COUNT(*) AS total_servicios_mes
-- FROM
--     mensajeria_servicio m
-- GROUP BY
--     cliente_id,
--     numero_mes,
--     nombre_mes -- Incluir nombre_mes aquí asegura que no haya errores de agregación,
-- ORDER BY
--     cliente_id ASC,
--     numero_mes ASC



-- 5. Mensajeros más eficientes (Los que más servicios prestan)
-- SELECT
--     mensajero_id,
--     COUNT(*) AS total_servicios
-- FROM
--     mensajeria_servicio
-- GROUP BY
--     mensajero_id
-- ORDER BY
--     total_servicios DESC, mensajero_id ASC



-- 6. Promedio de duración por Fase
-- WITH eventos_con_timestamp AS (
--     SELECT
--         es.servicio_id,
--         e.nombre AS estado,
--         -- Combinamos fecha + hora
--         (es.fecha + es.hora) AS timestamp
--     FROM mensajeria_estadosservicio es
--     JOIN mensajeria_estado e ON es.estado_id = e.id
-- ),

-- pivot_servicio AS (
--     SELECT
--         servicio_id,
--         MIN(CASE WHEN estado = 'Iniciado'   THEN timestamp END) AS ts_iniciado,
--         MIN(CASE WHEN estado = 'Con mensajero Asignado'   THEN timestamp END) AS ts_asignado,
--         MIN(CASE WHEN estado = 'Recogido por mensajero'   THEN timestamp END) AS ts_recogido,
--         MIN(CASE WHEN estado = 'Entregado en destino'  THEN timestamp END) AS ts_entregado,
--         MIN(CASE WHEN estado = 'Terminado completo'    THEN timestamp END) AS ts_cerrado
--     FROM eventos_con_timestamp
--     GROUP BY servicio_id
-- ),

-- duraciones_por_servicio AS (
--     SELECT
--         servicio_id,
--         EXTRACT(EPOCH FROM ts_asignado   - ts_iniciado)   / 60 AS min_iniciado_asignado ,
--         EXTRACT(EPOCH FROM ts_recogido   - ts_asignado)   / 60 AS min_asignado_recogido,
--         EXTRACT(EPOCH FROM ts_entregado  - ts_recogido)   / 60 AS min_recogido_entregado,
--         EXTRACT(EPOCH FROM ts_cerrado    - ts_entregado)  / 60 AS min_entregado_cerrado
--     FROM pivot_servicio
-- )

-- SELECT
--     AVG(min_iniciado_asignado)   AS promedio_iniciado_asignado,
--     AVG(min_asignado_recogido)   AS promedio_asignado_recogido,
--     AVG(min_recogido_entregado)  AS promedio_recogido_entregado,
--     AVG(min_entregado_cerrado)   AS promedio_entregado_cerrado
-- FROM duraciones_por_servicio
-- WHERE
--     min_iniciado_asignado   IS NOT NULL AND min_iniciado_asignado   > 0 AND
-- 	min_asignado_recogido   IS NOT NULL AND min_asignado_recogido   > 0 AND
--     min_recogido_entregado  IS NOT NULL AND min_recogido_entregado  > 0 AND
--     min_entregado_cerrado   IS NOT NULL AND min_entregado_cerrado   > 0