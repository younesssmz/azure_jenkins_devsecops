package main

import data.kubernetes.services
import data.kubernetes.pods

violation[msg] {
    service := input.review.object
    containers := pods[service.spec.selector].spec.containers
    service_type := service.spec.type

    service_type != "NodePort"
    msg := sprintf("Service %v should be of type 'NodePort' but is of type '%v'", [service.metadata.name, service_type])
}

violation[msg] {
    service := input.review.object
    containers := pods[service.spec.selector].spec.containers

    container := containers[_]
    container.security_context.run_as_non_root == false
    msg := sprintf("Container %v should run as non-root user, but it is running as root user", [container.name])
}
