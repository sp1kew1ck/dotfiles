#!/usr/bin/env bash
set -euo pipefail

mamba create -n jupyter python=3.12

conda activate jupyter

mamba install jupyterlab ipywidgets

jupyter lab --port=8888 --no-browser --ip=0.0.0.0