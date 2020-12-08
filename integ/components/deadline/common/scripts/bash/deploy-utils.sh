#!/bin/bash
#
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# This hook function is meant to be run before any interactions with AWS (such as a cdk deploy or destroy)
function run_aws_interaction_hook() {
    # Invoke hook function if it is exported and name is defined in PRE_AWS_INTERACTION_HOOK variable
    if [ ! -z "${PRE_AWS_INTERACTION_HOOK+x}" ]  && [ "$(type -t $PRE_AWS_INTERACTION_HOOK)" == "function" ]
    then
      $PRE_AWS_INTERACTION_HOOK
    fi
}

function deploy_component_stacks () {
  COMPONENT_NAME=$1

  run_aws_interaction_hook

  npx cdk deploy "*" --require-approval=never --json --outputs-file="$INTEG_TEMP_DIR/${COMPONENT_NAME}_deploy.json" --silent
  
  return 0
}

function execute_component_test () {
  COMPONENT_NAME=$1

  run_aws_interaction_hook

  yarn run test "$COMPONENT_NAME.test" --json --outputFile="$INTEG_TEMP_DIR/$COMPONENT_NAME.json" --silent

  return 0
}

function destroy_component_stacks () {
  COMPONENT_NAME=$1

  run_aws_interaction_hook

  npx cdk destroy "*" -f
  rm -f "./cdk.context.json"
  rm -rf "./cdk.out"

  return 0
}
