# sqs
resource "aws_sqs_queue" "stock_queue" {
  name                        = "terraform-stock_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.stock_queue_dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_policy" "stock-queue-policy" {
  queue_url = aws_sqs_queue.stock_queue.id

  policy = data.aws_iam_policy_document.data-stock-queue-policy.json
}

resource "aws_sqs_queue" "stock_queue_dlq" {
  name                        = "terraform-stock_queue_dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

data "aws_iam_policy_document" "data-stock-queue-policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "SQS:SendMessage",
    ]
    resources = [
      aws_sqs_queue.stock_queue.arn,
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.user_updates.arn,
      ]
    }
  }
}