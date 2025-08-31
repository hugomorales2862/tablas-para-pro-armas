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

CREATE TABLE pro_empresas_de_importacion (
    empresaimp_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID empresa importadora',
    empresaimp_pais INT NOT NULL COMMENT 'ID del país asociado',
    empresaimp_descripcion VARCHAR(50) COMMENT 'tipo: empresa matriz o logística',
    empresaimp_situacion INT DEFAULT 1 COMMENT '1 = activa, 0 = inactiva'
);

CREATE TABLE pro_licencias_para_importacion (
    lipaimp_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID de licencia de importación',
    lipaimp_descripcion VARCHAR(100) COMMENT 'Descripción identificativa de la licencia',
    lipaimp_empresa INT NOT NULL COMMENT 'Empresa asignada a la licencia',
    lipaimp_clase INT COMMENT 'Clase de arma',
    lipaimp_marca INT COMMENT 'Marca de arma',
    lipaimp_modelo INT COMMENT 'Modelo de arma',
    lipaimp_fecha_vencimiento DATE COMMENT 'Fecha de vencimiento de la licencia',
    lipaimp_situacion INT DEFAULT 1 COMMENT '1 = activa, 0 = inactiva',
    FOREIGN KEY (lipaimp_empresa) REFERENCES pro_empresas_de_importacion(empresaimp_id),
    FOREIGN KEY (lipaimp_clase) REFERENCES pro_clases_pistolas(clase_id),
    FOREIGN KEY (lipaimp_marca) REFERENCES pro_marcas(marca_id),
    FOREIGN KEY (lipaimp_modelo) REFERENCES pro_modelo(modelo_id)
);

CREATE TABLE pro_digecam (
    digecam_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID digecam',
    digecam_licencia_import INT NOT NULL COMMENT 'Licencia asociada',
    digecam_autorizacion VARCHAR(50) DEFAULT 'no aprobada' COMMENT 'Estado autorización',
    digecam_situacion INT DEFAULT 1 COMMENT '1 = activa, 0 = inactiva',
    CONSTRAINT chk_digecam_autorizacion CHECK (digecam_autorizacion IN ('aprobada','no aprobada')),
    FOREIGN KEY (digecam_licencia_import) REFERENCES pro_licencias_para_importacion(lipaimp_id)
);

CREATE TABLE pro_metodos_pago (
    metpago_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID método de pago',
    metpago_descripcion VARCHAR(50) NOT NULL COMMENT 'efectivo, transferencia, etc.',
    metpago_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo'
);

CREATE TABLE pro_pagos_licencias (
    pago_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID de pago',
    pago_licencia_id INT NOT NULL COMMENT 'Licencia pagada',
    pago_empresa_id INT NOT NULL COMMENT 'Empresa receptora',
    pago_fecha DATE NOT NULL COMMENT 'Fecha del pago',
    pago_monto DECIMAL(10,2) NOT NULL COMMENT 'Monto pagado',
    pago_metodo INT NOT NULL COMMENT 'Método de pago (clave ajena)',
    pago_verificado VARCHAR(50) DEFAULT 'no aprobada' COMMENT 'Estado verificación',
    pago_concepto VARCHAR(250) COMMENT 'Concepto: matriz, logística, etc.',
    CONSTRAINT chk_pago_verificado CHECK (pago_verificado IN ('aprobada','no aprobada')),
    FOREIGN KEY (pago_licencia_id) REFERENCES pro_licencias_para_importacion(lipaimp_id),
    FOREIGN KEY (pago_empresa_id) REFERENCES pro_empresas_de_importacion(empresaimp_id),
    FOREIGN KEY (pago_metodo) REFERENCES pro_metodos_pago(metpago_id)
);

CREATE TABLE pro_comprobantes_pago (
    comprob_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID comprobante de pago',
    comprob_ruta VARCHAR(50) COMMENT 'Ruta del comprobante',
    comprob_pagos_licencia INT COMMENT 'Pago asociado',
    comprob_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo',
    FOREIGN KEY (comprob_pagos_licencia) REFERENCES pro_pagos_licencias(pago_id)
);

CREATE TABLE pro_documentacion_lic_import (
    doclicimport_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID documento licencia importación',
    doclicimport_ruta VARCHAR(50) NOT NULL COMMENT 'Ruta del documento',
    doclicimport_num_lic INT COMMENT 'Licencia asociada',
    doclicimport_situacion INT DEFAULT 1 COMMENT '1 = activo, 0 = inactivo',
    FOREIGN KEY (doclicimport_num_lic) REFERENCES pro_licencias_para_importacion(lipaimp_id)
);
