resource "oci_dns_rrset" "lb_a_record" {
  count = var.create_dns ? 1 : 0

  domain          = "${local.Sp3_env_name}.${local.Sp3_dns_suffix}"
  rtype           = "A"
  zone_name_or_id = local.Gpas_dev_ox_ac_uk_dns_zone_id
  items {
    domain = "${local.Sp3_env_name}.${local.Sp3_dns_suffix}"
    rtype  = "A"
    rdata  = local.Sp3_lb_public_ip
    ttl    = 30

  }

}

resource "oci_dns_rrset" "bastion_a_record" {
  count = var.create_dns ? 1 : 0

  domain          = "bastion.${local.Sp3_env_name}.${local.Sp3_dns_suffix}"
  rtype           = "A"
  zone_name_or_id = local.Gpas_dev_ox_ac_uk_dns_zone_id
  items {
    domain = "bastion.${local.Sp3_env_name}.${local.Sp3_dns_suffix}"
    rtype  = "A"
    rdata  = local.Sp3Bastion_public_ip
    ttl    = 30

  }

}
