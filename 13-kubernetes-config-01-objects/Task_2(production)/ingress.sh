#!/bin/bash
kubectl create ingress test_13.1 --calss=nginx ==rule=cp1.cluster.local/*=frontend-svc:8000
kubectl port-forward service/frontend-svc 80:8000 --address=0.0.0.0 &

