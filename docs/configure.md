<!--
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0
-->

# Configure RBAC

````{only} not publish_bsp
```{contents}
:depth: 2
:backlinks: none
:local: true
```
````

## Inject Istio

1. Label the namespace to enable Istio injection.

   ```console
   kubectl label namespace <namespace> istio-injection=enabled --overwrite
   ```

   Replace the `<namespace>` with your target namespace.

2. Delete the existing pods to recreate them with Istio sidecar containers.

   ```console
   kubectl delete pod $(kubectl get pods -n <namespace> | awk '{print $1}') -n <namespace>
   ````

## Deploy Manifests

1. The following sample manifest deploys a gateway and ingress virtual service.

    - Update the target namespace for the virtual service resource.
    - The sample manifest applies to NVIDIA NIM for LLMs. For other NVIDIA microservices, update the `match` and `route` for the microservice endpoints.
        - For information about the microservice endpoints, refer to the following documents:
          - [NIM Inference API Inference](https://docs.nvidia.com/nim/large-language-models/latest/api-reference.html)
          - [NIM Embedding API Reference](https://docs.nvidia.com/nim/nemo-retriever/text-embedding/latest/reference.html)
          - [NIM ReRanking API Reference](https://docs.nvidia.com/nim/nemo-retriever/text-reranking/latest/reference.html)

   ```{literalinclude} ./manifests/istio-sample-manifest.yaml
   :language: yaml
   ```

2. Apply the manifest.

   ```console
   kubectl apply -f istio-sample-manifest.yaml
   ````

3. Determine the Istio ingress gateway node port.

   ```console
   kubectl get svc -n istio-system | grep ingress
   ```

   *Example Output*

   ```output
   istio-ingressgateway   LoadBalancer   10.102.8.149     10.28.234.101   15021:32658/TCP,80:30611/TCP,443:31874/TCP,31400:30160/TCP,15443:32430/TCP   22h
   ```

4. List the worker IP addresses.

   ```console
   for node in `kubectl get nodes | awk '{print $1}' | grep -v NAME`; do echo $node ' ' | tr -d '\n'; kubectl describe node $node | grep -i 'internalIP:' | awk '{print $2}'; done
   ```

   *Example Output*

   ```console
   nim-test-cluster-03-worker-nbhk9-56b4b888dd-8lpqd  10.120.199.16
   nim-test-cluster-03-worker-nbhk9-56b4b888dd-hnrxr  10.120.199.23
   ```

5. The following manifest creates request authentication resources.

    - Update the target namespace.
    - Modify the issuer in the manifest with one of the preceding IP addresses and preceeding ingress Istio gateway node ports, mapped to port 80.

    ```{literalinclude} ./manifests/requestAuthentication.yaml
    :language: yaml
    ```

6. Apply the manifest.

   ```console
   kubectl apply -f requestAuthentication.yaml
   ```

7. The following manifest creates an authorization policy resource.

    - Update the target namespace.
    - Update the rules that apply to the target microservices.

   ```{literalinclude} ./manifests/authorizationPolicy.yaml
   :language: yaml
   ```

8. Apply the manifest.

   ```console
   kubectl apply -f authorizationPolicy.yaml
   ```

9. Create a token for Keycloak authentication.
   Update the node IP address and ingress gateway node port.

   ```console
   TOKEN=`curl -X POST -d "client_id=nvidia-nim" -d "username=nim" -d "password=nvidia123" -d "grant_type=password" "http://10.217.19.114:30611/realms/nvidia-nim-llm/protocol/openid-connect/token"| jq .access_token| tr -d '"' `
   ```

10. Verify access to the microservice from Keycloak through the Istio gateway.

    ```console
    curl -v -X POST http://10.217.19.114:30611/v1/completions -H "Authorization: Bearer $TOKEN" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{ "model": "llama-2-13b-chat","prompt": "What is Kubernetes?","max_tokens": 16,"temperature": 1, "n": 1, "stream": false, "stop": "string", "frequency_penalty": 0.0 }'
    ```

    Update the node IP address and ingress gateway port.
    Update the model name if it is not `llama-2-13b-chat`.

11. Generate some more data so it can be visualized in the next step on the Kiali dashboard.

    ```console
    for i in $(seq 1 100); do curl -X POST http://10.217.19.114:30611/v1/chat/completions -H 'accept: application/json' -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"model": "llama-2-13b-chat","messages": [{"role": "system","content": "You are a helpful assistant."},{"role": "user", "content": "Hello!"}]}'  -s -o /dev/null; done
    ```

12. Access the Istio Dashboard, specifying your client system IP address.

    ```console
    istioctl dashboard kiali --address <system-ip>
    ```

Access in browser with `system-ip` and port `20001`.

## Conclusion

This architecture offers a robust solution for deploying NVIDIA NeMo MicroServices in a secure, scalable, and efficient manner. Integrating advanced service mesh capabilities with OIDC authentication sets a new standard for building sophisticated AI-driven applications.