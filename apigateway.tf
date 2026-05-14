resource "aws_apigatewayv2_api" "main" {
  name          = "unapezuna-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type", "authorization"]
    allow_methods     = ["GET", "POST", "OPTIONS", "PUT", "DELETE", "PATCH"]
    allow_origins     = ["*"]
    max_age           = 300
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  name             = "unapezuna-cognito-auth"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.web_client.id]
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

resource "aws_apigatewayv2_integration" "listar_servicios" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["listar-servicios"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "listar_disponibilidad" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["listar-disponibilidad"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "listar_disponibilidad_mes" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["listar-disponibilidad-mes"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "crear_reserva" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["crear-reserva"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "historial_citas" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["historial-citas"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "cancelar_reserva" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["cancelar-reserva"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "panel_admin" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["panel-admin"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "admin_historial_cliente" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["admin-historial-cliente"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "admin_buscar_cliente" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["admin-buscar-cliente"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "admin_actualizar_contacto" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["admin-actualizar-contacto"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "crear_disponibilidad" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["crear-disponibilidad"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "bloquear_hueco" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["bloquear-hueco"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "admin_fotos_url" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["admin-fotos-url"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "admin_fotos_guardar" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions["admin-fotos-guardar"].invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_servicios" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /servicios"
  target    = "integrations/${aws_apigatewayv2_integration.listar_servicios.id}"
}

resource "aws_apigatewayv2_route" "get_disponibilidad" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /disponibilidad"
  target    = "integrations/${aws_apigatewayv2_integration.listar_disponibilidad.id}"
}

resource "aws_apigatewayv2_route" "get_disponibilidad_mes" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /disponibilidad/mes"
  target    = "integrations/${aws_apigatewayv2_integration.listar_disponibilidad_mes.id}"
}

resource "aws_apigatewayv2_route" "post_reservas" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /reservas"
  target             = "integrations/${aws_apigatewayv2_integration.crear_reserva.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_reservas" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /reservas"
  target             = "integrations/${aws_apigatewayv2_integration.historial_citas.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "delete_reservas" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "DELETE /reservas"
  target             = "integrations/${aws_apigatewayv2_integration.cancelar_reserva.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_admin" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /admin"
  target             = "integrations/${aws_apigatewayv2_integration.panel_admin.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_admin_cliente" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /admin/cliente"
  target             = "integrations/${aws_apigatewayv2_integration.admin_historial_cliente.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_admin_buscar_cliente" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /admin/buscar-cliente"
  target             = "integrations/${aws_apigatewayv2_integration.admin_buscar_cliente.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "patch_admin_contacto" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "PATCH /admin/contacto"
  target             = "integrations/${aws_apigatewayv2_integration.admin_actualizar_contacto.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "post_disponibilidad" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /disponibilidad"
  target             = "integrations/${aws_apigatewayv2_integration.crear_disponibilidad.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "put_disponibilidad_bloquear" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "PUT /disponibilidad/bloquear"
  target             = "integrations/${aws_apigatewayv2_integration.bloquear_hueco.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "post_admin_fotos_url" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /admin/fotos/url"
  target             = "integrations/${aws_apigatewayv2_integration.admin_fotos_url.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "put_admin_fotos_guardar" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "PUT /admin/fotos/guardar"
  target             = "integrations/${aws_apigatewayv2_integration.admin_fotos_guardar.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_integration" "formulario_contacto" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.formulario_contacto.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_contacto" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /contacto"
  target    = "integrations/${aws_apigatewayv2_integration.formulario_contacto.id}"
}
