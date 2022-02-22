# Output Values:

output "region" {
  value = "${var.aws_region}"
}

output "route53_subdomain" {
  value = "${var.name_prefix}"
}
output "route53_domain" {
  value = "${var.route53_domainname}"
}

output "route53-infra" {
  value = ["${aws_route53_record.infra.name}"]
}

output "infra-instance-public-name" {
  value = "${aws_instance.infra.public_dns}"
}
output "infra-instance-public-ip" {
  value = "${aws_instance.infra.public_ip}"
}
output "infra-instance-private-name" {
  value = "${aws_instance.infra.private_dns}"
}
output "infra-instance-private-ip" {
  value = "${aws_instance.infra.private_ip}"
}

