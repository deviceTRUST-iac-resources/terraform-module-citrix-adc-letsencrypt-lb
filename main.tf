
#####
# Add LB Server
#####

resource "citrixadc_server" "le_lb_server" {
  count     = length(var.adc-lb-server.name)
  name      = element(var.adc-lb-server["name"],count.index)
  ipaddress = element(var.adc-lb-server["ip"],count.index)
}

#####
# Add LB Service Groups
#####

resource "citrixadc_servicegroup" "le_lb_servicegroup" {
  count             = length(var.adc-lb-servicegroup.servicegroupname)
  servicegroupname  = element(var.adc-lb-servicegroup["servicegroupname"],count.index)
  servicetype       = element(var.adc-lb-servicegroup["servicetype"],count.index)
  healthmonitor     = element(var.adc-lb-servicegroup["healthmonitor"],count.index)

  depends_on = [
    citrixadc_server.le_lb_server
  ]
}

#####
# Bind LB Server to Service Groups
#####

resource "citrixadc_servicegroup_servicegroupmember_binding" "le_lb_sg_server_binding" {
  count             = length(var.adc-lb-sg-server-binding.servicegroupname)
  servicegroupname  = element(var.adc-lb-sg-server-binding["servicegroupname"],count.index)
  servername        = element(var.adc-lb-sg-server-binding["servername"],count.index)
  port              = element(var.adc-lb-sg-server-binding["port"],count.index)

  depends_on = [
    citrixadc_servicegroup.le_lb_servicegroup
  ]
}

#####
# Add and configure LB vServer - Type http
#####

resource "citrixadc_lbvserver" "le_lb_vserver_http" {
  count   = length(var.adc-lb-vserver-http.name)
  name    = element(var.adc-lb-vserver-http["name"],count.index)

  servicetype = element(var.adc-lb-vserver-http["servicetype"],count.index)
  ipv46 = element(var.adc-lb-vserver-http["ipv46"],count.index)
  port = element(var.adc-lb-vserver-http["port"],count.index)
  lbmethod = element(var.adc-lb-vserver-http["lbmethod"],count.index)
  persistencetype = element(var.adc-lb-vserver-http["persistencetype"],count.index)
  timeout = element(var.adc-lb-vserver-http["timeout"],count.index)

  depends_on = [
    citrixadc_servicegroup_servicegroupmember_binding.le_lb_sg_server_binding
  ]
}

#####
# Bind LB Service Groups to LB vServers
#####

resource "citrixadc_lbvserver_servicegroup_binding" "le_lb_vserver_sg_binding" {
  count             = length(var.adc-lb-vserver-sg-binding.name)
  name              = element(var.adc-lb-vserver-sg-binding["name"],count.index)
  servicegroupname  = element(var.adc-lb-vserver-sg-binding["servicegroupname"],count.index)

  depends_on = [
    citrixadc_lbvserver.le_lb_vserver_http
  ]
}

#####
# Save config
#####

resource "citrixadc_nsconfig_save" "le_lb_save" {
  all        = true
  timestamp  = timestamp()

  depends_on = [
      citrixadc_lbvserver_servicegroup_binding.le_lb_vserver_sg_binding
  ]
}