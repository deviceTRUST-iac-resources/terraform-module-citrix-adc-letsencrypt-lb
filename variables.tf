#####
# Variables for administrative connection to the ADC
#####

variable adc-base{
}

#####
# ADC Loadbalancing Server
#####

variable "adc-lb-server" {
}

#####
# ADC Loadbalancing Servicegroups
#####

variable adc-lb-servicegroup {
}

#####
# ADC Loadbalancing Servicegroup-Server-Bindings
#####

variable adc-lb-sg-server-binding {
}

#####
# ADC Loadbalancing vServer - Type http
#####

variable adc-lb-vserver-http{
}

#####
# ADC Loadbalancing vServer-Servicegroup-Bindings
#####

variable adc-lb-vserver-sg-binding {
}