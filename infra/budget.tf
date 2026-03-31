resource "aws_budgets_budget" "portfolio_resource" {
  name              = "monthly-budget-portfolio"
  budget_type       = "COST"
  limit_amount      = "6"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2025-09-12_00:01"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["zenaba.mogne@live.fr"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["zenaba.mogne@live.fr"]
  }
}