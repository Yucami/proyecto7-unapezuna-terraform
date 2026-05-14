locals {
  lambdas = {
    "listar-servicios" = {
      timeout     = 10
      description = "Lista los servicios del catálogo"
    }
    "listar-disponibilidad" = {
      timeout     = 10
      description = "Lista huecos disponibles por fecha"
    }
    "listar-disponibilidad-mes" = {
      timeout     = 10
      description = "Lista días disponibles de un mes"
    }
    "crear-reserva" = {
      timeout     = 30
      description = "Crea una reserva y envía email vía SQS"
    }
    "historial-citas" = {
      timeout     = 10
      description = "Historial de citas de la clienta logueada"
    }
    "cancelar-reserva" = {
      timeout     = 15
      description = "Cancela una reserva y libera huecos"
    }
    "crear-cliente" = {
      timeout     = 10
      description = "Trigger post-confirmación Cognito"
    }
    "enviar-email" = {
      timeout     = 30
      description = "Lee de SQS y envía email con Resend"
    }
    "panel-admin" = {
      timeout     = 15
      description = "Panel admin: reservas del día"
    }
    "crear-disponibilidad" = {
      timeout     = 30
      description = "Crea huecos de disponibilidad"
    }
    "bloquear-hueco" = {
      timeout     = 10
      description = "Bloquea un hueco manualmente"
    }
    "admin-historial-cliente" = {
      timeout     = 15
      description = "Historial completo de una clienta (admin)"
    }
    "admin-buscar-cliente" = {
      timeout     = 10
      description = "Busca clienta por email (admin)"
    }
    "admin-actualizar-contacto" = {
      timeout     = 10
      description = "Actualiza datos de contacto (admin)"
    }
    "admin-fotos-url" = {
      timeout     = 10
      description = "Genera presigned PUT URL para fotos"
    }
    "admin-fotos-guardar" = {
      timeout     = 10
      description = "Guarda s3Key de foto en reserva"
    }
  }
}

resource "aws_lambda_function" "functions" {
  for_each = local.lambdas

  function_name = "unapezuna-${each.key}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = each.value.timeout
  description   = each.value.description

  filename = "${path.module}/placeholder.zip"

  environment {
    variables = {
      RESEND_API_KEY = var.resend_api_key
      SQS_QUEUE_URL  = aws_sqs_queue.email_queue.url
    }
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }
}

resource "aws_lambda_function" "formulario_contacto" {
  function_name = "formulario-contacto"
  role          = "arn:aws:iam::065932174472:role/lambda-ses-role"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  timeout       = 3
  description   = "Formulario de contacto vía SES"

  filename = "${path.module}/placeholder.zip"

  lifecycle {
    ignore_changes = [filename, source_code_hash, environment]
  }
}
