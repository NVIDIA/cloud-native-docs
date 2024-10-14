<!--
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0
-->

# Confifgure RBAC

````{only} not publish_bsp
```{contents}
:depth: 2
:backlinks: none
:local: true
```
````

## Inject Istio 

1. Run the below command to enable Istio to namespace, replace the `<namespace>` with your target namespace

   ```console
   kubectl label namespace <namespace> istio-injection=enabled --overwrite
   ```
        

2. Run the below command to delete the existing pods to recreate with Istio sidecar containers, replace the `<namespace>` with your target namespace

   ```console
   kubectl delete pod $(kubectl get pods -n <namespace> | awk '{print $1}') -n <namespace>
   ````
        
## Deploy Manifests

1. The following sample manifest deploys Ingress Virutal Service and Gateway.
  - `NOTE:`
    - 1. Make sure to update the target namespace for VirtualService object
    - 2. Below example are target for NIM Inference Microservice, if you plan to other NVIDIA NeMo MicroService, make sure to update the `match` and `route` appropriately
        - To find more information about `match` and `route` for NeMo MicroServices refer 
          - [NIM Inference API Inference](https://docs.nvidia.com/nim/large-language-models/latest/api-reference.html)
          - [NIM Embedding API Reference](https://docs.nvidia.com/nim/nemo-retriever/text-embedding/latest/reference.html)
          - [NIM ReRanking API Reference](https://docs.nvidia.com/nim/nemo-retriever/text-reranking/latest/reference.html)

  ```{literalinclude} ./manifests/istio-sample-manifest.yaml
  :language: yaml
  ```

2. Run the below command to expose Inference service externally via Istio Ingress Gateway.

  ```console
  kubectl apply -f istio-sample-manifest.yaml
  ````

3. Run the below command to get the Istio Ingress Gateway NodePort.

  ```console        
  kubectl get svc -n istio-system | grep ingress
  ```
  
  Example Output:

  ```console
  istio-ingressgateway   LoadBalancer   10.102.8.149     10.28.234.101   15021:32658/TCP,80:30611/TCP,443:31874/TCP,31400:30160/TCP,15443:32430/TCP   22h
  ```
  
4. Run the below command to list the worker IP addresses.

  ```console       
  for node in `kubectl get nodes | awk '{print $1}' | grep -v NAME`; do echo $node ' ' | tr -d '\n'; kubectl describe node $node | grep -i 'internalIP:' | awk '{print $2}'; done
  ```
  
  Example Output:

  ```console
  nim-test-cluster-03-worker-nbhk9-56b4b888dd-8lpqd  10.120.199.16
  nim-test-cluster-03-worker-nbhk9-56b4b888dd-hnrxr  10.120.199.23
  ```

5. The following manifest deploys RequestAuthentication.
  - `NOTE:`
    - 1. Make sure to update the target namespace
    - 2. Modify issuer in the yaml with one of the above system IP addresses and above ingress Istio gateway NodePort mapped to 80

  ```{literalinclude} ./manifests/requestAuthentication.yaml
  :language: yaml
  ```

6. Run the below command to apply Request Authentication to Kubernetes Cluster.

  ```console
  kubectl apply -f requestAuthentication.yaml
  ```

7. The following manifest deploys authorizationPolicy.
  - `NOTE:`
    - 1. Make sure to update the target namespace
    - 2. Modify or Update the rules that applies to target micro services

  ```{literalinclude} ./manifests/authorizationPolicy.yaml
  :language: yaml
  ```

8. Run the below command to create Authentication Policy on Kubernetes Cluster.

  ```console
  kubectl apply -f authorizationPolicy.yaml
  ```

9. Run the below command to create a Token for Keycloak authentication, make sure to update the node IP and Ingress Gateway NodePort as per below.

  ```console        
  TOKEN=`curl -X POST -d "client_id=nvidia-nim" -d "username=nim" -d "password=nvidia123" -d "grant_type=password" "http://10.217.19.114:30611/realms/nvidia-nim-llm/protocol/openid-connect/token"| jq .access_token| tr -d '"' `
  ```

10. Run the below command to verify whether you can access NeMo from Keycloak through Istio Gateway. 

  ```console
  curl -v -X POST http://10.217.19.114:30611/v1/completions -H "Authorization: Bearer $TOKEN" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{ "model": "llama-2-13b-chat","prompt": "What is Kubernetes?","max_tokens": 16,"temperature": 1, "n": 1, "stream": false, "stop": "string", "frequency_penalty": 0.0 }'
  ```

  `NOTE`:
    - Make sure to update the node IP and Ingress Gateway port 
    - Update the model name if it’s other than llama-2-13b-chat
        
11. Generate some more data, so it can be usable in the next step to visualize it on the Kiali dashboard. 

  ```console
  for i in $(seq 1 100); do curl -X POST http://10.217.19.114:30611/v1/chat/completions -H 'accept: application/json' -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"model": "llama-2-13b-chat","messages": [{"role": "system","content": "You are a helpful assistant."},{"role": "user", "content": "Hello!"}]}'  -s -o /dev/null; done
  ```

  `Note:`
    - Make sure to update the node IP and Ingress Gateway port 
    - Update the model name if it’s other than llama-2-13b-chat

12. Run the below command to access the Istio Dashboard with replacing your Linux/WSL system IP.

  ```console    
    istioctl dashboard kiali --address <system-ip>
  ```

Access in browser with ``system-ip`` and port ``20001``

## Conclusion

This architecture offers a robust solution for deploying NVIDIA NeMo MicroServices in a secure, scalable, and efficient manner. Integrating advanced service mesh capabilities with OIDC authentication sets a new standard for building sophisticated AI-driven applications.