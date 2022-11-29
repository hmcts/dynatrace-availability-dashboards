#!/bin/bash

[[ "$(command -v python3)" ]] || { echo "python3 is not installed, exiting." 1>&2 ; exit 1; }

python3 -c 'import yaml'
if [ $? -eq 1 ]; then
   printf "\npython3 yaml library is not installed, installing via python3 -m pip install pyyaml --user\n\n...\n"
   python3 -m pip install pyyaml --user
fi

python3 -c 'import kubernetes'
if [ $? -eq 1 ]; then
   printf "\npython3 kubernetes library is not installed, installing via python3 -m pip install kubernetes --user\n\n...\n"
   python3 -m pip install pyyaml --user
fi

# python3 -m pip install -r requirements.txt
python3 generate_synthetic_monitors.py \
    --environment demo \
    --department cft \
    --context cft-demo-01-aks
