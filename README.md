# UñaPezuña — Infraestructura como Código con Terraform

> Proyecto 7 del portfolio AWS · Toda la infraestructura serverless de UñaPezuña codificada en Terraform

🌐 **[App en producción → unapezuna.es](https://unapezuna.es)**  
🔗 **[Repositorio del frontend → proyecto5-unapezuna](https://github.com/Yucami/proyecto5-unapezuna)**

---

## ¿Qué es esto?

Codificación en Terraform de la infraestructura real en producción de [UñaPezuña](https://unapezuna.es) — aplicación serverless de reservas de manicura en Madrid.

Toda la infraestructura fue creada originalmente a mano en la consola de AWS. Este proyecto la documenta en archivos `.tf` usando el flujo de importación (`terraform import`), sin destruir ni interrumpir el servicio en producción.

---

## Infraestructura codificada

| Archivo | Recursos | Descripción |
|---|---|---|
| `iam.tf` | 6 | Role `unapezuna-lambda-role` + 5 políticas |
| `dynamodb.tf` | 4 | 4 tablas on-demand + GSI `fecha-index` |
| `cognito.tf` | 4 | User Pool + App Client + grupos Admins/Clientes |
| `sqs.tf` | 2 | Cola principal + DLQ (maxReceiveCount: 3) |
| `s3.tf` | 5 | Buckets frontend y fotos + acceso público + CORS |
| `lambda.tf` | 17 | 16 funciones Python + formulario-contacto |
| `apigateway.tf` | 31 | HTTP API + autorizador JWT + 15 integraciones + 15 rutas |

**Total: 70 recursos gestionados por Terraform**

---

## Stack

- **Terraform** ~> 5.0
- **AWS Provider** hashicorp/aws v5.100.0
- **Región** us-east-1
- **Runtime Lambdas** Python 3.12 (formulario-contacto: Python 3.13)
---

## Arquitectura de la app

```
Usuario
  ├── unapezuna.es → Route53 → CloudFront → S3 (React SPA)
  └── Login → Amazon Cognito → JWT
                    │
                    ▼
          Amazon API Gateway HTTP
                    │ (valida JWT automáticamente)
                    ▼
          AWS Lambda (Python)
                    ├── Amazon DynamoDB (reservas, clientes, servicios, disponibilidad)
                    ├── Amazon S3 unapezuna-fotos (fotos antes/después, privado)
                    └── Amazon SQS → Lambda enviar-email → Resend API

Cognito Post Confirmation → Lambda unapezuna-crear-cliente → DynamoDB
```

---

## Tablas DynamoDB

| Tabla | PK | SK | GSI |
|---|---|---|---|
| unapezuna-servicios | servicioId | — | — |
| unapezuna-clientes | clienteId | — | — |
| unapezuna-reservas | clienteId | reservaId | fecha-index (PK: fecha / SK: horaInicio) |
| unapezuna-disponibilidad | fecha | horaInicio | — |

---

## Lambdas

| Función | Ruta | Timeout |
|---|---|---|
| unapezuna-listar-servicios | GET /servicios | 10s |
| unapezuna-listar-disponibilidad | GET /disponibilidad | 10s |
| unapezuna-listar-disponibilidad-mes | GET /disponibilidad/mes | 10s |
| unapezuna-crear-reserva | POST /reservas | 30s |
| unapezuna-historial-citas | GET /reservas | 10s |
| unapezuna-cancelar-reserva | DELETE /reservas | 15s |
| unapezuna-crear-cliente | Cognito trigger | 10s |
| unapezuna-enviar-email | SQS trigger | 30s |
| unapezuna-panel-admin | GET /admin | 15s |
| unapezuna-crear-disponibilidad | POST /disponibilidad | 30s |
| unapezuna-bloquear-hueco | PUT /disponibilidad/bloquear | 10s |
| unapezuna-admin-historial-cliente | GET /admin/cliente | 15s |
| unapezuna-admin-buscar-cliente | GET /admin/buscar-cliente | 10s |
| unapezuna-admin-actualizar-contacto | PATCH /admin/contacto | 10s |
| unapezuna-admin-fotos-url | POST /admin/fotos/url | 10s |
| unapezuna-admin-fotos-guardar | PUT /admin/fotos/guardar | 10s |
| formulario-contacto | POST /contacto | 3s |

---

## Decisiones técnicas destacadas

**`terraform import` — importar sin destruir**  
Toda la infraestructura existía en AWS antes de este proyecto. El flujo correcto es escribir el `.tf`, importar con `terraform import`, y ajustar hasta que `terraform plan` muestre 0 cambios. Nunca `terraform apply` sobre recursos que ya existen sin importarlos primero.

**`for_each` para las 17 Lambdas**  
En lugar de 17 bloques `resource` idénticos, se define un mapa `locals` con la configuración de cada función y Terraform genera los 17 recursos. DRY aplicado a IaC.

**`lifecycle { ignore_changes }` en Lambda**  
Terraform gestiona la configuración de las Lambdas (timeout, memoria, variables de entorno). GitHub Actions gestiona el código. El `lifecycle` evita que Terraform interfiera con los despliegues del CI/CD.

**`sensitive = true` en variables con secretos**  
La API key de Resend nunca aparece en los logs de `terraform plan` ni en el output de `terraform apply`. Los valores reales van en `terraform.tfvars`, excluido del repositorio mediante `.gitignore`.

**FullAccess en portfolio — Least Privilege en producción real**  
El role `unapezuna-lambda-role` usa políticas `FullAccess` por simplicidad de portfolio. En producción real se usarían políticas con el mínimo permiso necesario (acceso solo a las tablas del proyecto, solo a los buckets específicos, etc.).

**`max_message_size` en SQS — diferencia de defaults**  
AWS usa 1MB como default para `max_message_size`. El provider de Terraform usa 256KB. Como los mensajes de UñaPezuña son JSONs pequeños (<1KB), no afecta al funcionamiento. Se resuelve con `lifecycle { ignore_changes = [max_message_size] }`.

---

## Estructura del proyecto

```
unapezuna-terraform/
├── main.tf              # Provider AWS + versión requerida
├── variables.tf         # Declaración de variables
├── terraform.tfvars     # Valores reales — NO subir a GitHub
├── iam.tf               # IAM role + políticas
├── dynamodb.tf          # 4 tablas DynamoDB
├── cognito.tf           # User Pool + App Client + grupos
├── sqs.tf               # Cola principal + DLQ
├── s3.tf                # Buckets frontend y fotos
├── lambda.tf            # 17 funciones Lambda con for_each
├── apigateway.tf        # HTTP API + autorizador + rutas
├── placeholder.zip      # ZIP vacío requerido por Terraform para Lambdas
└── .gitignore           # Excluye .tfstate, .tfvars, .terraform/
```

---

## Cómo usar

### Requisitos

- Terraform >= 1.0
- AWS CLI configurado (`aws configure`)
- Cuenta AWS con los recursos de UñaPezuña ya creados

### Inicializar

```bash
terraform init
```

### Ver estado actual

```bash
terraform state list
terraform plan
```

### Importar infraestructura existente

```bash
# Ejemplo — importar una tabla DynamoDB
terraform import aws_dynamodb_table.reservas unapezuna-reservas

# Verificar sincronización
terraform plan  # debe mostrar: No changes
```

### Aplicar cambios

```bash
terraform plan   # revisar siempre antes
terraform apply  # confirmar con "yes"
```

---

## Lo que NO está en Terraform

| Recurso | Motivo |
|---|---|
| Amazon CloudFront (3 distribuciones) | CloudFront Functions inline — riesgo de afectar dominio en producción |
| Amazon Route 53 (3 hosted zones) | Cambiar DNS en producción tiene riesgo de downtime |
| AWS Certificate Manager (3 certs) | Certificados ya validados, recrearlos requiere revalidación |
| Datos en DynamoDB | Son datos de negocio, no infraestructura |
| Registros DNS de Resend (DKIM, SPF) | Dependen de configuración externa de Resend |

---

## Comandos útiles

```bash
# Listar todos los recursos en el state
terraform state list

# Ver detalles de un recurso
terraform state show aws_dynamodb_table.reservas

# Formatear código
terraform fmt

# Validar sintaxis
terraform validate

# Eliminar un recurso del state SIN borrarlo en AWS
terraform state rm aws_lambda_function.functions[\"enviar-email\"]
```

---

## Coste de Terraform

**Terraform open source: gratis.** No hay coste por usar Terraform localmente. El state se guarda en `.tfstate` en local. Para proyectos de equipo se usaría Terraform Cloud o un backend remoto en S3, pero para este portfolio no es necesario.

---

## Región

`us-east-1` — misma región que toda la infraestructura de UñaPezuña.

---

## Autor

**Yucami** · AWS Certified Solutions Architect Associate  
[yucami.com](https://yucami.com) · [contacto@yucami.com](mailto:contacto@yucami.com)
