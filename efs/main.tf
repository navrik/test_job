resource "aws_efs_file_system" "test" {
  creation_token = "test_job"

  tags = {
    Name = "test_job"
  }
}

resource "aws_efs_file_system" "test_lifecyle_policy" {
  creation_token = "test_job"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}