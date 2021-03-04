variable "AWS_REGION" {    
    default = "us-east-1"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}