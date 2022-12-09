import re
import sys
import json
import logging
import yaml

logger = logging.getLogger("default")


class Dumper(yaml.Dumper):
    """This class is used to dump YAML files with a non-default indentation."""

    def increase_indent(self, flow=False, *args, **kwargs):
        return super().increase_indent(flow=flow, indentless=False)


def get_kubectl_ingress(stdin, context_name):
    """
    This function will return a list of kubernetes ingress objects.
    Depending on the input, either from stdin or from the kubernetes client.
    Function will read the JSON data and return a list of kubernetes ingress objects.

    Parameters:
        stdin (bool):
            If True, the function will read the JSON data from stdin.
            If False, the function will read the JSON data from the kubernetes client.
            If None, the function will read the JSON data from the kubernetes client.

        context_name (str): The name of the context to be used when reading the JSON
        data from the kubernetes client.

    Returns:
        A list of kubernetes ingress objects.

    Raises:
        Exception if any errors occur.
    """
    try:
        if stdin:
            logger.info("Reading JSON input from stdin...")
            if sys.stdin.isatty():
                sys.exit("No data sent to stdin... Exiting.")
            data = sys.stdin
            data = json.load(data)
            if "items" in data:
                data = data["items"]
        else:
            logger.info("Reading data using python kubernetes client...")
            from kubernetes import client, config
            from kubernetes.client import ApiClient

            contexts, active_context = config.list_kube_config_contexts()
            if not contexts:
                raise Exception("Cannot find any context in kube-config file.")
            context_names = [context["name"] for context in contexts]
            logger.info(f"Found available contexts: {context_names}")
            logger.info(f"Trying to use {context_name} context...")
            if context_name not in context_names:
                raise Exception(
                    f"Context {context_name} is not found in configured contexts."
                )
            logger.info(f"Using {context_name} context")
            client = client.NetworkingV1Api(
                api_client=config.new_client_from_config(context=context_name)
            )
            data = client.list_ingress_for_all_namespaces(watch=False)
            data = data.items
            data = ApiClient().sanitize_for_serialization(data)
        return data
    except Exception as e:
        raise Exception(e)


def filter_ingress(data, environment):
    """
    This function filters the ingress data from the Kubernetes API.
    It returns a list of dictionaries with the following keys:
    - name
    - namespace
    - host

    The function takes two arguments:
    - data: the data from the Kubernetes API
    - environment: the environment to filter for
    """

    # Filter out PR ingress names
    data = [
        item
        for item in data
        if not (re.search("-pr-[0-9]{1,5}-", item["metadata"]["name"]))
    ]

    data_filtered = [
        {
            "name": item["metadata"]["name"],
            "namespace": item["metadata"]["namespace"],
            "host": item["spec"]["rules"][0]["host"],
        }
        for item in data
        # Define custom filters below
        if (
            "annotations" in item["metadata"]
            and "helm.fluxcd.io/antecedent" in item["metadata"]["annotations"]
        )
        or (
            environment == "demo"
            and "ingressClassName" in item["spec"]
            and item["spec"]["ingressClassName"] == "traefik-no-proxy"
        )
        or (
            environment == "demo"
            and "annotations" in item["metadata"]
            and "kubernetes.io/ingress.class" in item["metadata"]["annotations"]
            and item["metadata"]["annotations"]["kubernetes.io/ingress.class"]
            == "traefik-no-proxy"
        )
        or (environment == "sbox" and "labs" not in item["metadata"]["namespace"])
        # End of custom filters
    ]
    return data_filtered


def format_dt_monitors_yaml(department, data_filtered, environment):
    department = department.upper()
    environment = environment.upper()
    return [
        {
            "name": item["name"],
            "management_zone_name": (
                f'{department}-{item["namespace"].upper()}-{environment}'
            ),
            "enabled": True,
            "locations": ["SYNTHETIC_LOCATION-CC3E4D2657A13D18"],
            "requests": [
                {
                    "url": f'http://{item["host"]}/health',
                    "description": item["host"],
                    "method": "GET",
                    "configuration": {
                        "accept_any_certificate": True,
                        "follow_redirects": True,
                    },
                    "rules": [
                        {
                            "type": "httpStatusesList",
                            "value": ">400",
                            "pass_if_found": False,
                        }
                    ],
                }
            ],
        }
        for item in data_filtered
    ]


def handle_synthetic_monitors_yaml(generated_yaml):
    """
    This function takes a list of synthetic monitors in the form of a list of
    dictionaries, and returns a string of the same list of synthetic monitors in the
    form of a YAML file.

    The function also returns the number of synthetic monitors in the list, and a
    list of the management zones that the synthetic monitors are assigned to.

    The function is used to generate a YAML file of synthetic monitors that can be
    imported into Dynatrace.
    """

    monitors_dict = {}
    for item in generated_yaml:
        monitors_dict[item["name"]] = item
    monitors_dict_new = dict({"synthetic_monitors": list(monitors_dict.values())})
    monitors_new_yaml = yaml.dump(monitors_dict_new, sort_keys=False, Dumper=Dumper)
    object_count = len(list(monitors_dict.values()))
    management_zones = [x["management_zone_name"] for x in list(monitors_dict.values())]
    return "---\n" + monitors_new_yaml, object_count, management_zones


def handle_management_zones(management_zones_list):
    """
    This function takes a list of management zones and returns a dictionary of
    management zones with the name of the management zone as the key and the
    management zone name as the value.

    Args:
        management_zones_list (list): A list of management zones.

    Returns:
        management_zones_dict (dict): A dictionary of management zones.
    """

    management_zones_dict = {}

    for item in sorted(set(management_zones_list)):
        management_zones_dict[item] = {"name": item}

    management_zones_dict_new = dict(
        {"management_zones": list(management_zones_dict.values())}
    )
    management_zones_new_yaml = yaml.dump(
        management_zones_dict_new, sort_keys=True, Dumper=Dumper
    )
    object_count = len(list(management_zones_dict.values()))
    return "---\n" + management_zones_new_yaml, object_count


def read_yaml(yaml_file_path):
    """
    Reads a YAML file and returns a dictionary.

    Parameters
    ----------
    yaml_file_path : str
        The path to the YAML file to be read.

    Returns
    -------
    dict
        A dictionary containing the contents of the YAML file.

    Raises
    ------
    Exception
        If the YAML file cannot be read.
    """
    with open(yaml_file_path, "r") as f:
        try:
            return yaml.safe_load(f)
        except Exception as e:
            raise Exception(e)
