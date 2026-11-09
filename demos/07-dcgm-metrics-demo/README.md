# 07 - DCGM GPU metrics, paired with vLLM

Watch GPU utilization react to live inference. Run this at the same time as
folder 06, in two terminal panes, so the audience sees cause and effect.

This folder has no instance of its own. It runs on folder 04's instance,
and folder 06's vLLM Deployment must already be Running.

`dcgm-exporter` is installed by the GPU Operator (folder 04). It serves
Prometheus-format GPU metrics on port 9400 at `/metrics`. No Prometheus or
Grafana is needed for this demo, just two panes.

## Setup

Find the exporter pod's IP and the vLLM Service IP:

```
DCGM_POD_IP=$(kubectl get pods -n gpu-operator -l app=nvidia-dcgm-exporter -o jsonpath='{.items[0].status.podIP}')
CLUSTER_IP=$(kubectl get svc vllm-demo -o jsonpath='{.spec.clusterIP}')
```

## What to show

**Pane A** - send requests to vLLM in a loop (curl the ClusterIP by IP, as
in folder 06):

```
while true; do
  curl -s http://${CLUSTER_IP}:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model": "Qwen/Qwen2.5-0.5B-Instruct", "prompt": "Explain Flatcar in one sentence.", "max_tokens": 30}' \
    -o /dev/null -w "request done\n"
  sleep 2
done
```

**Pane B** - watch GPU utilization. Run `curl` on the host, against the
pod's IP:

```
watch -n1 "curl -s http://${DCGM_POD_IP}:9400/metrics | grep DCGM_FI_DEV_GPU_UTIL"
```

The utilization jumps from near 0 to high when a request lands in Pane A,
then drops between requests. That is the whole demo: cause and effect,
shown with the metric the GPU Operator manages for you.

## Notes

- **Run `curl` on the host, not inside the exporter pod.** That image ships
  only the `dcgm-exporter` binary, with no shell or `curl`.
- **The metric refresh interval must be 2s**, set by folder 04's install
  (`DCGM_EXPORTER_INTERVAL=2000`). The default is 30s, which makes the
  value look stuck under load. If you installed without that flag, patch it
  live:
  ```
  kubectl set env daemonset/nvidia-dcgm-exporter -n gpu-operator DCGM_EXPORTER_INTERVAL=2000
  ```
  Then wait for the pod to restart.
- If the `app=nvidia-dcgm-exporter` label does not match on your GPU
  Operator version, find the pod with `kubectl get pods -n gpu-operator`
  and look for "dcgm" in the name.

## Playback

```
asciinema rec demo.cast -c ./demo-tmux.sh
```

`demo-tmux.sh` opens the two panes this demo needs, both SSH'd into folder 04's instance via its reused SSH state. Bring folder 04 up and start folder 06's vLLM Deployment first, or `wait-for-ssh.sh` tells you to.
