# 07 - vLLM inference on Flatcar

Serve a small language model on the GPU with vLLM. vLLM exposes an
OpenAI-compatible HTTP API, so the `curl` the audience sees has the same
shape as a call to OpenAI.

This folder has no instance of its own. It runs on folder 05's instance.
Folder 05's cluster must be Ready with the GPU Operator installed.

- **Model:** `Qwen/Qwen2.5-0.5B-Instruct`. Small, so it downloads and loads
  fast and fits the T4's 16GB with room to spare.
- `vllm-demo.yaml` is staged onto the node by folder 05's Ignition, so
  `kubectl apply` needs no copy step.

## What to show

```
kubectl apply -f vllm-demo.yaml
kubectl get pods -w
```

The first start pulls the model (about 1GB). Budget up to 5 minutes. While
the model loads, the startup probe fails with `connection refused`. That is
expected. Check progress with `kubectl logs -l app=vllm-demo --tail=50`.

Once the pod is Running and ready, send a request:

```
CLUSTER_IP=$(kubectl get svc vllm-demo -o jsonpath='{.spec.clusterIP}')
curl http://${CLUSTER_IP}:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "Qwen/Qwen2.5-0.5B-Instruct", "prompt": "Flatcar Container Linux is", "max_tokens": 40}'
```

**Use the Service ClusterIP by IP, not the name.** The bare hostname
`vllm-demo` does not resolve from the node's own shell. Cluster DNS only
serves pods, not the host. From your laptop, `kubectl port-forward
svc/vllm-demo 8000:8000` works instead.

The completion text coming back live is the payoff: a real model generating
on a GPU that Kubernetes scheduled onto a Flatcar node.

## Optional: the scheduling limit

Show that Kubernetes tracks the GPU as a finite resource:

```
kubectl scale deployment vllm-demo --replicas=2
kubectl get pods
kubectl describe pod <the-pending-one> | grep -A3 Events   # Insufficient nvidia.com/gpu
kubectl scale deployment vllm-demo --replicas=1
```

The second pod stays Pending because there is only one T4 on the node.

## Before the real recording

- **Pin the `vllm/vllm-openai` image tag** in `vllm-demo.yaml`. It is
  `:latest` now, which is not reproducible.
- **Pre-pull the model once, uncached.** Time the first
  `ContainerCreating -> Running` transition so you know whether to narrate
  through it or compress it with `asciinema rec -i <seconds>`.

## Playback

```
asciinema rec demo.cast -c ./demo-tmux.sh
```

`demo-tmux.sh` and `wait-for-ssh.sh` reuse folder 05's SSH key and instance
state, wait for SSH, and give you a prompt to type the commands live. Bring
folder 05 up first, or `wait-for-ssh.sh` tells you to.
