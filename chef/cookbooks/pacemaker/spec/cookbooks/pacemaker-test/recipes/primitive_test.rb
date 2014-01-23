pacemaker_primitive "keystone" do
  agent "ocf:openstack:keystone"
  params ({
    "os_auth_url"    => "http://node1:5000/v2.0",
    "os_tenant_name" => "openstack",
    "os_username"    => "admin",
    "os_password"    => "adminpw",
    "user"           => "openstack-keystone"
  })
  meta ({
    "is-managed" => true,
    "target-role" => "Started"
  })
  op ({
    "monitor" => {
      "interval" => "10s",
      "timeout" =>  "60",
    },
    "start" => {
      "interval" => "10s",
      "timeout" =>  "240",
    },
  })
  #action [ :create, :start ]
  action [ :create ]
end
