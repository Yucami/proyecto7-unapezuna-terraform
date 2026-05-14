resource "aws_cognito_user_pool" "main" {
  name = "unapezuna-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  deletion_protection      = "ACTIVE"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  lambda_config {
    post_confirmation = "arn:aws:lambda:us-east-1:065932174472:function:unapezuna-crear-cliente"
  }
}

resource "aws_cognito_user_pool_client" "web_client" {
  name         = "unapezuna-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  explicit_auth_flows = [
    "ALLOW_USER_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = [
    "https://d84l1y8p4kdic.cloudfront.net",
    "https://localhost:5174",
    "https://unapezuna.com",
    "https://unapezuna.com/",
    "https://unapezuna.es",
    "https://unapezuna.es/",
  ]

  logout_urls = [
    "https://localhost:5174",
    "https://unapezuna.com",
    "https://unapezuna.com/",
    "https://unapezuna.es",
    "https://unapezuna.es/",
  ]

  default_redirect_uri                          = "https://unapezuna.com"
  enable_token_revocation                       = true
  prevent_user_existence_errors                 = "ENABLED"
  enable_propagate_additional_user_context_data = false

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 5

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_group" "admins" {
  name         = "Admins"
  user_pool_id = aws_cognito_user_pool.main.id
  precedence   = 1
  description  = "Acceso al panel de administración"
}

resource "aws_cognito_user_group" "clientes" {
  name         = "Clientes"
  user_pool_id = aws_cognito_user_pool.main.id
  precedence   = 2
  description  = "Clientas registradas"
}
