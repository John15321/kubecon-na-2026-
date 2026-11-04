# 09 - Triton inference on Flatcar (optional)

Serve a vision model on the GPU with NVIDIA Triton. This is the optional
"Flatcar is not locked to one inference framework" beat: a different model
and a different API from folder 07's LLM. Skip this folder if that message
is not worth the extra setup. Nothing else depends on it.

This folder has no instance of its own. It runs on folder 05's instance.
Folder 05's cluster must be Ready with the GPU Operator installed.

- **Model:** DenseNet-121, image classification, in ONNX format.
- `triton-demo.yaml` is staged onto the node by folder 05's Ignition, so
  `kubectl apply` needs no copy step.

## Why the client is a program, not a curl

vLLM (folder 07) speaks an OpenAI-compatible API, so a plain `curl` works.
Triton wants a raw tensor payload matching the model's input shape, so the
client is a small program (`classify.py`): it downloads an image,
preprocesses it to the model's `224x224x3` input, sends it, and prints the
prediction.

The client runs **in-cluster as a Job** and reaches the server by its
Service name `triton-demo:8000`. This is how a real client is wired, it
needs no port-forward or SSH tunnel, and it works where running the client
on the node cannot (Flatcar's host has no python).

## What to show

One apply brings up the server and the client Job:

```
kubectl apply -f triton-demo.yaml
kubectl get pods -w
```

- `triton-demo-...`: the server. An init container fetches the model
  (about 30MB) first.
- `triton-classify-...`: the client Job.

Print the prediction when the Job completes:

```
kubectl logs job/triton-classify
```

Example:

```
Predicted class index: 258 (confidence score: 17.360)
```

Index **258** is **"Samoyed"** in `densenet_labels.txt`. The default test
image is a Samoyed, so this is correct. The score is a raw logit, not a
probability, so values above 1 are normal.

Re-run the client (a completed Job does not re-run on its own):

```
kubectl delete job triton-classify && kubectl apply -f triton-demo.yaml
```

## Notes

- **Input shape:** the model has `max_batch_size: 0`, so the client sends
  `[3,224,224]` with no batch dimension and reads the output with
  `np.squeeze`. Input tensor is `data_0`, output is `fc6_1`.
- **The client Job installs its python deps at start** (`tritonclient[http]`,
  `pillow`, `numpy`). This adds about 30s and prints pip warnings. For a
  clean recording, bake the deps into an image or use the Triton SDK image
  (`nvcr.io/nvidia/tritonserver:<tag>-py3-sdk`, which already ships
  `tritonclient` and numpy).
- **Pin the `tritonserver` image tag** before recording. It is `24.08-py3`
  now. Keep folder 05's staged copy of `triton-demo.yaml` in sync if you
  change this file.

## Playback

```
asciinema rec demo.cast -c ./demo-tmux.sh
```

`demo-tmux.sh` and `wait-for-ssh.sh` reuse folder 05's SSH key and instance
state, wait for SSH, and give you a prompt to type the commands live. Bring
folder 05 up first, or `wait-for-ssh.sh` tells you to.
