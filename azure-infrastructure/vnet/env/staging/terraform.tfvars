location      = "centralus"
env           = "staging"
prefix        = "sk"
address_space = ["10.1.0.0/16"]
subnets = {
  default = { address_prefix = "10.1.1.0/24" }
  app     = { address_prefix = "10.1.2.0/24" }
  data    = { address_prefix = "10.1.3.0/24" }
}
