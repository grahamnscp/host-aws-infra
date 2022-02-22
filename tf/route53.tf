# Route53 for instances

resource "aws_route53_record" "infra" {
  zone_id = "${var.route53_zone_id}"
  name = "infra.${var.name_prefix}.${var.route53_domainname}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.infra.public_ip}"]
}
