user "cloudera" do
  supports ":manage_home" => true
  shell "/bin/bash"
  home "/home/cloudera"
  password "cloudera"
	# TODO: enable sudo
end
