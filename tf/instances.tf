# Instances:

# Single Infra Instance:
#
resource "aws_instance" "infra" {
  instance_type = "${var.aws_instance_type_infra}"
  ami           = "${var.aws_ami}"
  key_name      = "${var.aws_key_pair_name}"

  root_block_device {
    volume_size = "${var.infra_root_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  vpc_security_group_ids = ["${aws_security_group.infra-instance-sg.id}"]

  subnet_id = "${aws_subnet.infra-subnet.id}"

  user_data = "${file("userdata.sh")}"

  tags = {
    Name    = "${var.tag_owner}_${var.name_prefix}"
    owner   = "${var.tag_owner}"
    purpose = "${var.tag_purpose}"
    enddate = "${var.tag_enddate}"
  }
}

