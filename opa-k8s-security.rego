package main

deny[msg] {
    input.kind = "Service"
    not input.spec.type = "NodePort"
    msg = "Service type should be Nodeport"
}

deny[msg] {
    input.kind = "Deployment"
    not input.spec.template.spec.containers[0].securityContext.runAsRoot = true
    msg = "Containers must run as non root - use runAsNonRoot within container security context"
}