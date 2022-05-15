#!/bin/bash
kubectl create ingress prod_13.2 --class=nginx ==rule=cp1.cluster.local/*=prod-svc:88
kubectl port-forward service/prod-svc 80:88 --address=0.0.0.0 &

