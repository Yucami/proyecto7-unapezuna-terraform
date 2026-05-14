resource "aws_dynamodb_table" "servicios" {
  name         = "unapezuna-servicios"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "servicioId"

  attribute {
    name = "servicioId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "clientes" {
  name         = "unapezuna-clientes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "clienteId"

  attribute {
    name = "clienteId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "disponibilidad" {
  name         = "unapezuna-disponibilidad"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fecha"
  range_key    = "horaInicio"

  attribute {
    name = "fecha"
    type = "S"
  }

  attribute {
    name = "horaInicio"
    type = "S"
  }
}

resource "aws_dynamodb_table" "reservas" {
  name         = "unapezuna-reservas"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "clienteId"
  range_key    = "reservaId"

  attribute {
    name = "clienteId"
    type = "S"
  }

  attribute {
    name = "reservaId"
    type = "S"
  }

  attribute {
    name = "fecha"
    type = "S"
  }

  attribute {
    name = "horaInicio"
    type = "S"
  }

  global_secondary_index {
    name            = "fecha-index"
    hash_key        = "fecha"
    range_key       = "horaInicio"
    projection_type = "ALL"
  }
}
