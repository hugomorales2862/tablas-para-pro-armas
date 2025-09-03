

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol_id INT DEFAULT NULL,  -- ya no UNSIGNED
    remember_token VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE SET NULL
);
-- ========================
-- ENTIDADES FUERTES
-- ========================

CREATE TABLE pro_metodos_pago (
    metpago_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID método de pago',
    metpago_descripcion VARCHAR(50) NOT NULL COMMENT 'efectivo, transferencia, etc.',
    metpago_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo'
);

CREATE TABLE pro_paises (
    pais_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID de país',
    pais_descripcion VARCHAR(50) COMMENT 'Descripción del país',
    pais_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo'
);

CREATE TABLE pro_clases_pistolas (
    clase_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID de clase de arma',
    clase_descripcion VARCHAR(50) COMMENT 'pistola, carabina, etc.',
    clase_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo'
);

CREATE TABLE pro_marcas (
    marca_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID de marca',
    marca_descripcion VARCHAR(50) COMMENT 'system defense, glock, brigade',
    marca_situacion INT DEFAULT 1 COMMENT '1 = activa, 0 = inactiva'
);

CREATE TABLE pro_modelo (
    modelo_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID de modelo',
    modelo_descripcion VARCHAR(50) COMMENT 'c9, bm-f-9, sd15',
    modelo_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo'
);


CREATE TABLE pro_unidades_medida (
    unidad_id SERIAL PRIMARY KEY,
    unidad_nombre VARCHAR(50) NOT NULL,       -- Ej: 'milímetro', 'pulgada'
    unidad_abreviacion VARCHAR(10) NOT NULL,  -- Ej: 'mm', 'in'
    unidad_tipo VARCHAR(20) DEFAULT 'longitud',
    unidad_situacion INT DEFAULT 1            -- 1 = activo, 0 = inactivo
);

-- =========================================
-- 🟦 TABLA: Calibres
-- =========================================
CREATE TABLE pro_calibres (
    calibre_id SERIAL PRIMARY KEY,
    calibre_nombre VARCHAR(20) NOT NULL,         -- Ej: '9', '.45'
    calibre_unidad_id INT NOT NULL,
    calibre_equivalente_mm DECIMAL(6,2) NULL,
    calibre_situacion INT DEFAULT 1,

    FOREIGN KEY (calibre_unidad_id) REFERENCES pro_unidades_medida(unidad_id)
);

-- ========================
-- EMPRESAS E IMPORTACIONES
-- ========================

CREATE TABLE pro_empresas_de_importacion (
    empresaimp_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID empresa importadora',
    empresaimp_pais INT NOT NULL COMMENT 'ID del país asociado',
    empresaimp_descripcion VARCHAR(50) COMMENT 'tipo: empresa matriz o logística',
    empresaimp_situacion INT DEFAULT 1 COMMENT '1 = activa, 0 = inactiva',
    FOREIGN KEY (empresaimp_pais) REFERENCES pro_paises(pais_id)
);


CREATE TABLE pro_licencias_para_importacion (
    lipaimp_id SERIAL PRIMARY KEY,
    lipaimp_poliza INT,
    lipaimp_descripcion VARCHAR(100),
    lipaimp_empresa INT NOT NULL,
    lipaimp_fecha_vencimiento DATE,
    lipaimp_situacion INT DEFAULT 1,    ----- 1 pendiente  2 autorizado 3 rechazado

    FOREIGN KEY (lipaimp_empresa) REFERENCES pro_empresas_de_importacion(empresaimp_id)
);

-- =========================================
-- 🟦 TABLA: Armas Licenciadas (relacionadas a la licencia)
-- =========================================
CREATE TABLE pro_armas_licenciadas (
    arma_id SERIAL PRIMARY KEY,
    arma_licencia_id INT NOT NULL,
    arma_clase_id INT NOT NULL,
    arma_marca_id INT NOT NULL,
    arma_modelo_id INT NOT NULL,
    arma_calibre_id INT NOT NULL,
    arma_cantidad INT DEFAULT 1,
    arma_situacion INT DEFAULT 1,

    FOREIGN KEY (arma_licencia_id) REFERENCES pro_licencias_para_importacion(lipaimp_id),
    FOREIGN KEY (arma_clase_id) REFERENCES pro_clases_pistolas(clase_id),
    FOREIGN KEY (arma_marca_id) REFERENCES pro_marcas(marca_id),
    FOREIGN KEY (arma_modelo_id) REFERENCES pro_modelo(modelo_id),
    FOREIGN KEY (arma_calibre_id) REFERENCES pro_calibres(calibre_id)
);

CREATE TABLE pro_digecam (
    digecam_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID digecam',
    digecam_licencia_import INT NOT NULL COMMENT 'Licencia asociada',
    digecam_autorizacion VARCHAR(50) DEFAULT 'no aprobada' COMMENT 'Estado autorización',
    digecam_situacion INT DEFAULT 1 COMMENT '1 = activa, 0 = inactiva',
    CONSTRAINT chk_digecam_autorizacion CHECK (digecam_autorizacion IN ('aprobada','no aprobada')),
    FOREIGN KEY (digecam_licencia_import) REFERENCES pro_licencias_para_importacion(lipaimp_id)
);

-- ========================
-- INVENTARIO 
-- ========================

-- Catálogo de lotes/modelos
CREATE TABLE pro_inventario_modelos (
    modelo_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID del modelo/lote',
    modelo_licencia INT NOT NULL COMMENT 'Licencia de importación asociada',
    modelo_poliza INT NOT NULL COMMENT 'No. de póliza/factura de compra',
    modelo_fecha_ingreso DATE NOT NULL COMMENT 'Fecha de ingreso del lote',
    modelo_clase INT NOT NULL,
    modelo_marca INT NOT NULL,
    modelo_modelo INT NOT NULL,
    modelo_calibre VARCHAR(50),
    modelo_cantidad INT NOT NULL DEFAULT 0 COMMENT 'Cantidad total en este lote',
    modelo_disponible INT NOT NULL DEFAULT 0 COMMENT 'Stock disponible',
    modelo_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo',
    FOREIGN KEY (modelo_licencia) REFERENCES pro_licencias_para_importacion(lipaimp_id),
    FOREIGN KEY (modelo_clase) REFERENCES pro_clases_pistolas(clase_id),
    FOREIGN KEY (modelo_marca) REFERENCES pro_marcas(marca_id),
    FOREIGN KEY (modelo_modelo) REFERENCES pro_modelo(modelo_id)
);

-- Armas individuales con serie
CREATE TABLE pro_inventario_armas (
    arma_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID correlativo',
    arma_modelo_id INT NOT NULL COMMENT 'Referencia al lote o modelo',
    arma_numero_serie VARCHAR(200) UNIQUE COMMENT 'Número de serie de la pistola',
    arma_estado ENUM('disponible','vendida','reservada','baja') DEFAULT 'disponible',
    FOREIGN KEY (arma_modelo_id) REFERENCES pro_inventario_modelos(modelo_id)
);




------tabla para poger guardar un historial mas exacto  

CREATE TABLE pro_historial_inventario (
    histinv_historial_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID del registro de historial',
    histinv_tipo_movimiento ENUM('ingreso','venta','reserva','baja','ajuste') NOT NULL COMMENT 'Tipo de movimiento realizado',
    histinv_modelo_id INT DEFAULT NULL COMMENT 'Referencia al modelo/lote si aplica',
    histinv_arma_id INT DEFAULT NULL COMMENT 'Referencia al arma individual si aplica',
    histinv_cantidad INT DEFAULT 1 COMMENT 'Cantidad afectada por el movimiento',
    histinv_fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del movimiento',
    histinv_usuario_id INT NOT NULL COMMENT 'Usuario que realizó el movimiento',
    histinv_observaciones VARCHAR(255) COMMENT 'Notas adicionales sobre el movimiento',
    FOREIGN KEY (histinv_modelo_id) REFERENCES pro_inventario_modelos(modelo_id),
    FOREIGN KEY (histinv_arma_id) REFERENCES pro_inventario_armas(arma_id),
    FOREIGN KEY (histinv_usuario_id) REFERENCES users(id)
);


-- ========================
-- CLIENTES Y VENTAS
-- ========================

CREATE TABLE pro_clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_tipo ENUM('empresa','persona') NOT NULL,
    cliente_nombre_empresa VARCHAR(200) ,
    cliente_nombre VARCHAR(200)  NOT NULL COMMENT 'NOMBRE DEL DUENO DE LA EMPRESA O PERSONA INDIVIDUAL',
    cliente_razon_social VARCHAR(200), -- solo para empresas
    cliente_ubicacion VARCHAR(100),
    cliente_situacion INT DEFAULT 1
);

-- Ventas solo referencian cliente_id
CREATE TABLE pro_ventas (
    venta_id INT AUTO_INCREMENT PRIMARY KEY,
    venta_cliente_id INT NOT NULL,
    venta_factura VARCHAR(200),
    venta_fecha DATE NOT NULL,
    venta_autorizacion INT NOT NULL,
    venta_cantidad_total INT DEFAULT 0 COMMENT 'Cantidad total de items en la venta';
    venta_situacion INT DEFAULT 1,
    venta_observaciones VARCHAR(200),
    FOREIGN KEY (venta_cliente_id) REFERENCES pro_clientes(cliente_id)
);


CREATE TABLE pro_detalle_venta (
    detallev_id INT AUTO_INCREMENT PRIMARY KEY,
    detallev_venta_id INT NOT NULL,
    detallev_modelo_id INT COMMENT 'Si la venta es por lote/cantidad',
    detallev_arma_id INT COMMENT 'Si la venta es por arma única',
    detallev_cantidad INT DEFAULT 1,
    detallev_precio_unitario DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (detallev_id) REFERENCES pro_ventas(venta_id),
    FOREIGN KEY (detallev_modelo_id) REFERENCES pro_inventario_modelos(modelo_id),
    FOREIGN KEY (detallev_arma_id) REFERENCES pro_inventario_armas(arma_id)
);




-- ========================
-- PAGOS DE VENTAS
-- ========================

CREATE TABLE pro_pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    pago_venta_id INT NOT NULL,
    pago_venta_tipo ENUM('empresa','persona') NOT NULL,
    pago_pago_fecha DATE NOT NULL,
    pago_monto DECIMAL(12,2) NOT NULL,
    pago_metodo INT NOT NULL,
    pago_num_cuota INT DEFAULT 1,
    FOREIGN KEY (pago_metodo) REFERENCES pro_metodos_pago(metpago_id)
);

CREATE TABLE pro_comprobantes_pago_ventas (
    comprobventas_id INT AUTO_INCREMENT PRIMARY KEY,
    comprobventas_ruta VARCHAR(255) NOT NULL,
    comprobventas_pago_id INT NOT NULL,
    comprobventas_situacion TINYINT DEFAULT 1,
    FOREIGN KEY (comprobventas_pago_id) REFERENCES pro_pagos(pago_id)
);

-- ========================
-- PAGOS DE LICENCIAS
-- ========================

CREATE TABLE pro_pagos_licencias (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    pago_licencia_id INT NOT NULL,
    pago_empresa_id INT NOT NULL,
    pago_fecha DATE NOT NULL,
    pago_monto DECIMAL(10,2) NOT NULL,
    pago_metodo INT NOT NULL,
    pago_verificado VARCHAR(50) DEFAULT 'no aprobada',
    pago_concepto VARCHAR(250),
    CONSTRAINT chk_pago_verificado CHECK (pago_verificado IN ('aprobada','no aprobada')),
    FOREIGN KEY (pago_licencia_id) REFERENCES pro_licencias_para_importacion(lipaimp_id),
    FOREIGN KEY (pago_empresa_id) REFERENCES pro_empresas_de_importacion(empresaimp_id),
    FOREIGN KEY (pago_metodo) REFERENCES pro_metodos_pago(metpago_id)
);

CREATE TABLE pro_comprobantes_pago (
    comprob_id INT AUTO_INCREMENT PRIMARY KEY,
    comprob_ruta VARCHAR(50),
    comprob_pagos_licencia INT,
    comprob_situacion INT DEFAULT 1,
    FOREIGN KEY (comprob_pagos_licencia) REFERENCES pro_pagos_licencias(pago_id)
);

CREATE TABLE pro_documentacion_lic_import (
    doclicimport_id INT AUTO_INCREMENT PRIMARY KEY,
    doclicimport_ruta VARCHAR(50) NOT NULL,
    doclicimport_num_lic INT,
    doclicimport_situacion INT DEFAULT 1,
    FOREIGN KEY (doclicimport_num_lic) REFERENCES pro_licencias_para_importacion(lipaimp_id)
);
