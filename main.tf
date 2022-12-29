data "adc-letsencrypt-lb" "static" {
  lb-srv-name           = "lb_srv_letsencrypt_backend"
  lb-sg-name            = "lb_sg_letsencrypt_backend"
  lb-sg-healthmonitor   = "NO"
  lb-vs-name            = "lb_srv_letsencrypt"  
  lb-vs-lbmethod        = "LEASTCONNECTION"
  lb-vs-persistencetype = "SOURCEIP"
  lb-vs-timeout         = "2"
}

#####
# Add LB Server
#####

resource "citrixadc_server" "le_lb_server" {
  name      = data.adc-letsencrypt-lb.static.lb-srv-name
  ipaddress = var.adc-letsencrypt-lb.backendip
}

#####
# Add LB Service Groups
#####

resource "citrixadc_servicegroup" "le_lb_servicegroup" {

  servicegroupname  = data.adc-letsencrypt-lb.static.lb-sg-name
  servicetype       = var.adc-lb-servicegroup.servicetype
  healthmonitor     = data.adc-letsencrypt-lb.static.lb-sg-healthmonitor

  depends_on = [
    citrixadc_server.le_lb_server
  ]
}

#####
# Bind LB Server to Service Groups
#####

resource "citrixadc_servicegroup_servicegroupmember_binding" "le_lb_sg_server_binding" {
  servicegroupname  = citrixadc_servicegroup.le_lb_servicegroup.servicegroupname
  servername        = citrixadc_server.le_lb_server.name
  port              = var.adc-letsencrypt-lb.port

  depends_on = [
    citrixadc_servicegroup.le_lb_servicegroup
  ]
}

#####
# Add and configure LB vServer - Type http
#####

resource "citrixadc_lbvserver" "le_lb_vserver_http" {
  name            = data.adc-letsencrypt-lb.static.lb-vs-name
  servicetype     = var.adc-letsencrypt-lb.servicetype
  ipv46           = var.adc-letsencrypt-lb.frontend-ip
  port            = var.adc-letsencrypt-lb.port
  lbmethod        = data.adc-letsencrypt-lb.static.lb-vs-lbmethod
  persistencetype = data.adc-letsencrypt-lb.static.lb-vs-persistencetype
  timeout         = data.adc-letsencrypt-lb.static.lb-vs-timeout

  depends_on = [
    citrixadc_servicegroup_servicegroupmember_binding.le_lb_sg_server_binding
  ]
}

#####
# Bind LB Service Groups to LB vServers
#####

resource "citrixadc_lbvserver_servicegroup_binding" "le_lb_vserver_sg_binding" {
  name              = citrixadc_lbvserver.le_lb_vserver_http.name
  servicegroupname  = citrixadc_servicegroup.le_lb_servicegroup.servicegroupname

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