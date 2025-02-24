/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_id" "suffix" {
  byte_length = 4
}
module "cloud_armor" {
  source  = "GoogleCloudPlatform/cloud-armor/google"
  version = "~> 5.0"

  project_id                  = var.project_id
  name                        = "test-camp-policy-${random_id.suffix.hex}"
  description                 = "Test Cloud Armor security policy with with rules supported by Cloud Armor Enterprise (Former Managed Protection Plus - CAMP+)"
  default_rule_action         = "allow"
  type                        = "CLOUD_ARMOR"
  layer_7_ddos_defense_enable = true
  user_ip_request_headers     = ["True-Client-IP", ]

  layer_7_ddos_defense_threshold_configs = [
    {
      name                             = "test1111"
      auto_deploy_load_threshold       = 0.2
      auto_deploy_confidence_threshold = 0.4
    },
    {
      name                       = "test9999"
      detection_load_threshold   = 0.7
      auto_deploy_expiration_sec = 3
      traffic_granularity_configs = [{
        type                     = "HTTP_PATH"
        enable_each_unique_value = true
      }]
    },
  ]

  adaptive_protection_auto_deploy = {
    enable   = true
    priority = 100000
    action   = "deny(403)"

    # load_threshold              = 0.3    This cannot be provided if `layer_7_ddos_defense_threshold_configs` is not null
    # confidence_threshold        = 0.6    This cannot be provided if `layer_7_ddos_defense_threshold_configs` is not null
    # impacted_baseline_threshold = 0.7    This cannot be provided if `layer_7_ddos_defense_threshold_configs` is not null
    # expiration_sec              = 7000   This cannot be provided if `layer_7_ddos_defense_threshold_configs` is not null
  }

  ## This is an example of deny policy. Examples for redirect and throttle policies are in README.

  threat_intelligence_rules = {

    deny_malicious_ips = {
      action      = "deny(502)"
      priority    = 300
      description = "Deny IP addresses known to attack web applications"
      preview     = false
      feed        = "iplist-known-malicious-ips"
      exclude_ip  = "['47.100.100.100', '47.189.12.139']"
    }

    deny_tor_exit_ips = {
      action      = "deny(502)"
      priority    = 400
      description = "Deny Tor exit nodes IP addresses"
      preview     = false
      feed        = "iplist-tor-exit-nodes"
    }

  }

}
