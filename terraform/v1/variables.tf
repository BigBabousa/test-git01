variable "ami" {
        type = string
        description = "Variable para la AMI"
}

variable "instance_type" {
        type = string
        description = "Variable del tipo de instancia"
}

variable "region" {
        type = string
        description = "Variable que define la region"
}

variable "vpc_block" {
        type = string
        description = "Variable que define el bloque IP del VPC"
}

variable "subnet_block" {
        type = string
        description = "Variable que define la subred"
}
