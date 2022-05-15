#!/bin/bash
kubectl create ingress test_13.2 --class=nginx ==rule=cp1.cluster.local/*=stage-svc:88
kubectl port-forward service/stage-svc 80:88 --address=0.0.0.0 &

