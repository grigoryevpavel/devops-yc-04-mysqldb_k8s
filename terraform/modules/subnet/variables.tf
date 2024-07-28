 
variable "subnets"{
  type=list(object({zone=string, name=string,cidr=optional(string)})) 
  default=[
    { zone = "ru-central1-a", name="private-0", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", name="private-1", cidr = "10.0.2.0/24" }]
}  

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "имя сети"
}  
 
 