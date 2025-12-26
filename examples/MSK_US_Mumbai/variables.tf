variable "us_west_2_private_subnet_ids" {
  description = "List of private subnet IDs for US West 2. If empty, will attempt to discover subnets automatically."
  type        = list(string)
  default     = []
}

variable "ap_south_1_private_subnet_ids" {
  description = "List of private subnet IDs for AP South 1. If empty, will attempt to discover subnets automatically."
  type        = list(string)
  default     = []
}

