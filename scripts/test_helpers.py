import io
import sys
import json
import unittest
from unittest.mock import patch
import yaml

from helpers import (
    get_kubectl_ingress,
    filter_ingress,
    format_dt_monitors_yaml,
    handle_synthetic_monitors_yaml,
    handle_management_zones,
)

sample_app = {
    "name": "cnp-sample-app",
    "namespace": "cnp",
    "labels": {"aadpodidbinding": "cnp", "helm.toolkit.fluxcd.io/name": "sampleapp"},
    "annotations": {"meta.helm.sh/release-name": "samplevalue"},
    "spec": {
        "ingressClassName": "traefik-no-proxy",
        "rules": [
            {
                "host": "cnp-sample-app.internal",
            }
        ],
    },
}
sample_idam_app = {
    "name": "idam-sample-app",
    "namespace": "idam",
    "labels": {"aadpodidbinding": "idam", "helm.toolkit.fluxcd.io/name": "idamsampleapp"},
    "annotations": {"meta.helm.sh/release-name": "samplevalue"},
    "spec": {
        "ingressClassName": "traefik-no-proxy",
        "rules": [
            {
                "host": "idam-sample-app.internal",
            }
        ],
    },
}
kube_data = {
    "apiVersion": "",
    "kind": "",
    "metadata": {},
    "items": [
        {
            "apiVersion": "networking.k8s.io/v1",
            "kind": "Ingress",
            "metadata": {
                "annotations": sample_app["annotations"],
                "labels": sample_app["labels"],
                "name": sample_app["name"],
                "namespace": sample_app["namespace"],
            },
            "spec": sample_app["spec"],
        }
    ],
}


class TestHelperResources(unittest.TestCase):
    @patch("sys.stdin", io.StringIO(json.dumps(kube_data)))
    def test_get_kubectl_ingress_stdin(self):
        """Assert kubectl ingress function returning a list"""
        self.assertEqual(get_kubectl_ingress(True, None), kube_data["items"])

    def test_filter_ingress(self):
        """Assert that ingress data is filtered for YAML generation"""
        filtered_data = filter_ingress(kube_data["items"], "demo")
        expected_data = [
            {
                "name": sample_app["name"],
                "namespace": sample_app["namespace"],
                "host": sample_app["spec"]["rules"][0]["host"],
            }
        ]
        self.assertEqual(filtered_data, expected_data)

    def test_format_dt_monitors_yaml(self):
        filtered_data = [
            {
                "name": sample_app["name"],
                "namespace": sample_app["namespace"],
                "host": sample_app["spec"]["rules"][0]["host"],
            }
        ]
        formatted_data = format_dt_monitors_yaml("cft", filtered_data, "demo")
        self.assertIsInstance(formatted_data, list)
        self.assertEqual(formatted_data[0]["name"], filtered_data[0]["name"])
        self.assertEqual(
            formatted_data[0]["management_zone_name"],
            f'CFT-{filtered_data[0]["namespace"].upper()}-DEMO',
        )
        self.assertEqual(
            formatted_data[0]["requests"][0]["url"],
            f'http://{filtered_data[0]["host"]}/health',
        )
    def test_format_dt_monitors_yaml_idam_https(self):
        filtered_data = [
            {
                "name": sample_idam_app["name"],
                "namespace": sample_idam_app["namespace"],
                "host": sample_idam_app["spec"]["rules"][0]["host"],
            }
        ]
        formatted_data = format_dt_monitors_yaml("cft", filtered_data, "demo")
        self.assertIsInstance(formatted_data, list)
        self.assertEqual(formatted_data[0]["name"], filtered_data[0]["name"])
        self.assertEqual(
            formatted_data[0]["management_zone_name"],
            f'CFT-{filtered_data[0]["namespace"].upper()}-DEMO',
        )
        self.assertEqual(
            formatted_data[0]["requests"][0]["url"],
            f'https://{filtered_data[0]["host"]}/health',
        )

    def test_handle_synthetic_monitors_yaml(self):
        sample_data = {
            "name": sample_app["name"],
            "namespace": sample_app["namespace"],
            "host": sample_app["spec"]["rules"][0]["host"],
        }
        sample_yaml_monitor = f"""
---
synthetic_monitors:
  - name: {sample_data["name"]}
    management_zone_name: CFT-{sample_data["namespace"].upper()}-DEMO
    enabled: true
    locations:
      - SYNTHETIC_LOCATION-CC3E4D2657A13D18
    requests:
      - url: http://{sample_data["host"]}/health
        description: {sample_data["host"]}
        method: GET
        configuration:
          accept_any_certificate: true
          follow_redirects: true
        rules:
          - type: httpStatusesList
            value: '>400'
            pass_if_found: false
"""
        yaml_as_object = yaml.safe_load(sample_yaml_monitor)
        yaml_response, count, management_zones = handle_synthetic_monitors_yaml(
            yaml_as_object["synthetic_monitors"]
        )

        self.assertEqual(
            yaml.safe_load(yaml_response), yaml.safe_load(sample_yaml_monitor)
        )
        self.assertEqual(count, 1)
        self.assertEqual(management_zones, ["CFT-CNP-DEMO"])

    def test_handle_management_zones(self):
        sample_data = ["CFT-CNP-DEMO"]
        management_zones, count = handle_management_zones(sample_data)
        sample_response = "---\nmanagement_zones:\n  - name: CFT-CNP-DEMO\n"
        self.assertEqual(count, 1)
        self.assertEqual(
            yaml.safe_load(management_zones), yaml.safe_load(sample_response)
        )


if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestHelperResources)
    result = unittest.TextTestRunner(verbosity=1).run(suite)
    sys.exit(not result.wasSuccessful())
