### Creating ELB
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  security_groups = ["${aws_security_group.ab_sg.id}"]
  #availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:80"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
  subnets = ["${aws_subnet.ab_mypub1.id}"]
  #instances = "${aws_instance.ab_foo.*.id}"
  #instances                   = "${aws_instance.ab_foo.[count.index].id}"
  #instances = ["{ab_instance${count.index + 1}.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}
#output "myinstances" {
# value = ["${aws_instance.ab_foo.*.public_ip}"]
#}

output "myelb" {
 value = "${aws_elb.example.dns_name}"
}


## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.ab_foo.id}" 
  availability_zones = "${data.aws_availability_zones.all.names}"  
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
}
}
