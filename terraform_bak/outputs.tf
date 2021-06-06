output "public_ip_web" {
  value = "${aws_instance.web.*.public_ip}"
}

output "private_ip_web" {
  value = "${aws_instance.web.*.private_ip}"
}

output "subnet_web" {
  value = "${aws_instance.web.*.subnet_id}"
}

output "account_id" {
  value = data.aws_caller_identity.web.*.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.web.*.user_id
}

output "caller_arn" {
  value = data.aws_caller_identity.web.*.arn
}

output "region" {
  value = data.aws_region.web.*.id
}