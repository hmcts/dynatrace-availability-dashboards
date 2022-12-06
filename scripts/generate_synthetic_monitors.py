import os
import sys
import json
import logging
from datetime import datetime
import argparse
from helpers import (
    Dumper,
    get_kubectl_ingress,
    filter_ingress,
    read_yaml,
    format_dt_monitors_yaml,
    handle_synthetic_monitors_yaml,
    handle_management_zones,
)

logger = logging.getLogger("default")
datenow = datetime.now().strftime("%Y_%m_%d-%I_%M_%S")
logfile_path = f"/tmp/{os.path.basename(__file__)}_{datenow}.log"

dt_config_dir = os.path.abspath(os.path.dirname(__file__) + "/../dynatrace")

logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s: %(message)s",
    handlers=[
        logging.FileHandler(filename=logfile_path),
        logging.StreamHandler(stream=sys.stdout),
    ],
)
logger.info(f"Logging to {logfile_path}")

parser = argparse.ArgumentParser(
    description="""Convert kubernetes ingress definitions
                 into dynatrace synthetic monitors"""
)
parser.add_argument(
    "-e",
    "--environment",
    type=str,
    help="Specify kubernetes cluster environment",
    required=True,
)
parser.add_argument(
    "-d",
    "--department",
    type=str,
    help="Specify the departement such as CFT/SDS",
    required=True,
    default="CFT",
)
parser.add_argument(
    "-c",
    "--context",
    type=str,
    help="Specify the name of kubernetes context to use",
    default=False,
    required="--stdin" not in sys.argv,
)
parser.add_argument(
    "--stdin",
    help="Accept JSON data from stdin instead of running kubernetes module",
    default=False,
    required=False,
    action="store_true",
)

args = parser.parse_args()

environment = args.environment
department = args.department
context = args.context
stdin = args.stdin

monitors_yaml_path = (
    f"{dt_config_dir}/synthetic_monitors/synthetic_monitors_{environment.lower()}.yaml"
)
management_zones_yaml_path = (
    f"{dt_config_dir}/management_zones/management_zones_{environment.lower()}.yaml"
)


def main():
    """
    This function is the main function of the script.
    It does the following:
    1. Retrieves ingress objects from the cluster
    2. Filters the ingress objects based on the environment
    3. Generates the yaml for the synthetic monitors
    4. Generates the yaml for the management zones
    5. Writes the yaml to the respective files
    """
    logger.info(f"Environment is {environment}")
    logger.info(f"Trying to retrieve ingress objects from {context}...")
    kubectl_data = get_kubectl_ingress(stdin, context)
    logger.info(f"{environment} - using context {context}")
    kubectl_data_filtered = filter_ingress(kubectl_data, environment)
    # Handle synthetic monitors
    logger.info("Handling synthetic monitors...")
    generated_yaml_monitors = format_dt_monitors_yaml(
        department, kubectl_data_filtered, environment
    )

    (
        monitors_final_yaml,
        monitors_count,
        generated_management_zones,
    ) = handle_synthetic_monitors_yaml(generated_yaml_monitors)

    with open(monitors_yaml_path, "w") as f:
        try:
            f.write(monitors_final_yaml)
            logger.info(
                f"{environment} - Number of synthetic monitors generated: {monitors_count}"
            )
        except Exception as e:
            logger.exception(e)

    # Handle management zones
    logger.info("Handling management_zones...")
    management_zones_final_yaml, management_zones_count = handle_management_zones(
        generated_management_zones
    )

    with open(management_zones_yaml_path, "w") as f:
        try:
            f.write(management_zones_final_yaml)
            logger.info(
                f"{environment} - Number of management_zones generated: {management_zones_count}"
            )
        except Exception as e:
            logger.exception(e)


if __name__ == "__main__":
    main()
