resource "aws_sqs_queue" "email_dlq" {
  name = "unapezuna-email-dlq"

  lifecycle {
    ignore_changes = [max_message_size]
  }
}

resource "aws_sqs_queue" "email_queue" {
  name = "unapezuna-email-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.email_dlq.arn
    maxReceiveCount     = 3
  })

  lifecycle {
    ignore_changes = [max_message_size]
  }
}
